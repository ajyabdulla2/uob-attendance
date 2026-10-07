import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/doc_ids.dart';
import '../../../core/firebase/firebase_providers.dart';
import '../data/department_repository.dart';

final departmentRepositoryProvider = Provider<DepartmentRepository>(
  (ref) => DepartmentRepository(ref.watch(firestoreProvider)),
);

final departmentSummaryProvider = FutureProvider.autoDispose<DepartmentSummary>((ref) async {
  final repo = ref.watch(departmentRepositoryProvider);
  final now = DateTime.now();
  final today = DocIds.dateKey(DateTime.utc(now.year, now.month, now.day));
  final results = await Future.wait([repo.stageCounts(today), repo.pendingAccessRequests(), repo.activeTeachers()]);
  return DepartmentSummary(
    stages: results[0] as List<StageCounts>,
    accessRequests: results[1] as int,
    activeAccounts: results[2] as int,
  );
});

final class DepartmentSummary {
  const DepartmentSummary({required this.stages, required this.accessRequests, required this.activeAccounts});

  final List<StageCounts> stages;
  final int accessRequests;
  final int activeAccounts;
}

/// The dashboard and the home screen remind admins after this long.
const backupReminderAfter = Duration(days: 7);

bool backupIsDue(DateTime? lastBackup, DateTime now) =>
    lastBackup == null || now.difference(lastBackup) > backupReminderAfter;
