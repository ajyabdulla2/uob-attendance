import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/domain/stage_ref.dart';
import '../../../core/firebase/doc_ids.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../l10n/l10n.dart';
import '../../auth/application/auth_providers.dart';
import '../../courses/application/courses_providers.dart';
import '../../courses/domain/course.dart';
import '../application/data_fix_providers.dart';
import '../data/data_fix_repository.dart';
import '../domain/fix_plan.dart';

enum _Tool { rename, delete }

enum _DeleteKind { students, courses, teachers, lectures }

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

  /// Lecture deletion: the days, and one stage or (null) every stage.
  DateTimeRange? _days;
  StageRef? _lectureStage;

  /// Lecture deletion: one course of [_lectureStage] (null = all its courses).
  String? _lectureCourse;
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
    final repo = ref.read(dataFixRepositoryProvider);
    final actor = ref.read(signedInUserProvider).id;
    final l10n = context.l10n;
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
            _DeleteKind.teachers => await repo.planTeacherDeletion(onlyEmail: _only.text, actor: actor),
            _DeleteKind.lectures => _days == null
                ? null
                : await repo.planLectureDeletion(
                    _days!.start,
                    _days!.end,
                    stageId: _lectureStage?.id,
                    courseId: _lectureStage == null ? null : _lectureCourse,
                    actor: actor,
                    rejectNote: l10n.fixLecturesRejectNote,
                  ),
          },
      };
      if (plan == null) {
        if (mounted) showSnack(context, l10n.fixLecturesPickDays);
        return;
      }
      if (mounted) setState(() => _plan = plan);
    } on Object catch (e) {
      if (mounted) showError(context, e);
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

  Future<void> _pickDays() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year, now.month, now.day),
      initialDateRange: _days,
      helpText: context.l10n.fixLecturesPickDays,
    );
    if (picked == null || !mounted) return;
    if (picked.end.difference(picked.start).inDays >= DataFixRepository.maxDays) {
      showSnack(context, context.l10n.fixLecturesTooLong(DataFixRepository.maxDays));
      return;
    }
    _reset(() => _days = picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final perms = ref.watch(permissionsProvider);
    final kinds = [FixKind.student, FixKind.course, if (perms.canRenameTeachers) FixKind.teacher];
    final kind = kinds.contains(_kind) ? _kind : FixKind.student;
    final deleteKinds = [
      _DeleteKind.students,
      _DeleteKind.courses,
      _DeleteKind.lectures,
      if (perms.canRenameTeachers) _DeleteKind.teachers,
    ];
    final deleteKind = deleteKinds.contains(_deleteKind) ? _deleteKind : _DeleteKind.students;
    final lectures = _tool == _Tool.delete && deleteKind == _DeleteKind.lectures;
    final needsStage = _tool == _Tool.delete
        ? deleteKind != _DeleteKind.teachers && !lectures
        : kind == FixKind.course;
    final format = MaterialLocalizations.of(context).formatMediumDate;
    final ltr = _tool == _Tool.rename ? kind == FixKind.teacher : deleteKind == _DeleteKind.teachers;
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
                  key: const Key('fix.deleteKind'),
                  segments: [
                    for (final k in deleteKinds)
                      ButtonSegment(
                        value: k,
                        label: Text(switch (k) {
                          _DeleteKind.students => l10n.fixDeleteStudents,
                          _DeleteKind.courses => l10n.fixDeleteCourses,
                          _DeleteKind.teachers => l10n.fixDeleteTeachers,
                          _DeleteKind.lectures => l10n.fixDeleteLectures,
                        }),
                      ),
                  ],
                  selected: {deleteKind},
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
              if (lectures) ...[
                DropdownButtonFormField<StageRef?>(
                  key: const Key('fix.lectureStage'),
                  initialValue: _lectureStage,
                  decoration: InputDecoration(labelText: l10n.fixStage, prefixIcon: const Icon(Icons.layers)),
                  items: [
                    DropdownMenuItem(value: null, child: Text(l10n.fixAllStages)),
                    for (final s in StageRef.all) DropdownMenuItem(value: s, child: Text(l10n.stage(s))),
                  ],
                  onChanged: _busy
                      ? null
                      : (s) => _reset(() {
                            _lectureStage = s;
                            _lectureCourse = null;
                          }),
                ),
                const SizedBox(height: 12),
                if (_lectureStage case final stage?) ...[
                  DropdownButtonFormField<String?>(
                    key: ValueKey('fix.lectureCourse.${stage.id}'),
                    initialValue: _lectureCourse,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: l10n.fixLecturesCourse,
                      prefixIcon: const Icon(Icons.menu_book_outlined),
                    ),
                    items: [
                      DropdownMenuItem(value: null, child: Text(l10n.fixAllCourses)),
                      for (final c in ref.watch(stageCoursesProvider(stage.id)).value ?? const <Course>[])
                        DropdownMenuItem(
                          value: c.id,
                          child: Text('${c.name} (${bidiIsolate(c.code)})', overflow: TextOverflow.ellipsis),
                        ),
                    ],
                    onChanged: _busy ? null : (c) => _reset(() => _lectureCourse = c),
                  ),
                  const SizedBox(height: 12),
                ],
                OutlinedButton.icon(
                  key: const Key('fix.days'),
                  icon: const Icon(Icons.date_range),
                  label: Text(switch (_days) {
                    null => l10n.fixLecturesPickDays,
                    final d when DateUtils.isSameDay(d.start, d.end) => format(d.start),
                    final d => l10n.fixLecturesDays(format(d.start), format(d.end)),
                  }),
                  onPressed: _busy ? null : _pickDays,
                ),
                const SizedBox(height: 8),
                Text(l10n.fixDeleteLecturesHelp, style: theme.textTheme.bodySmall),
              ] else if (_tool == _Tool.rename) ...[
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
                  textDirection: ltr ? TextDirection.ltr : null,
                  keyboardType: ltr ? TextInputType.emailAddress : null,
                  decoration: ltr
                      ? InputDecoration(labelText: l10n.fixOnlyEmail, hintText: l10n.fixOnlyTeacherHint)
                      : InputDecoration(labelText: l10n.fixOnlyOne, hintText: l10n.fixOnlyOneHint),
                  onChanged: (_) => _reset(() {}),
                ),
                const SizedBox(height: 8),
                Text(ltr ? l10n.fixDeleteTeachersHelp : l10n.fixDeleteHelp, style: theme.textTheme.bodySmall),
              ],
              const SizedBox(height: 4),
              Text(lectures ? l10n.fixLecturesPhonesNote : l10n.fixPhonesNote, style: theme.textTheme.bodySmall),
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
            if (plan.sessionIds.isNotEmpty) ...[
              const SizedBox(height: 8),
              ExpansionTile(
                key: const Key('fix.lectures'),
                tilePadding: EdgeInsets.zero,
                shape: const Border(),
                title: Text(l10n.fixLecturesList(plan.sessionIds.length), style: theme.textTheme.titleSmall),
                children: [
                  for (final id in plan.sessionIds)
                    ListTile(dense: true, contentPadding: EdgeInsets.zero, title: Text(lectureLabel(context, id))),
                ],
              ),
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

/// «12 تشرين الأول · CS101 · نظري · كل الشعب · المحاضرة 1 · المرحلة الأولى صباحي»
/// from a session ID (`{courseId}__{type}__{target}__{yyyyMMdd}__{no}`).
String lectureLabel(BuildContext context, String sessionId) {
  final l10n = context.l10n;
  final p = sessionId.split('__');
  if (p.length != 5) return sessionId;
  final courseId = p[0];
  final cut = courseId.indexOf('_');
  final code = cut < 0 ? courseId : courseId.substring(0, cut);
  final stage = cut < 0 ? '' : courseId.substring(cut + 1);
  final date = DocIds.parseDateKey(p[3]);
  return [
    if (date != null) MaterialLocalizations.of(context).formatMediumDate(date),
    bidiIsolate(code),
    if (p[1] == 'theory') ...[
      l10n.theoryLabel,
      p[2] == DocIds.allSections ? l10n.allSections : l10n.sectionLabel(p[2]),
    ] else
      l10n.groupLabel(p[2]),
    l10n.activityLectureNo(int.tryParse(p[4]) ?? 1),
    if (stage.isNotEmpty) l10n.stageId(stage),
  ].join(' · ');
}
