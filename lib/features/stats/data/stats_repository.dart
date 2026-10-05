import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/firebase/collections.dart';
import '../domain/student_course_stat.dart';

class StatsRepository {
  StatsRepository(this._db);

  final FirebaseFirestore _db;

  /// One document per student and course that has a non-present lecture.
  /// The `stageId` filter is what the rules need to authorize the query.
  Stream<List<StudentCourseStat>> watchStage(String stageId) => _db
      .collection(Col.stats)
      .where('stageId', isEqualTo: stageId)
      .snapshots()
      .map((snap) => [for (final d in snap.docs) StudentCourseStat.fromMap(d.id, d.data())]);
}
