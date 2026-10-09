import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../../../core/theme/app_settings.dart';
import '../../auth/application/auth_providers.dart';
import '../../edit_requests/application/edit_requests_providers.dart';
import '../../edit_requests/domain/edit_request.dart';
import '../data/messages_repository.dart';
import '../domain/app_message.dart';

final messagesRepositoryProvider = Provider<MessagesRepository>(
  (ref) => MessagesRepository(ref.watch(firestoreProvider)),
);

/// The latest messages meant for the signed-in user.
final myMessagesProvider = StreamProvider.autoDispose<List<AppMessage>>((ref) {
  final me = ref.watch(signedInUserProvider);
  return ref.watch(messagesRepositoryProvider).watchRecent().map((all) => [
        for (final m in all)
          if (m.isFor(me)) m,
      ]);
});

/// The user's own edit requests that were decided, newest first.
final myDecisionsProvider = Provider.autoDispose<List<EditRequest>>((ref) {
  final mine = ref.watch(myEditRequestsProvider).value ?? const <EditRequest>[];
  return [
    for (final r in mine)
      if (r.status != EditRequestStatus.pending) r,
  ]..sort((a, b) => (b.decidedAt ?? DateTime(0)).compareTo(a.decidedAt ?? DateTime(0)));
});

/// Pending edit requests in the stages the user manages.
final pendingRequestsCountProvider = Provider.autoDispose<int>((ref) {
  var n = 0;
  for (final s in ref.watch(permissionsProvider).manageableStages) {
    n += ref.watch(pendingEditRequestsProvider(s.id)).value?.length ?? 0;
  }
  return n;
});

/// When the user last opened «الإشعارات» (kept on the device).
class NotificationsSeen extends Notifier<DateTime?> {
  static const key = 'notifications.seenAt';

  @override
  DateTime? build() {
    final ms = ref.read(sharedPreferencesProvider).getInt(key);
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }

  void markSeen([DateTime? at]) {
    final now = at ?? DateTime.now();
    ref.read(sharedPreferencesProvider).setInt(key, now.millisecondsSinceEpoch);
    state = now;
  }
}

final notificationsSeenProvider = NotifierProvider<NotificationsSeen, DateTime?>(NotificationsSeen.new);

/// The home badge: new messages and decisions since the screen was last
/// opened, plus pending requests the user can act on.
final unreadNotificationsProvider = Provider.autoDispose<int>((ref) {
  final seen = ref.watch(notificationsSeenProvider);
  final me = ref.watch(signedInUserProvider).id;
  bool isNew(DateTime? at) => at != null && (seen == null || at.isAfter(seen));
  final messages = ref.watch(myMessagesProvider).value ?? const <AppMessage>[];
  return messages.where((m) => m.createdBy != me && isNew(m.createdAt)).length +
      ref.watch(myDecisionsProvider).where((r) => isNew(r.decidedAt)).length +
      ref.watch(pendingRequestsCountProvider);
});
