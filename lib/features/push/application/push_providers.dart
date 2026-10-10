import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/firebase/firebase_providers.dart';
import '../../../core/theme/app_settings.dart';
import '../../activity/application/activity_providers.dart';
import '../../attendance/application/attendance_providers.dart';
import '../../auth/application/auth_providers.dart';
import '../data/device_notifications.dart';
import '../data/push_client.dart';
import '../domain/unsent_reminder.dart';

/// Replaced in main.dart on Android; nothing elsewhere (web, tests).
final deviceNotificationsProvider = Provider<DeviceNotifications>((ref) => const NoDeviceNotifications());

final pushClientProvider = Provider<PushClient>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return PushClient(endpoint: AppConfig.pushEndpoint, idToken: () async => auth.currentUser?.getIdToken());
});

/// Registers this phone for the signed-in account's messages (the FCM token
/// in `presence/{email}`, read by push-worker/), once per token and account.
Future<void> registerDevice(Ref ref) async {
  final status = ref.read(authStatusProvider);
  if (status is! SignedIn) return;
  final email = status.user.id;
  try {
    final token = await ref.read(deviceNotificationsProvider).enable();
    if (token == null) return;
    await _saveToken(ref, email, token);
  } on Object catch (e) {
    debugPrint('push: $e');
  }
}

Future<void> _saveToken(Ref ref, String email, String token) async {
  final prefs = ref.read(sharedPreferencesProvider);
  final key = 'push.token.$email';
  if (prefs.getString(key) == token) return;
  await ref.read(activityRepositoryProvider).reportPushToken(email, token);
  await prefs.setString(key, token);
}

/// Before signing out: the phone stops receiving this account's messages.
Future<void> forgetDevice(Ref ref) async {
  final status = ref.read(authStatusProvider);
  if (status is! SignedIn) return;
  final email = status.user.id;
  try {
    await ref.read(activityRepositoryProvider).reportPushToken(email, null).timeout(const Duration(seconds: 5));
    await ref.read(sharedPreferencesProvider).remove('push.token.$email');
    await ref.read(deviceNotificationsProvider).forget();
  } on Object catch (e) {
    debugPrint('push: $e');
  }
}

/// Schedules (or cancels) the «not uploaded» reminder from the outbox.
Future<void> updateUnsentReminder(Ref ref, {DateTime? now}) async {
  if (!ref.read(localFirstProvider)) return;
  try {
    final at = UnsentReminder.at(await ref.read(appDatabaseProvider).oldestPendingAt(), now ?? DateTime.now());
    final device = ref.read(deviceNotificationsProvider);
    if (at == null) {
      await device.cancel(UnsentReminder.id);
    } else {
      await device.schedule(
        id: UnsentReminder.id,
        at: at,
        title: 'سجلات حضور لم تُرفع',
        body: 'على هاتفك حضور لم يصل إلى القسم منذ يوم. افتح البرنامج مع اتصال بالإنترنت.',
      );
    }
  } on Object catch (e) {
    debugPrint('push: $e');
  }
}

final pushActionsProvider = Provider<({Future<void> Function() register, Future<void> Function() forget})>(
  (ref) => (register: () => registerDevice(ref), forget: () => forgetDevice(ref)),
);

/// Keeps the saved token current when FCM rotates it.
final tokenRefreshProvider = StreamProvider.autoDispose<void>((ref) {
  final status = ref.watch(authStatusProvider);
  if (status is! SignedIn) return const Stream.empty();
  return ref.watch(deviceNotificationsProvider).tokenRefresh.asyncMap((t) async {
    try {
      await _saveToken(ref, status.user.id, t);
    } on Object catch (e) {
      debugPrint('push: $e');
    }
  });
});
