import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/domain/stage_ref.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../l10n/l10n.dart';
import '../../assignments/domain/assignment.dart';
import '../../attendance/application/attendance_providers.dart';
import '../../auth/application/auth_providers.dart';
import '../../edit_requests/application/edit_requests_providers.dart';
import '../../edit_requests/domain/edit_request.dart';
import '../../stats/application/stats_providers.dart';
import '../../stats/domain/student_course_stat.dart';
import '../application/notifications_providers.dart';
import '../domain/app_message.dart';

/// الإشعارات (inside the app — push needs a server, not on Spark):
/// messages from the department, pending edit requests (managers), the
/// user's own decided requests, and students who reached the alert level.
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  /// What counted as new when the screen opened (kept while it is open).
  DateTime? _seenBefore;

  @override
  void initState() {
    super.initState();
    _seenBefore = ref.read(notificationsSeenProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) => ref.read(notificationsSeenProvider.notifier).markSeen());
  }

  bool _isNew(DateTime? at) => at != null && (_seenBefore == null || at.isAfter(_seenBefore!));

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final perms = ref.watch(permissionsProvider);
    final canWrite = perms.isAdmin || perms.isStageManager;
    final stages = perms.manageableStages;
    final decisions = ref.watch(myDecisionsProvider);
    final pending = ref.watch(pendingRequestsCountProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.notifTitle)),
      floatingActionButton: canWrite
          ? FloatingActionButton.extended(
              key: const Key('notif.compose'),
              onPressed: () => showDialog<void>(context: context, builder: (_) => const _ComposeDialog()),
              icon: const Icon(Icons.send),
              label: Text(l10n.notifCompose),
            )
          : null,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: [
          _Section(title: l10n.notifMessages),
          AsyncBody<List<AppMessage>>(
            value: ref.watch(myMessagesProvider),
            data: (messages) => messages.isEmpty
                ? _Empty(text: l10n.notifNoMessages)
                : Column(children: [for (final m in messages) _MessageCard(message: m, isNew: _isNew(m.createdAt))]),
          ),
          if (stages.isNotEmpty) ...[
            _Section(title: l10n.notifRequests),
            // One line per stage with requests, opening that stage directly.
            Card(
              child: Column(
                children: [
                  if (pending == 0)
                    ListTile(
                      key: const Key('notif.requests'),
                      leading: const Icon(Icons.edit_calendar),
                      title: Text(l10n.dashRequests(0)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push(Routes.editRequests),
                    ),
                  for (final s in stages)
                    if (ref.watch(pendingEditRequestsProvider(s.id)).value?.length ?? 0 case final n when n > 0)
                      ListTile(
                        key: Key('notif.requests.${s.id}'),
                        leading: Icon(Icons.edit_calendar, color: Theme.of(context).colorScheme.error),
                        title: Text(l10n.stage(s)),
                        subtitle: Text(l10n.dashRequests(n)),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push(Routes.editRequestsFor(s.id)),
                      ),
                ],
              ),
            ),
          ],
          if (decisions.isNotEmpty) ...[
            _Section(title: l10n.notifDecisions),
            Card(child: Column(children: [for (final r in decisions.take(20)) _DecisionTile(request: r, isNew: _isNew(r.decidedAt))])),
          ],
          _Section(title: l10n.notifAlerts),
          if (ref.watch(localFirstProvider)) const _MyClassesAlerts(),
          for (final s in stages) _StageAlerts(stage: s),
          if (!ref.watch(localFirstProvider) && stages.isEmpty) _Empty(text: l10n.notifAlertsOnPhone),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 6),
        child: Text(title, style: Theme.of(context).textTheme.titleMedium),
      );
}

class _Empty extends StatelessWidget {
  const _Empty({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(leading: const Icon(Icons.inbox), title: Text(text, style: Theme.of(context).textTheme.bodyMedium)),
      );
}

class _MessageCard extends ConsumerWidget {
  const _MessageCard({required this.message, required this.isNew});

