import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/doc_ids.dart';
import '../../../core/firebase/firebase_providers.dart';
import '../../academic/application/academic_providers.dart';
import '../../courses/application/courses_providers.dart';
import '../../leaves/application/leaves_providers.dart';
import '../../students/application/students_providers.dart';
import '../data/stats_repository.dart';
import '../domain/period_standings.dart';
import '../domain/standings.dart';
import '../domain/student_course_stat.dart';

final statsRepositoryProvider = Provider<StatsRepository>(
  (ref) => StatsRepository(ref.watch(firestoreProvider)),
);

final stageStatsProvider = StreamProvider.autoDispose.family<List<StudentCourseStat>, String>(
  (ref, stageId) => ref.watch(statsRepositoryProvider).watchStage(stageId),
);

/// The stage's standings, recomputed whenever a lecture, leave, student,
/// course or the year's settings change (loading until all have arrived).
final stageStandingsProvider = Provider.autoDispose.family<AsyncValue<List<Standing>>, String>((ref, stageId) {
  final parts = (
    ref.watch(stageStudentsProvider(stageId)),
    ref.watch(stageCoursesProvider(stageId)),
    ref.watch(stageStatsProvider(stageId)),
    ref.watch(stageLeavesProvider(stageId)),
    ref.watch(activeYearProvider),
  );
  for (final p in [parts.$1, parts.$2, parts.$3, parts.$4, parts.$5]) {
    if (p.hasError) return AsyncValue.error(p.error!, p.stackTrace ?? StackTrace.current);
  }
  final (students, courses, stats, leaves, year) =
      (parts.$1.value, parts.$2.value, parts.$3.value, parts.$4.value, parts.$5.value);
  if (students == null || courses == null || stats == null || leaves == null || !parts.$5.hasValue) {
    return const AsyncValue.loading();
  }
  if (year == null) return const AsyncValue.data([]);
  return AsyncValue.data(buildStandings(students: students, courses: courses, stats: stats, leaves: leaves, year: year));
});

/// «غياب فترة»: the stage's students absent between two days, read once
/// when opened (the period's lectures and the stage's practical groups).
final periodStandingsProvider = FutureProvider.autoDispose
    .family<List<PeriodStanding>, ({String stageId, DateTime from, DateTime to})>((ref, key) async {
  final year = await ref.watch(activeYearProvider.future);
  if (year == null) return const [];
  final (students, courses, stats, leaves, sessions, groups) = await (
    ref.watch(stageStudentsProvider(key.stageId).future),
    ref.watch(stageCoursesProvider(key.stageId).future),
    ref.watch(stageStatsProvider(key.stageId).future),
    ref.watch(stageLeavesProvider(key.stageId).future),
    ref.read(statsRepositoryProvider).sessionsBetween(key.stageId, DocIds.dateKey(key.from), DocIds.dateKey(key.to)),
    ref.read(coursesRepositoryProvider).fetchStageGroups(key.stageId),
  ).wait;
  return buildPeriodStandings(
    students: students,
    courses: courses,
    stats: stats,
    leaves: leaves,
    sessions: sessions,
    groups: groups,
    year: year,
    from: key.from,
    to: key.to,
  );
});
