import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/firebase/collections.dart';
import '../../../core/router/app_router.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../l10n/l10n.dart';
import '../../backup/application/backup_providers.dart';
import '../application/department_providers.dart';
import '../data/department_repository.dart';
import 'absence_charts.dart';

/// لوحة القسم (admins): every stage at a glance, pending requests and the
/// backup reminder. Built from count() aggregations only.
class DepartmentDashboardScreen extends ConsumerWidget {
  const DepartmentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final summary = ref.watch(departmentSummaryProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.deptTitle),
        actions: [
          IconButton(
            tooltip: l10n.actionUpdate,
            onPressed: () => ref.invalidate(departmentSummaryProvider),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const BackupReminderCard(always: true),
          const SizedBox(height: 12),
          AsyncBody<DepartmentSummary>(
            value: summary,
            data: (s) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (s.failures.isNotEmpty)
                  Card(
                    key: const Key('dept.failures'),
                    color: Theme.of(context).colorScheme.errorContainer,
                    child: ListTile(
                      leading: const Icon(Icons.error_outline),
                      title: Text(l10n.deptPartial(
                          s.failures.keys.map(l10n.backupCollection).join('، '), s.failures.values.toSet().join('، '))),
                    ),
                  ),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        key: const Key('dept.accounts'),
                        leading: const Icon(Icons.groups_outlined),
                        title: Text(s.activeAccounts == null ? '${l10n.backupCollection(Col.users)}: —' : l10n.deptActiveAccounts(s.activeAccounts!)),
                      ),
                      ListTile(
                        key: const Key('dept.access'),
                        leading: const Icon(Icons.person_add_alt),
                        title: Text(s.accessRequests == null ? '${l10n.backupCollection(Col.accessRequests)}: —' : l10n.deptAccessRequests(s.accessRequests!)),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push(Routes.accounts),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const AbsenceChartsCard(),
                const SizedBox(height: 12),
                for (final c in s.stages) _StageCard(counts: c),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StageCard extends StatelessWidget {
  const _StageCard({required this.counts});

  final StageCounts counts;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final empty = counts.students == 0 && counts.courses == 0;
    String n(int? v, String collection, String Function(int) label) =>
        v == null ? '${l10n.backupCollection(collection)}: —' : label(v);
    return Card(
      key: Key('dept.stage.${counts.stageId}'),
      child: InkWell(
        onTap: () => context.push(Routes.stageDashboard),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.stageId(counts.stageId), style: theme.textTheme.titleMedium),
              const SizedBox(height: 6),
              if (empty)
                Text(l10n.deptStageEmpty, style: theme.textTheme.bodySmall)
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    _chip(Icons.person_outline, n(counts.students, Col.students, l10n.deptStudents)),
                    _chip(Icons.menu_book_outlined, n(counts.courses, Col.courses, l10n.deptCourses)),
                    _chip(Icons.calendar_today, n(counts.lecturesToday, Col.sessions, l10n.deptLecturesToday)),
                    if (counts.pendingRequests != 0)
                      _chip(Icons.edit_calendar, n(counts.pendingRequests, Col.editRequests, l10n.deptPendingRequests),
                          highlight: theme),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String text, {ThemeData? highlight}) => Chip(
        avatar: Icon(icon, size: 18),
        label: Text(text),
        backgroundColor: highlight?.colorScheme.tertiaryContainer,
      );
}

/// Reminds admins to save a backup when the last one is older than a week
/// (on the home screen only then; on the dashboard [always]).
class BackupReminderCard extends ConsumerWidget {
  const BackupReminderCard({super.key, this.always = false});

  final bool always;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final last = ref.watch(lastBackupProvider);
    if (!last.hasValue) return const SizedBox.shrink();
    final at = last.value?.at;
    final due = backupIsDue(at, DateTime.now());
    if (!due && !always) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final days = at == null ? null : DateTime.now().difference(at).inDays;
    return Card(
      key: const Key('backup.reminder'),
      color: due ? theme.colorScheme.errorContainer : null,
      child: ListTile(
        leading: Icon(due ? Icons.warning_amber : Icons.verified),
        title: Text(at == null ? l10n.backupNever : l10n.backupAgo(days!)),
        subtitle: due ? Text(l10n.backupDue) : null,
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push(Routes.backup),
      ),
    );
  }
}
