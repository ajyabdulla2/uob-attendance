import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../../stats/application/stats_providers.dart';
import '../data/missed_lecture_repository.dart';
import '../domain/attendance_session.dart';

final missedLectureRepositoryProvider = Provider<MissedLectureRepository>(
  (ref) => MissedLectureRepository(ref.watch(firestoreProvider)),
);

/// A stage's lectures on one day, to number a missed lecture after them.
final sessionsOnDayProvider =
    StreamProvider.autoDispose.family<List<AttendanceSession>, ({String stageId, String dateKey})>(
  (ref, k) => ref.watch(statsRepositoryProvider).watchSessionsOn(k.stageId, [k.dateKey]),
);
