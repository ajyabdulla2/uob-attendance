import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/firebase/doc_ids.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../l10n/l10n.dart';
import '../../assignments/application/assignments_providers.dart';
import '../../assignments/domain/assignment.dart';
import '../application/attendance_providers.dart';
import '../data/attendance_store.dart';

/// Keeps the phone in sync while the signed-in area is open: at start,
/// every [every], when the app returns to the foreground, and — through a
/// live listener on the teacher's assignments — as soon as the department
/// assigns or removes a class.
class SyncLifecycle extends ConsumerStatefulWidget {
  const SyncLifecycle({super.key, required this.child});

  final Widget child;

  static const every = Duration(minutes: 2);

  @override
  ConsumerState<SyncLifecycle> createState() => _SyncLifecycleState();
}

class _SyncLifecycleState extends ConsumerState<SyncLifecycle> with WidgetsBindingObserver {
  Timer? _timer;
  late final bool _enabled = ref.read(localFirstProvider);

  @override
  void initState() {
    super.initState();
    if (!_enabled) return;
    WidgetsBinding.instance.addObserver(this);
    _timer = Timer.periodic(SyncLifecycle.every, (_) => _sync());
    // Not during this build: syncing updates providers.
    Future.microtask(_sync);
  }

  void _sync({bool forceDownload = false}) {
    if (mounted) unawaited(ref.read(syncControllerProvider.notifier).sync(forceDownload: forceDownload));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _sync();
  }

  @override
  void dispose() {
    _timer?.cancel();
    if (_enabled) WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_enabled) {
      ref.listen<AsyncValue<List<Assignment>>>(myAssignmentsProvider, (_, next) {
        final online = next.value;
        final local = ref.read(localClassesProvider).value;
        if (online == null || local == null) return;
        final changed = {for (final a in online) a.id}.difference({for (final a in local) a.id}).isNotEmpty ||
            {for (final a in local) a.id}.difference({for (final a in online) a.id}).isNotEmpty;
        if (changed) _sync(forceDownload: true);
      });
    }
    return widget.child;
  }
}

/// Home card: what waits on the phone, connection problems, refused saves
/// and «مزامنة الآن».
class SyncStatusCard extends ConsumerWidget {
  const SyncStatusCard({super.key});

  static const staleAfter = Duration(hours: 24);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final pending = ref.watch(pendingUploadsProvider).value ?? 0;
    final rejected = ref.watch(rejectedUploadsProvider).value ?? const <OutboxEntry>[];
    final oldest = ref.watch(oldestPendingProvider).value;
    final sync = ref.watch(syncControllerProvider);
    final stale = pending > 0 && oldest != null && DateTime.now().difference(oldest) > staleAfter;

    final lines = <Widget>[
      Text(switch (sync) {
        SyncState(running: true) => l10n.syncRunning,
        SyncState(offline: true) => l10n.syncOffline,
        SyncState(:final problem?) => l10n.syncProblem(problem),
        SyncState(:final lastUploadAt?) => l10n.syncLast(_time(context, lastUploadAt)),
        _ => l10n.syncNever,
      }),
      if (stale)
        Text(l10n.syncStale, key: const Key('sync.stale'), style: TextStyle(color: theme.colorScheme.error)),
    ];

    return Card(
      key: const Key('sync.card'),
      color: pending > 0 ? theme.colorScheme.secondaryContainer : null,
      child: Column(
        children: [
          ListTile(
            leading: sync.running
                ? const SizedBox.square(dimension: 24, child: CircularProgressIndicator(strokeWidth: 3))
                : Icon(switch (sync) {
                    SyncState(offline: true) => Icons.cloud_off,
                    _ when pending > 0 => Icons.cloud_upload_outlined,
                    _ => Icons.cloud_done_outlined,
                  }),
            title: Text(pending > 0 ? l10n.pendingUploads(pending) : l10n.syncAllUploaded),
            subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: lines),
            trailing: TextButton(
              key: const Key('sync.now'),
              onPressed: sync.running
                  ? null
                  : () => ref.read(syncControllerProvider.notifier).sync(forceDownload: true),
              child: Text(l10n.syncNow),
            ),
          ),
          if (rejected.isNotEmpty)
            ListTile(
              key: const Key('sync.rejected'),
              leading: Icon(Icons.report_outlined, color: theme.colorScheme.error),
              title: Text(l10n.syncRejected(rejected.length)),
              trailing: const Icon(Icons.chevron_right), // mirrors in RTL
              onTap: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                showDragHandle: true,
                builder: (_) => const RejectedUploadsSheet(),
              ),
            ),
        ],
      ),
    );
  }

  static String _time(BuildContext context, DateTime at) {
    final local = at.toLocal();
    final m = MaterialLocalizations.of(context);
    return '${m.formatShortDate(local)} ${m.formatTimeOfDay(TimeOfDay.fromDateTime(local))}';
  }
}

/// Saves the server refused: retry them all, or give one up.
class RejectedUploadsSheet extends ConsumerWidget {
  const RejectedUploadsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final rejected = ref.watch(rejectedUploadsProvider).value ?? const <OutboxEntry>[];
    if (rejected.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Text(l10n.syncAllUploaded, textAlign: TextAlign.center),
      );
    }
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(l10n.syncRejected(rejected.length), style: Theme.of(context).textTheme.titleMedium),
            subtitle: Text(l10n.syncRejectedBody),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final e in rejected)
                  ListTile(
                    leading: const Icon(Icons.event_busy),
                    title: Text(_lectureLabel(context, AttendanceStore.sessionOfBatch(e.batchId))),
                    subtitle: Text(e.lastError ?? '', textDirection: TextDirection.ltr),
                    trailing: TextButton(
                      onPressed: () => _discard(context, ref, e.batchId),
                      child: Text(l10n.syncDiscard),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton.icon(
              key: const Key('sync.retryRejected'),
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retry),
              onPressed: () async {
                await ref.read(appDatabaseProvider).retryRejected();
                if (context.mounted) Navigator.pop(context);
                unawaited(ref.read(syncControllerProvider.notifier).sync());
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _discard(BuildContext context, WidgetRef ref, String batchId) async {
    final l10n = context.l10n;
    final ok = await confirmDialog(
      context,
      title: l10n.syncDiscard,
      body: l10n.syncDiscardBody,
      confirmLabel: l10n.syncDiscard,
      destructive: true,
    );
    if (ok) await ref.read(attendanceStoreProvider).discardRejected(batchId);
  }

  /// «CS101_1-morning · 12/10/2026 · المحاضرة 1» from a session ID.
  static String _lectureLabel(BuildContext context, String sessionId) {
    final parts = sessionId.split('__');
    if (parts.length != 5) return bidiIsolate(sessionId);
    final date = DocIds.parseDateKey(parts[3]);
    return [
      bidiIsolate(parts[0]),
      if (date != null) MaterialLocalizations.of(context).formatShortDate(date),
      context.l10n.recordLectureN(int.tryParse(parts[4]) ?? 1),
    ].join(' · ');
  }
}
