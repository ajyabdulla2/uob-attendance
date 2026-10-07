import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/firebase/doc_ids.dart';
import '../../../core/router/app_router.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../l10n/l10n.dart';
import '../../academic/application/academic_providers.dart';
import '../../assignments/application/assignments_providers.dart';
import '../../assignments/domain/assignment.dart';
import '../../attendance/application/attendance_providers.dart';
import '../../attendance/presentation/sync_widgets.dart';
import '../../auth/application/auth_providers.dart';
import '../../auth/domain/app_user.dart';
import '../../department/presentation/department_dashboard_screen.dart';
import '../../users/application/users_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final user = ref.watch(signedInUserProvider);
    final perms = ref.watch(permissionsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // The local queue lives on phones; the web panel works online.
          if (ref.watch(localFirstProvider)) const SyncStatusCard(),
          _WelcomeCard(user: user),
          if (perms.isAdmin) const _SetupCard(),
          if (perms.canBackup) const BackupReminderCard(),
          if (perms.canManageAccounts) const _AccessRequestsCard(),
          if (perms.canImportAnything || perms.canManageAssignments) ...[
            const SizedBox(height: 12),
            Text(l10n.homeQuickActions, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  if (perms.canImportAnything)
                    ListTile(
                      leading: const Icon(Icons.upload_file),
                      title: Text(l10n.homeImportAction),
                      trailing: const Icon(Icons.chevron_right), // mirrors in RTL
                      onTap: () => context.go(Routes.import),
                    ),
                  if (perms.canManageAssignments)
                    ListTile(
                      leading: const Icon(Icons.link),
                      title: Text(l10n.homeAssignAction),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.go(Routes.assignments),
                    ),
                  if (perms.canViewDepartmentDashboard)
                    ListTile(
                      key: const Key('home.department'),
                      leading: const Icon(Icons.supervisor_account),
                      title: Text(l10n.deptAction),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push(Routes.departmentDashboard),
                    ),
                  if (perms.canViewStageDashboard)
                    ListTile(
                      key: const Key('home.dashboard'),
                      leading: const Icon(Icons.dashboard_outlined),
                      title: Text(l10n.dashAction),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push(Routes.stageDashboard),
                    ),
                  if (perms.canReviewEditRequests)
                    ListTile(
                      key: const Key('home.requests'),
                      leading: const Icon(Icons.edit_calendar),
                      title: Text(l10n.editRequestsAction),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push(Routes.editRequests),
                    ),
                  if (perms.canViewWarnings)
                    ListTile(
                      key: const Key('home.warnings'),
                      leading: const Icon(Icons.warning_amber),
                      title: Text(l10n.warnAction),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push(Routes.warnings),
                    ),
                  if (perms.canManageLeaves)
                    ListTile(
                      key: const Key('home.leaves'),
                      leading: const Icon(Icons.event_available),
                      title: Text(l10n.leavesAction),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push(Routes.leaves),
                    ),
                  if (perms.canEditYear)
                    ListTile(
                      key: const Key('home.year'),
                      leading: const Icon(Icons.tune),
                      title: Text(l10n.yearAction),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push(Routes.yearSettings),
                    ),
                  if (perms.canViewAuditLog)
                    ListTile(
                      key: const Key('home.audit'),
                      leading: const Icon(Icons.search),
                      title: Text(l10n.auditOpen),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push(Routes.auditLog),
                    ),
                  if (perms.canBackup)
                    ListTile(
                      key: const Key('home.backup'),
                      leading: const Icon(Icons.cloud_upload_outlined),
                      title: Text(l10n.backupAction),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push(Routes.backup),
                    ),
                  if (perms.canFixData)
                    ListTile(
                      key: const Key('home.dataFix'),
                      leading: const Icon(Icons.build_outlined),
                      title: Text(l10n.homeDataFixAction),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push(Routes.dataFix),
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text(l10n.homeMyCourses, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          const _MyCourses(),
        ],
      ),
    );
  }
}

/// One compact card: greeting, roles (and managed stages) and the active
/// year — the courses below are what the screen is for.
class _WelcomeCard extends ConsumerWidget {
  const _WelcomeCard({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final year = ref.watch(activeYearProvider).value;
    final roles = [
      for (final role in UserRole.values)
        if (user.hasRole(role)) l10n.role(role),
    ].join('، ');
    final scopes = user.hasRole(UserRole.stageManager) && user.stageScopes.isNotEmpty
        ? user.stageScopes.map(l10n.stageId).join('، ')
        : null;
    return Card(
      key: const Key('home.welcome'),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(Icons.person, color: theme.colorScheme.onPrimaryContainer),
        ),
        title: Text(l10n.homeWelcome(user.displayName), style: theme.textTheme.titleMedium),
        subtitle: Text(
          [
            roles,
            ?scopes,
            if (year != null) l10n.homeActiveYear(year.id, '${year.semester}'),
          ].join('\n'),
          style: theme.textTheme.bodySmall,
        ),
      ),
    );
  }
}

/// Offers to create the eight stages and an active year when missing.
class _SetupCard extends ConsumerStatefulWidget {
  const _SetupCard();

  @override
  ConsumerState<_SetupCard> createState() => _SetupCardState();
}

class _SetupCardState extends ConsumerState<_SetupCard> {
  bool _busy = false;

