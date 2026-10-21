import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/arabic_text.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../l10n/l10n.dart';
import '../../auth/application/auth_providers.dart';
import '../../students/application/students_providers.dart';
import '../../students/domain/student.dart';
import '../application/courses_providers.dart';
import '../domain/course.dart';
import '../domain/practical_group.dart';

/// Moves students between the practical groups of a course after the
/// alphabetical split (groups may end up with different sizes), and adds
/// an empty group to move students into.
class GroupMembersScreen extends ConsumerStatefulWidget {
  const GroupMembersScreen({super.key, required this.course});

  final Course course;

  @override
  ConsumerState<GroupMembersScreen> createState() => _GroupMembersScreenState();
}

class _GroupMembersScreenState extends ConsumerState<GroupMembersScreen> {
  final _selected = <String>{};
  String _query = '';
  bool _busy = false;

  /// Other courses the last move was repeated in, offered again next time.
  Set<String> _applyTo = {};

  Course get _course => widget.course;

  void _toggle(String id) => setState(() => _selected.contains(id) ? _selected.remove(id) : _selected.add(id));

  Future<void> _move(List<PracticalGroup> groups, List<Course> otherCourses) async {
    final l10n = context.l10n;
    final to = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(l10n.groupsMoveTitle(_selected.length), style: Theme.of(context).textTheme.titleMedium),
            ),
            for (final g in groups)
              ListTile(
                key: Key('groups.to.${g.name}'),
                leading: CircleAvatar(child: Text(g.name)),
                title: Text(l10n.assignmentsGroupStudents(l10n.groupLabel(g.name), g.studentIds.length)),
                onTap: () => Navigator.pop(context, g.name),
              ),
          ],
        ),
      ),
    );
    if (to == null || !mounted) return;
    final moved = _selected.length;
    setState(() => _busy = true);
    try {
      final repo = ref.read(coursesRepositoryProvider);
      // The same move in other practical courses of the stage, if chosen.
      final others = [
        for (final c in otherCourses)
          if (c.hasPractical && c.id != _course.id) c,
      ];
      var all = groups;
      var extra = 0;
      if (others.isNotEmpty) {
        final stageGroups = await repo.fetchStageGroups(_course.stageId);
        if (!mounted) return;
        final chosen = await showDialog<Set<String>>(
          context: context,
          builder: (_) => _ApplyToCoursesDialog(
            course: _course,
            courses: others,
            stageGroups: stageGroups,
            toGroup: to,
            count: moved,
            initial: _applyTo,
          ),
        );
        if (chosen == null || !mounted) return;
        _applyTo = chosen;
        all = [
          ...groups,
          for (final id in chosen) ...?stageGroups[id],
        ];
        extra = chosen.length;
      }
      await repo.moveStudents(
        groups: all,
        studentIds: {..._selected},
        toGroup: to,
        actor: ref.read(signedInUserProvider).id,
      );
      if (!mounted) return;
      setState(_selected.clear);
      showSnack(
        context,
        extra == 0
            ? l10n.groupsMoved(moved, l10n.groupLabel(to))
            : l10n.groupsMovedCourses(moved, l10n.groupLabel(to), extra + 1),
      );
    } on Object catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _addGroup(List<PracticalGroup> groups) async {
    final l10n = context.l10n;
    setState(() => _busy = true);
    try {
      final name = await ref
          .read(coursesRepositoryProvider)
          .addGroup(course: _course, groups: groups, actor: ref.read(signedInUserProvider).id);
      if (mounted) showSnack(context, l10n.groupsAdded(l10n.groupLabel(name)));
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
    final groups = ref.watch(courseGroupsProvider((courseId: _course.id, stageId: _course.stageId)));
    final students = ref.watch(stageStudentsProvider(_course.stageId));
    final stageCourses = ref.watch(stageCoursesProvider(_course.stageId)).value ?? const <Course>[];
    final list = groups.value ?? const <PracticalGroup>[];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.groupsEditTitle),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(24),
          child: Padding(
            padding: const EdgeInsetsDirectional.only(start: 16, end: 16, bottom: 8),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text('${_course.name} · ${l10n.stageId(_course.stageId)}', style: theme.textTheme.bodySmall),
            ),
          ),
        ),
        actions: [
          if (groups.hasValue && list.isNotEmpty)
            IconButton(
              key: const Key('groups.add'),
              tooltip: l10n.groupsAdd,
              icon: const Icon(Icons.group_add_outlined),
              onPressed: _busy ? null : () => _addGroup(list),
            ),
        ],
      ),
      body: AsyncBody<List<PracticalGroup>>(
        value: groups,
        data: (groupList) => AsyncBody<List<Student>>(
          value: students,
          data: (studentList) => groupList.isEmpty
              ? Center(
                  child: MessageView(icon: Icons.groups_outlined, title: l10n.groupsNone),
                )
              : _body(groupList, studentList),
        ),
      ),
      bottomNavigationBar: _selected.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Row(
                  children: [
                    Expanded(child: Text(l10n.groupsSelected(_selected.length))),
                    TextButton(onPressed: _busy ? null : () => setState(_selected.clear), child: Text(l10n.cancel)),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      key: const Key('groups.move'),
                      icon: const Icon(Icons.drive_file_move_outline),
                      label: Text(l10n.groupsMoveTo),
                      onPressed: _busy || list.isEmpty ? null : () => _move(list, stageCourses),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _body(List<PracticalGroup> groups, List<Student> students) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final byId = {for (final s in students) s.id: s};
    final grouped = {for (final g in groups) ...g.studentIds};
    final unassigned = [
      for (final s in students)
        if (s.attendsLectures && !grouped.contains(s.id)) s,
    ];
    final q = ArabicText.normalizeForCompare(_query);
    final qDigits = ArabicText.normalizeDigits(_query.trim());
    bool matches(String id) {
      if (q.isEmpty) return true;
      final s = byId[id];
      return id.contains(qDigits) || (s != null && ArabicText.normalizeForCompare(s.fullName).contains(q));
    }

    List<String> sorted(Iterable<String> ids) {
      final list = ids.where(matches).toList();
      list.sort((a, b) {
        final sa = byId[a], sb = byId[b];
        if (sa == null || sb == null) return a.compareTo(b);
        return Student.compare(sa, sb);
      });
      return list;
    }

    Widget header(String text, Key key) => Padding(
      key: key,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(text, style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary)),
    );

    Widget tile(String id) {
      final s = byId[id];
      return CheckboxListTile(
        key: Key('groups.student.$id'),
        dense: true,
        value: _selected.contains(id),
        onChanged: _busy ? null : (_) => _toggle(id),
        title: Text(s?.fullName ?? id),
        subtitle: Text(bidiIsolate(s?.universityId ?? id)),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: TextField(
            key: const Key('groups.search'),
            decoration: InputDecoration(
              isDense: true,
              prefixIcon: const Icon(Icons.search),
              hintText: l10n.recordSearch,
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Text(l10n.groupsHelp, style: theme.textTheme.bodySmall),
        ),
        for (final g in groups) ...[
          header(
            l10n.assignmentsGroupStudents(l10n.groupLabel(g.name), g.studentIds.length),
            Key('groups.header.${g.name}'),
          ),
          for (final id in sorted(g.studentIds)) tile(id),
        ],
        if (unassigned.isNotEmpty) ...[
          header(l10n.groupsUnassigned(unassigned.length), const Key('groups.header.none')),
          for (final id in sorted(unassigned.map((s) => s.id))) tile(id),
        ],
        const SizedBox(height: 16),
      ],
    );
  }
}

