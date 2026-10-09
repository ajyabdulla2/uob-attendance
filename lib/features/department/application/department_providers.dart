import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/doc_ids.dart';
import '../../../core/firebase/firebase_providers.dart';
import '../../../core/firebase/rules_version.dart';
import '../data/department_repository.dart';

final departmentSummaryProvider = FutureProvider.autoDispose<DepartmentSummary>((ref) async {
  // A fresh repository per load, so failures reflect this load only.
  final repo = DepartmentRepository(ref.watch(firestoreProvider));
  final now = DateTime.now();
  final today = DocIds.dateKey(DateTime.utc(now.year, now.month, now.day));
  final results = await Future.wait([repo.stageCounts(today), repo.pendingAccessRequests(), repo.activeTeachers()]);
  return DepartmentSummary(
    stages: results[0] as List<StageCounts>,
    accessRequests: results[1] as int?,
    activeAccounts: results[2] as int?,
    failures: {
      ...repo.failures,
      if (repo.failures.isNotEmpty) 'rules': RulesVersion.describe(await RulesVersion.isDeployed(ref.read(firestoreProvider))),
    },
  );
});

final class DepartmentSummary {
  const DepartmentSummary({
    required this.stages,
    required this.accessRequests,
    required this.activeAccounts,
    this.failures = const {},
  });

  final List<StageCounts> stages;
  final int? accessRequests;
  final int? activeAccounts;

  /// collection → error code of the counts that failed.
  final Map<String, String> failures;
}

/// The dashboard and the home screen remind admins after this long.
const backupReminderAfter = Duration(days: 7);

bool backupIsDue(DateTime? lastBackup, DateTime now) =>
    lastBackup == null || now.difference(lastBackup) > backupReminderAfter;
