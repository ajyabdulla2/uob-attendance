import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../l10n/l10n.dart';
import '../../notifications/application/notifications_providers.dart';
import '../../users/application/users_providers.dart';
import '../domain/admin_menu.dart';

/// The management tools as titled rows of tiles, one colour per group.
///
/// Icons: exactly the set of the 1.4.0 release — a patch can neither add nor
/// drop a glyph (test/core/release_icons_test.dart). The grid is plain rows,
/// not a GridView, so the home screen keeps a single scrollable.
class AdminTiles extends ConsumerWidget {
  const AdminTiles({super.key, required this.sections});

  final List<AdminSection> sections;

  static const _colors = {
    AdminGroup.daily: Colors.indigo,
    AdminGroup.students: Colors.teal,
    AdminGroup.data: Colors.deepOrange,
    AdminGroup.communication: Colors.purple,
    AdminGroup.system: Colors.blueGrey,
  };

  static Color colorOf(BuildContext context, AdminGroup group) {
    final c = _colors[group]!;
    return Theme.of(context).brightness == Brightness.dark ? c.shade200 : c.shade700;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final badges = <AdminTool, int>{
      AdminTool.editRequests: ref.watch(pendingRequestsCountProvider),
      if (sections.any((s) => s.tools.contains(AdminTool.accounts)))
        AdminTool.accounts: ref.watch(accessRequestsProvider).value?.length ?? 0,
    };
    return LayoutBuilder(
      builder: (context, box) {
        final columns = math.max(3, math.min(6, (box.maxWidth / 120).floor()));
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final section in sections) ...[
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(4, 12, 4, 6),
                child: Text(
                  _groupLabel(l10n, section.group),
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colorOf(context, section.group),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              for (var i = 0; i < section.tools.length; i += columns)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      for (var j = i; j < i + columns; j++) ...[
                        if (j > i) const SizedBox(width: 8),
                        Expanded(
                          child: j < section.tools.length
                              ? _Tile(
                                  tool: section.tools[j],
                                  color: colorOf(context, section.group),
                                  badge: badges[section.tools[j]] ?? 0,
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ],
        );
      },
    );
  }

  static String _groupLabel(AppLocalizations l10n, AdminGroup g) => switch (g) {
    AdminGroup.daily => l10n.menuDaily,
    AdminGroup.students => l10n.menuStudents,
    AdminGroup.data => l10n.menuData,
    AdminGroup.communication => l10n.menuCommunication,
    AdminGroup.system => l10n.menuSystem,
  };
}

class _Tile extends StatelessWidget {
  const _Tile({required this.tool, required this.color, required this.badge});

  final AdminTool tool;
  final Color color;
  final int badge;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final (key, icon, label, route) = switch (tool) {
      AdminTool.departmentDashboard => (
        'home.department',
        Icons.supervisor_account,
        l10n.deptAction,
        Routes.departmentDashboard,
      ),
      AdminTool.stageDashboard => ('home.dashboard', Icons.dashboard_outlined, l10n.dashAction, Routes.stageDashboard),
      AdminTool.editRequests => ('home.requests', Icons.edit_calendar, l10n.editRequestsAction, Routes.editRequests),
      AdminTool.teacherActivity => ('home.activity', Icons.how_to_reg, l10n.activityAction, Routes.teacherActivity),
      AdminTool.warnings => ('home.warnings', Icons.warning_amber, l10n.menuWarnings, Routes.warnings),
      AdminTool.leaves => ('home.leaves', Icons.event_available, l10n.leavesAction, Routes.leaves),
      AdminTool.import => ('home.import', Icons.upload_file_outlined, l10n.navImport, Routes.import),
      AdminTool.assignments => ('home.assignments', Icons.link_outlined, l10n.navAssignments, Routes.assignments),
      AdminTool.accounts => (
        'home.accounts',
        badge > 0 ? Icons.manage_accounts : Icons.manage_accounts_outlined,
        l10n.navAccounts,
        Routes.accounts,
      ),
      AdminTool.dataFix => ('home.dataFix', Icons.build_outlined, l10n.menuDataFix, Routes.dataFix),
      AdminTool.announcements => ('home.announcements', Icons.event_note, l10n.annAction, Routes.announcements),
      AdminTool.yearSettings => ('home.year', Icons.tune, l10n.menuYear, Routes.yearSettings),
      AdminTool.backup => ('home.backup', Icons.cloud_upload_outlined, l10n.backupAction, Routes.backup),
      AdminTool.auditLog => ('home.audit', Icons.search, l10n.auditOpen, Routes.auditLog),
      AdminTool.appRelease => ('home.release', Icons.system_update, l10n.releaseAction, Routes.appRelease),
    };
    return Material(
      key: Key(key),
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: color.withValues(alpha: 0.25)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(route),
        child: SizedBox(
          height: 100,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Badge(
                  isLabelVisible: badge > 0,
                  label: Text('$badge'),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 26),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600, height: 1.2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
