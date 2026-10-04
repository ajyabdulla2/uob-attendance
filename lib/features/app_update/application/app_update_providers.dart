import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../data/config_repository.dart';
import '../domain/app_update_policy.dart';

final configRepositoryProvider = Provider<ConfigRepository>(
  (ref) => ConfigRepository(ref.watch(firestoreProvider)),
);

/// Version of the installed build (from pubspec `version:`).
final installedVersionProvider = FutureProvider<AppVersion?>(
  (ref) async => AppVersion.tryParse((await PackageInfo.fromPlatform()).version),
);

final appPolicyProvider = StreamProvider<AppUpdatePolicy?>(
  (ref) => ref.watch(configRepositoryProvider).watchAppPolicy(),
);

final class AppUpdateState {
  const AppUpdateState({required this.urgency, required this.installed, this.latest, this.url, this.notes = ''});

  final UpdateUrgency urgency;
  final AppVersion installed;
  final AppVersion? latest;
  final String? url;
  final String notes;
}

/// Null when no update applies. The web panel is always current (updated by
/// `firebase deploy --only hosting`), so it is never asked to update.
final appUpdateProvider = Provider<AppUpdateState?>((ref) {
  if (kIsWeb) return null;
  final installed = ref.watch(installedVersionProvider).value;
  final policy = ref.watch(appPolicyProvider).value;
  if (installed == null || policy == null) return null;
  final urgency = policy.evaluate(installed);
  if (urgency == UpdateUrgency.none) return null;
  return AppUpdateState(
    urgency: urgency,
    installed: installed,
    latest: policy.latest,
    url: policy.downloadUrl(ios: defaultTargetPlatform == TargetPlatform.iOS),
    notes: policy.notes,
  );
});

/// «لاحقاً» hides the optional banner until the app restarts.
class UpdateBannerDismissed extends Notifier<bool> {
  @override
  bool build() => false;

  void dismiss() => state = true;
}

final updateBannerDismissedProvider = NotifierProvider<UpdateBannerDismissed, bool>(UpdateBannerDismissed.new);
