import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../l10n/l10n.dart';
import '../../assignments/domain/assignment.dart';
import '../../reports/application/report_builders.dart';
import '../../reports/application/report_exporter.dart';
import '../../stats/domain/absence_summary.dart';
import '../../stats/domain/student_course_stat.dart';
import '../../students/domain/student.dart';
import '../application/attendance_providers.dart';
import '../application/server_register_providers.dart';
import '../domain/attendance_session.dart';
import 'register_export.dart';

/// سجل الحضور of one class: students × lectures, with the number of
/// absences. A lecture's header opens it in the record screen.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key, required this.assignmentId});

  final String assignmentId;

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  bool _pulling = false;
  bool _pullStarted = false;

  Future<void> _refresh(Assignment a, {bool quiet = false}) async {
    final l10n = context.l10n;
    setState(() => _pulling = true);
    try {
      final sync = ref.read(teacherDataSyncProvider);
      final stored = await sync.pullClassSessions(a, ref.read(attendanceStoreProvider)).timeout(const Duration(seconds: 30));
      await sync.pullStanding(a).timeout(const Duration(seconds: 30));
      ref.read(standingCacheTickProvider.notifier).bump();
      if (!quiet && mounted) showSnack(context, l10n.registerPulled(stored));
    } on Object {
      if (mounted) showSnack(context, l10n.registerOffline);
    } finally {
      if (mounted) setState(() => _pulling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (!ref.watch(localFirstProvider)) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.registerTitle)),
        body: Center(child: MessageView(icon: Icons.phone_android, title: l10n.homeRecordOnPhone)),
      );
    }
    final classes = ref.watch(localClassesProvider);
    final a = ref.watch(localClassProvider(widget.assignmentId));
    final students = ref.watch(classStudentsProvider(widget.assignmentId));
    final sessions = ref.watch(classSessionsProvider(widget.assignmentId));
    final marks = ref.watch(classMarksProvider(widget.assignmentId));

    if (a != null && !_pullStarted) {
      _pullStarted = true;
      Future.microtask(() => _refresh(a, quiet: true));
    }

    final Widget body;
    if (!classes.hasValue || !students.hasValue || !sessions.hasValue || !marks.hasValue) {
      body = const Center(child: CircularProgressIndicator());
    } else if (a == null) {
      body = Center(child: MessageView(icon: Icons.link_off, title: l10n.recordClassMissing));
    } else if (sessions.value!.isEmpty) {
      body = Center(child: MessageView(icon: Icons.event_note, title: l10n.registerEmpty));
    } else if (students.value!.isEmpty) {
      body = Center(child: MessageView(icon: Icons.group_off, title: l10n.recordNoStudents));
    } else {
      body = _RegisterTable(
        assignment: a,
        students: students.value!,
        sessions: sessions.value!,
        marks: marks.value!,
        standings: ref.watch(classStandingsProvider(widget.assignmentId)).value ?? const {},
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(a == null ? l10n.registerTitle : (a.courseName.isEmpty ? a.courseId : a.courseName)),
        actions: [
          if (a != null && students.hasValue && sessions.hasValue && (sessions.value?.isNotEmpty ?? false))
            IconButton(
              key: const Key('register.export'),
              tooltip: l10n.reportRegisterAction,
              icon: const Icon(Icons.download),
              onPressed: () async {
                final whole = await chooseRegisterScope(context, first: l10n.reportThisClassAction, firstIcon: Icons.menu_book);
                if (whole == null || !context.mounted) return;
                if (whole) return loadAndExportCourseRegister(context, ref, a.courseId, withClasses: false);
                final period = await chooseRegisterPeriod(context, sessions.value!);
                if (period == null || !context.mounted) return;
                final formatDate = MaterialLocalizations.of(context).formatMediumDate;
                await exportReport(
                  context,
                  ref,
                  year: ref.read(cachedYearProvider).value,
                  build: (format) => ReportBuilders.classRegister(
                    l10n,
                    assignment: a,
                    courseName: a.courseName.isEmpty ? a.courseId : a.courseName,
                    students: students.value!,
                    sessions: sessions.value!,
                    marks: marks.value ?? const {},
                    standings: ref.read(classStandingsProvider(widget.assignmentId)).value ?? const {},
                    format: format,
                    period: period.range,
                    formatDate: formatDate,
                  ),
                );
              },
            ),
          if (a != null)
            IconButton(
              key: const Key('register.refresh'),
              tooltip: l10n.registerRefresh,
              icon: _pulling
                  ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.cloud_sync),
              onPressed: _pulling ? null : () => _refresh(a),
            ),
        ],
      ),
      body: Column(
        children: [
          if (a != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(l10n.classLabel(a), style: Theme.of(context).textTheme.bodySmall),
              ),
            ),
          Expanded(child: body),
        ],
      ),
      floatingActionButton: a == null
          ? null
          : FloatingActionButton.extended(
              key: const Key('register.record'),
              icon: const Icon(Icons.how_to_reg),
              label: Text(l10n.recordAction),
              onPressed: () => context.push(Routes.recordFor(a.id)),
            ),
    );
  }
}

