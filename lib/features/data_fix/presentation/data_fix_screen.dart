import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/domain/stage_ref.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../l10n/l10n.dart';
import '../../auth/application/auth_providers.dart';
import '../application/data_fix_providers.dart';
import '../domain/fix_plan.dart';

enum _Tool { rename, delete }

enum _DeleteKind { students, courses }

/// تصحيح البيانات (admins): change a university ID / course code / teacher
/// e-mail, or delete what a wrong import created. Always preview first.
class DataFixScreen extends ConsumerStatefulWidget {
  const DataFixScreen({super.key});

  @override
  ConsumerState<DataFixScreen> createState() => _DataFixScreenState();
}

class _DataFixScreenState extends ConsumerState<DataFixScreen> {
  _Tool _tool = _Tool.rename;
  FixKind _kind = FixKind.student;
  _DeleteKind _deleteKind = _DeleteKind.students;
  StageRef _stage = StageRef.all.first;
  final _old = TextEditingController();
  final _new = TextEditingController();
  final _only = TextEditingController();
  FixPlan? _plan;
  bool _busy = false;
  (int, int)? _progress;

  @override
  void dispose() {
    _old.dispose();
    _new.dispose();
    _only.dispose();
    super.dispose();
  }

  void _reset(VoidCallback change) => setState(() {
        change();
        _plan = null;
      });

