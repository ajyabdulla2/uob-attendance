
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/collections.dart';
import '../../../core/firebase/doc_ids.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../l10n/l10n.dart';
import '../../auth/application/auth_providers.dart';
import '../application/backup_providers.dart';
import '../domain/backup_file.dart';
import '../domain/restore_plan.dart';

/// النسخ الاحتياطي (admins): an encrypted `.uobk` file of the whole
/// department, saved wherever the admin chooses; the super admin can restore
/// one (twice confirmed).
class BackupScreen extends ConsumerWidget {
  const BackupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final perms = ref.watch(permissionsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.backupTitle)),
      body: !perms.canBackup
          ? Center(child: MessageView(icon: Icons.lock_outline, title: l10n.backupAdminsOnly))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const _LastBackupCard(),
                const SizedBox(height: 12),
                const _CreateCard(),
                if (perms.canRestore) ...[
                  const SizedBox(height: 12),
                  const _RestoreCard(),
                ],
              ],
            ),
    );
  }
}

class _LastBackupCard extends ConsumerWidget {
  const _LastBackupCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final m = MaterialLocalizations.of(context);
    final last = ref.watch(lastBackupProvider).value;
    final at = last?.at;
    return Card(
      child: ListTile(
        key: const Key('backup.last'),
        leading: const Icon(Icons.history),
        title: Text(at == null
            ? l10n.backupNever
            : l10n.backupLast(m.formatMediumDate(at.toLocal()), m.formatTimeOfDay(TimeOfDay.fromDateTime(at.toLocal())))),
        subtitle: last == null ? null : Text(l10n.backupLastDetail(last.documents, last.by)),
      ),
    );
  }
}

class _CreateCard extends ConsumerStatefulWidget {
  const _CreateCard();

  @override
  ConsumerState<_CreateCard> createState() => _CreateCardState();
}

class _CreateCardState extends ConsumerState<_CreateCard> {
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  Map<String, int>? _estimate;
  bool _withRecords = true;
  bool _busy = false;
  String? _step;

  static const _recordsByDefaultBelow = 30000;

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _count() async {
    setState(() => _busy = true);
    try {
      final e = await ref.read(backupRepositoryProvider).estimate();
      setState(() {
        _estimate = e;
        _withRecords = (e[Col.records] ?? 0) <= _recordsByDefaultBelow;
      });
    } on Object catch (e) {
      if (mounted) showSnack(context, context.l10n.errorGeneric('$e'));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _create() async {
    final l10n = context.l10n;
    if (_password.text.length < 8) return showSnack(context, l10n.backupPasswordShort);
    if (_password.text != _confirm.text) return showSnack(context, l10n.backupPasswordMismatch);
    final actor = ref.read(signedInUserProvider).id;
    final repo = ref.read(backupRepositoryProvider);
    setState(() => _busy = true);
    try {
      final data = await repo.collect(
        actor: actor,
        includeRecords: _withRecords,
        onStep: (c) => setState(() => _step = l10n.backupReading(l10n.backupCollection(c))),
      );
      setState(() => _step = l10n.backupEncrypting);
      final bytes = await BackupFile.encrypt(data, _password.text);
      final now = DateTime.now();
      final stamp = '${DocIds.dateKey(now)}-${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
      final saved = await FilePicker.saveFile(
        fileName: 'uob-attendance-backup-$stamp.${BackupFile.extension}',
        bytes: bytes,
        mimeType: 'application/octet-stream',
        type: FileType.any,
      );
      // On the web the download starts without a path.
      if (saved == null && !kIsWeb) return;
      await repo.markSaved(data, actor: actor);
      _password.clear();
      _confirm.clear();
      if (mounted) showSnack(context, l10n.backupSaved(data.documentCount));
    } on Object catch (e) {
      if (mounted) showSnack(context, l10n.errorGeneric('$e'));
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _step = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final e = _estimate;
    final total = e == null ? 0 : e.entries.where((x) => x.key != Col.records).fold<int>(0, (n, x) => n + x.value);
    final records = e?[Col.records] ?? 0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.backupCreateTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(l10n.backupCreateHelp, style: theme.textTheme.bodySmall),
            const SizedBox(height: 12),
            if (e == null)
              OutlinedButton.icon(
                key: const Key('backup.count'),
                onPressed: _busy ? null : _count,
                icon: const Icon(Icons.calculate_outlined),
                label: Text(l10n.backupCount),
              )
            else ...[
              Text(l10n.backupEstimate(total), key: const Key('backup.estimate')),
              SwitchListTile(
                key: const Key('backup.records'),
                contentPadding: EdgeInsets.zero,
                value: _withRecords,
                onChanged: _busy ? null : (v) => setState(() => _withRecords = v),
                title: Text(l10n.backupWithRecords(records)),
                subtitle: Text(l10n.backupRecordsHelp),
              ),
              TextField(
                key: const Key('backup.password'),
                controller: _password,
                obscureText: true,
                textDirection: TextDirection.ltr,
                decoration: InputDecoration(labelText: l10n.backupPassword, prefixIcon: const Icon(Icons.key)),
              ),
              const SizedBox(height: 8),
              TextField(
                key: const Key('backup.confirm'),
                controller: _confirm,
                obscureText: true,
                textDirection: TextDirection.ltr,
                decoration: InputDecoration(labelText: l10n.backupPasswordConfirm, prefixIcon: const Icon(Icons.key)),
              ),
              const SizedBox(height: 4),
              Text(l10n.backupPasswordWarning, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error)),
              const SizedBox(height: 12),
              FilledButton.icon(
                key: const Key('backup.create'),
                onPressed: _busy ? null : _create,
                icon: const Icon(Icons.save_alt),
                label: Text(l10n.backupCreate),
              ),
            ],
            if (_busy) ...[
              const SizedBox(height: 12),
              const LinearProgressIndicator(),
              if (_step != null) Padding(padding: const EdgeInsets.only(top: 4), child: Text(_step!)),
            ],
          ],
        ),
      ),
    );
  }
}