  Future<void> _initialize() async {
    final l10n = context.l10n;
    setState(() => _busy = true);
    try {
      await ref.read(academicRepositoryProvider).initializeDefaults(
            now: DateTime.now(),
            actor: ref.read(signedInUserProvider).id,
          );
      ref.invalidate(setupStatusProvider);
      if (mounted) showSnack(context, l10n.homeSetupDone);
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(setupStatusProvider).value;
    if (status == null || status.isComplete) return const SizedBox.shrink();
    final l10n = context.l10n;
    return Card(
      color: Theme.of(context).colorScheme.tertiaryContainer,
      child: ListTile(
        leading: const Icon(Icons.build_circle_outlined),
        title: Text(l10n.homeSetupTitle),
        subtitle: Text(l10n.homeSetupBody),
        trailing: FilledButton(
          onPressed: _busy ? null : _initialize,
          child: Text(l10n.homeSetupAction),
        ),
      ),
    );
  }
}

/// Admins: join requests waiting for approval (hidden when none).
class _AccessRequestsCard extends ConsumerWidget {
  const _AccessRequestsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(accessRequestsProvider).value?.length ?? 0;
    if (count == 0) return const SizedBox.shrink();
    return Card(
      key: const Key('home.accessRequests'),
      color: Theme.of(context).colorScheme.tertiaryContainer,
      child: ListTile(
        leading: const Icon(Icons.how_to_reg),
        title: Text(context.l10n.homeAccessRequests(count)),
        trailing: const Icon(Icons.chevron_right), // mirrors in RTL
        onTap: () => context.go(Routes.accounts),
      ),
    );
  }
}

class _MyCourses extends ConsumerWidget {
  const _MyCourses();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final local = ref.watch(localFirstProvider);
    return AsyncBody<List<Assignment>>(
      // Phones list the downloaded classes (works offline); the web panel
      // reads them online and only shows them.
      value: local ? ref.watch(localClassesProvider) : ref.watch(myAssignmentsProvider),
      data: (items) {
        if (items.isEmpty) {
          final downloading = local && ref.watch(syncControllerProvider.select((s) => s.running));
          return Card(
            child: ListTile(
              leading: downloading
                  ? const SizedBox.square(dimension: 24, child: CircularProgressIndicator(strokeWidth: 3))
                  : const Icon(Icons.info_outline),
              title: Text(downloading ? l10n.homeDownloading : l10n.homeNoCourses),
            ),
          );
        }
        // One card per course (its theory and practical classes together),
        // each course in its own colour.
        final byCourse = <String, List<Assignment>>{};
        for (final a in items) {
          (byCourse[a.courseId] ??= []).add(a);
        }
        final courses = byCourse.values.toList()
          ..sort((x, y) => _name(x.first).compareTo(_name(y.first)));
        return Column(
          children: [
            for (var i = 0; i < courses.length; i++)
              _CourseCard(classes: courses[i], color: _CourseCard.colorAt(context, i), local: local),
            if (!local)
              Card(
                child: ListTile(
                  dense: true,
                  leading: const Icon(Icons.phone_android),
                  title: Text(l10n.homeRecordOnPhone),
                ),
              ),
          ],
        );
      },
    );
  }

  static String _name(Assignment a) => a.courseName.isEmpty ? a.courseId : a.courseName;
}

/// A course with a coloured edge; one row per class (theory first, then the
/// practical groups) — tap to record, the table opens the register.
class _CourseCard extends StatelessWidget {
  const _CourseCard({required this.classes, required this.color, required this.local});

  final List<Assignment> classes;
  final Color color;
  final bool local;

  static const _palette = [
    Colors.indigo,
    Colors.teal,
    Colors.deepOrange,
    Colors.purple,
    Colors.green,
    Colors.brown,
    Colors.pink,
    Colors.blueGrey,
  ];

  static Color colorAt(BuildContext context, int i) {
    final c = _palette[i % _palette.length];
    return Theme.of(context).brightness == Brightness.dark ? c.shade300 : c.shade600;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final first = classes.first;
    final sorted = [...classes]
      ..sort((a, b) => a.type == b.type ? a.target.compareTo(b.target) : a.type.index.compareTo(b.type.index));
    return Card(
      key: Key('home.course.${first.courseId}'),
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withValues(alpha: 0.5)),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 6, color: color),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(12, 10, 12, 2),
                    child: Text(
                      first.courseName.isEmpty ? first.courseId : first.courseName,
                      style: theme.textTheme.titleMedium?.copyWith(color: color, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 12, 4),
                    child: Text(l10n.stageId(first.stageId), style: theme.textTheme.bodySmall),
                  ),
                  for (final a in sorted)
                    ListTile(
                      key: Key('home.class.${a.id}'),
                      dense: true,
                      visualDensity: VisualDensity.compact,
                      leading: Icon(a.type == AssignmentType.theory ? Icons.menu_book : Icons.computer, color: color),
                      title: Text(_classPart(l10n, a), style: theme.textTheme.titleSmall),
                      onTap: local ? () => context.push(Routes.recordFor(a.id)) : null,
                      trailing: local
                          ? IconButton(
                              key: Key('home.register.${a.id}'),
                              tooltip: l10n.registerAction,
                              icon: const Icon(Icons.table_chart_outlined),
                              onPressed: () => context.push(Routes.registerFor(a.id)),
                            )
                          : null,
                    ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// «نظري · كل الشعب» / «عملي · مجموعة A» (the stage is in the header).
  static String _classPart(AppLocalizations l10n, Assignment a) => [
        if (a.type == AssignmentType.theory) ...[
          l10n.theoryLabel,
          a.target == DocIds.allSections ? l10n.allSections : l10n.sectionLabel(a.target),
        ] else ...[
          l10n.practicalLabel,
          l10n.groupLabel(a.target),
        ],
      ].join(' · ');
}
