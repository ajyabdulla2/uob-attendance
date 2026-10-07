import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/domain/stage_ref.dart';
import '../../../core/utils/arabic_text.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../l10n/l10n.dart';
import '../../auth/application/auth_providers.dart';
import '../../students/application/students_providers.dart';
import '../../students/domain/student.dart';
import '../application/leaves_providers.dart';
import '../domain/leave.dart';

/// الإجازات (stage managers and admins): a leave entered here is approved,
/// and the student's absences on its days count as «مُجاز».
class LeavesScreen extends ConsumerStatefulWidget {
  const LeavesScreen({super.key});

  @override
  ConsumerState<LeavesScreen> createState() => _LeavesScreenState();
}

class _LeavesScreenState extends ConsumerState<LeavesScreen> {
  StageRef? _stage;

  Future<void> _add(StageRef stage, List<Student> students) async {
    final l10n = context.l10n;
    final leave = await showDialog<Leave>(
      context: context,
      builder: (_) => _LeaveDialog(stageId: stage.id, students: students),
    );
    if (leave == null || !mounted) return;
    try {
      await ref.read(leavesRepositoryProvider).add(leave, actor: ref.read(signedInUserProvider).id);
      if (mounted) showSnack(context, l10n.leaveSaved);
    } on Object catch (e) {
      if (mounted) showError(context, e);
    }
  }