  final AppMessage message;
  final bool isNew;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final m = MaterialLocalizations.of(context);
    final at = message.createdAt?.toLocal();
    final me = ref.watch(signedInUserProvider);
    final canDelete = message.createdBy == me.id ||
        ref.watch(permissionsProvider).isAdmin ||
        (message.audience == MessageAudience.person && message.to == me.id);
    return Card(
      key: Key('notif.message.${message.id}'),
      color: isNew ? theme.colorScheme.secondaryContainer : null,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (isNew) ...[
                  Badge(label: Text(l10n.notifNew)),
                  const SizedBox(width: 8),
                ],
                Expanded(child: Text(message.title, style: theme.textTheme.titleSmall)),
                if (canDelete)
                  IconButton(
                    tooltip: l10n.delete,
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () async {
                      if (await confirmDialog(context, title: l10n.delete, body: message.title, destructive: true)) {
                        try {
                          await ref.read(messagesRepositoryProvider).delete(message);
                        } on Object catch (e) {
                          if (context.mounted) showError(context, e);
                        }
                      }
                    },
                  ),
              ],
            ),
            if (message.body.isNotEmpty) Text(message.body),
            const SizedBox(height: 4),
            Text(
              [
                if (at != null) '${m.formatMediumDate(at)} ${m.formatTimeOfDay(TimeOfDay.fromDateTime(at))}',
                _audience(l10n, message),
                bidiIsolate(message.createdBy),
              ].join(' · '),
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  static String _audience(AppLocalizations l10n, AppMessage m) => switch (m.audience) {
        MessageAudience.all => l10n.notifToAll,
        MessageAudience.teachers => l10n.notifToTeachers,
        MessageAudience.stageManagers => l10n.notifToStageManagers,
        MessageAudience.stage => l10n.stageId(m.stageId ?? ''),
        MessageAudience.person => l10n.notifToMe,
      };
}

class _DecisionTile extends StatelessWidget {
  const _DecisionTile({required this.request, required this.isNew});

  final EditRequest request;
  final bool isNew;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = StatusPalette.of(context);
    final approved = request.status == EditRequestStatus.approved;
    final p = EditRequest.parseSession(request.sessionId);
    return ListTile(
      key: Key('notif.decision.${request.id}'),
      tileColor: isNew ? Theme.of(context).colorScheme.secondaryContainer : null,
      leading: Icon(approved ? Icons.check_circle : Icons.cancel,
          color: approved ? palette.forStatus(request.requestedStatus) : Theme.of(context).colorScheme.error),
      title: Text(approved ? l10n.notifApproved : l10n.notifRejected),
      subtitle: Text([
        bidiIsolate(request.studentId),
        l10n.attendance(request.requestedStatus),
        if (p != null) '${bidiIsolate(p.courseId)} · ${p.dateKey} · ${l10n.recordLectureN(p.lectureNo)}',
        if (request.decisionNote.isNotEmpty) request.decisionNote,
      ].join(' · ')),
    );
  }
}

/// Teachers (on the phone): students of their classes at alert level or
/// above — from the data the register already downloaded, no extra reads.
class _MyClassesAlerts extends ConsumerWidget {
  const _MyClassesAlerts();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final classes = ref.watch(localClassesProvider).value ?? const <Assignment>[];
    final rows = <Widget>[];
    for (final a in classes) {
      final standings = ref.watch(classStandingsProvider(a.id)).value ?? const {};
      final names = {for (final s in ref.watch(classStudentsProvider(a.id)).value ?? const []) s.id: s.fullName};
      final hits = standings.entries.where((e) => e.value.level != WarningLevel.none).toList()
        ..sort((x, y) => y.value.percent.compareTo(x.value.percent));
      for (final e in hits) {
        final color = StatusPalette.of(context).forLevel(e.value.level);
        rows.add(ListTile(
          key: Key('notif.alert.${a.id}.${e.key}'),
          leading: Icon(StatusPalette.iconForLevel(e.value.level), color: color),
          title: Text(names[e.key] ?? e.key),
          subtitle: Text('${a.courseName.isEmpty ? a.courseId : a.courseName} · ${l10n.classLabel(a)}'),
          trailing: Text('${e.value.percent.toStringAsFixed(1)}%', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          onTap: () => context.push(Routes.studentFor(a.id, e.key)),
        ));
      }
    }
    if (rows.isEmpty) return _Empty(text: l10n.notifNoAlerts);
    return Card(child: Column(children: rows));
  }
}

/// Stage managers and admins: per stage, loaded only when opened (it reads
/// the stage's statistics).
class _StageAlerts extends StatelessWidget {
  const _StageAlerts({required this.stage});

  final StageRef stage;

