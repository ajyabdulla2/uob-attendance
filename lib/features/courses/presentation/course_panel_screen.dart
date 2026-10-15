import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/domain/stage_ref.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/arabic_text.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../l10n/l10n.dart';
import '../../academic/application/academic_providers.dart';
import '../../assignments/domain/assignment.dart';
import '../../attendance/application/server_register_providers.dart';
import '../../attendance/domain/attendance_session.dart';
import '../../auth/application/auth_providers.dart';
import '../../reports/application/report_builders.dart';
import '../../reports/application/report_exporter.dart';
import '../../stats/domain/student_course_stat.dart';
import '../../data_fix/application/data_fix_providers.dart';
import '../application/courses_providers.dart';
import '../data/course_panel.dart';
import '../domain/course.dart';

/// «لوحة المادة»: pick a stage, then a course.
class CoursePickerScreen extends ConsumerStatefulWidget {
  const CoursePickerScreen({super.key});

  @override
  ConsumerState<CoursePickerScreen> createState() => _CoursePickerScreenState();
}

class _CoursePickerScreenState extends ConsumerState<CoursePickerScreen> {
  StageRef? _stage;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final stages = ref.watch(permissionsProvider).manageableStages;
    final stage = _stage != null && stages.contains(_stage) ? _stage : stages.firstOrNull;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.coursePanelAction)),
      body: stage == null
          ? Center(child: MessageView(icon: Icons.lock_outline, title: l10n.assignmentsNoStages))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: DropdownButtonFormField<StageRef>(
                    key: const Key('coursePanel.stage'),
                    initialValue: stage,
                    decoration: InputDecoration(labelText: l10n.assignmentsPickStage, prefixIcon: const Icon(Icons.layers)),
                    items: [for (final s in stages) DropdownMenuItem(value: s, child: Text(l10n.stage(s)))],
                    onChanged: (s) => setState(() => _stage = s),
                  ),
                ),
                Expanded(
                  child: AsyncBody<List<Course>>(
                    value: ref.watch(stageCoursesProvider(stage.id)),
                    data: (courses) => courses.isEmpty
                        ? Center(child: MessageView(icon: Icons.menu_book_outlined, title: l10n.assignmentsNoCourses))
                        : ListView(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            children: [
                              for (final c in courses)
                                Card(
                                  child: ListTile(
                                    key: Key('coursePanel.pick.${c.id}'),
                                    leading: Icon(c.hasPractical ? Icons.computer : Icons.menu_book),
                                    title: Text(c.name),
                                    subtitle: Text(courseInfo(context, ref, c)),
                                    trailing: const Icon(Icons.chevron_right),
                                    onTap: () => context.push(Routes.coursePanelFor(c.id)),
                                  ),
                                ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
    );
  }
}

/// «الرمز X · 3 وحدات · الفصل 1» (or «سنوية»).
String courseInfo(BuildContext context, WidgetRef ref, Course c) {
  final l10n = context.l10n;
  return ref.watch(activeYearProvider).value?.isAnnual(c.stageId) == true
      ? l10n.assignmentsCourseInfoAnnual(bidiIsolate(c.code), '${c.units}')
      : l10n.assignmentsCourseInfo(bidiIsolate(c.code), '${c.units}', '${c.semester}');
}

/// One course from the server: information and teachers, every lecture
/// recorded, the students with their percentages, and a PDF/Excel export.
class CoursePanelScreen extends ConsumerWidget {
  const CoursePanelScreen({super.key, required this.courseId});

  final String courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final value = ref.watch(coursePanelProvider(courseId));
    final p = value.value;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(p?.course.name ?? l10n.coursePanelAction),
          actions: [
            if (p != null)
              IconButton(
                key: const Key('coursePanel.export'),
                tooltip: l10n.coursePanelExport,
                icon: const Icon(Icons.download),
                onPressed: () {
                  final formatDate = MaterialLocalizations.of(context).formatMediumDate;
                  final info = courseInfo(context, ref, p.course);
                  exportReport(
                    context,
                    ref,
                    year: p.year,
                    build: (_) => ReportBuilders.coursePanel(
                      l10n,
                      panel: p,
                      stageLabel: l10n.stageId(p.course.stageId),
                      courseInfo: info,
                      formatDate: formatDate,
                    ),
                  );
                },
              ),
            IconButton(
              key: const Key('coursePanel.refresh'),
              tooltip: l10n.registerRefresh,
              icon: const Icon(Icons.refresh),
              onPressed: value.isLoading ? null : () => ref.invalidate(coursePanelProvider(courseId)),
            ),
          ],
          bottom: p == null
              ? null
              : TabBar(
                  tabs: [
                    Tab(key: const Key('coursePanel.tab.info'), text: l10n.coursePanelInfo),
                    Tab(key: const Key('coursePanel.tab.lectures'), text: l10n.coursePanelLectures(p.sessions.length)),
                    Tab(key: const Key('coursePanel.tab.students'), text: l10n.coursePanelStudents(p.students.length)),
                  ],
                ),
        ),
        body: AsyncBody<CoursePanel?>(
          value: value,
          data: (p) => p == null
              ? Center(child: MessageView(icon: Icons.link_off, title: l10n.coursePanelMissing))
              : TabBarView(
                  children: [
                    _InfoTab(panel: p),
                    _LecturesTab(panel: p),
                    _StudentsTab(panel: p),
                  ],
                ),
        ),
      ),
    );
  }
}

