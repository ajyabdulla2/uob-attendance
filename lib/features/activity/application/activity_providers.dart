import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../../../core/theme/app_settings.dart';
import '../../app_update/application/app_update_providers.dart';
import '../../auth/application/auth_providers.dart';
import '../../users/application/users_providers.dart';
import '../data/activity_repository.dart';
import '../domain/teacher_activity.dart';

final activityRepositoryProvider = Provider<ActivityRepository>(
  (ref) => ActivityRepository(ref.watch(firestoreProvider)),
);

final presenceProvider = StreamProvider.autoDispose<Map<String, Presence>>(
  (ref) => ref.watch(activityRepositoryProvider).watchAll(),
);

/// «متابعة التدريسيين»: active teachers, least active first.
final teacherActivityProvider = Provider.autoDispose<AsyncValue<List<TeacherActivity>>>((ref) {
  final users = ref.watch(allUsersProvider);
  final presence = ref.watch(presenceProvider);
  if (users.hasError) return AsyncValue.error(users.error!, users.stackTrace ?? StackTrace.current);
  if (presence.hasError) return AsyncValue.error(presence.error!, presence.stackTrace ?? StackTrace.current);
  if (!users.hasValue || !presence.hasValue) return const AsyncValue.loading();
  return AsyncValue.data(TeacherActivity.rows(users.value!, presence.value!, DateTime.now()));
});

final lecturesByProvider = FutureProvider.autoDispose.family(
  (ref, String email) => ref.watch(activityRepositoryProvider).lecturesBy(email),
);

/// Records that the signed-in account opened the app, at most every
/// [Presence.seenEvery] per device (kept in the preferences). Best effort:
/// a failure (offline, older rules) is retried next time.
Future<void> reportSeen(Ref ref, {DateTime? now}) async {
  final status = ref.read(authStatusProvider);
  if (status is! SignedIn) return;
  final email = status.user.id;
  final prefs = ref.read(sharedPreferencesProvider);
  final key = 'presence.seenAt.$email';
  final at = now ?? DateTime.now();
  final last = prefs.getInt(key);
  if (last != null && at.difference(DateTime.fromMillisecondsSinceEpoch(last)) < Presence.seenEvery) return;
  try {
    final version = await ref.read(installedVersionProvider.future).timeout(const Duration(seconds: 5));
    await ref.read(activityRepositoryProvider).reportSeen(
          email,
          platform: kIsWeb ? 'web' : defaultTargetPlatform.name,
          appVersion: version?.toString() ?? '',
        );
    await prefs.setInt(key, at.millisecondsSinceEpoch);
  } on Object catch (e) {
    debugPrint('presence: $e');
  }
}

/// Records that the signed-in account's phone uploaded attendance.
Future<void> reportUpload(Ref ref) async {
  final status = ref.read(authStatusProvider);
  if (status is! SignedIn) return;
  try {
    await ref.read(activityRepositoryProvider).reportUpload(status.user.id);
  } on Object catch (e) {
    debugPrint('presence: $e');
  }
}

/// Calls [reportSeen] for widgets (the app shell).
final presenceReporterProvider = Provider<Future<void> Function()>((ref) => () => reportSeen(ref));
