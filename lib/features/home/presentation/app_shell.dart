import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../l10n/l10n.dart';
import '../../auth/application/auth_providers.dart';

class _Destination {
  const _Destination(this.route, this.icon, this.selectedIcon, this.label);
  final String route;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

/// Adaptive navigation: bottom bar on phones, rail on tablets / web.
/// Destinations depend on the account's permissions.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  static const wideBreakpoint = 840.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final perms = ref.watch(permissionsProvider);
    final destinations = [
      _Destination(Routes.home, Icons.home_outlined, Icons.home, l10n.navHome),
      if (perms.canImportAnything)
        _Destination(Routes.import, Icons.upload_file_outlined, Icons.upload_file, l10n.navImport),
      if (perms.canManageAssignments)
        _Destination(Routes.assignments, Icons.link_outlined, Icons.link, l10n.navAssignments),
      _Destination(Routes.profile, Icons.person_outline, Icons.person, l10n.navProfile),
    ];
    final index = destinations.indexWhere((d) => location.startsWith(d.route)).clamp(0, destinations.length - 1);
    void go(int i) => context.go(destinations[i].route);

    if (MediaQuery.sizeOf(context).width >= wideBreakpoint) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: index,
              onDestinationSelected: go,
              labelType: NavigationRailLabelType.all,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Icon(Icons.how_to_reg, size: 32, color: Theme.of(context).colorScheme.primary),
              ),
              destinations: [
                for (final d in destinations)
                  NavigationRailDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.selectedIcon),
                    label: Text(d.label),
                  ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: child),
          ],
        ),
      );
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: go,
        destinations: [
          for (final d in destinations)
            NavigationDestination(icon: Icon(d.icon), selectedIcon: Icon(d.selectedIcon), label: d.label),
        ],
      ),
    );
  }
}