class _InfoTab extends ConsumerWidget {
  const _InfoTab({required this.panel});

  final CoursePanel panel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final c = panel.course;
    final last = panel.sessions.firstOrNull;
    final levels = <WarningLevel, int>{};
    for (final s in panel.students) {
      final level = s.worst?.level ?? WarningLevel.none;
      if (level != WarningLevel.none) levels[level] = (levels[level] ?? 0) + 1;
    }
    Widget line(IconData icon, String text) => ListTile(dense: true, leading: Icon(icon), title: Text(text));
    return ListView(
      key: const Key('coursePanel.info'),
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(c.name, style: theme.textTheme.titleLarge),
                ),
                line(Icons.layers, l10n.stageId(c.stageId)),
                line(Icons.menu_book_outlined, courseInfo(context, ref, c)),
                line(c.hasPractical ? Icons.computer : Icons.menu_book,
                    c.hasPractical ? l10n.coursePanelWithPractical(panel.groups.length) : l10n.coursePanelTheoryOnly),
                line(Icons.groups_outlined, l10n.reportStudentCount(panel.students.length)),
                line(Icons.event_note, l10n.reportLectureCount(panel.sessions.length)),
                if (last != null)
                  line(Icons.schedule, l10n.coursePanelLastLecture(MaterialLocalizations.of(context).formatMediumDate(last.date))),
                if (levels.isNotEmpty)
                  line(
                    Icons.warning_amber,
                    [
                      for (final l in [WarningLevel.alert, WarningLevel.warning, WarningLevel.dismissal])
                        if (levels[l] case final n?) '${l10n.warningLevel(l)}: $n',
                    ].join(' · '),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(l10n.coursePanelClasses, style: theme.textTheme.titleMedium),
        Text(l10n.coursePanelClassesHelp, style: theme.textTheme.bodySmall),
        const SizedBox(height: 4),
        if (panel.classes.isEmpty && panel.groups.isEmpty)
          Card(child: ListTile(leading: const Icon(Icons.link_off), title: Text(l10n.coursePanelNoClasses))),
        for (final a in panel.theoryClasses) _ClassRow(panel: panel, assignment: a),
        ..._practical(context),
      ],
    );
  }

  /// The practical groups under one «العملي» row when there are several,
  /// so they do not crowd the screen.
  List<Widget> _practical(BuildContext context) {
    final l10n = context.l10n;
    final byGroup = <String, List<Assignment>>{
      for (final g in panel.groups) g.name: [],
    };
    for (final a in panel.practicalClasses) {
      (byGroup[a.target] ??= []).add(a);
    }
    final rows = [
      for (final MapEntry(key: name, value: list) in byGroup.entries)
        if (list.isEmpty)
          ListTile(
            dense: true,
            leading: const Icon(Icons.computer),
            title: Text(l10n.groupLabel(name)),
            subtitle: Text(l10n.coursePanelNoTeacher),
          )
        else
          for (final a in list) _ClassRow(panel: panel, assignment: a, inCard: false),
    ];
    if (rows.isEmpty) return const [];
    if (rows.length == 1) return [Card(child: rows.single)];
    return [
      Card(
        child: ExpansionTile(
          key: const Key('coursePanel.practical'),
          shape: const Border(),
          leading: const Icon(Icons.computer),
          title: Text(l10n.practicalLabel),
          subtitle: Text(l10n.homeGroupsList(byGroup.keys.join('، '))),
          children: rows,
        ),
      ),
    ];
  }
}

