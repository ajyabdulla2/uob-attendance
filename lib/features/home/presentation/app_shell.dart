import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/diagnostics/error_log.dart';
import '../../../core/router/app_router.dart';
import '../../../l10n/l10n.dart';
import '../../activity/presentation/presence_reporter.dart';
import '../../app_update/application/app_update_providers.dart';
import '../../app_update/presentation/update_gate.dart';
import '../../attendance/presentation/sync_widgets.dart';
import '../../auth/application/auth_providers.dart';
import '../../push/presentation/push_lifecycle.dart';
import '../domain/admin_menu.dart';

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
    final me = ref.watch(signedInUserProvider);
    final version = ref.watch(installedVersionProvider).value;
    ErrorLog.context = [
      'account: ${me.email} (${me.roles.map((r) => r.name).join(', ')})',
      if (me.stageScopes.isNotEmpty) 'stages: ${me.stageScopes.join(', ')}',
      'app: ${version ?? '?'} · ${kIsWeb ? 'web' : defaultTargetPlatform.name}',
    ].join('\n');
    // The management tools are tiles on the home screen (AdminMenu); a
    // manager's own classes get their own tab.
    final destinations = [
      _Destination(Routes.home, Icons.home_outlined, Icons.home, l10n.navHome),
      if (AdminMenu.of(perms).isNotEmpty)
        _Destination(Routes.courses, Icons.menu_book_outlined, Icons.menu_book, l10n.navCourses),
      _Destination(Routes.profile, Icons.person_outline, Icons.person, l10n.navProfile),
    ];
    final index = destinations.indexWhere((d) => location.startsWith(d.route)).clamp(0, destinations.length - 1);
    void go(int i) => context.go(destinations[i].route);

    final Widget shell;
    if (MediaQuery.sizeOf(context).width >= wideBreakpoint) {
      shell = Scaffold(
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
            Expanded(child: PresenceReporter(child: PushLifecycle(child: SyncLifecycle(child: UpdateGate(child: child))))),
          ],
        ),
      );
    } else {
      shell = Scaffold(
        body: PresenceReporter(child: PushLifecycle(child: SyncLifecycle(child: UpdateGate(child: child)))),
        bottomNavigationBar: _ToScreenEdge(
          child: NavigationBar(
            selectedIndex: index,
            onDestinationSelected: go,
            destinations: [
              for (final d in destinations)
                NavigationDestination(icon: Icon(d.icon), selectedIcon: Icon(d.selectedIcon), label: d.label),
            ],
          ),
        ),
      );
    }
    return _BackToHome(location: location, child: shell);
  }
}

/// The app-wide SafeArea (app.dart) keeps the system's bottom inset (the
/// iPhone home indicator, Android's gesture bar) clear and fills it with the
/// page colour, which left a band of another colour under the bottom bar.
/// This paints the bar's own colour down to the screen edge.
class _ToScreenEdge extends StatelessWidget {
  const _ToScreenEdge({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    // The SafeArea removed the inset from MediaQuery; the view still has it.
    final inset = MediaQueryData.fromView(View.of(context)).padding.bottom;
    if (inset == 0) return child;
    final color = NavigationBarTheme.of(context).backgroundColor ?? Theme.of(context).colorScheme.surfaceContainer;
    return Stack(
      fit: StackFit.passthrough,
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          key: const Key('shell.navEdge'),
          left: 0,
          right: 0,
          bottom: -inset,
          height: inset,
          child: ColoredBox(color: color),
        ),
      ],
    );
  }
}

/// Android back on a tab: another tab returns to the home screen, and the
/// home screen asks for a second press within two seconds before leaving
/// (a single press used to close the app from «الاستيراد» or «الحسابات»).
/// Pages pushed above the shell pop as usual. The web keeps the browser's
/// own history.
class _BackToHome extends StatefulWidget {
  const _BackToHome({required this.location, required this.child});

  final String location;
  final Widget child;

  @override
  State<_BackToHome> createState() => _BackToHomeState();
}

class _BackToHomeState extends State<_BackToHome> {
  static const _window = Duration(seconds: 2);
  DateTime? _lastBack;

  void _onBack(bool didPop, Object? _) {
    if (didPop) return;
    if (!widget.location.startsWith(Routes.home)) {
      context.go(Routes.home);
      return;
    }
    final now = DateTime.now();
    final last = _lastBack;
    if (last != null && now.difference(last) < _window) {
      SystemNavigator.pop();
      return;
    }
    _lastBack = now;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(context.l10n.backAgainToExit), duration: _window));
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) return widget.child;
    return PopScope(canPop: false, onPopInvokedWithResult: _onBack, child: widget.child);
  }
}
