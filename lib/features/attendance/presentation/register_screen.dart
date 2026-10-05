import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../l10n/l10n.dart';
import '../../assignments/domain/assignment.dart';
import '../../students/domain/student.dart';
import '../application/attendance_providers.dart';
import '../domain/attendance_session.dart';

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
      final stored = await ref
          .read(teacherDataSyncProvider)
          .pullClassSessions(a, ref.read(attendanceStoreProvider))
          .timeout(const Duration(seconds: 30));
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
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(a == null ? l10n.registerTitle : (a.courseName.isEmpty ? a.courseId : a.courseName)),
        actions: [
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

class _RegisterTable extends StatelessWidget {
  const _RegisterTable({
    required this.assignment,
    required this.students,
    required this.sessions,
    required this.marks,
  });

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
        sessions.where((s) => marks[s.id]?[studentId] == AttendanceStatus.absent).length;

    return Scrollbar(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 88), // clear the FAB
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
              for (final s in sessions)
                DataColumn(
                  label: Tooltip(
                    message: l10n.registerOpenLecture,
                    child: InkWell(
                      key: Key('register.session.${s.id}'),
                      onTap: () => context.push(Routes.recordFor(assignment.id, date: s.date, lectureNo: s.lectureNo)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('${s.date.day}/${s.date.month}', style: theme.textTheme.labelSmall),
                          Text('#${s.lectureNo}', style: theme.textTheme.labelSmall),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
            rows: [
              for (final st in students)
                DataRow(cells: [
                  DataCell(ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 220),
                    child: Text(st.fullName, overflow: TextOverflow.ellipsis),
                  )),
                  DataCell(Text('${absences(st.id)}')),
                  for (final s in sessions)
                    DataCell(switch (marks[s.id]?[st.id]) {
                      final status? => Tooltip(
                          message: l10n.attendance(status),
                          child: Icon(StatusPalette.iconForStatus(status), color: palette.forStatus(status), size: 20),
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
