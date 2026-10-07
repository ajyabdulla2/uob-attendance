import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/domain/stage_ref.dart';
import '../../../core/firebase/doc_ids.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../l10n/l10n.dart';
import '../../academic/application/academic_providers.dart';
import '../../auth/application/auth_providers.dart';
import '../../auth/domain/app_user.dart';
import '../../courses/application/courses_providers.dart';
import '../../courses/domain/course.dart';
import '../../courses/domain/practical_group.dart';
import '../../courses/presentation/group_members_screen.dart';
import '../../students/application/students_providers.dart';
import '../../users/application/users_providers.dart';
import '../application/assignments_providers.dart';
import '../domain/assignment.dart';

/// SPEC §3 «الربط»: link a teacher to a course's theory lectures (whole stage
/// or one section) and/or to practical groups; one course may have several
/// teachers. Also creates practical groups («توزيعهم تلقائياً بالتساوي أبجدياً»).
class AssignmentsScreen extends ConsumerStatefulWidget {
  const AssignmentsScreen({super.key});

  @override
  ConsumerState<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends ConsumerState<AssignmentsScreen> {
  StageRef? _stage;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final stages = ref.watch(permissionsProvider).manageableStages;
    final stage = _stage != null && stages.contains(_stage) ? _stage : stages.firstOrNull;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.assignmentsTitle)),
      body: stage == null
          ? Center(child: MessageView(icon: Icons.lock_outline, title: l10n.assignmentsNoStages))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: DropdownButtonFormField<StageRef>(
                    key: const Key('assignments.stage'),
                    initialValue: stage,
                    decoration: InputDecoration(labelText: l10n.assignmentsPickStage, prefixIcon: const Icon(Icons.layers)),
                    items: [for (final s in stages) DropdownMenuItem(value: s, child: Text(l10n.stage(s)))],
                    onChanged: (s) => setState(() => _stage = s),
                  ),
                ),
                Expanded(child: _StageCourses(stage: stage)),
              ],
            ),
    );
  }
}

class _StageCourses extends ConsumerWidget {
  const _StageCourses({required this.stage});

  final StageRef stage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return AsyncBody<List<Course>>(
      value: ref.watch(stageCoursesProvider(stage.id)),
      data: (courses) {
        if (courses.isEmpty) {
          return Center(child: MessageView(icon: Icons.menu_book_outlined, title: l10n.assignmentsNoCourses));
        }
        final assignments = ref.watch(stageAssignmentsProvider(stage.id)).value ?? const <Assignment>[];
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          itemCount: courses.length,
          itemBuilder: (context, i) => _CourseCard(
            course: courses[i],
            assignments: [for (final a in assignments) if (a.courseId == courses[i].id) a],
          ),
        );
      },
    );
  }
}

class _CourseCard extends ConsumerWidget {
  const _CourseCard({required this.course, required this.assignments});

  final Course course;
  final List<Assignment> assignments;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final theory = [for (final a in assignments) if (a.type == AssignmentType.theory) a];
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        shape: const Border(),
        leading: Icon(course.hasPractical ? Icons.computer : Icons.menu_book),
        title: Text(course.name, style: theme.textTheme.titleMedium),
        subtitle: Text(l10n.assignmentsCourseInfo(bidiIsolate(course.code), '${course.units}', '${course.semester}')),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.assignmentsTheory, style: theme.textTheme.titleSmall),
          const SizedBox(height: 4),
          if (theory.isEmpty)
            Text(l10n.assignmentsNoTheoryTeacher, style: theme.textTheme.bodySmall)
          else
            Wrap(spacing: 8, runSpacing: 4, children: [for (final a in theory) _AssignmentChip(assignment: a)]),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              icon: const Icon(Icons.person_add_alt),
              label: Text(l10n.assignmentsAssignTheory),
              onPressed: () => _assignTheory(context, ref),
            ),
          ),
          if (course.hasPractical) ...[
            const Divider(),
            _PracticalSection(course: course, assignments: assignments),
          ],
        ],
      ),
    );
  }

  Future<void> _assignTheory(BuildContext context, WidgetRef ref) async {
    final picked = await showDialog<({AppUser teacher, String? section})>(
      context: context,
      builder: (_) => _AssignDialog(stageId: course.stageId, withSection: true),
    );
    if (picked == null || !context.mounted) return;
    final assignment = Assignment.theory(
      teacherId: picked.teacher.id,
      courseId: course.id,
      stageId: course.stageId,
      section: picked.section,
      teacherName: picked.teacher.displayName,
      courseName: course.name,
    );
    await _save(context, ref, assignment, picked.teacher, assignments);
  }
}

class _PracticalSection extends ConsumerWidget {
  const _PracticalSection({required this.course, required this.assignments});

