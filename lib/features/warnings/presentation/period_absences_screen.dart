import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/domain/stage_ref.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../l10n/l10n.dart';
import '../../academic/application/academic_providers.dart';
import '../../auth/application/auth_providers.dart';
import '../../reports/application/report_builders.dart';
import '../../reports/application/report_exporter.dart';
import '../../stats/application/stats_providers.dart';
import '../../stats/domain/period_standings.dart';

/// Which days «تقرير غياب المرحلة» covers.
enum AbsencePeriod { semester, day, range }

/// «تقرير غياب المرحلة» (طلب القسم, for stage managers and the admins): pick
/// a stage, the whole semester / one day / from–to, and the least number of
/// absences (hours) — the students with that many in a course, each with
/// their courses and hours, ready for Excel/PDF and sharing. The lists'
/// course and section filters carry over when opened from them.
class PeriodAbsencesScreen extends ConsumerStatefulWidget {
  const PeriodAbsencesScreen({super.key, this.stage, this.courseId, this.section, this.from, this.to});

  final StageRef? stage;
  final String? courseId;
  final String? section;

  /// A preset period (whole days); none = the whole semester.
  final DateTime? from;
  final DateTime? to;

  @override
  ConsumerState<PeriodAbsencesScreen> createState() => _PeriodAbsencesScreenState();
}

class _PeriodAbsencesScreenState extends ConsumerState<PeriodAbsencesScreen> {
  late StageRef? _stage = widget.stage;
  late String? _courseId = widget.courseId;
  late final String? _section = widget.section;
  late AbsencePeriod _period = widget.from == null
      ? AbsencePeriod.semester
      : (widget.from == widget.to ? AbsencePeriod.day : AbsencePeriod.range);
  late DateTime _from = widget.from ?? _today();
  late DateTime _to = widget.to ?? _today();
  int _min = 1;

  static DateTime _today() {
    final now = DateTime.now();
    return DateTime.utc(now.year, now.month, now.day);
  }

  static DateTime _utc(DateTime d) => DateTime.utc(d.year, d.month, d.day);

