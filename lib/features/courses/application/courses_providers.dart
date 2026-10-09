import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../data/courses_repository.dart';
import '../domain/course.dart';
import '../domain/practical_group.dart';

final coursesRepositoryProvider = Provider<CoursesRepository>(
  (ref) => CoursesRepository(ref.watch(firestoreProvider)),
);

final stageCoursesProvider = StreamProvider.autoDispose.family<List<Course>, String>(
  (ref, stageId) => ref.watch(coursesRepositoryProvider).watchStage(stageId),
);

/// Keyed by a record (value equality) so rebuilds reuse the subscription.
final courseGroupsProvider =
    StreamProvider.autoDispose.family<List<PracticalGroup>, ({String courseId, String stageId})>(
  (ref, key) => ref.watch(coursesRepositoryProvider).watchGroups(courseId: key.courseId, stageId: key.stageId),
);