class _RestoreCard extends ConsumerStatefulWidget {
  const _RestoreCard();

  @override
  ConsumerState<_RestoreCard> createState() => _RestoreCardState();
}

class _RestoreCardState extends ConsumerState<_RestoreCard> {
  final _password = TextEditingController();
  Uint8List? _bytes;
  String? _fileName;
  BackupData? _data;
  bool _busy = false;
  String? _progress;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    final file = await FilePicker.pickFile(type: FileType.any);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() {
      _bytes = bytes;
      _fileName = file.name;
      _data = null;
    });
  }

  Future<void> _open() async {
    final l10n = context.l10n;
    final bytes = _bytes;
    if (bytes == null) return;
    setState(() => _busy = true);
    try {
      final data = await BackupFile.decrypt(bytes, _password.text);
      setState(() => _data = data);
    } on BackupPasswordException {
      if (mounted) showSnack(context, l10n.backupWrongPassword);
    } on BackupFormatException {
      if (mounted) showSnack(context, l10n.backupNotABackup);
    } on Object catch (e) {
      if (mounted) showSnack(context, l10n.errorGeneric('$e'));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restore(BackupData data) async {
    final l10n = context.l10n;
    final first = await confirmDialog(
      context,
      title: l10n.backupRestoreConfirmTitle,
      body: l10n.backupRestoreConfirmBody,
      confirmLabel: l10n.backupRestore,
      destructive: true,
    );
    if (!first || !mounted) return;
    final typed = await showDialog<bool>(context: context, builder: (_) => const _TypeToConfirm());
    if (typed != true || !mounted) return;
    setState(() => _busy = true);
    try {
      final writes = await ref.read(backupRepositoryProvider).restore(
            data,
            actor: ref.read(signedInUserProvider).id,
            onProgress: (done, total) => setState(() => _progress = l10n.backupRestoreProgress(done, total)),
          );
      if (mounted) showSnack(context, l10n.backupRestored(writes));
    } on Object catch (e) {
      if (mounted) showSnack(context, l10n.backupRestoreFailed('$e'));
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _progress = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final m = MaterialLocalizations.of(context);
    final data = _data;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.backupRestoreTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(l10n.backupRestoreHelp, style: theme.textTheme.bodySmall),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              key: const Key('restore.pick'),
              onPressed: _busy ? null : _pick,
              icon: const Icon(Icons.folder_open),
              label: Text(_fileName ?? l10n.backupPickFile),
            ),
            if (_bytes != null && data == null) ...[
              const SizedBox(height: 8),
              TextField(
                key: const Key('restore.password'),
                controller: _password,
                obscureText: true,
                textDirection: TextDirection.ltr,
                decoration: InputDecoration(labelText: l10n.backupPassword, prefixIcon: const Icon(Icons.key)),
                onSubmitted: (_) => _open(),
              ),
              const SizedBox(height: 8),
              FilledButton.tonal(
                key: const Key('restore.open'),
                onPressed: _busy ? null : _open,
                child: Text(l10n.backupOpen),
              ),
            ],
            if (data != null) ...[
              const SizedBox(height: 12),
              Text(
                l10n.backupFileInfo(m.formatMediumDate(data.createdAt.toLocal()), data.createdBy),
                key: const Key('restore.info'),
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final c in BackupScope.collections)
                    if (!BackupScope.notRestored.contains(c) && (data.collections[c]?.isNotEmpty ?? false))
                      Chip(label: Text('${l10n.backupCollection(c)}: ${data.collections[c]!.length}')),
                  Chip(
                    label: Text('${l10n.backupCollection(Col.records)}: '
                        '${data.records.values.fold<int>(0, (n, r) => n + r.length)}'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                key: const Key('restore.run'),
                style: FilledButton.styleFrom(backgroundColor: theme.colorScheme.error),
                onPressed: _busy ? null : () => _restore(data),
                icon: const Icon(Icons.settings_backup_restore),
                label: Text(l10n.backupRestore),
              ),
            ],
            if (_busy) ...[
              const SizedBox(height: 12),
              const LinearProgressIndicator(),
              if (_progress != null) Padding(padding: const EdgeInsets.only(top: 4), child: Text(_progress!)),
            ],
          ],
        ),
      ),
    );
  }
}

/// Second confirmation: type the word «استعادة».
class _TypeToConfirm extends StatefulWidget {
  const _TypeToConfirm();

  @override
  State<_TypeToConfirm> createState() => _TypeToConfirmState();
}

class _TypeToConfirmState extends State<_TypeToConfirm> {
  final _text = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final word = l10n.backupRestoreWord;
    return AlertDialog(
      title: Text(l10n.backupRestoreTypeTitle),
      content: TextField(
        key: const Key('restore.word'),
        controller: _text,
        autofocus: true,
        decoration: InputDecoration(labelText: l10n.backupRestoreType(word)),
        onChanged: (_) => setState(() {}),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
        FilledButton(
          key: const Key('restore.confirm'),
          style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
          onPressed: _text.text.trim() == word ? () => Navigator.pop(context, true) : null,
          child: Text(l10n.backupRestore),
        ),
      ],
    );
  }
}
