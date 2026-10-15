import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/firebase/collections.dart';
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