/// After a move: the other practical courses of the stage to repeat it in.
/// A course without a group of that name cannot take it. Returns the chosen
/// course IDs (empty = this course only), or null to cancel the move.
class _ApplyToCoursesDialog extends StatefulWidget {
  const _ApplyToCoursesDialog({
    required this.course,
    required this.courses,
    required this.stageGroups,
    required this.toGroup,
    required this.count,
    required this.initial,
  });

  final Course course;
  final List<Course> courses;
  final Map<String, List<PracticalGroup>> stageGroups;
  final String toGroup;
  final int count;
  final Set<String> initial;

  @override
  State<_ApplyToCoursesDialog> createState() => _ApplyToCoursesDialogState();
}

class _ApplyToCoursesDialogState extends State<_ApplyToCoursesDialog> {
  late final Set<String> _chosen = {
    for (final c in widget.courses)
      if (widget.initial.contains(c.id) && _canTake(c)) c.id,
  };

  bool _canTake(Course c) => (widget.stageGroups[c.id] ?? const []).any((g) => g.name == widget.toGroup);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final group = l10n.groupLabel(widget.toGroup);
    return AlertDialog(
      title: Text(l10n.groupsApplyTitle),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.groupsApplyBody(widget.count, group, widget.course.name)),
              const SizedBox(height: 8),
              for (final c in widget.courses)
                CheckboxListTile(
                  key: Key('groups.apply.${c.id}'),
                  contentPadding: EdgeInsets.zero,
                  value: _chosen.contains(c.id),
                  title: Text(c.name),
                  subtitle: Text(_canTake(c) ? bidiIsolate(c.code) : l10n.groupsApplyMissing(group)),
                  onChanged: _canTake(c)
                      ? (v) => setState(() => v == true ? _chosen.add(c.id) : _chosen.remove(c.id))
                      : null,
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
        TextButton(
          key: const Key('groups.apply.onlyThis'),
          onPressed: () => Navigator.pop(context, <String>{}),
          child: Text(l10n.groupsApplyOnlyThis),
        ),
        FilledButton(
          key: const Key('groups.apply.confirm'),
          onPressed: _chosen.isEmpty ? null : () => Navigator.pop(context, {..._chosen}),
          child: Text(l10n.groupsApply(_chosen.length)),
        ),
      ],
    );
  }
}
