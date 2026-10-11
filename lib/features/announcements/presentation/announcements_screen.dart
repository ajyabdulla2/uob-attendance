import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/widgets/common_widgets.dart';
import '../../../l10n/l10n.dart';
import '../../auth/application/auth_providers.dart';
import '../../reports/application/report_exporter.dart';
import '../application/announcements_providers.dart';
import '../domain/announcement.dart';

/// «إعلانات القسم» (admins): the public announcements behind the
/// department's QR poster, and that poster.
///
/// Icons: only ones already in the 1.4.0 release (a Shorebird patch cannot
/// add glyphs to the trimmed icon font, see CLAUDE.md).
class AnnouncementsScreen extends ConsumerWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.annTitle),
        actions: [
          IconButton(
            key: const Key('ann.qr'),
            tooltip: l10n.annQr,
            icon: const Icon(Icons.link),
            onPressed: () => showDialog<void>(context: context, builder: (_) => const _QrDialog()),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('ann.add'),
        icon: const Icon(Icons.add),
        label: Text(l10n.annAdd),
        onPressed: () => showAnnouncementEditor(context),
      ),
      body: AsyncBody<List<Announcement>>(
        value: ref.watch(announcementsProvider),
        data: (all) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            Text(l10n.annHelp, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            if (all.isEmpty)
              Padding(padding: const EdgeInsets.all(24), child: Center(child: Text(l10n.annEmpty)))
            else
              for (final a in all) _AnnouncementCard(a),
          ],
        ),
      ),
    );
  }
}

class _AnnouncementCard extends ConsumerWidget {
  const _AnnouncementCard(this.a);

  final Announcement a;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final m = MaterialLocalizations.of(context);
    final theme = Theme.of(context);
    final when = [
      if (a.createdAt != null) m.formatMediumDate(a.createdAt!.toLocal()),
      if (a.updatedAt != null) l10n.annEdited(m.formatMediumDate(a.updatedAt!.toLocal())),
    ].join(' · ');
    return Card(
      key: Key('ann.row.${a.id}'),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 4, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(a.title, style: theme.textTheme.titleMedium)),
                IconButton(
                  key: Key('ann.edit.${a.id}'),
                  tooltip: l10n.annEdit,
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => showAnnouncementEditor(context, existing: a),
                ),
                IconButton(
                  key: Key('ann.delete.${a.id}'),
                  tooltip: l10n.delete,
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    final ok = await confirmDialog(context,
                        title: l10n.annDeleteTitle, body: l10n.annDeleteBody, confirmLabel: l10n.delete, destructive: true);
                    if (!ok || !context.mounted) return;
                    try {
                      await ref.read(announcementsRepositoryProvider).delete(a.id);
                      if (context.mounted) showSnack(context, l10n.annDeleted);
                    } on Object catch (e) {
                      if (context.mounted) showError(context, e);
                    }
                  },
                ),
              ],
            ),
            if (a.body.isNotEmpty) Text(a.body),
            if (when.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(when, style: theme.textTheme.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}

Future<void> showAnnouncementEditor(BuildContext context, {Announcement? existing}) =>
    showDialog<void>(context: context, builder: (_) => _EditorDialog(existing: existing));

class _EditorDialog extends ConsumerStatefulWidget {
  const _EditorDialog({this.existing});

  final Announcement? existing;

  @override
  ConsumerState<_EditorDialog> createState() => _EditorDialogState();
}

class _EditorDialogState extends ConsumerState<_EditorDialog> {
  late final _title = TextEditingController(text: widget.existing?.title ?? '');
  late final _body = TextEditingController(text: widget.existing?.body ?? '');
  bool _busy = false;

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    if (_title.text.trim().isEmpty) return;
    setState(() => _busy = true);
    try {
      final repo = ref.read(announcementsRepositoryProvider);
      final me = ref.read(signedInUserProvider).id;
      final existing = widget.existing;
      if (existing == null) {
        await repo.create(title: _title.text, body: _body.text, by: me);
      } else {
        await repo.update(existing.id, title: _title.text, body: _body.text, by: me);
      }
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.annSaved)));
    } on Object catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(widget.existing == null ? l10n.annAdd : l10n.annEdit),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              key: const Key('ann.title'),
              controller: _title,
              maxLength: Announcement.maxTitle,
              decoration: InputDecoration(labelText: l10n.annFieldTitle),
            ),
            TextField(
              key: const Key('ann.body'),
              controller: _body,
              maxLength: Announcement.maxBody,
              minLines: 4,
              maxLines: 10,
              decoration: InputDecoration(labelText: l10n.annFieldBody),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
        FilledButton(key: const Key('ann.save'), onPressed: _busy ? null : _save, child: Text(l10n.save)),
      ],
    );
  }
}

/// The QR for the public page, with its link and a printable poster.
class _QrDialog extends ConsumerWidget {
  const _QrDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final url = Announcement.pageUrl();
    return AlertDialog(
      title: Text(l10n.annQr),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.annQrHelp),
            const SizedBox(height: 12),
            // White behind the code in dark mode too: scanners expect it.
            Container(
              key: const Key('ann.qrImage'),
              color: Colors.white,
              padding: const EdgeInsets.all(8),
              // A fixed size: QrImageView lays out with a LayoutBuilder, which
              // cannot answer the dialog's intrinsic-size questions.
              child: SizedBox(
                width: 220,
                height: 220,
                child: QrImageView(data: url, size: 220, backgroundColor: Colors.white),
              ),
            ),
            const SizedBox(height: 8),
            SelectableText(url, textDirection: TextDirection.ltr, textAlign: TextAlign.center),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: url));
            if (context.mounted) showSnack(context, l10n.annLinkCopied);
          },
          child: Text(l10n.annCopyLink),
        ),
        FilledButton(
          key: const Key('ann.poster'),
          onPressed: () => exportQrPoster(
            context,
            ref,
            title: l10n.annPosterTitle,
            lines: [l10n.annPosterLine],
            url: url,
            fileName: 'department_announcements_qr.pdf',
          ),
          child: Text(l10n.annPoster),
        ),
      ],
    );
  }
}
