import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/domain/stage_ref.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../l10n/l10n.dart';
import '../../academic/application/academic_providers.dart';
import '../../reports/application/report_builders.dart';
import '../../reports/application/report_exporter.dart';
import '../../stats/application/stats_providers.dart';
import '../../stats/domain/period_standings.dart';

/// Asks the days, then opens «غياب فترة» for [stage] (the lists' course and
/// section filters carry over).
Future<void> openPeriodAbsences(BuildContext context, StageRef stage, {String? courseId, String? section}) async {
  final l10n = context.l10n;
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final picked = await showDateRangePicker(
    context: context,
    firstDate: today.subtract(const Duration(days: 365)),
    lastDate: today,
    initialDateRange: DateTimeRange(start: today.subtract(const Duration(days: 29)), end: today),
    helpText: l10n.periodAction,
  );
  if (picked == null || !context.mounted) return;
  await Navigator.of(context).push(MaterialPageRoute<void>(
    builder: (_) => PeriodAbsencesScreen(
      stage: stage,
      from: DateTime.utc(picked.start.year, picked.start.month, picked.start.day),
      to: DateTime.utc(picked.end.year, picked.end.month, picked.end.day),
      courseId: courseId,
      section: section,
    ),
  ));
}

/// «غياب فترة»: the stage's students absent between [from] and [to], with
/// their absences against the lectures their classes held then.
class PeriodAbsencesScreen extends ConsumerWidget {
  const PeriodAbsencesScreen({
    super.key,
    required this.stage,
    required this.from,
    required this.to,
    this.courseId,
    this.section,
  });

  final StageRef stage;
  final DateTime from;
  final DateTime to;
  final String? courseId;
  final String? section;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final m = MaterialLocalizations.of(context);
    final value = ref.watch(periodStandingsProvider((stageId: stage.id, from: from, to: to)));
    final periodLabel = l10n.reportPeriod(m.formatMediumDate(from), m.formatMediumDate(to));

    List<PeriodStanding> filtered(List<PeriodStanding> all) => [
          for (final s in all)
            if ((courseId == null || s.course.id == courseId) && (section == null || s.student.section == section)) s,
        ];
    final rows = value.hasValue ? filtered(value.value!) : const <PeriodStanding>[];
    final courseName = rows.isEmpty ? null : (courseId == null ? null : rows.first.course.name);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.periodTitle),
        actions: [
          if (rows.isNotEmpty)
            IconButton(
              key: const Key('period.export'),
              tooltip: l10n.reportListAction,
              icon: const Icon(Icons.download),
              onPressed: () => exportReport(
                context,
                ref,
                year: ref.read(activeYearProvider).value,
                build: (_) => ReportBuilders.periodAbsences(
                  l10n,
                  stageLabel: l10n.stage(stage),
                  periodLabel: periodLabel,
                  courseName: courseName,
                  rows: rows,
                ),
              ),
            ),
        ],
      ),
      body: AsyncBody<List<PeriodStanding>>(
        value: value,
        data: (all) {
          final shown = filtered(all);
          return ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Text(
                  [l10n.stage(stage), periodLabel, if (section != null) '${l10n.fieldSection}: $section'].join(' · '),
                  style: theme.textTheme.titleSmall,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(l10n.periodNote, style: theme.textTheme.bodySmall),
              ),
              if (shown.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: MessageView(icon: Icons.verified, title: l10n.periodEmpty),
                )
              else ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Text(l10n.periodCount(shown.length), style: theme.textTheme.labelLarge),
                ),
                for (final s in shown)
                  ListTile(
                    key: Key('period.row.${s.student.id}.${s.course.id}${s.type == null ? '' : '.${s.type}'}'),
                    title: Text(s.student.fullName),
                    subtitle: Text([
                      s.course.name,
                      if (s.type != null) s.type == 'theory' ? l10n.theoryLabel : l10n.practicalLabel,
                      if (s.student.section.isNotEmpty) s.student.section,
                      l10n.periodRow(s.absences, s.lectures),
                    ].join(' · ')),
                    trailing: Text(
                      '${ReportBuilders.percent(s.percent)}%',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }
}