  final Course course;
  final List<Assignment> assignments;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final groups = ref.watch(courseGroupsProvider((courseId: course.id, stageId: course.stageId)));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.assignmentsPractical, style: theme.textTheme.titleSmall),
        const SizedBox(height: 4),
        AsyncBody<List<PracticalGroup>>(
          value: groups,
          data: (list) => list.isEmpty
              ? Text(l10n.assignmentsNoGroups, style: theme.textTheme.bodySmall)
              : Column(
                  children: [
                    for (final g in list)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(child: Text(g.name)),
                        title: Text(l10n.assignmentsGroupStudents(l10n.groupLabel(g.name), g.studentIds.length)),
                        subtitle: Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            for (final a in assignments)
                              if (a.type == AssignmentType.practical && a.target == g.name) _AssignmentChip(assignment: a),
                          ],
                        ),
                        onTap: () => _editMembers(context),
                        trailing: IconButton(
                          tooltip: l10n.assignmentsAssignGroup(l10n.groupLabel(g.name)),
                          icon: const Icon(Icons.person_add_alt),
                          onPressed: () => _assignGroup(context, ref, g),
                        ),
                      ),
                  ],
                ),
        ),
        Wrap(
          spacing: 8,
          children: [
            TextButton.icon(
              icon: const Icon(Icons.groups),
              label: Text(l10n.assignmentsCreateGroups),
              onPressed: () => _distribute(context, ref, groups.value?.length ?? 0),
            ),
            if (groups.value?.isNotEmpty ?? false)
              TextButton.icon(
                key: Key('assignments.members.${course.id}'),
                icon: const Icon(Icons.swap_horiz),
                label: Text(l10n.groupsEditAction),
                onPressed: () => _editMembers(context),
              ),
          ],
        ),
      ],
    );
  }

  void _editMembers(BuildContext context) => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => GroupMembersScreen(course: course)),
      );

  Future<void> _assignGroup(BuildContext context, WidgetRef ref, PracticalGroup group) async {
    final picked = await showDialog<({AppUser teacher, String? section})>(
      context: context,
      builder: (_) => _AssignDialog(stageId: course.stageId, withSection: false),
    );
    if (picked == null || !context.mounted) return;
    final assignment = Assignment.practical(
      teacherId: picked.teacher.id,
      courseId: course.id,
      stageId: course.stageId,
      groupName: group.name,
      teacherName: picked.teacher.displayName,
      courseName: course.name,
    );
    await _save(context, ref, assignment, picked.teacher, assignments);
  }

  Future<void> _distribute(BuildContext context, WidgetRef ref, int currentCount) async {
    final l10n = context.l10n;
    final students = await ref.read(studentsRepositoryProvider).watchStage(course.stageId).first;
    final attending = students.where((s) => s.attendsLectures).length;
    if (!context.mounted) return;
    if (attending == 0) {
      showSnack(context, l10n.assignmentsNoStudents);
      return;
    }
    final count = await showDialog<int>(
      context: context,
      builder: (_) => _DistributeDialog(
        initial: currentCount > 0 ? currentCount : 2,
        redistributing: currentCount > 0,
        studentCount: attending,
        stageLabel: l10n.stageId(course.stageId),
      ),
    );
    if (count == null || !context.mounted) return;
    try {
      final actor = ref.read(signedInUserProvider).id;
      final removed = await ref.read(coursesRepositoryProvider).distributeGroups(
            course: course,
            students: students,
            groupCount: count,
            actor: actor,
          );
      final repo = ref.read(assignmentsRepositoryProvider);
      for (final teacherId in removed) {
        await repo.syncTeachingStage(teacherId, course.stageId);
      }
      if (context.mounted) showSnack(context, l10n.assignmentsDistributed(count));
    } catch (e) {
      if (context.mounted) showError(context, e);
    }
  }
}

Future<void> _save(
  BuildContext context,
  WidgetRef ref,
  Assignment assignment,
  AppUser teacher,
  List<Assignment> existing,
) async {
  final l10n = context.l10n;
  if (existing.any((a) => a.id == assignment.id)) {
    showSnack(context, l10n.assignmentsAlreadyAssigned);
    return;
  }
  try {
    await ref.read(assignmentsRepositoryProvider).assign(
          assignment,
          teacher: teacher,
          actor: ref.read(signedInUserProvider).id,
        );
    if (context.mounted) showSnack(context, l10n.assignmentsSaved);
  } catch (e) {
    if (context.mounted) showError(context, e);
  }
}

class _AssignmentChip extends ConsumerWidget {
  const _AssignmentChip({required this.assignment});

