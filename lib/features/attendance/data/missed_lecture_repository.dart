import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/config/app_config.dart';
import '../../../core/firebase/collections.dart';
import '../../../core/firebase/doc_ids.dart';
import '../../academic/domain/academic_year.dart';
import '../../assignments/domain/assignment.dart';
import '../../audit/domain/audit_entry.dart';
import '../domain/attendance_session.dart';
import '../domain/missed_lecture.dart';

/// Writes a missed lecture straight to Firestore (no outbox: stage managers
/// and admins do this online, often from the web panel). The rules let them
/// create sessions, records and stats in their stages whatever the date.
class MissedLectureRepository {
  MissedLectureRepository(this._db);

  final FirebaseFirestore _db;

  /// Firestore's limit per batch.
  static const _maxWrites = 500;

  /// One batch: the session, a record per student, the stats of everyone
  /// not present (like a teacher's first save) and an audit entry. Teachers'
  /// phones download it with the class's other lectures. Returns the
  /// session ID.
  Future<String> save({
    required Assignment cls,
    required AcademicYear year,
    required DateTime date,
    required int lectureNo,
    required Map<String, AttendanceStatus> marks,
    required String actor,
  }) async {
    final session = AttendanceSession(
      courseId: cls.courseId,
      stageId: cls.stageId,
      yearId: year.id,
      type: cls.type,
      target: cls.target,
      groupId: cls.groupId,
      date: date,
      lectureNo: lectureNo,
      openedBy: actor,
      lockAt: AttendanceSession.lockAtFor(date, year.lockHours),
      counts: MissedLecture.counts(marks),
    );
    final sid = session.id;
    final notPresent = {
      for (final e in marks.entries)
        if (e.value != AttendanceStatus.present) e.key: e.value,
    };
    if (marks.length + notPresent.length + 2 > _maxWrites) {
      throw StateError('Too many students for one batch: ${marks.length}');
    }

    final ref = _db.collection(Col.sessions).doc(sid);
    final batch = _db.batch()
      ..set(ref, {
        ...session.toMap(),
        'updatedBy': actor,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    for (final e in marks.entries) {
      batch.set(ref.collection(Col.records).doc(e.key), {
        'studentId': e.key,
        'status': e.value.name,
        'note': '',
        'updatedBy': actor,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    for (final e in notPresent.entries) {
      batch.set(
        _db.collection(Col.stats).doc(DocIds.stat(cls.courseId, e.key)),
        {
          'courseId': cls.courseId,
          'studentId': e.key,
          'stageId': cls.stageId,
          'lastSessionId': sid,
          'bySession': {sid: e.value.name},
          'updatedAt': FieldValue.serverTimestamp(),
          'departmentId': AppConfig.departmentId,
        },
        SetOptions(merge: true),
      );
    }
    batch.set(_db.collection(Col.auditLog).doc(), {
      ...AuditEntry(
        actor: actor,
        action: 'session.missed',
        targetPath: '${Col.sessions}/$sid',
        stageId: cls.stageId,
        after: {
          'date': session.dateKey,
          'lectureNo': lectureNo,
          for (final s in AttendanceStatus.values) s.name: session.counts[s] ?? 0,
        },
      ).toMap(),
      'at': FieldValue.serverTimestamp(),
    });
    await batch.commit();
    return sid;
  }
}
