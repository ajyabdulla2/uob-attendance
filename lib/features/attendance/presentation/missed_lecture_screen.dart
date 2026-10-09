import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/domain/stage_ref.dart';
import '../../../core/firebase/doc_ids.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../l10n/l10n.dart';
import '../../academic/application/academic_providers.dart';
import '../../assignments/application/assignments_providers.dart';
import '../../assignments/domain/assignment.dart';
import '../../auth/application/auth_providers.dart';
import '../../courses/application/courses_providers.dart';
import '../../students/application/students_providers.dart';
import '../../students/domain/student.dart';
import '../application/missed_lecture_providers.dart';
import '../domain/attendance_session.dart';
import '../domain/missed_lecture.dart';

/// «تسجيل محاضرة فائتة» (stage managers and admins): a lecture that was not
/// recorded in time, for any class of a stage they manage, on any past day.
/// Online, on the phone or the web panel; teachers' phones download it like
/// their own lectures. Opened from the stage dashboard, optionally on a class
/// ([stageId] + [classKey] = `courseId|type|target`).
class MissedLectureScreen extends ConsumerStatefulWidget {
  const MissedLectureScreen({super.key, this.stageId, this.classKey, this.date});

  final String? stageId;
  final String? classKey;
  final DateTime? date;

  @override
  ConsumerState<MissedLectureScreen> createState() => _MissedLectureScreenState();
}

String classKeyOf(Assignment a) => '${a.courseId}|${a.type.name}|${a.target}';

/// «البرمجة · نظري · كل الشعب» (the stage is chosen above).
String _label(AppLocalizations l10n, Assignment a) => [
      a.courseName.isEmpty ? a.courseId : a.courseName,
      if (a.type == AssignmentType.theory) ...[
        l10n.theoryLabel,
        a.target == DocIds.allSections ? l10n.allSections : l10n.sectionLabel(a.target),
      ] else ...[
        l10n.practicalLabel,
        l10n.groupLabel(a.target),
      ],
    ].join(' · ');

