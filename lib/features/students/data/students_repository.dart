import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/config/app_config.dart';
import '../../../core/domain/stage_ref.dart';
import '../../../core/firebase/collections.dart';
import '../../../core/firebase/doc_ids.dart';
import '../../audit/domain/audit_entry.dart';
import '../domain/student.dart';

/// Adding a student refused because the university ID is taken.
final class StudentExists implements Exception {
  const StudentExists(this.existing);
  final Student existing;
}

/// A stage manager's add refused by the rules: most likely the ID belongs
/// to a student of a stage they do not manage.
final class StudentElsewhere implements Exception {
  const StudentElsewhere();
}

class StudentsRepository {
  StudentsRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col => _db.collection(Col.students);

  /// Students keyed by ID. [stageIds] null = every stage (admins only);
  /// stage managers must pass their scopes (rules require the filter).
  Future<Map<String, Student>> fetchByStages(Iterable<String>? stageIds) async {
    final snaps = stageIds == null
        ? [await _col.get()]
        : await Future.wait([for (final id in stageIds) _col.where('stageId', isEqualTo: id).get()]);
    return {
      for (final snap in snaps)
        for (final d in snap.docs) d.id: Student.fromMap(d.id, d.data()),
    };
  }

  /// Students of one stage in register order.
  Stream<List<Student>> watchStage(String stageId) =>
      _col.where('stageId', isEqualTo: stageId).snapshots().map((snap) {
        final list = [for (final d in snap.docs) Student.fromMap(d.id, d.data())];
        return list..sort(Student.compare);
      });

  /// Adds one student (joined after the import, e.g. transferred to the
  /// department), optionally into practical groups ([groupIds]), with an
  /// audit entry. Refuses a university ID already in use: [stageStudents]
  /// (the stage as shown) catches one in this stage; an admin's read finds
  /// one elsewhere, and for a stage manager — who cannot read other stages,
  /// nor a missing document — the rules refuse writing over it.
  Future<void> add(
    Student s, {
    required String actor,
    required Iterable<Student> stageStudents,
    List<String> groupIds = const [],
  }) async {
    for (final x in stageStudents) {
      if (x.id == s.id) throw StudentExists(x);
    }
    try {
      final snap = await _col.doc(s.id).get();
      if (snap.exists) throw StudentExists(Student.fromMap(snap.id, snap.data()!));
    } on FirebaseException catch (e) {
      if (e.code != 'permission-denied') rethrow;
    }
    final batch = _db.batch()
      ..set(_col.doc(s.id), {...s.toMap(), 'createdAt': FieldValue.serverTimestamp(), 'createdBy': actor});
    for (final g in groupIds) {
      batch.update(_db.collection(Col.groups).doc(g), {
        'studentIds': FieldValue.arrayUnion([s.id]),
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': actor,
      });
    }
    batch.set(_db.collection(Col.auditLog).doc(), _audit(actor, 'student.create', s, after: s.toMap()));
    try {
      await batch.commit();
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') throw const StudentElsewhere();
      rethrow;
    }
  }

  /// Edits a student's name, section, status or carry-over (same ID and
  /// stage), with the before/after in the audit log.
  Future<void> update(Student before, Student after, {required String actor}) async {
    final batch = _db.batch();
    batch.set(_col.doc(after.id), {
      ...after.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
      'updatedBy': actor,
    }, SetOptions(merge: true));
    batch.set(_db.collection(Col.auditLog).doc(),
        _audit(actor, 'student.update', after, before: before.toMap(), after: after.toMap()));
    await batch.commit();
  }

  /// Moves [student] to [to] (e.g. a hosted student from the evening study
  /// to the morning one) with everything that follows them, in one batch:
  /// the student (new stage and [section]); out of their old practical
  /// groups and into [groupIds] of the new stage; their absences — every
  /// `stats` of an old course copied onto the new stage's course with the
  /// same code, so the percentage carries on (the old ones stay as
  /// history); their leaves; and an audit entry. Returns the codes of old
  /// courses with absences that the new stage does not have (not carried).
  Future<List<String>> transfer(
    Student student, {
    required StageRef to,
    required String section,
    required List<String> groupIds,
    required String actor,
  }) async {
    final from = student.stageId;
    final results = await Future.wait([
      _db.collection(Col.groups).where('stageId', isEqualTo: from).where('studentIds', arrayContains: student.id).get(),
      _db.collection(Col.stats).where('stageId', isEqualTo: from).where('studentId', isEqualTo: student.id).get(),
      _db.collection(Col.leaves).where('stageId', isEqualTo: from).where('studentId', isEqualTo: student.id).get(),
      _db.collection(Col.courses).where('stageId', isEqualTo: to.id).get(),
    ]);
    final [oldGroups, oldStats, leaves, targetCourses] = results;
    final targetIds = {for (final d in targetCourses.docs) d.id};
    final moved = Student(
      universityId: student.universityId,
      fullName: student.fullName,
      stage: to,
      section: section,
      status: student.status,
      carryOver: student.carryOver,
    );

    final batch = _db.batch()
      ..set(_col.doc(student.id), {
        ...moved.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': actor,
      }, SetOptions(merge: true));
    for (final g in oldGroups.docs) {
      batch.update(g.reference, {
        'studentIds': FieldValue.arrayRemove([student.id]),
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': actor,
      });
    }
    for (final g in groupIds) {
      batch.update(_db.collection(Col.groups).doc(g), {
        'studentIds': FieldValue.arrayUnion([student.id]),
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': actor,
      });
    }
    final notCarried = <String>[];
    for (final d in oldStats.docs) {
      final oldCourse = '${d.data()['courseId'] ?? ''}';
      final suffix = '_$from';
      final code = oldCourse.endsWith(suffix) ? oldCourse.substring(0, oldCourse.length - suffix.length) : oldCourse;
      final bySession = Map<String, Object?>.from((d.data()['bySession'] as Map?) ?? const {});
      if (bySession.isEmpty) continue;
      final newCourse = DocIds.course(code, to.id);
      if (!targetIds.contains(newCourse)) {
        notCarried.add(code);
        continue;
      }
      batch.set(_db.collection(Col.stats).doc(DocIds.stat(newCourse, student.id)), {
        'courseId': newCourse,
        'studentId': student.id,
        'stageId': to.id,
        'bySession': bySession,
        'updatedAt': FieldValue.serverTimestamp(),
        'departmentId': AppConfig.departmentId,
      }, SetOptions(merge: true));
    }
    for (final l in leaves.docs) {
      batch.update(l.reference, {'stageId': to.id});
    }
    batch.set(
      _db.collection(Col.auditLog).doc(),
      _audit(actor, 'student.transfer', moved, before: {
        'stageId': from,
        'section': student.section,
      }, after: {
        'stageId': to.id,
        'section': section,
        'groups': groupIds,
        'notCarried': notCarried,
      }),
    );
    await batch.commit();
    return notCarried;
  }

  static Map<String, Object?> _audit(
    String actor,
    String action,
    Student s, {
    Map<String, Object?>? before,
    Map<String, Object?>? after,
  }) =>
      {
        ...AuditEntry(
          actor: actor,
          action: action,
          targetPath: '${Col.students}/${s.id}',
          stageId: s.stageId,
          before: before,
          after: after,
        ).toMap(),
        'at': FieldValue.serverTimestamp(),
      };
}
