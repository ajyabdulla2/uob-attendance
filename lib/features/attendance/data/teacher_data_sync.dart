import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/database/app_database.dart';
import '../../../core/firebase/collections.dart';
import '../../academic/domain/academic_year.dart';
import '../../assignments/domain/assignment.dart';
import '../../courses/domain/course.dart';
import '../../courses/domain/practical_group.dart';
import '../../students/domain/student.dart';
import '../domain/attendance_session.dart';
import 'attendance_store.dart';

/// Downloads what a teacher needs to record offline (SPEC «عند أول تسجيل
/// دخول تُنزَّل بيانات التدريسي فقط»): the active year, their assignments,
/// the courses and groups of those, and the students of the stages they
/// teach. Only queries the rules allow a teacher are used.
///
/// Every read goes to the server: offline, Firestore would otherwise answer
/// from its own cache — possibly empty — and wipe the local mirror.
class TeacherDataSync {
  TeacherDataSync(this._db, this._fs);

  final AppDatabase _db;
  final FirebaseFirestore _fs;

  static const activeYearKey = 'activeYear';
  static const lastDownloadKey = 'lastDownloadAt';
  static const _server = GetOptions(source: Source.server);

  /// The cached active year (null before the first download).
  Future<AcademicYear?> cachedYear() async {
    final raw = await _db.readState(activeYearKey);
    if (raw == null) return null;
    final map = (jsonDecode(raw) as Map).cast<String, Object?>();
    return AcademicYear.fromMap(map['id'] as String, map);
  }

  Future<DateTime?> lastDownloadAt() async {
    final raw = await _db.readState(lastDownloadKey);
    return raw == null ? null : DateTime.tryParse(raw);
  }

  Future<void> refresh(String teacherId, {DateTime? now}) async {
    final years = await _fs.collection(Col.academicYears).where('active', isEqualTo: true).limit(1).get(_server);
    if (years.docs.isNotEmpty) {
      final y = AcademicYear.fromMap(years.docs.first.id, years.docs.first.data());
      await _db.writeState(activeYearKey, jsonEncode({...y.toMap(), 'id': y.id}));
    }

    final mine = await _fs.collection(Col.assignments).where('teacherId', isEqualTo: teacherId).get(_server);
    final assignments = [for (final d in mine.docs) Assignment.fromMap(d.id, d.data())];
    await _db.replaceAssignmentsOfTeacher(teacherId, assignments);

    final stages = {for (final a in assignments) a.stageId};
    for (final stageId in stages) {
      final courses = await _fs.collection(Col.courses).where('stageId', isEqualTo: stageId).get(_server);
      await _db.upsertCourses([for (final d in courses.docs) Course.fromMap(d.id, d.data())]);
      final students = await _fs.collection(Col.students).where('stageId', isEqualTo: stageId).get(_server);
      await _db.replaceStudentsOfStage(stageId, [for (final d in students.docs) Student.fromMap(d.id, d.data())]);
    }

    final groupIds = {for (final a in assignments) if (a.groupId != null) a.groupId!};
    final groups = <PracticalGroup>[];
    for (final id in groupIds) {
      try {
        final snap = await _fs.collection(Col.groups).doc(id).get(_server);
        if (snap.exists) groups.add(PracticalGroup.fromMap(snap.id, snap.data()!));
      } on FirebaseException catch (e) {
        // A deleted group reads as permission-denied (the rules check its
        // stage); skip it rather than fail the whole download.
        if (e.code != 'permission-denied' && e.code != 'not-found') rethrow;
      }
    }
    await _db.upsertGroups(groups);

    await _db.writeState(lastDownloadKey, (now ?? DateTime.now()).toUtc().toIso8601String());
  }

  /// Pulls the server's sessions of one class into the local register
  /// (records only for sessions that are new here or changed since).
  Future<int> pullClassSessions(Assignment a, AttendanceStore store) async {
    final snaps = await _fs
        .collection(Col.sessions)
        .where('courseId', isEqualTo: a.courseId)
        .where('type', isEqualTo: a.type.name)
        .where('target', isEqualTo: a.target)
        .get(_server);
    var stored = 0;
    for (final doc in snaps.docs) {
      final server = AttendanceSession.fromMap(doc.id, doc.data());
      final local = await store.session(doc.id);
      final localAt = local?.updatedAt;
      final serverAt = server.updatedAt;
      if (local != null && localAt != null && serverAt != null && !serverAt.isAfter(localAt)) continue;
      final records = await doc.reference.collection(Col.records).get(_server);
      final ok = await store.storeDownloaded(
        server,
        [for (final r in records.docs) AttendanceRecord.fromMap(r.id, r.data())],
      );
      if (ok) stored++;
    }
    return stored;
  }
}
