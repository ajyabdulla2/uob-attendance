import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/domain/stage_ref.dart';
import '../../../core/utils/arabic_text.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../l10n/l10n.dart';
import '../../auth/application/auth_providers.dart';
import '../../courses/application/courses_providers.dart';
import '../../courses/domain/course.dart';
import '../../courses/domain/practical_group.dart';
import '../application/students_providers.dart';
import '../data/students_repository.dart';
import '../domain/student.dart';

/// «الطلبة» (admins, and a stage manager for their stages): the students of
/// a stage, with adding one student who joined after the import (e.g.
/// transferred to the department) and editing one — the import stays the
/// way to bring in many.
class StudentsScreen extends ConsumerStatefulWidget {
  const StudentsScreen({super.key});

  @override
  ConsumerState<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends ConsumerState<StudentsScreen> {
  StageRef? _stage;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final stages = ref.watch(permissionsProvider).manageableStages;
    final stage = _stage != null && stages.contains(_stage) ? _stage : stages.firstOrNull;
    final students = stage == null ? null : ref.watch(stageStudentsProvider(stage.id));
    return Scaffold(
      appBar: AppBar(title: Text(l10n.studentsTitle)),
      floatingActionButton: stage == null || students?.value == null
          ? null
          : FloatingActionButton.extended(
              key: const Key('students.add'),
              icon: const Icon(Icons.person_add_alt_1),
              label: Text(l10n.studentsAdd),
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => StudentDialog(stage: stage, stageStudents: students!.value!),
              ),
            ),
      body: stage == null
          ? Center(child: MessageView(icon: Icons.lock_outline, title: l10n.assignmentsNoStages))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: DropdownButtonFormField<StageRef>(
                    key: const Key('students.stage'),
                    initialValue: stage,
                    decoration: InputDecoration(labelText: l10n.assignmentsPickStage, prefixIcon: const Icon(Icons.layers)),
                    items: [for (final s in stages) DropdownMenuItem(value: s, child: Text(l10n.stage(s)))],
                    onChanged: (s) => setState(() => _stage = s),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    key: const Key('students.search'),
                    decoration: InputDecoration(hintText: l10n.coursePanelSearch, prefixIcon: const Icon(Icons.search)),
                    onChanged: (v) => setState(() => _query = ArabicText.normalizeForCompare(v)),
                  ),
                ),
                Expanded(
                  child: AsyncBody<List<Student>>(
                    value: students!,
                    data: (all) {
                      final shown = [
                        for (final s in all)
                          if (_query.isEmpty ||
                              ArabicText.normalizeForCompare(s.fullName).contains(_query) ||
                              s.universityId.contains(_query))
                            s,
                      ];
                      if (all.isEmpty) {
                        return Center(child: MessageView(icon: Icons.group_off, title: l10n.recordNoStudents));
                      }
                      return ListView(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 88), // clear the FAB
                        children: [
                          Text(l10n.reportStudentCount(all.length), style: Theme.of(context).textTheme.bodySmall),
                          for (final s in shown)
                            Card(
                              child: ListTile(
                                key: Key('students.row.${s.id}'),
                                title: Text(s.fullName),
                                subtitle: Text([
                                  bidiIsolate(s.universityId),
                                  if (s.section.isNotEmpty) l10n.sectionLabel(s.section),
                                  if (s.status != StudentStatus.continuing) l10n.studentStatus(s.status),
                                  if (s.carryOver) l10n.fieldCarryOver,
                                ].join(' · ')),
                                trailing: const Icon(Icons.edit_outlined),
                                onTap: () => showDialog<void>(
                                  context: context,
                                  builder: (_) => StudentDialog(stage: stage, stageStudents: all, student: s),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

/// Add ([student] null) or edit one student of [stage].
class StudentDialog extends ConsumerStatefulWidget {
  const StudentDialog({super.key, required this.stage, required this.stageStudents, this.student});

  final StageRef stage;
  final List<Student> stageStudents;
  final Student? student;

  @override
  ConsumerState<StudentDialog> createState() => _StudentDialogState();
}

class _StudentDialogState extends ConsumerState<StudentDialog> {
  late final _id = TextEditingController(text: widget.student?.universityId ?? '');
  late final _name = TextEditingController(text: widget.student?.fullName ?? '');
  late String _section = widget.student?.section ?? '';
  late StudentStatus _status = widget.student?.status ?? StudentStatus.transferredIn;
  late bool _carryOver = widget.student?.carryOver ?? false;

  /// Practical course → chosen group ID (adding only).
  final _groups = <String, String>{};
  bool _busy = false;
  String? _error;

  bool get _adding => widget.student == null;

  @override
  void dispose() {
    _id.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    final student = Student(
      universityId: _id.text,
      fullName: _name.text,
      stage: widget.stage,
      section: _section,
      status: _status,
      carryOver: _carryOver,
    );
    if (student.universityId.isEmpty || student.fullName.isEmpty) {
      setState(() => _error = l10n.studentsRequired);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final repo = ref.read(studentsRepositoryProvider);
    final actor = ref.read(signedInUserProvider).id;
    try {
      if (_adding) {
        await repo.add(student, actor: actor, stageStudents: widget.stageStudents, groupIds: _groups.values.toList());
      } else {
        await repo.update(widget.student!, student, actor: actor);
      }
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(_adding ? l10n.studentsAdded(student.fullName) : l10n.studentsSaved)));
    } on StudentExists catch (e) {
      if (mounted) {
        setState(() => _error = l10n.studentsExists(e.existing.fullName, l10n.stageId(e.existing.stageId)));
      }
    } on StudentElsewhere {
      if (mounted) setState(() => _error = l10n.studentsElsewhere);
    } on Object catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final sections = {
      for (final s in widget.stageStudents)
        if (s.section.isNotEmpty) s.section,
      if (_section.isNotEmpty) _section,
    }.toList()
      ..sort();
    final courses = _adding ? ref.watch(stageCoursesProvider(widget.stage.id)).value ?? const <Course>[] : const <Course>[];
    final words = ArabicText.wordCount(_name.text);
    return AlertDialog(
      title: Text(_adding ? l10n.studentsAdd : l10n.studentsEdit),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.stage(widget.stage), style: theme.textTheme.bodySmall),
              TextField(
                key: const Key('student.id'),
                controller: _id,
                enabled: _adding && !_busy,
                textDirection: TextDirection.ltr,
                decoration: InputDecoration(labelText: l10n.fieldUniversityId),
              ),
              TextField(
                key: const Key('student.name'),
                controller: _name,
                enabled: !_busy,
                decoration: InputDecoration(
                  labelText: l10n.fieldFullName,
                  helperText: _name.text.trim().isNotEmpty && words < 4 ? l10n.studentsNameHint : null,
                ),
                onChanged: (_) => setState(() {}),
              ),
              if (sections.isNotEmpty)
                DropdownButtonFormField<String>(
                  key: const Key('student.section'),
                  initialValue: _section,
                  decoration: InputDecoration(labelText: l10n.fieldSection),
                  items: [
                    DropdownMenuItem(value: '', child: Text(l10n.studentsNoSection)),
                    for (final s in sections) DropdownMenuItem(value: s, child: Text(l10n.sectionLabel(s))),
                  ],
                  onChanged: _busy ? null : (v) => setState(() => _section = v ?? ''),
                ),
              DropdownButtonFormField<StudentStatus>(
                key: const Key('student.status'),
                initialValue: _status,
                decoration: InputDecoration(labelText: l10n.fieldStatus),
                items: [
                  for (final s in StudentStatus.values) DropdownMenuItem(value: s, child: Text(l10n.studentStatus(s))),
                ],
                onChanged: _busy ? null : (v) => setState(() => _status = v ?? _status),
              ),
              SwitchListTile(
                key: const Key('student.carryOver'),
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.fieldCarryOver),
                subtitle: Text(l10n.studentsCarryOverHelp, style: theme.textTheme.bodySmall),
                value: _carryOver,
                onChanged: _busy ? null : (v) => setState(() => _carryOver = v),
              ),
              // A new student joins a practical group in each practical course.
              for (final c in courses)
                if (c.hasPractical) _GroupPicker(course: c, value: _groups[c.id], onChanged: (g) => setState(() {
                      if (g == null) {
                        _groups.remove(c.id);
                      } else {
                        _groups[c.id] = g;
                      }
                    })),
              if (_adding) ...[
                const SizedBox(height: 8),
                Text(l10n.studentsPhonesNote, style: theme.textTheme.bodySmall),
              ],
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, key: const Key('student.error'), style: TextStyle(color: theme.colorScheme.error)),
              ],
            ],
          ),
        ),
      ),
      actions: [
        if (!_adding &&
            ref.watch(permissionsProvider).manageableStages.any((s) => s != widget.stage))
          TextButton.icon(
            key: const Key('student.transfer'),
            icon: const Icon(Icons.swap_horiz),
            label: Text(l10n.transferAction),
            onPressed: _busy
                ? null
                : () async {
                    final navigator = Navigator.of(context);
                    final moved = await showDialog<bool>(
                      context: context,
                      builder: (_) => TransferDialog(student: widget.student!),
                    );
                    if (moved == true) navigator.pop();
                  },
          ),
        TextButton(onPressed: _busy ? null : () => Navigator.pop(context), child: Text(l10n.cancel)),
        FilledButton(
          key: const Key('student.save'),
          onPressed: _busy ? null : _save,
          child: Text(_adding ? l10n.studentsAdd : l10n.save),
        ),
      ],
    );
  }
}

