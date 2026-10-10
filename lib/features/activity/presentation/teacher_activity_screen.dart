import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/common_widgets.dart';
import '../../../l10n/l10n.dart';
import '../../assignments/domain/assignment.dart';
import '../../auth/application/auth_providers.dart';
import '../../auth/domain/app_user.dart';
import '../../notifications/application/notifications_providers.dart';
import '../../notifications/domain/app_message.dart';
import '../application/activity_providers.dart';
import '../domain/teacher_activity.dart';

/// «متابعة التدريسيين» (super admin): when each teacher last opened the app
/// and last uploaded attendance, with a personal in-app message to one
/// teacher or to everyone in the current filter.
class TeacherActivityScreen extends ConsumerStatefulWidget {
  const TeacherActivityScreen({super.key});

  @override
  ConsumerState<TeacherActivityScreen> createState() => _TeacherActivityScreenState();
}

class _TeacherActivityScreenState extends ConsumerState<TeacherActivityScreen> {
  /// null = all.
  ActivityLevel? _filter;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final rows = ref.watch(teacherActivityProvider);
    final shown = [
      for (final r in rows.value ?? const <TeacherActivity>[])
        if (_filter == null || r.level == _filter) r,
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.activityTitle),
        actions: [
          if (shown.isNotEmpty)
            IconButton(
              key: const Key('activity.messageAll'),
              tooltip: l10n.activityMessageShown(shown.length),
              icon: const Icon(Icons.send),
              onPressed: () => showPersonalMessageDialog(context, [for (final r in shown) r.user]),
            ),
        ],
      ),
      body: AsyncBody<List<TeacherActivity>>(
        value: rows,
        data: (all) {
          int count(ActivityLevel? l) => l == null ? all.length : all.where((r) => r.level == l).length;
          Widget chip(ActivityLevel? l, String label) => ChoiceChip(
                key: Key('activity.filter.${l?.name ?? 'all'}'),
                label: Text('$label ${count(l)}'),
                selected: _filter == l,
                onSelected: (_) => setState(() => _filter = l),
              );
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(l10n.activityHelp, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  chip(null, l10n.activityAll),
                  chip(ActivityLevel.today, l10n.activityToday),
                  chip(ActivityLevel.recent, l10n.activityRecent),
                  chip(ActivityLevel.idle, l10n.activityIdle),
                  chip(ActivityLevel.never, l10n.activityNever),
                ],
              ),
              const SizedBox(height: 8),
              if (shown.isEmpty)
                Padding(padding: const EdgeInsets.all(24), child: Center(child: Text(l10n.activityEmpty)))
              else
                for (final r in shown) _ActivityTile(row: r),
            ],
          );
        },
      ),
    );
  }
}

String agoText(AppLocalizations l10n, DateTime at, DateTime now) {
  final a = agoOf(at, now);
  return switch (a.unit) {
    AgoUnit.justNow => l10n.agoJustNow,
    AgoUnit.minutes => l10n.agoMinutes(a.n),
    AgoUnit.hours => l10n.agoHours(a.n),
    AgoUnit.days => l10n.agoDays(a.n),
  };
}

String _exact(BuildContext context, DateTime at) {
  final m = MaterialLocalizations.of(context);
  final local = at.toLocal();
  return '${m.formatMediumDate(local)} ${m.formatTimeOfDay(TimeOfDay.fromDateTime(local))}';
}

({IconData icon, Color color}) _look(BuildContext context, ActivityLevel level) {
  final scheme = Theme.of(context).colorScheme;
  return switch (level) {
    ActivityLevel.today => (icon: Icons.check_circle, color: Colors.green.shade600),
    ActivityLevel.recent => (icon: Icons.schedule, color: scheme.primary),
    ActivityLevel.idle => (icon: Icons.warning_amber, color: Colors.orange.shade700),
    ActivityLevel.never => (icon: Icons.person_off_outlined, color: scheme.error),
  };
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.row});

  final TeacherActivity row;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final now = DateTime.now();
    final look = _look(context, row.level);
    final p = row.presence;
    final seen = row.lastSeenAt;
    final upload = row.lastUploadAt;
    return Card(
      child: ListTile(
        key: Key('activity.row.${row.user.id}'),
        leading: Icon(look.icon, color: look.color, size: 32),
        title: Text(row.user.name.isEmpty ? row.user.id : row.user.name),
        subtitle: Text([
          seen == null ? l10n.activityNeverSeen : l10n.activityLastSeen(agoText(l10n, seen, now)),
          upload == null ? l10n.activityNoUpload : l10n.activityLastUpload(agoText(l10n, upload, now)),
          if (p != null && p.platform.isNotEmpty) bidiIsolate('${p.platform} ${p.appVersion}'.trim()),
        ].join('\n')),
        isThreeLine: true,
        trailing: const Icon(Icons.chevron_right),
        onTap: () => showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          showDragHandle: true,
          builder: (_) => _ActivityDetails(row: row),
        ),
      ),
    );
  }
}