  @override
  Widget build(BuildContext context) => Card(
        child: ExpansionTile(
          key: Key('notif.stage.${stage.id}'),
          leading: const Icon(Icons.warning_amber),
          title: Text(context.l10n.notifStageAlerts(context.l10n.stage(stage))),
          children: [_StageAlertsList(stageId: stage.id)],
        ),
      );
}

class _StageAlertsList extends ConsumerWidget {
  const _StageAlertsList({required this.stageId});

  final String stageId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return AsyncBody(
      value: ref.watch(stageStandingsProvider(stageId)),
      data: (standings) {
        final hits = standings.where((s) => s.level != WarningLevel.none).toList();
        if (hits.isEmpty) return ListTile(title: Text(l10n.notifNoAlerts));
        return Column(
          children: [
            for (final s in hits.take(50))
              ListTile(
                dense: true,
                leading: Icon(StatusPalette.iconForLevel(s.level), color: StatusPalette.of(context).forLevel(s.level)),
                title: Text(s.student.fullName),
                subtitle: Text(s.course.name),
                trailing: Text('${s.summary.percent.toStringAsFixed(1)}%'),
              ),
            ListTile(
              title: Text(l10n.notifOpenWarnings(hits.length)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(Routes.warnings),
            ),
          ],
        );
      },
    );
  }
}

/// «رسالة جديدة»: admins to everyone / teachers / stage managers / a stage;
/// a stage manager to a stage they manage.
class _ComposeDialog extends ConsumerStatefulWidget {
  const _ComposeDialog();

  @override
  ConsumerState<_ComposeDialog> createState() => _ComposeDialogState();
}

class _ComposeDialogState extends ConsumerState<_ComposeDialog> {
  final _title = TextEditingController();
  final _body = TextEditingController();
  late MessageAudience _audience =
      ref.read(permissionsProvider).isAdmin ? MessageAudience.all : MessageAudience.stage;
  late StageRef? _stage = ref.read(permissionsProvider).manageableStages.firstOrNull;
  bool _busy = false;

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final l10n = context.l10n;
    if (_title.text.trim().isEmpty) return;
    setState(() => _busy = true);
    try {
      await ref.read(messagesRepositoryProvider).send(AppMessage(
            id: '',
            title: _title.text,
            body: _body.text,
            audience: _audience,
            stageId: _audience == MessageAudience.stage ? _stage?.id : null,
            createdBy: ref.read(signedInUserProvider).id,
          ));
      if (!mounted) return;
      Navigator.pop(context);
      showSnack(context, l10n.notifSent);
    } on Object catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final perms = ref.watch(permissionsProvider);
    final audiences = perms.isAdmin ? MessageAudience.broadcast : const [MessageAudience.stage];
    return AlertDialog(
      title: Text(l10n.notifCompose),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<MessageAudience>(
              key: const Key('notif.audience'),
              initialValue: _audience,
              isExpanded: true,
              decoration: InputDecoration(labelText: l10n.notifAudience),
              items: [
                for (final a in audiences)
                  DropdownMenuItem(
                    value: a,
                    child: Text(switch (a) {
                      MessageAudience.all => l10n.notifToAll,
                      MessageAudience.teachers => l10n.notifToTeachers,
                      MessageAudience.stageManagers => l10n.notifToStageManagers,
                      MessageAudience.stage => l10n.notifToStage,
                      MessageAudience.person => l10n.notifToMe,
                    }),
                  ),
              ],
              onChanged: (a) => setState(() => _audience = a ?? _audience),
            ),
            if (_audience == MessageAudience.stage)
              DropdownButtonFormField<StageRef>(
                key: const Key('notif.stage'),
                initialValue: _stage,
                isExpanded: true,
                decoration: InputDecoration(labelText: l10n.fixStage),
                items: [for (final s in perms.manageableStages) DropdownMenuItem(value: s, child: Text(l10n.stage(s)))],
                onChanged: (s) => setState(() => _stage = s),
              ),
            TextField(
              key: const Key('notif.title'),
              controller: _title,
              maxLength: 120,
              decoration: InputDecoration(labelText: l10n.notifMessageTitle),
            ),
            TextField(
              key: const Key('notif.body'),
              controller: _body,
              maxLength: 2000,
              minLines: 3,
              maxLines: 8,
              decoration: InputDecoration(labelText: l10n.notifMessageBody),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
        FilledButton(
          key: const Key('notif.send'),
          onPressed: _busy ? null : _send,
          child: Text(l10n.notifSend),
        ),
      ],
    );
  }
}
