import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/common_widgets.dart';
import '../../../l10n/l10n.dart';
import '../../courses/data/course_panel.dart';
import '../../reports/application/report_builders.dart';
import '../../reports/application/report_exporter.dart';
import '../application/server_register_providers.dart';
import '../domain/attendance_session.dart';

/// The register export's period: the whole semester, or from–to days.
final class RegisterPeriod {
  const RegisterPeriod(this.range);
  final ({DateTime from, DateTime to})? range;
}

Future<RegisterPeriod?> chooseRegisterPeriod(BuildContext context, List<AttendanceSession> sessions) async {
  final l10n = context.l10n;
  final whole = await showModalBottomSheet<bool>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            key: const Key('export.period.all'),
            leading: const Icon(Icons.date_range),
            title: Text(l10n.reportPeriodAll),
            onTap: () => Navigator.pop(context, true),
          ),
          ListTile(
            key: const Key('export.period.range'),
            leading: const Icon(Icons.calendar_today),
            title: Text(l10n.reportPeriodPick),
            onTap: () => Navigator.pop(context, false),
          ),
        ],
      ),
    ),
  );
  if (whole == null || !context.mounted) return null;
  if (whole) return const RegisterPeriod(null);
  final dates = [for (final s in sessions) s.date]..sort();
  final now = DateTime.now();
  final first = dates.isEmpty ? now.subtract(const Duration(days: 180)) : dates.first;
  final last = dates.isEmpty || now.isAfter(dates.last) ? now : dates.last;
  final picked = await showDateRangePicker(
    context: context,
    firstDate: DateTime(first.year, first.month, first.day),
    lastDate: DateTime(last.year, last.month, last.day),
    initialDateRange: DateTimeRange(
      start: DateTime(last.year, last.month, last.day).subtract(const Duration(days: 6)).isBefore(first)
          ? DateTime(first.year, first.month, first.day)
          : DateTime(last.year, last.month, last.day).subtract(const Duration(days: 6)),
      end: DateTime(last.year, last.month, last.day),
    ),
    helpText: l10n.reportPeriodPick,
  );
  if (picked == null) return null;
  return RegisterPeriod((from: picked.start, to: picked.end));
}

/// What to download: [first] (this class, or the panel's summary) → false,
/// or the full course register (theory and practical) → true.
Future<bool?> chooseRegisterScope(BuildContext context, {required String first, required IconData firstIcon}) {
  final l10n = context.l10n;
  return showModalBottomSheet<bool>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            key: const Key('export.scope.class'),
            leading: Icon(firstIcon),
            title: Text(first),
            onTap: () => Navigator.pop(context, false),
          ),
          ListTile(
            key: const Key('export.scope.course'),
            leading: const Icon(Icons.layers),
            title: Text(l10n.reportCourseRegisterAction),
            onTap: () => Navigator.pop(context, true),
          ),
        ],
      ),
    ),
  );
}

/// Asks the period, then exports [panel] as the full course register.
Future<void> exportCourseRegister(BuildContext context, WidgetRef ref, CoursePanel panel) async {
  final l10n = context.l10n;
  if (panel.sessions.isEmpty) {
    showSnack(context, l10n.registerEmpty);
    return;
  }
  final period = await chooseRegisterPeriod(context, panel.sessions);
  if (period == null || !context.mounted) return;
  final formatDate = MaterialLocalizations.of(context).formatMediumDate;
  await exportReport(
    context,
    ref,
    year: panel.year,
    build: (format) => ReportBuilders.courseRegister(
      l10n,
      panel: panel,
      format: format,
      period: period.range,
      formatDate: formatDate,
    ),
  );
}

/// Reads the course from the server (a teacher's phone holds only their own
/// classes), then exports its full register. [withClasses] false for a
/// teacher, who may read only their own assignments.
Future<void> loadAndExportCourseRegister(
  BuildContext context,
  WidgetRef ref,
  String courseId, {
  required bool withClasses,
}) async {
  final navigator = Navigator.of(context);
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );
  CoursePanel? panel;
  try {
    panel = await ref
        .read(coursePanelRepositoryProvider)
        .load(courseId, withClasses: withClasses)
        .timeout(const Duration(seconds: 45));
  } on Object catch (e, st) {
    navigator.pop();
    if (context.mounted) showError(context, e, st);
    return;
  }
  navigator.pop();
  if (!context.mounted) return;
  if (panel == null) {
    showSnack(context, context.l10n.coursePanelMissing);
    return;
  }
  await exportCourseRegister(context, ref, panel);
}
