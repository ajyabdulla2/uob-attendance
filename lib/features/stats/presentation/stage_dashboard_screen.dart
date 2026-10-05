import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/domain/stage_ref.dart';
import '../../../core/firebase/doc_ids.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../l10n/l10n.dart';
import '../../assignments/application/assignments_providers.dart';
import '../../assignments/domain/assignment.dart';
import '../../attendance/domain/attendance_session.dart';
import '../../auth/application/auth_providers.dart';
import '../../edit_requests/application/edit_requests_providers.dart';
import '../application/stats_providers.dart';
import '../domain/student_course_stat.dart';

/// The last [days] calendar days (UTC keys, today first).
List<String> recentDateKeys(DateTime now, {int days = 7}) => [
      for (var i = 0; i < days; i++)
        DocIds.dateKey(DateTime.utc(now.year, now.month, now.day).subtract(Duration(days: i))),
    ];

final _recentSessionsProvider =
    StreamProvider.autoDispose.family<List<AttendanceSession>, String>((ref, stageId) =>
        ref.watch(statsRepositoryProvider).watchSessionsOn(stageId, recentDateKeys(DateTime.now())));

/// لوحة المرحلة (stage managers and admins): today's lectures, classes with
/// nothing recorded this week, the stage's alert / warning / dismissal
/// counts and pending edit requests.
class StageDashboardScreen extends ConsumerStatefulWidget {
  const StageDashboardScreen({super.key});

  @override
  ConsumerState<StageDashboardScreen> createState() => _StageDashboardScreenState();
}

class _StageDashboardScreenState extends ConsumerState<StageDashboardScreen> {
  StageRef? _stage;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final stages = ref.watch(permissionsProvider).manageableStages;
    final stage = _stage != null && stages.contains(_stage) ? _stage : stages.firstOrNull;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.dashTitle)),
      body: stage == null
          ? Center(child: MessageView(icon: Icons.lock_outline, title: l10n.assignmentsNoStages))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                DropdownButtonFormField<StageRef>(
                  key: const Key('dash.stage'),
                  initialValue: stage,
                  isExpanded: true,
                  decoration: InputDecoration(labelText: l10n.fixStage, prefixIcon: const Icon(Icons.layers)),
                  items: [for (final s in stages) DropdownMenuItem(value: s, child: Text(l10n.stage(s)))],
                  onChanged: (s) => setState(() => _stage = s),
                ),
                const SizedBox(height: 12),
                _Lectures(stageId: stage.id),
                const SizedBox(height: 12),
                _Levels(stageId: stage.id),
                const SizedBox(height: 12),
                _Requests(stageId: stage.id),
              ],
            ),
    );
  }
}

class _Lectures extends ConsumerWidget {
  const _Lectures({required this.stageId});

  final String stageId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final sessions = ref.watch(_recentSessionsProvider(stageId));
    final assignments = ref.watch(stageAssignmentsProvider(stageId));
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: AsyncBody<List<AttendanceSession>>(
          value: sessions,
          data: (recent) {
            final today = recentDateKeys(DateTime.now()).first;
            final todayCount = recent.where((s) => s.dateKey == today).length;
            // A class is identified by course + type + target (several
            // teachers may share it).
            String key(String courseId, String type, String target) => '$courseId|$type|$target';
            final active = {for (final s in recent) key(s.courseId, s.type.name, s.target)};
            final idle = <String, Assignment>{
              for (final a in assignments.value ?? const <Assignment>[])
                if (!active.contains(key(a.courseId, a.type.name, a.target))) key(a.courseId, a.type.name, a.target): a,
            };
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.dashToday(todayCount), key: const Key('dash.today'), style: theme.textTheme.titleMedium),
                Text(l10n.dashWeek(recent.length), style: theme.textTheme.bodySmall),
                const Divider(height: 24),
                Text(l10n.dashIdle(idle.length), key: const Key('dash.idle'), style: theme.textTheme.titleSmall),
                Text(l10n.dashIdleHelp, style: theme.textTheme.bodySmall),
                for (final a in idle.values)
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.event_busy),
                    title: Text(a.courseName.isEmpty ? a.courseId : a.courseName),
                    subtitle: Text([l10n.classLabel(a), if (a.teacherName.isNotEmpty) a.teacherName].join(' · ')),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Levels extends ConsumerWidget {
  const _Levels({required this.stageId});

  final String stageId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final palette = StatusPalette.of(context);
    return Card(
      child: AsyncBody(
        value: ref.watch(stageStandingsProvider(stageId)),
        data: (standings) => Column(
          children: [
            for (final level in [WarningLevel.alert, WarningLevel.warning, WarningLevel.dismissal])
              ListTile(
                key: Key('dash.level.${level.name}'),
                leading: Icon(StatusPalette.iconForLevel(level), color: palette.forLevel(level)),
                title: Text(l10n.warningLevel(level)),
                trailing: Text('${standings.where((s) => s.level == level).length}',
                    style: Theme.of(context).textTheme.titleMedium),
                onTap: () => context.push(Routes.warnings),
              ),
          ],
        ),
      ),
    );
  }
}

class _Requests extends ConsumerWidget {
  const _Requests({required this.stageId});

  final String stageId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final count = ref.watch(pendingEditRequestsProvider(stageId)).value?.length ?? 0;
    return Card(
      child: ListTile(
        key: const Key('dash.requests'),
        leading: const Icon(Icons.edit_calendar),
        title: Text(l10n.dashRequests(count)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push(Routes.editRequests),
      ),
    );
  }
}
