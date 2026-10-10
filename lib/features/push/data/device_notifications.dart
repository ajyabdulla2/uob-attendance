import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// The phone's notification services: the FCM device token (for messages
/// from the super admin, sent by push-worker/) and local notifications.
/// [NoDeviceNotifications] on the web and in tests.
abstract class DeviceNotifications {
  /// Asks for the permission (Android 13+) and returns the FCM token, or
  /// null when notifications are off or unavailable.
  Future<String?> enable();

  /// New tokens (FCM rotates them now and then).
  Stream<String> get tokenRefresh;

  /// A notification was tapped (also the one that opened the app).
  Stream<void> get opened;

  Future<void> schedule({required int id, required DateTime at, required String title, required String body});

  Future<void> cancel(int id);

  /// Signing out: this phone stops receiving the account's messages.
  Future<void> forget();
}

class NoDeviceNotifications implements DeviceNotifications {
  const NoDeviceNotifications();

  @override
  Future<String?> enable() async => null;

  @override
  Stream<String> get tokenRefresh => const Stream.empty();

  @override
  Stream<void> get opened => const Stream.empty();

  @override
  Future<void> schedule({required int id, required DateTime at, required String title, required String body}) async {}

  @override
  Future<void> cancel(int id) async {}

  @override
  Future<void> forget() async {}
}

/// Android: firebase_messaging + flutter_local_notifications.
class AndroidDeviceNotifications implements DeviceNotifications {
  AndroidDeviceNotifications();

  /// Also named in AndroidManifest.xml (default channel of FCM messages)
  /// and in push-worker/src/index.js.
  static const channelId = 'department';

  final _local = FlutterLocalNotificationsPlugin();
  final _opened = StreamController<void>.broadcast();
  Future<void>? _ready;

  Future<void> _init() => _ready ??= () async {
        tzdata.initializeTimeZones();
        await _local.initialize(
          settings: const InitializationSettings(android: AndroidInitializationSettings('ic_notification')),
          onDidReceiveNotificationResponse: (_) => _opened.add(null),
        );
        await _local
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(const AndroidNotificationChannel(
              channelId,
              'إشعارات القسم',
              description: 'رسائل الإدارة وتذكير السجلات غير المرفوعة',
              importance: Importance.high,
            ));
        // FCM messages: the system shows them while the app is closed; in
        // the foreground we show them ourselves.
        FirebaseMessaging.onMessage.listen((m) {
          final n = m.notification;
          if (n != null) unawaited(_show(m.hashCode, n.title ?? '', n.body ?? ''));
        });
        FirebaseMessaging.onMessageOpenedApp.listen((_) => _opened.add(null));
        final initial = await FirebaseMessaging.instance.getInitialMessage();
        if (initial != null) scheduleMicrotask(() => _opened.add(null));
        final launch = await _local.getNotificationAppLaunchDetails();
        if (launch?.didNotificationLaunchApp ?? false) scheduleMicrotask(() => _opened.add(null));
      }();

  NotificationDetails get _details => const NotificationDetails(
        android: AndroidNotificationDetails(channelId, 'إشعارات القسم',
            importance: Importance.high, priority: Priority.high, icon: 'ic_notification'),
      );

  Future<void> _show(int id, String title, String body) =>
      _local.show(id: id, title: title, body: body, notificationDetails: _details);

  @override
  Future<String?> enable() async {
    await _init();
    final settings = await FirebaseMessaging.instance.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.denied) return null;
    return FirebaseMessaging.instance.getToken();
  }

  @override
  Stream<String> get tokenRefresh => FirebaseMessaging.instance.onTokenRefresh;

  @override
  Stream<void> get opened {
    unawaited(_init().catchError((Object e) => debugPrint('push: $e')));
    return _opened.stream;
  }

  @override
  Future<void> schedule({required int id, required DateTime at, required String title, required String body}) async {
    await _init();
    await _local.zonedSchedule(
      id: id,
      scheduledDate: tz.TZDateTime.from(at.toUtc(), tz.UTC),
      notificationDetails: _details,
      // No exact-alarm permission: a few minutes late is fine.
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      title: title,
      body: body,
    );
  }

  @override
  Future<void> cancel(int id) async {
    await _init();
    await _local.cancel(id: id);
  }

  @override
  Future<void> forget() async {
    try {
      await FirebaseMessaging.instance.deleteToken();
    } on Object catch (e) {
      debugPrint('push: $e');
    }
  }
}
