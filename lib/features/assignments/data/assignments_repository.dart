import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/firebase/collections.dart';
import '../../auth/domain/app_user.dart';
import '../domain/assignment.dart';

/// `assignments` + the denormalized `users.teachingStages` that lets
/// teachers read the students of the stages they teach (see firestore.rules).
class AssignmentsRepository {
  AssignmentsRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col => _db.collection(Col.assignments);
  CollectionReference<Map<String, dynamic>> get _users => _db.collection(Col.users);

  Stream<List<Assignment>> watchStage(String stageId) =>
      _col.where('stageId', isEqualTo: stageId).snapshots().map(
            (snap) => [for (final d in snap.docs) Assignment.fromMap(d.id, d.data())],
          );

  /// The signed-in teacher's own assignments («موادي»).
  Stream<List<Assignment>> watchTeacher(String teacherId) =>
      _col.where('teacherId', isEqualTo: teacherId).snapshots().map(
            (snap) => [for (final d in snap.docs) Assignment.fromMap(d.id, d.data())],
          );

  /// Creates the link and adds the stage to the teacher's teachingStages in
  /// one batch. Admin teachers are skipped: they can read everything anyway,
  /// and deputies may not edit admin accounts.
  Future<void> assign(Assignment assignment, {required AppUser teacher, required String actor}) async {
    final batch = _db.batch();
    batch.set(_col.doc(assignment.id), {
      ...assignment.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'updatedBy': actor,
    });
    if (!_isAdmin(teacher) && !teacher.teachingStages.contains(assignment.stageId)) {
      batch.update(_users.doc(teacher.id), {
        'teachingStages': FieldValue.arrayUnion([assignment.stageId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  /// Removes the link; drops the stage from teachingStages when it was the
  /// teacher's last assignment there.
  Future<void> unassign(Assignment assignment) async {
    await _col.doc(assignment.id).delete();
    await syncTeachingStage(assignment.teacherId, assignment.stageId);
  }

  /// Removes [stageId] from the teacher's teachingStages if no assignment in
  /// that stage remains.
  Future<void> syncTeachingStage(String teacherId, String stageId) async {
    final remaining = await _col
        .where('stageId', isEqualTo: stageId)
        .where('teacherId', isEqualTo: teacherId)
        .limit(1)
        .get();
    if (remaining.docs.isNotEmpty) return;
    final userDoc = await _users.doc(teacherId).get();
    if (!userDoc.exists) return;
    final user = AppUser.fromMap(userDoc.id, userDoc.data()!);
    if (_isAdmin(user) || !user.teachingStages.contains(stageId)) return;
    await _users.doc(teacherId).update({
      'teachingStages': FieldValue.arrayRemove([stageId]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static bool _isAdmin(AppUser u) => u.hasRole(UserRole.superAdmin) || u.hasRole(UserRole.deputyAdmin);
}