class _ActivityDetails extends ConsumerWidget {
  const _ActivityDetails({required this.row});

  final TeacherActivity row;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final p = row.presence;
    final lectures = ref.watch(lecturesByProvider(row.user.id));
    Widget line(IconData icon, String text) => ListTile(dense: true, leading: Icon(icon), title: Text(text));
    return SafeArea(
      child: ListView(
        key: const Key('activity.details'),
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Text(row.user.name, style: theme.textTheme.titleLarge),
          Text(bidiIsolate(row.user.id), style: theme.textTheme.bodySmall),
          line(Icons.schedule,
              p?.lastSeenAt == null ? l10n.activityNeverSeen : l10n.activityLastSeen(_exact(context, p!.lastSeenAt!))),
          line(Icons.cloud_upload_outlined,
              p?.lastUploadAt == null ? l10n.activityNoUpload : l10n.activityLastUpload(_exact(context, p!.lastUploadAt!))),
          if (p != null && p.platform.isNotEmpty)
            line(p.platform == 'web' ? Icons.computer : Icons.phone_android,
                l10n.activityDevice(bidiIsolate('${p.platform} ${p.appVersion}'.trim()))),
          const Divider(),
          lectures.when(
            loading: () => const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator())),
            error: (e, _) => Text(l10n.activityLecturesError),
            data: (l) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.activityLectures(l.total), key: const Key('activity.lectureCount'), style: theme.textTheme.titleSmall),
                for (final s in l.latest)
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.event_note),
                    title: Text([
                      bidiIsolate(s.courseId.split('_').first),
                      s.type == AssignmentType.theory ? l10n.theoryLabel : l10n.groupLabel(s.target),
                      l10n.stageId(s.stageId),
                    ].join(' · ')),
                    subtitle: Text(
                        '${MaterialLocalizations.of(context).formatMediumDate(s.date)} · ${l10n.activityLectureNo(s.lectureNo)}'),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            key: const Key('activity.message'),
            icon: const Icon(Icons.send),
            label: Text(l10n.activitySendMessage),
            onPressed: () => showPersonalMessageDialog(context, [row.user]),
          ),
        ],
      ),
    );
  }
}

/// «إرسال إشعار» to [to]: one copy in each inbox, shown in their
/// «الإشعارات» (with the badge on the home screen).
Future<void> showPersonalMessageDialog(BuildContext context, List<AppUser> to) =>
    showDialog<void>(context: context, builder: (_) => _PersonalMessageDialog(to: to));

class _PersonalMessageDialog extends ConsumerStatefulWidget {
  const _PersonalMessageDialog({required this.to});

  final List<AppUser> to;

  @override
  ConsumerState<_PersonalMessageDialog> createState() => _PersonalMessageDialogState();
}

class _PersonalMessageDialogState extends ConsumerState<_PersonalMessageDialog> {
  final _title = TextEditingController();
  final _body = TextEditingController();
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
      await ref.read(messagesRepositoryProvider).sendPersonal(
            AppMessage(
              id: '',
              title: _title.text,
              body: _body.text,
              audience: MessageAudience.person,
              createdBy: ref.read(signedInUserProvider).id,
            ),
            [for (final u in widget.to) u.id],
          );
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.activitySent(widget.to.length))));
    } on Object catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final names = widget.to.length == 1
        ? widget.to.single.name
        : l10n.activityRecipients(widget.to.length);
    return AlertDialog(
      title: Text(l10n.activitySendMessage),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.activityTo(names)),
            TextField(
              key: const Key('activity.msgTitle'),
              controller: _title,
              maxLength: 120,
              decoration: InputDecoration(labelText: l10n.notifMessageTitle),
            ),
            TextField(
              key: const Key('activity.msgBody'),
              controller: _body,
              maxLength: 2000,
              minLines: 3,
              maxLines: 8,
              decoration: InputDecoration(labelText: l10n.notifMessageBody),
            ),
            Text(l10n.activityInAppOnly, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
        FilledButton(
          key: const Key('activity.send'),
          onPressed: _busy ? null : _send,
          child: Text(l10n.notifSend),
        ),
      ],
    );
  }
}
