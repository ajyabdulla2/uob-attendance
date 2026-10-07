import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/domain/stage_ref.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../l10n/l10n.dart';
import '../../auth/application/auth_providers.dart';
import '../../auth/domain/app_user.dart';
import '../../courses/domain/course.dart';
import '../../students/domain/student.dart';
import '../application/import_controller.dart';
import '../data/import_templates.dart';
import '../data/import_writer.dart';
import '../domain/import_models.dart';

/// SPEC §2 «الاستيراد»: template download, preview before saving, duplicate
/// detection and «تحديث الموجود».
class ImportScreen extends ConsumerWidget {
  const ImportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final perms = ref.watch(permissionsProvider);
    final kinds = [
      if (perms.canImportStudents) ImportKind.students,
      if (perms.canImportTeachers) ImportKind.teachers,
      if (perms.canImportCourses) ImportKind.courses,
    ];
    if (kinds.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.importTitle)),
        body: Center(child: MessageView(icon: Icons.lock_outline, title: l10n.importNotAllowed)),
      );
    }
    return DefaultTabController(
      length: kinds.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.importTitle),
          bottom: TabBar(tabs: [for (final k in kinds) Tab(text: l10n.importKind(k))]),
        ),
        body: TabBarView(children: [for (final k in kinds) _ImportPanel(kind: k)]),
      ),
    );
  }
}

class _ImportPanel extends ConsumerStatefulWidget {
  const _ImportPanel({required this.kind});

  final ImportKind kind;

  @override
  ConsumerState<_ImportPanel> createState() => _ImportPanelState();
}

class _ImportPanelState extends ConsumerState<_ImportPanel> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  ImportController get _controller => ref.read(importControllerProvider(widget.kind).notifier);

  Future<void> _downloadTemplate() async {
    final l10n = context.l10n;
    try {
      final uri = await FilePicker.saveFile(
        fileName: ImportTemplates.fileName(widget.kind),
        bytes: _controller.template(),
        mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        type: FileType.custom,
        allowedExtensions: const ['xlsx'],
      );
      if (uri != null && mounted) showSnack(context, l10n.importTemplateSaved);
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  Future<void> _pickFile() async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const ['xlsx', 'csv', 'xls'],
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    await _controller.loadFile(bytes, file.name);
  }

  Future<void> _save(ImportPreview<Object?> preview) async {
    final l10n = context.l10n;
    final ok = await confirmDialog(
      context,
      title: l10n.importConfirmTitle,
      body: l10n.importConfirmBody('${preview.count(RowAction.create)}', '${preview.count(RowAction.update)}'),
      confirmLabel: l10n.save,
    );
    if (ok) await _controller.commit();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l10n = context.l10n;
    final state = ref.watch(importControllerProvider(widget.kind));
    final preview = state.preview;
    final rows = preview == null
        ? const <ImportRow<Object?>>[]
        : state.problemsOnly
            ? preview.rows.where((r) => r.action != RowAction.create && r.action != RowAction.update || r.hasWarnings).toList()
            : preview.rows;
    final writable = preview == null ? 0 : preview.count(RowAction.create) + preview.count(RowAction.update);

    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                sliver: SliverList.list(children: [
                  _StepsCard(
                    kind: widget.kind,
                    state: state,
                    onDownload: _downloadTemplate,
                    onPick: state.loading || state.saving ? null : _pickFile,
                  ),
                  const SizedBox(height: 12),
                  if (state.result case final result?) _ResultCard(result: result),
                  if (state.fileProblem case final problem?)
                    _ErrorCard(message: l10n.fileProblem(problem)),
                  if (state.error case final error?) _ErrorCard(message: l10n.errorGeneric('$error')),
                  if (state.loading)
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(children: [const CircularProgressIndicator(), const SizedBox(height: 8), Text(l10n.importReading)]),
                    ),
                  if (preview != null) ...[
                    for (final issue in preview.fileIssues) _ErrorCard(message: l10n.issue(issue)),
                    if (!preview.hasFileErrors) ...[
                      Text(l10n.importPreviewTitle, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      _Summary(preview: preview),
                      const SizedBox(height: 8),
                      SegmentedButton<bool>(
                        segments: [
                          ButtonSegment(value: false, label: Text(l10n.importFilterAll)),
                          ButtonSegment(value: true, label: Text(l10n.importFilterProblems)),
                        ],
                        selected: {state.problemsOnly},
                        onSelectionChanged: (s) => _controller.setProblemsOnly(s.first),
                      ),
                      const SizedBox(height: 8),
                      if (rows.isEmpty) Center(child: Text(l10n.importNoRowsMatch)),
                    ],
                  ],
                ]),
              ),
              if (preview != null && !preview.hasFileErrors)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  sliver: SliverList.builder(
                    itemCount: rows.length,
                    itemBuilder: (context, i) => _RowTile(row: rows[i]),
                  ),
                ),
            ],
          ),
        ),
        if (preview != null && !preview.hasFileErrors)
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  key: Key('import.save.${widget.kind.name}'),
                  icon: state.saving
                      ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.save),
                  label: Text(state.saving ? l10n.importSaving : l10n.importSave(writable)),
                  onPressed: preview.canCommit && !state.saving ? () => _save(preview) : null,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _StepsCard extends ConsumerWidget {
  const _StepsCard({required this.kind, required this.state, required this.onDownload, required this.onPick});

  final ImportKind kind;
  final ImportState state;
  final VoidCallback onDownload;
  final VoidCallback? onPick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final controller = ref.read(importControllerProvider(kind).notifier);
    final perms = ref.watch(permissionsProvider);
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.importStep1, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: onDownload,
              icon: const Icon(Icons.download),
              label: Text(l10n.importDownloadTemplate),
            ),
            const SizedBox(height: 16),
            Text(l10n.importStep2, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                FilledButton.icon(onPressed: onPick, icon: const Icon(Icons.attach_file), label: Text(l10n.importPickFile)),
                if (state.fileName case final name?) Text(l10n.importFileName(bidiIsolate(name))),
              ],
            ),
            const Divider(height: 32),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: state.updateExisting,
              onChanged: state.saving ? null : controller.setUpdateExisting,
              title: Text(switch (kind) {
                ImportKind.students => l10n.importUpdateExistingStudents,
                ImportKind.teachers => l10n.importUpdateExistingTeachers,
                ImportKind.courses => l10n.importUpdateExistingCourses,
              }),
            ),
            if (kind == ImportKind.students)
              DropdownButtonFormField<StageRef?>(
                initialValue: state.defaultStage,
                decoration: InputDecoration(labelText: l10n.importDefaultStage),
                items: [
                  DropdownMenuItem(value: null, child: Text(l10n.importDefaultStageNone)),
                  for (final s in perms.manageableStages) DropdownMenuItem(value: s, child: Text(l10n.stage(s))),
                ],
                onChanged: state.saving ? null : controller.setDefaultStage,
              ),
            if (kind == ImportKind.courses) ...[
              Text(l10n.importDefaultSemester),
              const SizedBox(height: 8),
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 1, label: Text('1')),
                  ButtonSegment(value: 2, label: Text('2')),
                ],
                selected: {state.defaultSemester},
                onSelectionChanged: (s) => controller.setDefaultSemester(s.first),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.preview});

  final ImportPreview<Object?> preview;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = StatusPalette.of(context);
    Widget chip(IconData icon, Color color, String text) => Chip(
          avatar: Icon(icon, color: color, size: 18),
          label: Text(text),
          side: BorderSide(color: color.withValues(alpha: 0.6)),
        );
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        chip(Icons.add_circle, palette.present, l10n.importSummaryCreate(preview.count(RowAction.create))),
        chip(Icons.sync, palette.excused, l10n.importSummaryUpdate(preview.count(RowAction.update))),
        chip(Icons.skip_next, Theme.of(context).colorScheme.outline, l10n.importSummarySkip(preview.count(RowAction.skip))),
        chip(Icons.error, palette.absent, l10n.importSummaryInvalid(preview.count(RowAction.invalid))),
        chip(Icons.warning_amber, palette.late, l10n.importSummaryWarnings(preview.warningCount)),
      ],
    );
  }
}

