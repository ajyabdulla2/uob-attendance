import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/domain/stage_ref.dart';
import '../../../l10n/l10n.dart';
import '../../academic/application/academic_providers.dart';
import '../../courses/application/courses_providers.dart';
import '../../stats/application/stats_providers.dart';
import '../../students/application/students_providers.dart';
import '../domain/absence_rates.dart';

/// لوحة القسم: mean absence percentage by stage, then by course of a chosen
/// stage. Horizontal bars in one hue (a single measure), each labelled with
/// its value; status colours stay for the warning levels. Loaded on request:
/// it reads every stage's statistics.
class AbsenceChartsCard extends StatefulWidget {
  const AbsenceChartsCard({super.key});

  @override
  State<AbsenceChartsCard> createState() => _AbsenceChartsCardState();
}

class _AbsenceChartsCardState extends State<AbsenceChartsCard> {
  bool _shown = false;
  StageRef? _stage;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Card(
      key: const Key('dept.charts'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.chartTitle, style: theme.textTheme.titleMedium),
            Text(l10n.chartHelp, style: theme.textTheme.bodySmall),
            const SizedBox(height: 12),
            if (!_shown)
              OutlinedButton.icon(
                key: const Key('dept.charts.show'),
                onPressed: () => setState(() => _shown = true),
                icon: const Icon(Icons.trending_up),
                label: Text(l10n.chartShow),
              )
            else ...[
              _StagesChart(selected: _stage, onSelect: (s) => setState(() => _stage = s)),
              if (_stage case final stage?) ...[
                const Divider(height: 32),
                Text(l10n.chartByCourse(l10n.stage(stage)), style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                _CoursesChart(stage: stage),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

/// Everything one stage's bars need; null while loading.
({List<AbsenceRate> courses, AbsenceRate stage})? _stageRates(WidgetRef ref, StageRef stage, AppLocalizations l10n) {
  final standings = ref.watch(stageStandingsProvider(stage.id)).value;
  final students = ref.watch(stageStudentsProvider(stage.id)).value;
  final courses = ref.watch(stageCoursesProvider(stage.id)).value;
  final year = ref.watch(activeYearProvider).value;
  if (standings == null || students == null || courses == null || year == null) return null;
  final byCourse = AbsenceRates.byCourse(
    standings: standings,
    students: students,
    courses: courses.where((c) => c.semester == year.semester),
    combined: year.combinedTheoryPractical,
    label: (c, type) => type == null ? c.name : '${c.name} · ${type == 'theory' ? l10n.theoryLabel : l10n.practicalLabel}',
  );
  return (
    courses: byCourse,
    stage: AbsenceRates.stage(l10n.stage(stage), byCourse, standings, students.where((s) => s.attendsLectures).length),
  );
}

class _StagesChart extends ConsumerWidget {
  const _StagesChart({required this.selected, required this.onSelect});

  final StageRef? selected;
  final ValueChanged<StageRef> onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final rows = [
      for (final s in StageRef.all) (stage: s, rates: _stageRates(ref, s, l10n)),
    ];
    final loaded = [for (final r in rows) if (r.rates case final x? when x.stage.students > 0) (stage: r.stage, rate: x.stage)];
    final loading = rows.any((r) => r.rates == null);
    if (loaded.isEmpty) {
      return loading ? const Center(child: CircularProgressIndicator()) : Text(l10n.chartNoData);
    }
    final max = _scaleMax(loaded.map((r) => r.rate.mean));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.chartByStage, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        for (final r in loaded)
          _Bar(
            key: Key('chart.stage.${r.stage.id}'),
            rate: r.rate,
            max: max,
            selected: r.stage == selected,
            onTap: () => onSelect(r.stage),
          ),
        if (loading) const LinearProgressIndicator(),
        const SizedBox(height: 4),
        Text(l10n.chartTapStage, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _CoursesChart extends ConsumerWidget {
  const _CoursesChart({required this.stage});

  final StageRef stage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rates = _stageRates(ref, stage, context.l10n);
    if (rates == null) return const Center(child: CircularProgressIndicator());
    if (rates.courses.isEmpty) return Text(context.l10n.chartNoData);
    final max = _scaleMax(rates.courses.map((r) => r.mean));
    return Column(
      children: [
        for (final (i, r) in rates.courses.indexed) _Bar(key: Key('chart.course.${stage.id}.$i'), rate: r, max: max),
      ],
    );
  }
}

/// The axis end: the largest value rounded up to a multiple of 5 (at least 5).
double _scaleMax(Iterable<double> values) {
  final top = values.fold<double>(0, math.max);
  return math.max(5, (top / 5).ceil() * 5).toDouble();
}

/// A label, a thin bar from the start edge (4 px rounded end) on a recessive
/// track, and the value in text ink. The tooltip adds the counts.
class _Bar extends StatelessWidget {
  const _Bar({super.key, required this.rate, required this.max, this.selected = false, this.onTap});

  final AbsenceRate rate;
  final double max;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final fraction = (rate.mean / max).clamp(0.0, 1.0);
    return Tooltip(
      message: l10n.chartBarTip(rate.mean.toStringAsFixed(1), rate.atAlert, rate.students),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          decoration: selected
              ? BoxDecoration(color: scheme.secondaryContainer, borderRadius: BorderRadius.circular(8))
              : null,
          child: Row(
            children: [
              SizedBox(
                width: 120,
                child: Text(rate.label, maxLines: 2, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, c) => Stack(
                    children: [
                      Container(
                        height: 14,
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      Container(
                        height: 14,
                        width: c.maxWidth * fraction,
                        decoration: BoxDecoration(color: scheme.primary, borderRadius: BorderRadius.circular(4)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 52,
                child: Text(
                  '${rate.mean.toStringAsFixed(1)}%',
                  textAlign: TextAlign.end,
                  style: theme.textTheme.labelLarge,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
