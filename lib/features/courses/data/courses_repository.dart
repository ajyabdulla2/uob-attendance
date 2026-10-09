import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/firebase/collections.dart';
import '../../../core/firebase/doc_ids.dart';
import '../../students/domain/student.dart';
import '../domain/course.dart';
import '../domain/group_distribution.dart';
import '../domain/practical_group.dart';

class CoursesRepository {
  CoursesRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _courses => _db.collection(Col.courses);
  CollectionReference<Map<String, dynamic>> get _groups => _db.collection(Col.groups);

  Future<Map<String, Course>> fetchAll() async {
    final snap = await _courses.get();
    return {for (final d in snap.docs) d.id: Course.fromMap(d.id, d.data())};
  }

  Stream<List<Course>> watchStage(String stageId) =>
      _courses.where('stageId', isEqualTo: stageId).snapshots().map((snap) {
        final list = [for (final d in snap.docs) Course.fromMap(d.id, d.data())];
        return list..sort((a, b) => a.code.compareTo(b.code));
      });

  /// Groups of one course. The `stageId` filter is required: security rules
  /// authorize stage managers and teachers by stage, and Firestore rejects a
  /// query whose filters cannot prove the rule.
  Stream<List<PracticalGroup>> watchGroups({required String courseId, required String stageId}) =>
      _groupsOf(courseId, stageId).snapshots().map((snap) {
        final list = [for (final d in snap.docs) PracticalGroup.fromMap(d.id, d.data())];
        return list..sort((a, b) => a.name.length != b.name.length
            ? a.name.length.compareTo(b.name.length)
            : a.name.compareTo(b.name));
      });

  /// Creates (or re-fills) groups A, B, … for [course], distributing the
  /// attending [students] alphabetically and evenly. Groups beyond
  /// [groupCount] are deleted together with their assignments. Returns the
  /// teacher IDs whose practical assignments were removed.
  Future<Set<String>> distributeGroups({
    required Course course,
    required Iterable<Student> students,
    required int groupCount,
    required String actor,
  }) async {
    final distribution = distributeAlphabetically(students, groupCount);
    final existing = await _groupsOf(course.id, course.stageId).get();
    final keepIds = <String>{};
    final batch = _db.batch();

    for (var i = 0; i < distribution.length; i++) {
      final group = PracticalGroup(
        courseId: course.id,
        stageId: course.stageId,
        name: PracticalGroup.nameFor(i),
        studentIds: [for (final s in distribution[i]) s.id],
      );
      keepIds.add(group.id);
      batch.set(_groups.doc(group.id), {
        ...group.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': actor,
      });
    }

    final removedTeachers = <String>{};
    for (final doc in existing.docs.where((d) => !keepIds.contains(d.id))) {
      final name = PracticalGroup.fromMap(doc.id, doc.data()).name;
      final assignments = await _db
          .collection(Col.assignments)
          .where('stageId', isEqualTo: course.stageId)
          .where('courseId', isEqualTo: course.id)
          .where('target', isEqualTo: name)
          .get();
      for (final a in assignments.docs) {
        if (a.data()['type'] != 'practical') continue;
        removedTeachers.add('${a.data()['teacherId']}');
        batch.delete(a.reference);
      }
      batch.delete(doc.reference);
    }

    await batch.commit();
    return removedTeachers;
  }

  /// Moves [studentIds] into group [toGroup] of a course, taking them out of
  /// whichever of [groups] holds them (also adds students who had no group).
  /// Group sizes may differ afterwards. One batch, so a student is never in
  /// two groups; array operations keep concurrent edits of other members.
  Future<void> moveStudents({
    required List<PracticalGroup> groups,
    required Set<String> studentIds,
    required String toGroup,
    required String actor,
  }) async {
    if (studentIds.isEmpty) return;
    final ids = studentIds.toList();
    final stamp = {'updatedAt': FieldValue.serverTimestamp(), 'updatedBy': actor};
    final batch = _db.batch();
    for (final g in groups) {
      if (g.name == toGroup) {
        batch.update(_groups.doc(g.id), {'studentIds': FieldValue.arrayUnion(ids), ...stamp});
      } else if (g.studentIds.any(studentIds.contains)) {
        batch.update(_groups.doc(g.id), {'studentIds': FieldValue.arrayRemove(ids), ...stamp});
      }
    }
    await batch.commit();
  }

  /// Adds an empty group after the existing ones (A, B → C); fill it by
  /// moving students. Returns its name.
  Future<String> addGroup({
    required Course course,
    required List<PracticalGroup> groups,
    required String actor,
  }) async {
    final taken = {for (final g in groups) g.name};
    var i = 0;
    while (taken.contains(PracticalGroup.nameFor(i))) {
      i++;
    }
    final group = PracticalGroup(courseId: course.id, stageId: course.stageId, name: PracticalGroup.nameFor(i));
    await _groups.doc(group.id).set({
      ...group.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
      'updatedBy': actor,
    });
    return group.name;
  }

  Query<Map<String, dynamic>> _groupsOf(String courseId, String stageId) => _groups
      .where('stageId', isEqualTo: stageId)
      .where('courseId', isEqualTo: courseId);

  /// The group ID a practical assignment refers to.
  static String groupIdOf(String courseId, String groupName) => DocIds.group(courseId, groupName);
}