class _MissedLectureScreenState extends ConsumerState<MissedLectureScreen> {
  StageRef? _stage;
  String? _classKey;
  DateTime? _date;
  final _marks = <String, AttendanceStatus>{};
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _stage = widget.stageId == null ? null : StageRef.tryParse(widget.stageId!);
    _classKey = widget.classKey;
    _date = widget.date;
  }

  DateTime get _today {
    final now = DateTime.now();
    return DateTime.utc(now.year, now.month, now.day);
  }

  void _resetMarks() => _marks.clear();

  Future<void> _pickDate() async {
    final today = _today;
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? today.subtract(const Duration(days: 1)),
      firstDate: today.subtract(const Duration(days: MissedLecture.maxDaysBack)),
      lastDate: today,
    );
    if (picked == null || !mounted) return;
    setState(() => _date = DateTime.utc(picked.year, picked.month, picked.day));
  }

  Future<void> _save(Assignment cls, List<Student> students, int lectureNo) async {
    final l10n = context.l10n;
    final year = ref.read(activeYearProvider).value;
    final date = _date;
    if (year == null || date == null) return;
    final marks = {for (final s in students) s.id: _marks[s.id] ?? AttendanceStatus.present};
    final counts = MissedLecture.counts(marks);
    final ok = await confirmDialog(
      context,
      title: l10n.missedTitle,
      body: l10n.missedConfirm(
        lectureNo,
        MaterialLocalizations.of(context).formatMediumDate(date),
        _label(l10n, cls),
        counts[AttendanceStatus.absent]!,
        counts[AttendanceStatus.late]!,
        counts[AttendanceStatus.excused]!,
        counts[AttendanceStatus.present]!,
      ),
      confirmLabel: l10n.missedSave,
    );
    if (!ok || !mounted) return;
    setState(() => _saving = true);
    try {
      await ref.read(missedLectureRepositoryProvider).save(
            cls: cls,
            year: year,
            date: date,
            lectureNo: lectureNo,
            marks: marks,
            actor: ref.read(signedInUserProvider).id,
          );
      if (!mounted) return;
      showSnack(context, l10n.missedSaved);
      setState(_resetMarks);
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final stages = ref.watch(permissionsProvider).manageableStages;
    final stage = _stage != null && stages.contains(_stage) ? _stage : stages.firstOrNull;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.missedTitle)),
      body: stage == null
          ? Center(child: MessageView(icon: Icons.lock_outline, title: l10n.assignmentsNoStages))
          : _body(context, stages, stage),
    );
  }

  Widget _body(BuildContext context, List<StageRef> stages, StageRef stage) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final assignments = ref.watch(stageAssignmentsProvider(stage.id));
    return AsyncBody<List<Assignment>>(
      value: assignments,
      data: (all) {
        final classes = MissedLecture.classes(all);
        final cls = classes.where((a) => classKeyOf(a) == _classKey).firstOrNull;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(l10n.missedHelp, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 16),
            DropdownButtonFormField<StageRef>(
              key: const Key('missed.stage'),
              initialValue: stage,
              isExpanded: true,
              decoration: InputDecoration(labelText: l10n.fixStage, prefixIcon: const Icon(Icons.layers)),
              items: [for (final s in stages) DropdownMenuItem(value: s, child: Text(l10n.stage(s)))],
              onChanged: (s) => setState(() {
                _stage = s;
                _classKey = null;
                _resetMarks();
              }),
            ),
            const SizedBox(height: 12),
            if (classes.isEmpty)
              Text(l10n.missedNoClasses)
            else
              DropdownButtonFormField<String>(
                key: const Key('missed.class'),
                initialValue: cls == null ? null : classKeyOf(cls),
                isExpanded: true,
                hint: Text(l10n.missedPickClass),
                decoration: InputDecoration(labelText: l10n.missedClass, prefixIcon: const Icon(Icons.menu_book)),
                items: [
                  for (final a in classes)
                    DropdownMenuItem(
                      value: classKeyOf(a),
                      child: Text(_label(l10n, a), overflow: TextOverflow.ellipsis),
                    ),
                ],
                onChanged: (k) => setState(() {
                  _classKey = k;
                  _resetMarks();
                }),
              ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              key: const Key('missed.date'),
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_today),
              label: Text(_date == null
                  ? l10n.missedDate
                  : '${l10n.missedDate}: ${MaterialLocalizations.of(context).formatMediumDate(_date!)}'),
            ),
            if (cls != null && _date != null) ..._classPart(context, cls, _date!),
          ],
        );
      },
    );
  }

  List<Widget> _classPart(BuildContext context, Assignment cls, DateTime date) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final palette = StatusPalette.of(context);
    final sessions = ref.watch(sessionsOnDayProvider((stageId: cls.stageId, dateKey: DocIds.dateKey(date))));
    final students = _studentsOf(cls);
    if (sessions.value == null || students == null) {
      return const [Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator()))];
    }
    final lectureNo = MissedLecture.nextLectureNo(cls, sessions.value!, date);
    final counts = MissedLecture.counts({for (final s in students) s.id: _marks[s.id] ?? AttendanceStatus.present});
    return [
      const SizedBox(height: 12),
      Card(
        child: ListTile(
          key: const Key('missed.lectureNo'),
          leading: const Icon(Icons.event_note),
          title: Text(l10n.missedLectureNo(lectureNo)),
        ),
      ),
      if (students.isEmpty)
        Padding(padding: const EdgeInsets.all(16), child: Text(l10n.missedNoStudents))
      else ...[
        const SizedBox(height: 4),
        Text(l10n.missedHint, style: theme.textTheme.bodySmall),
        Wrap(
          spacing: 8,
          children: [
            for (final s in AttendanceStatus.values)
              Chip(
                avatar: Icon(StatusPalette.iconForStatus(s), color: palette.forStatus(s), size: 18),
                label: Text('${l10n.attendance(s)} ${counts[s]}'),
              ),
            TextButton(
              key: const Key('missed.allPresent'),
              onPressed: () => setState(_resetMarks),
              child: Text(l10n.missedAllPresent),
            ),
          ],
        ),
        for (final s in students) _studentTile(context, s),
        const SizedBox(height: 16),
        FilledButton.icon(
          key: const Key('missed.save'),
          onPressed: _saving ? null : () => _save(cls, students, lectureNo),
          icon: const Icon(Icons.save),
          label: Text(l10n.missedSave),
        ),
        const SizedBox(height: 24),
      ],
    ];
  }

  Widget _studentTile(BuildContext context, Student s) {
    final l10n = context.l10n;
    final palette = StatusPalette.of(context);
    final status = _marks[s.id] ?? AttendanceStatus.present;
    final color = palette.forStatus(status);
    return ListTile(
      key: Key('missed.student.${s.id}'),
      contentPadding: EdgeInsets.zero,
      title: Text(s.fullName),
      subtitle: Text(s.universityId),
      trailing: Chip(
        avatar: Icon(StatusPalette.iconForStatus(status), color: color, size: 18),
        label: Text(l10n.attendance(status), style: TextStyle(color: color)),
      ),
      onTap: () => setState(() {
        final next = MissedLecture.next(status);
        if (next == AttendanceStatus.present) {
          _marks.remove(s.id);
        } else {
          _marks[s.id] = next;
        }
      }),
    );
  }

  /// Students of the class in register order, or null while loading.
  List<Student>? _studentsOf(Assignment cls) {
    final students = ref.watch(stageStudentsProvider(cls.stageId)).value;
    if (students == null) return null;
    final attending = students.where((s) => s.attendsLectures);
    switch (cls.type) {
      case AssignmentType.theory:
        return [
          for (final s in attending)
            if (cls.target == DocIds.allSections || s.section == cls.target) s,
        ];
      case AssignmentType.practical:
        final groups = ref.watch(courseGroupsProvider((courseId: cls.courseId, stageId: cls.stageId))).value;
        if (groups == null) return null;
        final ids = groups.where((g) => g.id == cls.groupId).firstOrNull?.studentIds.toSet() ?? const <String>{};
        return [for (final s in attending) if (ids.contains(s.id)) s];
    }
  }
}