/// A class with its teacher and lecture count; opens its register.
class _ClassRow extends StatelessWidget {
  const _ClassRow({required this.panel, required this.assignment, this.inCard = true});

  final CoursePanel panel;
  final Assignment assignment;
  final bool inCard;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final a = assignment;
    final theory = a.type == AssignmentType.theory;
    final tile = ListTile(
      key: Key('coursePanel.class.${a.id}'),
      leading: Icon(theory ? Icons.menu_book : Icons.computer),
      title: Text(a.teacherName.isEmpty ? a.teacherId : a.teacherName),
      subtitle: Text('${theory ? l10n.theoryLabel : l10n.groupLabel(a.target)} · '
          '${l10n.coursePanelLectureCount(panel.lecturesOf(a))}'),
      trailing: const Icon(Icons.table_chart_outlined),
      onTap: () => context.push(Routes.classRegisterFor(a.id)),
    );
    return inCard ? Card(child: tile) : tile;
  }
}

class _LecturesTab extends StatelessWidget {
  const _LecturesTab({required this.panel});

  final CoursePanel panel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (panel.sessions.isEmpty) {
      return Center(child: MessageView(icon: Icons.event_note, title: l10n.registerEmpty));
    }
    final palette = StatusPalette.of(context);
    final date = MaterialLocalizations.of(context).formatMediumDate;
    return ListView(
      key: const Key('coursePanel.lectures'),
      padding: const EdgeInsets.all(16),
      children: [
        for (final s in panel.sessions)
          Card(
            child: ListTile(
              key: Key('coursePanel.session.${s.id}'),
              title: Text('${date(s.date)} · ${l10n.activityLectureNo(s.lectureNo)}'),
              subtitle: Text('${l10n.sessionClassLabel(s)}\n${panel.teacherOf(s)}'),
              isThreeLine: true,
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final st in const [AttendanceStatus.present, AttendanceStatus.absent])
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${panel.count(s, st)} '),
                        Icon(StatusPalette.iconForStatus(st), size: 16, color: palette.forStatus(st)),
                      ],
                    ),
                ],
              ),
              onTap: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                showDragHandle: true,
                builder: (_) => _LectureSheet(panel: panel, session: s),
              ),
            ),
          ),
      ],
    );
  }
}

/// One lecture: who was absent, late or excused (read when opened).
class _LectureSheet extends ConsumerWidget {
  const _LectureSheet({required this.panel, required this.session});