/// A class register as stored on the server, for the admins: read-only,
/// with the same table and PDF/Excel export as the teacher's own register.
class ServerRegisterScreen extends ConsumerWidget {
  const ServerRegisterScreen({super.key, required this.assignmentId});

  final String assignmentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final value = ref.watch(serverRegisterProvider(assignmentId));
    final r = value.value;
    return Scaffold(
      appBar: AppBar(
        title: Text(r == null ? l10n.registerTitle : r.courseName),
        actions: [
          if (r != null && r.sessions.isNotEmpty)
            IconButton(
              key: const Key('serverRegister.export'),
              tooltip: l10n.reportRegisterAction,
              icon: const Icon(Icons.download),
              onPressed: () async {
                final whole = await chooseRegisterScope(context, first: l10n.reportThisClassAction, firstIcon: Icons.menu_book);
                if (whole == null || !context.mounted) return;
                if (whole) return loadAndExportCourseRegister(context, ref, r.assignment.courseId, withClasses: true);
                final period = await chooseRegisterPeriod(context, r.sessions);
                if (period == null || !context.mounted) return;
                final formatDate = MaterialLocalizations.of(context).formatMediumDate;
                await exportReport(
                  context,
                  ref,
                  year: r.year,
                  build: (format) => ReportBuilders.classRegister(
                    l10n,
                    assignment: r.assignment,
                    courseName: r.courseName,
                    students: r.students,
                    sessions: r.sessions,
                    marks: r.marks,
                    standings: r.standings,
                    format: format,
                    period: period.range,
                    formatDate: formatDate,
                  ),
                );
              },
            ),
          IconButton(
            key: const Key('serverRegister.refresh'),
            tooltip: l10n.registerRefresh,
            icon: const Icon(Icons.refresh),
            onPressed: value.isLoading ? null : () => ref.invalidate(serverRegisterProvider(assignmentId)),
          ),
        ],
      ),
      body: AsyncBody(
        value: value,
        data: (r) {
          if (r == null) return Center(child: MessageView(icon: Icons.link_off, title: l10n.recordClassMissing));
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    '${l10n.classLabel(r.assignment)} · ${r.assignment.teacherName.isEmpty ? r.assignment.teacherId : r.assignment.teacherName}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
              Expanded(
                child: r.sessions.isEmpty
                    ? Center(child: MessageView(icon: Icons.event_note, title: l10n.registerEmpty))
                    : r.students.isEmpty
                        ? Center(child: MessageView(icon: Icons.group_off, title: l10n.recordNoStudents))
                        : _RegisterTable(
                            assignment: r.assignment,
                            students: r.students,
                            sessions: r.sessions,
                            marks: r.marks,
                            standings: r.standings,
                            interactive: false,
                          ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RegisterTable extends StatelessWidget {
  const _RegisterTable({
    required this.assignment,
    required this.students,
    required this.sessions,
    required this.marks,
    required this.standings,
    this.interactive = true,
  });

  /// False on the server copy (admins): lectures and names open nothing,
  /// since the record and student screens read the phone's database.
  final bool interactive;
  final Map<String, AbsenceSummary> standings;
  final Assignment assignment;
  final List<Student> students;
  final List<AttendanceSession> sessions;
  final Map<String, Map<String, AttendanceStatus>> marks;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = StatusPalette.of(context);
    final theme = Theme.of(context);

    int absences(String studentId) =>
        sessions.where((s) => !s.excluded && marks[s.id]?[studentId] == AttendanceStatus.absent).length;
    final faded = theme.colorScheme.onSurfaceVariant;

    return Scrollbar(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: interactive ? 88 : 16), // clear the FAB
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            key: const Key('register.table'),
            columnSpacing: 12,
            horizontalMargin: 12,
            headingRowHeight: 56,
            dataRowMinHeight: 40,
            dataRowMaxHeight: 48,
            columns: [
              DataColumn(label: Text(l10n.registerStudent)),
              DataColumn(label: Text(l10n.registerAbsences), numeric: true),
              DataColumn(
                label: Tooltip(message: l10n.registerPercentHelp, child: Text(l10n.registerPercent)),
                numeric: true,
              ),
              for (final s in sessions)
                DataColumn(
                  label: Tooltip(
                    message: s.excluded ? l10n.lectureExcludedHelp : l10n.registerOpenLecture,
                    child: InkWell(
                      key: Key('register.session.${s.id}'),
                      onTap: interactive
                          ? () => context.push(Routes.recordFor(assignment.id, date: s.date, lectureNo: s.lectureNo))
                          : null,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('${s.date.day}/${s.date.month}', style: theme.textTheme.labelSmall),
                          Text('#${s.lectureNo}', style: theme.textTheme.labelSmall),
                          if (s.excluded)
                            Text(
                              l10n.lectureExcludedShort,
                              key: Key('register.excluded.${s.id}'),
                              style: theme.textTheme.labelSmall?.copyWith(color: faded),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
            rows: [
              for (final st in students)
                DataRow(cells: [
                  DataCell(
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 220),
                      child: Text(
                        st.fullName,
                        overflow: TextOverflow.ellipsis,
                        style: interactive
                            ? TextStyle(color: theme.colorScheme.primary, decoration: TextDecoration.underline)
                            : null,
                      ),
                    ),
                    onTap: interactive ? () => context.push(Routes.studentFor(assignment.id, st.id)) : null,
                  ),
                  DataCell(Text('${absences(st.id)}')),
                  DataCell(_PercentCell(key: Key('register.percent.${st.id}'), summary: standings[st.id])),
                  for (final s in sessions)
                    DataCell(switch (marks[s.id]?[st.id]) {
                      final status? => Tooltip(
                          message: s.excluded
                              ? '${l10n.attendance(status)} · ${l10n.lectureExcludedShort}'
                              : l10n.attendance(status),
                          child: Icon(
                            StatusPalette.iconForStatus(status),
                            color: s.excluded ? faded.withValues(alpha: 0.5) : palette.forStatus(status),
                            size: 20,
                          ),
                        ),
                      null => const Text('–'),
                    }),
                ]),
            ],
          ),
        ),
      ),
    );
  }
}

/// The student's percentage in the course, coloured by level, with ⚠ when
/// one more absence reaches the next level.
class _PercentCell extends StatelessWidget {
  const _PercentCell({super.key, required this.summary});

  final AbsenceSummary? summary;

  @override
  Widget build(BuildContext context) {
    final s = summary;
    if (s == null || s.planned == 0) return const Text('–');
    final l10n = context.l10n;
    final color = StatusPalette.of(context).forLevel(s.level);
    final next = s.nextLevel;
    final edge = next != null && s.untilNext == 1;
    return Tooltip(
      message: [
        l10n.warnAbsences(s.absences, s.planned, s.percent.toStringAsFixed(1)),
        if (s.level != WarningLevel.none) l10n.warningLevel(s.level),
        if (edge) l10n.warnOneMore(l10n.warningLevel(next)),
      ].join('\n'),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (edge) Icon(Icons.warning_amber, size: 16, color: StatusPalette.of(context).forLevel(next)),
          Text(
            '${s.percent.toStringAsFixed(1)}%',
            style: TextStyle(color: color, fontWeight: s.level == WarningLevel.none ? null : FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
