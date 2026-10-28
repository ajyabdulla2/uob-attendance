import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../l10n/l10n.dart';
import '../../stats/domain/absence_entry.dart';
import '../../stats/domain/absence_summary.dart';
import '../../stats/domain/student_course_stat.dart';
import '../../students/domain/student.dart';
import '../application/attendance_providers.dart';

/// «الطالب» (from the register): the student's percentage in the course and
/// every absence, lateness and excuse with its date — the course's lectures
/// by all its teachers as last fetched, plus this phone's own marks. One
/// register for theory and practical together (طلب القسم), each lecture
/// labelled; when the year keeps two percentages both are shown.
class StudentScreen extends ConsumerWidget {
  const StudentScreen({super.key, required this.assignmentId, required this.studentId});

  final String assignmentId;
  final String studentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final students = ref.watch(classStudentsProvider(assignmentId)).value ?? const <Student>[];
    final student = students.where((s) => s.id == studentId).firstOrNull;
    return Scaffold(
      appBar: AppBar(title: Text(student?.fullName ?? studentId)),
      body: AsyncBody<ClassAbsenceData?>(
        value: ref.watch(classAbsenceDataProvider(assignmentId)),
        data: (data) {
          if (data == null) return Center(child: MessageView(icon: Icons.info_outline, title: l10n.studentNoData));
          final bySession = data.bySession[studentId] ?? const {};
          final leaves = data.leaves[studentId] ?? const [];
          AbsenceSummary summary(String? type) => AbsenceSummary.of(
                bySession: bySession,
                leaves: leaves,
                units: data.course.units,
                year: data.year,
                stageId: data.course.stageId,
                type: type,
              );
          final entries = AbsenceEntry.of(
            bySession,
            leaveDays: AbsenceSummary.excusedLeaveDays(leaves, data.year.maxLeaveDays),
          );
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (data.year.combinedTheoryPractical)
                _SummaryCard(summary: summary(null), courseName: data.course.name, universityId: studentId)
              else ...[
                _SummaryCard(
                  key: const Key('student.summary.theory'),
                  summary: summary('theory'),
                  courseName: '${data.course.name} · ${l10n.theoryLabel}',
                  universityId: studentId,
                ),
                if (data.course.hasPractical)
                  _SummaryCard(
                    key: const Key('student.summary.practical'),
                    summary: summary('practical'),
                    courseName: '${data.course.name} · ${l10n.practicalLabel}',
                    universityId: studentId,
                  ),
              ],
              const SizedBox(height: 12),
              Text(l10n.studentHistory(entries.length), style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              if (entries.isEmpty)
                Card(child: ListTile(leading: const Icon(Icons.check_circle), title: Text(l10n.studentNoAbsences)))
              else
                Card(
                  child: Column(
                    children: [for (final e in entries) AbsenceEntryTile(entry: e)],
                  ),
                ),
              const SizedBox(height: 8),
              Text(l10n.studentSourceNote, style: Theme.of(context).textTheme.bodySmall),
            ],
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({super.key, required this.summary, required this.courseName, required this.universityId});

  final AbsenceSummary summary;
  final String courseName;
  final String universityId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final palette = StatusPalette.of(context);
    final color = palette.forLevel(summary.level);
    final next = summary.nextLevel;
    return Card(
      key: key == null ? const Key('student.summary') : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(courseName, style: theme.textTheme.titleMedium),
            Text(bidiIsolate(universityId), style: theme.textTheme.bodySmall),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  '${summary.percent.toStringAsFixed(1)}%',
                  key: const Key('student.percent'),
                  style: theme.textTheme.headlineMedium?.copyWith(color: color, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 12),
                if (summary.level != WarningLevel.none)
                  Chip(
                    avatar: Icon(StatusPalette.iconForLevel(summary.level), color: color, size: 18),
                    label: Text(l10n.warningLevel(summary.level)),
                  ),
              ],
            ),
            Text(l10n.warnAbsences(summary.absences, summary.planned, summary.percent.toStringAsFixed(1))),
            Text(l10n.studentCounts(summary.lates, summary.excused, summary.byLeave), style: theme.textTheme.bodySmall),
            if (next != null && summary.untilNext > 0)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  l10n.studentUntilNext(summary.untilNext, l10n.warningLevel(next)),
                  style: theme.textTheme.bodyMedium?.copyWith(color: palette.forLevel(next)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// One lecture of the student's register: date, lecture, theory or
/// practical, status (also in «لوحة المادة»).
class AbsenceEntryTile extends StatelessWidget {
  const AbsenceEntryTile({super.key, required this.entry});

  final AbsenceEntry entry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final m = MaterialLocalizations.of(context);
    final palette = StatusPalette.of(context);
    final date = entry.date;
    return ListTile(
      key: Key('student.entry.${entry.sessionId}'),
      dense: true,
      leading: Icon(StatusPalette.iconForStatus(entry.status), color: palette.forStatus(entry.status)),
      title: Text([
        if (date != null) m.formatFullDate(date) else '—',
      ].join()),
      subtitle: Text([
        l10n.recordLectureN(entry.lectureNo),
        entry.type == 'practical' ? l10n.practicalLabel : l10n.theoryLabel,
        l10n.attendance(entry.status),
        if (entry.onLeave) l10n.studentOnLeave,
      ].join(' · ')),
    );
  }
}