  Future<void> _delete(Leave leave, String name) async {
    final l10n = context.l10n;
    final ok = await confirmDialog(
      context,
      title: l10n.leaveDeleteTitle,
      body: l10n.leaveDeleteBody(name),
      confirmLabel: l10n.delete,
      destructive: true,
    );
    if (!ok || !mounted) return;
    try {
      await ref.read(leavesRepositoryProvider).delete(leave, actor: ref.read(signedInUserProvider).id);
    } on Object catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final stages = ref.watch(permissionsProvider).manageableStages;
    final stage = _stage != null && stages.contains(_stage) ? _stage : stages.firstOrNull;
    final students = stage == null ? null : ref.watch(stageStudentsProvider(stage.id));
    final leaves = stage == null ? null : ref.watch(stageLeavesProvider(stage.id));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.leavesTitle)),
      floatingActionButton: stage == null || !(students?.hasValue ?? false)
          ? null
          : FloatingActionButton.extended(
              key: const Key('leaves.add'),
              icon: const Icon(Icons.add),
              label: Text(l10n.leaveAdd),
              onPressed: () => _add(stage, students!.value!),
            ),
      body: stage == null
          ? Center(child: MessageView(icon: Icons.lock_outline, title: l10n.assignmentsNoStages))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: DropdownButtonFormField<StageRef>(
                    key: const Key('leaves.stage'),
                    initialValue: stage,
                    decoration: InputDecoration(labelText: l10n.fixStage, prefixIcon: const Icon(Icons.layers)),
                    items: [for (final s in stages) DropdownMenuItem(value: s, child: Text(l10n.stage(s)))],
                    onChanged: (s) => setState(() => _stage = s),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(l10n.leavesHelp, style: Theme.of(context).textTheme.bodySmall),
                ),
                Expanded(
                  child: AsyncBody<List<Leave>>(
                    value: leaves!,
                    data: (list) {
                      if (list.isEmpty) {
                        return Center(child: MessageView(icon: Icons.event_available, title: l10n.leavesEmpty));
                      }
                      final names = {for (final s in students?.value ?? const <Student>[]) s.id: s.fullName};
                      final m = MaterialLocalizations.of(context);
                      return ListView.builder(
                        padding: const EdgeInsets.only(bottom: 88),
                        itemCount: list.length,
                        itemBuilder: (context, i) {
                          final leave = list[i];
                          final name = names[leave.studentId] ?? leave.studentId;
                          return ListTile(
                            key: Key('leave.${leave.id}'),
                            leading: const Icon(Icons.event_available),
                            title: Text(name),
                            subtitle: Text([
                              '${l10n.leaveType(leave.type)} · ${l10n.leaveDays(leave.days)}',
                              l10n.leaveRange(m.formatMediumDate(leave.from), m.formatMediumDate(leave.to)),
                              if (leave.referenceNo.isNotEmpty) l10n.leaveRefShown(bidiIsolate(leave.referenceNo)),
                              if (leave.note.isNotEmpty) leave.note,
                            ].join('\n')),
                            isThreeLine: true,
                            trailing: IconButton(
                              tooltip: l10n.delete,
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _delete(leave, name),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class _LeaveDialog extends StatefulWidget {
  const _LeaveDialog({required this.stageId, required this.students});

  final String stageId;
  final List<Student> students;

  @override
  State<_LeaveDialog> createState() => _LeaveDialogState();
}

class _LeaveDialogState extends State<_LeaveDialog> {
  Student? _student;
  LeaveType _type = LeaveType.sick;
  DateTimeRange? _range;
  final _query = TextEditingController();
  final _ref = TextEditingController();
  final _note = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    _ref.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1, 12, 31),
      initialDateRange: _range,
    );
    if (picked != null) setState(() => _range = picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final m = MaterialLocalizations.of(context);
    final q = ArabicText.normalizeForCompare(_query.text);
    final qDigits = ArabicText.normalizeDigits(_query.text.trim());
    final matches = _student != null || _query.text.trim().isEmpty
        ? const <Student>[]
        : [
            for (final s in widget.students)
              if (ArabicText.normalizeForCompare(s.fullName).contains(q) || s.universityId.contains(qDigits)) s,
          ].take(6).toList();
    final range = _range;

    return AlertDialog(
      title: Text(l10n.leaveAdd),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_student == null) ...[
                TextField(
                  key: const Key('leave.student'),
                  controller: _query,
                  autofocus: true,
                  decoration: InputDecoration(labelText: l10n.leaveStudent, prefixIcon: const Icon(Icons.search)),
                  onChanged: (_) => setState(() {}),
                ),
                for (final s in matches)
                  ListTile(
                    key: Key('leave.pick.${s.id}'),
                    dense: true,
                    title: Text(s.fullName),
                    subtitle: Text(bidiIsolate(s.universityId)),
                    onTap: () => setState(() => _student = s),
                  ),
              ] else
                InputChip(
                  label: Text(_student!.fullName),
                  onDeleted: () => setState(() => _student = null),
                ),
              const SizedBox(height: 12),
              DropdownButtonFormField<LeaveType>(
                key: const Key('leave.type'),
                initialValue: _type,
                isExpanded: true,
                decoration: InputDecoration(labelText: l10n.leaveTypeLabel),
                items: [for (final t in LeaveType.values) DropdownMenuItem(value: t, child: Text(l10n.leaveType(t)))],
                onChanged: (t) => setState(() => _type = t ?? _type),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                key: const Key('leave.range'),
                icon: const Icon(Icons.date_range),
                label: Text(range == null
                    ? l10n.leavePickRange
                    : l10n.leaveRange(m.formatMediumDate(range.start), m.formatMediumDate(range.end))),
                onPressed: _pickRange,
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('leave.ref'),
                controller: _ref,
                decoration: InputDecoration(labelText: l10n.leaveRef),
              ),
              TextField(
                key: const Key('leave.note'),
                controller: _note,
                decoration: InputDecoration(labelText: l10n.recordNote),
                maxLength: 200,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
        FilledButton(
          key: const Key('leave.save'),
          onPressed: _student == null || range == null
              ? null
              : () => Navigator.pop(
                    context,
                    Leave(
                      id: '',
                      studentId: _student!.id,
                      stageId: widget.stageId,
                      type: _type,
                      from: DateTime.utc(range.start.year, range.start.month, range.start.day),
                      to: DateTime.utc(range.end.year, range.end.month, range.end.day),
                      referenceNo: _ref.text.trim(),
                      note: _note.text.trim(),
                    ),
                  ),
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