class _GroupPicker extends ConsumerWidget {
  const _GroupPicker({required this.course, required this.value, required this.onChanged});

  final Course course;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final groups = ref.watch(courseGroupsProvider((courseId: course.id, stageId: course.stageId))).value ??
        const <PracticalGroup>[];
    if (groups.isEmpty) return const SizedBox.shrink();
    return DropdownButtonFormField<String?>(
      key: Key('student.group.${course.id}'),
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: l10n.studentsGroupOf(course.name)),
      items: [
        DropdownMenuItem(value: null, child: Text(l10n.studentsNoGroup)),
        for (final g in groups)
          DropdownMenuItem(value: g.id, child: Text('${l10n.groupLabel(g.name)} (${g.studentIds.length})')),
      ],
      onChanged: onChanged,
    );
  }
}

/// «نقل إلى مرحلة أخرى»: e.g. a hosted student from the evening study to
/// the morning one, with their absences, leaves and practical groups
/// ([StudentsRepository.transfer]). For whoever manages both stages.
class TransferDialog extends ConsumerStatefulWidget {
  const TransferDialog({super.key, required this.student});

  final Student student;

  @override
  ConsumerState<TransferDialog> createState() => _TransferDialogState();
}

class _TransferDialogState extends ConsumerState<TransferDialog> {
  StageRef? _to;
  String _section = '';
  final _groups = <String, String>{};
  bool _busy = false;