class _RowTile extends StatelessWidget {
  const _RowTile({required this.row});

  final ImportRow<Object?> row;

  String _title(AppLocalizations l10n) => switch (row.entity) {
        Student s => '${s.fullName} — ${s.universityId} — ${l10n.stage(s.stage)}',
        AppUser u => '${u.displayName} — ${bidiIsolate(u.email)}',
        List<Course> cs when cs.isNotEmpty =>
          '${bidiIsolate(cs.first.code)} — ${cs.first.name} — ${cs.map((c) => l10n.stage(c.stage)).join('، ')}',
        _ => row.cells.where((c) => c.trim().isNotEmpty).take(3).join(' — '),
      };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = StatusPalette.of(context);
    final theme = Theme.of(context);
    final (actionColor, actionIcon) = switch (row.action) {
      RowAction.create => (palette.present, Icons.add_circle),
      RowAction.update => (palette.excused, Icons.sync),
      RowAction.skip => (theme.colorScheme.outline, Icons.skip_next),
      RowAction.invalid => (palette.absent, Icons.error),
    };
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(l10n.importRow(row.rowNumber.toString()), style: theme.textTheme.labelMedium),
                const SizedBox(width: 8),
                Expanded(child: Text(_title(l10n), style: theme.textTheme.bodyLarge)),
                const SizedBox(width: 8),
                Icon(actionIcon, color: actionColor, size: 18),
                const SizedBox(width: 4),
                Text(l10n.rowAction(row.action), style: TextStyle(color: actionColor, fontWeight: FontWeight.w600)),
              ],
            ),
            for (final issue in row.issues)
              Padding(
                padding: const EdgeInsetsDirectional.only(top: 4, start: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      switch (issue.severity) {
                        IssueSeverity.error => Icons.error_outline,
                        IssueSeverity.warning => Icons.warning_amber,
                        IssueSeverity.info => Icons.info_outline,
                      },
                      size: 16,
                      color: switch (issue.severity) {
                        IssueSeverity.error => palette.absent,
                        IssueSeverity.warning => palette.late,
                        IssueSeverity.info => palette.excused,
                      },
                    ),
                    const SizedBox(width: 6),
                    Expanded(child: Text(l10n.issue(issue), style: theme.textTheme.bodySmall)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result});

  final ImportWriteResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = StatusPalette.of(context);
    final failures = result.failures;
    return Card(
      child: ListTile(
        leading: Icon(failures.isEmpty ? Icons.check_circle : Icons.warning_amber,
            color: failures.isEmpty ? palette.present : palette.late),
        title: Text(l10n.importDone('${result.created}', '${result.updated}')),
        subtitle: failures.isEmpty
            ? null
            : Text(l10n.importFailures(
                failures.length,
                failures.map((f) => '${f.rowNumber} (${f.code})').join('، '),
              )),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.errorContainer,
      child: ListTile(
        leading: Icon(Icons.error_outline, color: scheme.onErrorContainer),
        title: Text(message, style: TextStyle(color: scheme.onErrorContainer)),
      ),
    );
  }
}