  final Assignment assignment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final name = assignment.teacherName.isEmpty ? assignment.teacherId : assignment.teacherName;
    final target = switch (assignment.type) {
      AssignmentType.practical => l10n.groupLabel(assignment.target),
      AssignmentType.theory =>
        assignment.target == DocIds.allSections ? l10n.allSections : l10n.sectionLabel(assignment.target),
    };
    return InputChip(
      avatar: const Icon(Icons.person, size: 18),
      label: Text(assignment.type == AssignmentType.theory ? '$name · $target' : name),
      onDeleted: () async {
        final ok = await confirmDialog(
          context,
          title: l10n.assignmentsRemoveTitle,
          body: l10n.assignmentsRemoveBody(name, '${assignment.courseName} · $target'),
          confirmLabel: l10n.delete,
          destructive: true,
        );
        if (!ok) return;
        try {
          await ref.read(assignmentsRepositoryProvider).unassign(assignment);
          if (context.mounted) showSnack(context, l10n.assignmentsRemoved);
        } catch (e) {
          if (context.mounted) showError(context, e);
        }
      },
    );
  }
}

/// Picks a teacher (searchable) and, for theory, a section.
class _AssignDialog extends ConsumerStatefulWidget {
  const _AssignDialog({required this.stageId, required this.withSection});

  final String stageId;
  final bool withSection;

  @override
  ConsumerState<_AssignDialog> createState() => _AssignDialogState();
}

class _AssignDialogState extends ConsumerState<_AssignDialog> {
  String _query = '';
  AppUser? _teacher;
  String? _section;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final users = ref.watch(allUsersProvider);
    final stage = ref.watch(stagesProvider).value?.where((s) => s.id == widget.stageId).firstOrNull;
    final studentSections = ref.watch(stageStudentsProvider(widget.stageId)).value?.map((s) => s.section) ?? const [];
    final sections = {...?stage?.sections, ...studentSections}.where((s) => s.isNotEmpty).toList()..sort();

    return AlertDialog(
      title: Text(widget.withSection ? l10n.assignmentsAssignTheory : l10n.assignmentsTeacher),
      content: SizedBox(
        width: 420,
        height: 420,
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: l10n.assignmentsSearchTeacher),
              onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: AsyncBody<List<AppUser>>(
                value: users,
                data: (all) {
                  final teachers = [
                    for (final u in all)
                      if (u.active &&
                          u.hasRole(UserRole.teacher) &&
                          (_query.isEmpty ||
                              u.name.toLowerCase().contains(_query) ||
                              u.email.contains(_query)))
                        u,
                  ];
                  if (all.isEmpty) return Center(child: Text(l10n.assignmentsNoTeachers));
                  return RadioGroup<String>(
                    groupValue: _teacher?.id,
                    onChanged: (id) => setState(() => _teacher = teachers.firstWhere((t) => t.id == id)),
                    child: ListView(
                      children: [
                        for (final t in teachers)
                          RadioListTile<String>(
                            value: t.id,
                            title: Text(t.displayName),
                            subtitle: Text(t.email, textDirection: TextDirection.ltr),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            if (widget.withSection && sections.isNotEmpty)
              DropdownButtonFormField<String?>(
                initialValue: _section,
                decoration: InputDecoration(labelText: l10n.assignmentsSection),
                items: [
                  DropdownMenuItem(value: null, child: Text(l10n.allSections)),
                  for (final s in sections) DropdownMenuItem(value: s, child: Text(l10n.sectionLabel(s))),
                ],
                onChanged: (v) => setState(() => _section = v),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
        FilledButton(
          onPressed: _teacher == null ? null : () => Navigator.pop(context, (teacher: _teacher!, section: _section)),
          child: Text(l10n.save),
        ),
      ],
    );
  }
}

class _DistributeDialog extends StatefulWidget {
  const _DistributeDialog({
    required this.initial,
    required this.redistributing,
    required this.studentCount,
    required this.stageLabel,
  });

  final int initial;
  final bool redistributing;
  final int studentCount;
  final String stageLabel;

  @override
  State<_DistributeDialog> createState() => _DistributeDialogState();
}

class _DistributeDialogState extends State<_DistributeDialog> {
  late int _count = widget.initial.clamp(1, 12);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.assignmentsCreateGroups),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.assignmentsDistributeBody(widget.studentCount, widget.stageLabel)),
          if (widget.redistributing) ...[
            const SizedBox(height: 8),
            Text(
              l10n.assignmentsRedistributeWarning,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 16),
          Text(l10n.assignmentsGroupCount),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: _count > 1 ? () => setState(() => _count--) : null,
              ),
              Text('$_count', style: Theme.of(context).textTheme.headlineSmall),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: _count < 12 ? () => setState(() => _count++) : null,
              ),
            ],
          ),
          Text([for (var i = 0; i < _count; i++) PracticalGroup.nameFor(i)].join(' · ')),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
        FilledButton(onPressed: () => Navigator.pop(context, _count), child: Text(l10n.assignmentsDistribute)),
      ],
    );
  }
}