  Future<void> _transfer(StageRef to) async {
    final l10n = context.l10n;
    setState(() => _busy = true);
    try {
      final notCarried = await ref.read(studentsRepositoryProvider).transfer(
            widget.student,
            to: to,
            section: _section,
            groupIds: _groups.values.toList(),
            actor: ref.read(signedInUserProvider).id,
          );
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context, true);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text([
            l10n.transferDone(widget.student.fullName, l10n.stage(to)),
            if (notCarried.isNotEmpty) l10n.transferNotCarried(notCarried.join('، ')),
          ].join('\n')),
        ));
    } on Object catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final from = widget.student.stage;
    final stages = [for (final s in ref.watch(permissionsProvider).manageableStages) if (s != from) s];
    // The same level in the other study first (evening → morning).
    final to = _to ??
        stages.where((s) => s.level == from.level).firstOrNull ??
        stages.firstOrNull;
    final students = to == null ? const <Student>[] : ref.watch(stageStudentsProvider(to.id)).value ?? const <Student>[];
    final sections = {for (final s in students) if (s.section.isNotEmpty) s.section}.toList()..sort();
    final courses = to == null ? const <Course>[] : ref.watch(stageCoursesProvider(to.id)).value ?? const <Course>[];
    return AlertDialog(
      title: Text(l10n.transferTitle),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(widget.student.fullName, style: theme.textTheme.titleSmall),
              Text(l10n.transferFrom(l10n.stage(from)), style: theme.textTheme.bodySmall),
              const SizedBox(height: 8),
              DropdownButtonFormField<StageRef>(
                key: const Key('transfer.stage'),
                initialValue: to,
                isExpanded: true,
                decoration: InputDecoration(labelText: l10n.transferTo),
                items: [for (final s in stages) DropdownMenuItem(value: s, child: Text(l10n.stage(s)))],
                onChanged: _busy
                    ? null
                    : (s) => setState(() {
                          _to = s;
                          _section = '';
                          _groups.clear();
                        }),
              ),
              if (sections.isNotEmpty)
                DropdownButtonFormField<String>(
                  key: ValueKey('transfer.section.${to?.id}'),
                  initialValue: sections.contains(_section) ? _section : '',
                  decoration: InputDecoration(labelText: l10n.fieldSection),
                  items: [
                    DropdownMenuItem(value: '', child: Text(l10n.studentsNoSection)),
                    for (final s in sections) DropdownMenuItem(value: s, child: Text(l10n.sectionLabel(s))),
                  ],
                  onChanged: _busy ? null : (v) => setState(() => _section = v ?? ''),
                ),
              for (final c in courses)
                if (c.hasPractical)
                  _GroupPicker(
                    course: c,
                    value: _groups[c.id],
                    onChanged: (g) => setState(() {
                      if (g == null) {
                        _groups.remove(c.id);
                      } else {
                        _groups[c.id] = g;
                      }
                    }),
                  ),
              const SizedBox(height: 8),
              Text(l10n.transferHelp, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: _busy ? null : () => Navigator.pop(context), child: Text(l10n.cancel)),
        FilledButton(
          key: const Key('transfer.confirm'),
          onPressed: _busy || to == null ? null : () => _transfer(to),
          child: Text(l10n.transferAction),
        ),
      ],
    );
  }
}
