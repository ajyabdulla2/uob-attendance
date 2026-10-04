import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/database_provider.dart';
import '../../../core/router/app_router.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../l10n/l10n.dart';
import '../../academic/application/academic_providers.dart';
import '../../assignments/application/assignments_providers.dart';
import '../../assignments/domain/assignment.dart';
import '../../auth/application/auth_providers.dart';
import '../../auth/domain/app_user.dart';
import '../../../core/firebase/doc_ids.dart';

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
          if (!kIsWeb) const _PendingUploadsBanner(),
          _WelcomeCard(user: user),
          const SizedBox(height: 12),
          const _ActiveYearLine(),
          if (perms.isAdmin) const _SetupCard(),
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

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.homeWelcome(user.displayName), style: theme.textTheme.titleLarge),
            Text(user.email, style: theme.textTheme.bodySmall, textDirection: TextDirection.ltr),
            const SizedBox(height: 12),
            Text(l10n.homeRoles, style: theme.textTheme.labelLarge),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final role in UserRole.values)
                  if (user.hasRole(role)) Chip(avatar: const Icon(Icons.verified, size: 18), label: Text(l10n.role(role))),
              ],
            ),
            if (user.hasRole(UserRole.stageManager) && user.stageScopes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(l10n.homeStageScopes, style: theme.textTheme.labelLarge),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [for (final s in user.stageScopes) Chip(label: Text(l10n.stageId(s)))],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActiveYearLine extends ConsumerWidget {
  const _ActiveYearLine();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final year = ref.watch(activeYearProvider).value;
    if (year == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const Icon(Icons.event_note, size: 20),
          const SizedBox(width: 8),
          Text(context.l10n.homeActiveYear(year.id, '${year.semester}')),
        ],
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
      if (mounted) showSnack(context, l10n.errorGeneric('$e'));
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

class _MyCourses extends ConsumerWidget {
  const _MyCourses();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return AsyncBody<List<Assignment>>(
      value: ref.watch(myAssignmentsProvider),
      data: (items) {
        if (items.isEmpty) {
          return Card(child: ListTile(leading: const Icon(Icons.info_outline), title: Text(l10n.homeNoCourses)));
        }
        final sorted = [...items]..sort((a, b) => a.courseId.compareTo(b.courseId));
        return Card(
          child: Column(
            children: [
              for (final a in sorted)
                ListTile(
                  leading: Icon(a.type == AssignmentType.theory ? Icons.menu_book : Icons.computer),
                  title: Text(a.courseName.isEmpty ? a.courseId : a.courseName),
                  subtitle: Text([
                    l10n.stageId(a.stageId),
                    a.type == AssignmentType.theory ? l10n.theoryLabel : l10n.practicalLabel,
                    if (a.type == AssignmentType.practical) l10n.groupLabel(a.target),
                    if (a.type == AssignmentType.theory)
                      a.target == DocIds.allSections ? l10n.allSections : l10n.sectionLabel(a.target),
                  ].join(' · ')),
                ),
              ListTile(
                dense: true,
                leading: const Icon(Icons.schedule),
                title: Text(l10n.homeAttendanceSoon),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PendingUploadsBanner extends ConsumerWidget {
  const _PendingUploadsBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(pendingUploadsProvider).value ?? 0;
    if (count == 0) return const SizedBox.shrink();
    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: ListTile(
        leading: const Icon(Icons.cloud_upload_outlined),
        title: Text(context.l10n.pendingUploads(count)),
      ),
    );
  }
}