  Future<void> _preview() async {
    final l10n = context.l10n;
    final repo = ref.read(dataFixRepositoryProvider);
    final actor = ref.read(signedInUserProvider).id;
    setState(() {
      _busy = true;
      _plan = null;
    });
    try {
      final plan = switch (_tool) {
        _Tool.rename => switch (_kind) {
            FixKind.student => await repo.planStudentRename(_old.text, _new.text, actor: actor),
            FixKind.course => await repo.planCourseRename(_stage.id, _old.text, _new.text, actor: actor),
            FixKind.teacher => await repo.planTeacherRename(_old.text, _new.text, actor: actor),
          },
        _Tool.delete => switch (_deleteKind) {
            _DeleteKind.students => await repo.planStudentDeletion(_stage.id, onlyId: _only.text, actor: actor),
            _DeleteKind.courses => await repo.planCourseDeletion(_stage.id, onlyCode: _only.text, actor: actor),
          },
      };
      if (mounted) setState(() => _plan = plan);
    } on Object catch (e) {
      if (mounted) showSnack(context, l10n.errorGeneric(e is FirebaseException ? e.code : '$e'));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _apply(FixPlan plan) async {
    final l10n = context.l10n;
    final ok = await confirmDialog(
      context,
      title: l10n.fixConfirmTitle,
      body: l10n.fixConfirmBody,
      confirmLabel: _tool == _Tool.delete ? l10n.delete : l10n.fixApply,
      destructive: true,
    );
    if (!ok || !mounted) return;
    setState(() {
      _busy = true;
      _progress = (0, 0);
    });
    try {
      final writes = await ref.read(dataFixRepositoryProvider).apply(
            plan,
            onProgress: (done, total) {
              if (mounted) setState(() => _progress = (done, total));
            },
          );
      if (!mounted) return;
      showSnack(context, l10n.fixDone(writes));
      setState(() {
        _plan = null;
        _old.clear();
        _new.clear();
        _only.clear();
      });
    } on Object catch (e) {
      if (mounted) showSnack(context, l10n.fixInterrupted(e is FirebaseException ? e.code : '$e'));
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
    final perms = ref.watch(permissionsProvider);
    final kinds = [FixKind.student, FixKind.course, if (perms.canRenameTeachers) FixKind.teacher];
    final kind = kinds.contains(_kind) ? _kind : FixKind.student;
    final needsStage = _tool == _Tool.delete || kind == FixKind.course;
    final ltr = _tool == _Tool.rename && kind == FixKind.teacher;
    final plan = _plan;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.fixTitle)),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SegmentedButton<_Tool>(
                segments: [
                  ButtonSegment(value: _Tool.rename, icon: const Icon(Icons.edit), label: Text(l10n.fixRenameTab)),
                  ButtonSegment(
                    value: _Tool.delete,
                    icon: const Icon(Icons.delete_sweep_outlined),
                    label: Text(l10n.fixDeleteTab),
                  ),
                ],
                selected: {_tool},
                onSelectionChanged: _busy ? null : (s) => _reset(() => _tool = s.first),
              ),
              const SizedBox(height: 16),
              if (_tool == _Tool.rename)
                SegmentedButton<FixKind>(
                  key: const Key('fix.kind'),
                  segments: [
                    for (final k in kinds)
                      ButtonSegment(
                        value: k,
                        label: Text(switch (k) {
                          FixKind.student => l10n.fixKindStudent,
                          FixKind.course => l10n.fixKindCourse,
                          FixKind.teacher => l10n.fixKindTeacher,
                        }),
                      ),
                  ],
                  selected: {kind},
                  onSelectionChanged: _busy ? null : (s) => _reset(() => _kind = s.first),
                )
              else
                SegmentedButton<_DeleteKind>(
                  segments: [
                    ButtonSegment(value: _DeleteKind.students, label: Text(l10n.fixDeleteStudents)),
                    ButtonSegment(value: _DeleteKind.courses, label: Text(l10n.fixDeleteCourses)),
                  ],
                  selected: {_deleteKind},
                  onSelectionChanged: _busy ? null : (s) => _reset(() => _deleteKind = s.first),
                ),
              const SizedBox(height: 16),
              if (needsStage) ...[
                DropdownButtonFormField<StageRef>(
                  key: const Key('fix.stage'),
                  initialValue: _stage,
                  decoration: InputDecoration(labelText: l10n.fixStage, prefixIcon: const Icon(Icons.layers)),
                  items: [for (final s in StageRef.all) DropdownMenuItem(value: s, child: Text(l10n.stage(s)))],
                  onChanged: _busy ? null : (s) => _reset(() => _stage = s ?? _stage),
                ),
                const SizedBox(height: 12),
              ],
              if (_tool == _Tool.rename) ...[
                TextField(
                  key: const Key('fix.old'),
                  controller: _old,
                  enabled: !_busy,
                  textDirection: ltr ? TextDirection.ltr : null,
                  keyboardType: ltr ? TextInputType.emailAddress : null,
                  decoration: InputDecoration(labelText: l10n.fixOldId),
                  onChanged: (_) => _reset(() {}),
                ),
                const SizedBox(height: 12),
                TextField(
                  key: const Key('fix.new'),
                  controller: _new,
                  enabled: !_busy,
                  textDirection: ltr ? TextDirection.ltr : null,
                  keyboardType: ltr ? TextInputType.emailAddress : null,
                  decoration: InputDecoration(labelText: l10n.fixNewId),
                  onChanged: (_) => _reset(() {}),
                ),
                const SizedBox(height: 8),
                Text(kind == FixKind.teacher ? l10n.fixTeacherHelp : l10n.fixRenameHelp,
                    style: theme.textTheme.bodySmall),
              ] else ...[
                TextField(
                  key: const Key('fix.only'),
                  controller: _only,
                  enabled: !_busy,
                  decoration: InputDecoration(labelText: l10n.fixOnlyOne, hintText: l10n.fixOnlyOneHint),
                  onChanged: (_) => _reset(() {}),
                ),
                const SizedBox(height: 8),
                Text(l10n.fixDeleteHelp, style: theme.textTheme.bodySmall),
              ],
              const SizedBox(height: 4),
              Text(l10n.fixPhonesNote, style: theme.textTheme.bodySmall),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                key: const Key('fix.preview'),
                icon: const Icon(Icons.preview),
                label: Text(l10n.fixPreview),
                onPressed: _busy ? null : _preview,
              ),
              if (_progress case (final done, final total)) ...[
                const SizedBox(height: 12),
                LinearProgressIndicator(value: total == 0 ? null : done / total),
              ],
              if (plan != null) ...[
                const SizedBox(height: 16),
                _PlanCard(
                  plan: plan,
                  deleting: _tool == _Tool.delete,
                  onApply: _busy ? null : () => _apply(plan),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.plan, required this.deleting, required this.onApply});

  final FixPlan plan;
  final bool deleting;
  final VoidCallback? onApply;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final counts = [
      for (final e in plan.counts.entries)
        if (e.value > 0 && e.key != FixCount.kept) l10n.fixCount(e.key, e.value),
    ];
    final kept = plan.counts[FixCount.kept] ?? 0;
    return Card(
      key: const Key('fix.plan'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final p in plan.problems)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.error_outline, color: theme.colorScheme.error),
                title: Text(l10n.fixProblem(p, plan.mergeInto)),
              ),
            if (plan.problems.isEmpty && plan.mergeInto != null)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.merge),
                title: Text(l10n.fixMerge(plan.mergeInto!)),
              ),
            if (counts.isNotEmpty) ...[
              Text(deleting ? l10n.fixWillDelete : l10n.fixWillMove, style: theme.textTheme.titleSmall),
              const SizedBox(height: 4),
              for (final c in counts) Text('• $c'),
            ],
            if (kept > 0) ...[
              const SizedBox(height: 4),
              Text(l10n.fixCountKept(kept), style: theme.textTheme.bodySmall),
            ],
            if (plan.canApply) ...[
              const SizedBox(height: 12),
              FilledButton.icon(
                key: const Key('fix.apply'),
                style: FilledButton.styleFrom(backgroundColor: theme.colorScheme.error),
                icon: Icon(deleting ? Icons.delete_forever : Icons.drive_file_move),
                label: Text(deleting ? l10n.delete : l10n.fixApply),
                onPressed: onApply,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