  final CoursePanel panel;
  final AttendanceSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final palette = StatusPalette.of(context);
    final s = session;
    final names = {for (final r in panel.students) r.student.id: r.student.fullName};
    final marks = ref.watch(sessionMarksProvider(s.id));
    return SafeArea(
      child: ListView(
        key: const Key('coursePanel.lecture'),
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Text('${MaterialLocalizations.of(context).formatMediumDate(s.date)} · ${l10n.activityLectureNo(s.lectureNo)}',
              style: theme.textTheme.titleLarge),
          Text('${l10n.sessionClassLabel(s)} · ${panel.teacherOf(s)}', style: theme.textTheme.bodySmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            children: [
              for (final st in AttendanceStatus.values)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(StatusPalette.iconForStatus(st), size: 18, color: palette.forStatus(st)),
                    Text(' ${l10n.attendance(st)} ${panel.count(s, st)}'),
                  ],
                ),
            ],
          ),
          const Divider(),
          if (ref.watch(permissionsProvider).canFixData)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                key: const Key('coursePanel.deleteLecture'),
                style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
                icon: const Icon(Icons.delete_forever),
                label: Text(l10n.coursePanelDeleteLecture),
                onPressed: () => _delete(context, ref),
              ),
            ),
          marks.when(
            loading: () => const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator())),
            error: (e, _) => Text(l10n.activityLecturesError),
            data: (m) {
              final notPresent = [
                for (final MapEntry(key: id, value: st) in m.entries)
                  if (st != AttendanceStatus.present) (id: id, status: st),
              ]..sort((a, b) => a.status != b.status
                  ? a.status.index.compareTo(b.status.index)
                  : (names[a.id] ?? a.id).compareTo(names[b.id] ?? b.id));
              if (notPresent.isEmpty) {
                return Padding(padding: const EdgeInsets.all(8), child: Text(l10n.coursePanelAllPresent));
              }
              return Column(
                children: [
                  for (final r in notPresent)
                    ListTile(
                      dense: true,
                      leading: Icon(StatusPalette.iconForStatus(r.status), color: palette.forStatus(r.status)),
                      title: Text(names[r.id] ?? r.id),
                      trailing: Text(l10n.attendance(r.status)),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  /// Deletes this lecture with its attendance and its place in the
  /// students' percentages (the data-fix lecture deletion, for one lecture).
  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final s = session;
    final label = '${panel.course.name} · ${MaterialLocalizations.of(context).formatMediumDate(s.date)} · '
        '${l10n.sessionClassLabel(s)} · ${l10n.activityLectureNo(s.lectureNo)}';
    final ok = await confirmDialog(
      context,
      title: l10n.coursePanelDeleteLecture,
      body: l10n.coursePanelDeleteLectureBody(label),
      confirmLabel: l10n.delete,
      destructive: true,
    );
    if (!ok || !context.mounted) return;
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final repo = ref.read(dataFixRepositoryProvider);
      final plan = await repo.planLectureDeletion(
        s.date,
        s.date,
        stageId: s.stageId,
        courseId: s.courseId,
        onlySessionIds: {s.id},
        actor: ref.read(signedInUserProvider).id,
        rejectNote: l10n.fixLecturesRejectNote,
      );
      if (!plan.canApply) {
        // Nothing found on the server under this lecture's ID: say so
        // instead of reporting a deletion that did not happen.
        ref.invalidate(coursePanelProvider(panel.course.id));
        navigator.pop();
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(l10n.coursePanelLectureNotFound)));
        return;
      }
      await repo.apply(plan);
      ref.invalidate(coursePanelProvider(panel.course.id));
      navigator.pop();
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.coursePanelLectureDeleted)));
    } on Object catch (e) {
      if (context.mounted) showError(context, e);
    }
  }
}

class _StudentsTab extends StatefulWidget {
  const _StudentsTab({required this.panel});

  final CoursePanel panel;

  @override
  State<_StudentsTab> createState() => _StudentsTabState();
}

class _StudentsTabState extends State<_StudentsTab> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = StatusPalette.of(context);
    final shown = [
      for (final r in widget.panel.students)
        if (_query.isEmpty ||
            ArabicText.normalizeForCompare(r.student.fullName).contains(_query) ||
            r.student.universityId.contains(_query))
          r,
    ];
    String label(String key) => switch (key) {
          '' => '',
          'theory' => '${l10n.theoryLabel} ',
          _ => '${l10n.practicalLabel} ',
        };
    return ListView(
      key: const Key('coursePanel.students'),
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          key: const Key('coursePanel.search'),
          decoration: InputDecoration(hintText: l10n.coursePanelSearch, prefixIcon: const Icon(Icons.search)),
          onChanged: (v) => setState(() => _query = ArabicText.normalizeForCompare(v)),
        ),
        const SizedBox(height: 8),
        if (widget.panel.students.isEmpty)
          Padding(padding: const EdgeInsets.all(24), child: Center(child: Text(l10n.recordNoStudents))),
        for (final r in shown)
          Card(
            child: ListTile(
              key: Key('coursePanel.student.${r.student.id}'),
              title: Text(r.student.fullName),
              subtitle: Text([
                bidiIsolate(r.student.universityId),
                if (r.student.section.isNotEmpty) l10n.sectionLabel(r.student.section),
                if (r.group != null) l10n.groupLabel(r.group!),
              ].join(' · ')),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final MapEntry(key: k, value: sum) in r.summaries.entries)
                    Text(
                      sum.planned == 0
                          ? '${label(k)}–'
                          : '${label(k)}${ReportBuilders.percent(sum.percent)}% (${sum.absences})',
                      style: TextStyle(
                        color: palette.forLevel(sum.level),
                        fontWeight: sum.level == WarningLevel.none ? null : FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
