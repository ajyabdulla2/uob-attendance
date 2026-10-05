import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/academic/presentation/year_settings_screen.dart';
import '../../features/assignments/presentation/assignments_screen.dart';
import '../../features/attendance/presentation/record_screen.dart';
import '../../features/attendance/presentation/register_screen.dart';
import '../../features/auth/application/auth_providers.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/no_access_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/presentation/verify_email_screen.dart';
import '../../features/data_fix/presentation/data_fix_screen.dart';
import '../../features/edit_requests/presentation/edit_requests_screen.dart';
import '../../features/home/presentation/app_shell.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/import/presentation/import_screen.dart';
import '../../features/leaves/presentation/leaves_screen.dart';
import '../../features/settings/presentation/profile_screen.dart';
import '../../features/stats/presentation/stage_dashboard_screen.dart';
import '../../features/users/presentation/accounts_screen.dart';
import '../../features/warnings/presentation/warnings_screen.dart';
import '../firebase/doc_ids.dart';

abstract final class Routes {
  static const splash = '/splash';
  static const login = '/login';
  static const verifyEmail = '/verify-email';
  static const noAccess = '/no-access';
  static const home = '/home';
  static const import = '/import';
  static const assignments = '/assignments';
  static const accounts = '/accounts';
  static const profile = '/profile';
  static const record = '/record';
  static const register = '/register';
  static const dataFix = '/data-fix';
  static const yearSettings = '/year-settings';
  static const leaves = '/leaves';
  static const warnings = '/warnings';
  static const editRequests = '/edit-requests';
  static const stageDashboard = '/stage-dashboard';

  /// Record screen of a class, optionally on a given lecture.
  static String recordFor(String assignmentId, {DateTime? date, int? lectureNo}) => Uri(path: record, queryParameters: {
        'a': assignmentId,
        if (date != null) 'd': DocIds.dateKey(date),
        if (lectureNo != null) 'n': '$lectureNo',
      }).toString();

  static String registerFor(String assignmentId) => Uri(path: register, queryParameters: {'a': assignmentId}).toString();

  static const _gates = {splash, login, verifyEmail, noAccess};
}

/// Pure redirect logic (unit-tested): where should [location] go for [status]?
/// Returns null to stay.
@visibleForTesting
String? redirectFor(AuthStatus status, String location) {
  String? goTo(String target) => location == target ? null : target;
  return switch (status) {
    AuthLoading() => goTo(Routes.splash),
    SignedOut() => goTo(Routes.login),
    NeedsVerification() => goTo(Routes.verifyEmail),
    NotProvisioned() || Suspended() || ProfileLoadFailed() => goTo(Routes.noAccess),
    SignedIn(:final permissions) => switch (location) {
        _ when Routes._gates.contains(location) => Routes.home,
        _ when location.startsWith(Routes.import) && !permissions.canImportAnything => Routes.home,
        _ when location.startsWith(Routes.assignments) && !permissions.canManageAssignments => Routes.home,
        _ when location.startsWith(Routes.accounts) && !permissions.canManageAccounts => Routes.home,
        _ when location.startsWith(Routes.dataFix) && !permissions.canFixData => Routes.home,
        _ when location.startsWith(Routes.yearSettings) && !permissions.canEditYear => Routes.home,
        _ when location.startsWith(Routes.leaves) && !permissions.canManageLeaves => Routes.home,
        _ when location.startsWith(Routes.warnings) && !permissions.canViewWarnings => Routes.home,
        _ when location.startsWith(Routes.editRequests) && !permissions.canReviewEditRequests => Routes.home,
        _ when location.startsWith(Routes.stageDashboard) && !permissions.canViewStageDashboard => Routes.home,
        _ => null,
      },
  };
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(authStatusProvider, (_, _) => refresh.value++);
  ref.onDispose(refresh.dispose);

  NoTransitionPage<void> page(GoRouterState state, Widget child) =>
      NoTransitionPage(key: state.pageKey, child: child);

  return GoRouter(
    initialLocation: Routes.home,
    refreshListenable: refresh,
    redirect: (context, state) => redirectFor(ref.read(authStatusProvider), state.matchedLocation),
    routes: [
      GoRoute(path: Routes.splash, builder: (_, _) => const SplashScreen()),
      GoRoute(path: Routes.login, builder: (_, _) => const LoginScreen()),
      GoRoute(path: Routes.verifyEmail, builder: (_, _) => const VerifyEmailScreen()),
      GoRoute(path: Routes.noAccess, builder: (_, _) => const NoAccessScreen()),
      // Full-screen pages pushed above the shell (back button, no nav bar).
      GoRoute(
        path: Routes.record,
        builder: (_, s) => RecordScreen(
          assignmentId: s.uri.queryParameters['a'] ?? '',
          date: DocIds.parseDateKey(s.uri.queryParameters['d'] ?? ''),
          lectureNo: int.tryParse(s.uri.queryParameters['n'] ?? ''),
        ),
      ),
      GoRoute(path: Routes.dataFix, builder: (_, _) => const DataFixScreen()),
      GoRoute(path: Routes.yearSettings, builder: (_, _) => const YearSettingsScreen()),
      GoRoute(path: Routes.leaves, builder: (_, _) => const LeavesScreen()),
      GoRoute(path: Routes.warnings, builder: (_, _) => const WarningsScreen()),
      GoRoute(path: Routes.editRequests, builder: (_, _) => const EditRequestsScreen()),
      GoRoute(path: Routes.stageDashboard, builder: (_, _) => const StageDashboardScreen()),
      GoRoute(
        path: Routes.register,
        builder: (_, s) => RegisterScreen(assignmentId: s.uri.queryParameters['a'] ?? ''),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(location: state.matchedLocation, child: child),
        routes: [
          GoRoute(path: Routes.home, pageBuilder: (_, s) => page(s, const HomeScreen())),
          GoRoute(path: Routes.import, pageBuilder: (_, s) => page(s, const ImportScreen())),
          GoRoute(path: Routes.assignments, pageBuilder: (_, s) => page(s, const AssignmentsScreen())),
          GoRoute(path: Routes.accounts, pageBuilder: (_, s) => page(s, const AccountsScreen())),
          GoRoute(path: Routes.profile, pageBuilder: (_, s) => page(s, const ProfileScreen())),
        ],
      ),
    ],
  );
});