  Future<void> _pick(AbsencePeriod p) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final first = today.subtract(const Duration(days: 365));
    switch (p) {
      case AbsencePeriod.semester:
        setState(() => _period = p);
      case AbsencePeriod.day:
        final d = await showDatePicker(context: context, initialDate: today, firstDate: first, lastDate: today);
        if (d != null) {
          setState(() {
            _period = p;
            _from = _to = _utc(d);
          });
        }
      case AbsencePeriod.range:
        final r = await showDateRangePicker(
          context: context,
          firstDate: first,
          lastDate: today,
          initialDateRange: DateTimeRange(start: today.subtract(const Duration(days: 29)), end: today),
        );
        if (r != null) {
          setState(() {
            _period = p;
            _from = _utc(r.start);
            _to = _utc(r.end);
          });
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final m = MaterialLocalizations.of(context);
    final stages = ref.watch(permissionsProvider).manageableStages;
    final stage = _stage != null && stages.contains(_stage) ? _stage : stages.firstOrNull;
    if (stage == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.periodTitle)),
        body: Center(child: MessageView(icon: Icons.lock_outline, title: l10n.assignmentsNoStages)),
      );
    }
    // The whole semester: every lecture recorded so far.
    final (from, to) = _period == AbsencePeriod.semester ? (DateTime.utc(2000), _today()) : (_from, _to);
    final value = ref.watch(periodStandingsProvider((stageId: stage.id, from: from, to: to)));
    final periodLabel = switch (_period) {
      AbsencePeriod.semester => l10n.periodWholeSemester,
      AbsencePeriod.day => l10n.periodOneDay(m.formatMediumDate(_from)),
      AbsencePeriod.range => l10n.reportPeriod(m.formatMediumDate(_from), m.formatMediumDate(_to)),
    };

    final all = value.value ?? const <PeriodStanding>[];
    final courses = {for (final s in all) s.course.id: s.course}.values.toList()..sort((a, b) => a.code.compareTo(b.code));
    final courseId = courses.any((c) => c.id == _courseId) ? _courseId : null;
    final rows = groupByStudent(
      [
        for (final s in all)
          if ((courseId == null || s.course.id == courseId) && (_section == null || s.student.section == _section)) s,
      ],
      minAbsences: _min,
    );
    final courseName = courseId == null ? null : courses.firstWhere((c) => c.id == courseId).name;

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
                  minAbsences: _min,
                  rows: rows,
                ),
              ),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: DropdownButtonFormField<StageRef>(
              key: const Key('period.stage'),
              initialValue: stage,
              isExpanded: true,
              decoration: InputDecoration(labelText: l10n.fixStage, prefixIcon: const Icon(Icons.layers)),
              items: [for (final s in stages) DropdownMenuItem(value: s, child: Text(l10n.stage(s)))],
              onChanged: (s) => setState(() {
                _stage = s;
                _courseId = null;
              }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final p in AbsencePeriod.values)
                  ChoiceChip(
                    key: Key('period.${p.name}'),
                    label: Text(switch (p) {
                      AbsencePeriod.semester => l10n.periodWholeSemester,
                      AbsencePeriod.day => l10n.periodDayChoice,
                      AbsencePeriod.range => l10n.reportPeriodPick,
                    }),
                    selected: _period == p,
                    onSelected: (_) => _pick(p),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    key: const Key('period.course'),
                    initialValue: courseId,
                    isExpanded: true,
                    decoration: InputDecoration(labelText: l10n.warnCourse, isDense: true),
                    items: [
                      DropdownMenuItem(value: null, child: Text(l10n.warnAllCourses)),
                      for (final c in courses) DropdownMenuItem(value: c.id, child: Text(c.name, overflow: TextOverflow.ellipsis)),
                    ],
                    onChanged: (v) => setState(() => _courseId = v),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 130,
                  child: DropdownButtonFormField<int>(
                    key: const Key('period.min'),
                    initialValue: _min,
                    isExpanded: true,
                    decoration: InputDecoration(labelText: l10n.periodMinHours, isDense: true),
                    items: [for (var n = 1; n <= 20; n++) DropdownMenuItem(value: n, child: Text('$n'))],
                    onChanged: (v) => setState(() => _min = v ?? 1),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              [periodLabel, if (_section != null) '${l10n.fieldSection}: $_section'].join(' · '),
              style: theme.textTheme.titleSmall,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(l10n.periodNote, style: theme.textTheme.bodySmall),
          ),
          if (!value.hasValue)
            Padding(
              padding: const EdgeInsets.all(32),
              child: SizedBox(
                height: 200,
                child: AsyncBody<List<PeriodStanding>>(value: value, data: (_) => const SizedBox.shrink()),
              ),
            )
          else if (rows.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: MessageView(icon: Icons.verified, title: l10n.periodEmpty),
            )
          else ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(l10n.periodCount(rows.length), style: theme.textTheme.labelLarge),
            ),
            for (final (i, r) in rows.indexed)
              Card(
                key: Key('period.student.${r.student.id}'),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text('${i + 1}. ${r.student.fullName}', style: theme.textTheme.titleSmall),
                          ),
                          Text(l10n.periodHours(r.total), style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      if (r.student.section.isNotEmpty) Text(l10n.sectionLabel(r.student.section), style: theme.textTheme.bodySmall),
                      for (final c in r.courses)
                        Text(
                          '${c.course.name}${c.type == null ? '' : ' · ${c.type == 'theory' ? l10n.theoryLabel : l10n.practicalLabel}'}: '
                          '${l10n.periodRow(c.absences, c.lectures)} (${ReportBuilders.percent(c.percent)}%)',
                          key: Key('period.row.${r.student.id}.${c.course.id}${c.type == null ? '' : '.${c.type}'}'),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
