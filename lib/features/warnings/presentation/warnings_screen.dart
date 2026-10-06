import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/domain/stage_ref.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../l10n/l10n.dart';
import '../../academic/application/academic_providers.dart';
import '../../auth/application/auth_providers.dart';
import '../../reports/application/report_builders.dart';
import '../../reports/application/report_exporter.dart';
import '../../stats/application/stats_providers.dart';
import '../../stats/domain/standings.dart';
import '../../stats/domain/student_course_stat.dart';
import '../application/warnings_providers.dart';
import '../domain/warning_list.dart';

/// What the list shows: one level, or students one absence short of the next.
enum _View { alert, warning, dismissal, edge }

/// النسب والقوائم (stage managers and admins): every student's percentage per
/// course, the alert / warning / dismissal lists, and saved decisions.
class WarningsScreen extends ConsumerStatefulWidget {
  const WarningsScreen({super.key});

  @override
  ConsumerState<WarningsScreen> createState() => _WarningsScreenState();
}

class _WarningsScreenState extends ConsumerState<WarningsScreen> {
  StageRef? _stage;
  String? _courseId;
  String? _section;
  _View _view = _View.warning;
  bool _busy = false;

  static WarningLevel? _levelOf(_View v) => switch (v) {
        _View.alert => WarningLevel.alert,
        _View.warning => WarningLevel.warning,
        _View.dismissal => WarningLevel.dismissal,
        _View.edge => null,
      };

  bool _matches(Standing s, _View v) {
    if (_courseId != null && s.course.id != _courseId) return false;
    if (_section != null && s.student.section != _section) return false;
    final level = _levelOf(v);
    return level == null ? s.summary.untilNext == 1 && s.level != WarningLevel.dismissal : s.level == level;
  }

  /// A student's row: their summary over every course of the stage.
  Future<void> _studentActions(StageRef stage, Standing s, List<Standing> all) async {
    final l10n = context.l10n;
    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: Text(s.student.fullName), subtitle: Text(bidiIsolate(s.student.universityId))),
            ListTile(
              key: const Key('student.summary'),
              leading: const Icon(Icons.picture_as_pdf),
              title: Text(l10n.reportStudentAction),
              onTap: () => Navigator.pop(context, 'summary'),
            ),
          ],
        ),
      ),
    );
    if (action != 'summary' || !mounted) return;
    await exportReport(
      context,
      ref,
      year: ref.read(activeYearProvider).value,
      formats: const {ReportFormat.pdf},
      build: (_) => ReportBuilders.studentSummary(
        l10n,
        student: s.student,
        stageLabel: l10n.stage(stage),
        standings: [for (final x in all) if (x.student.id == s.student.id) x],
      ),
    );
  }

  Future<void> _saveDecision(StageRef stage, WarningLevel level, List<Standing> rows) async {
    final l10n = context.l10n;
    final ok = await confirmDialog(
      context,
      title: l10n.warnSaveTitle,
      body: l10n.warnSaveBody(rows.length, l10n.warningLevel(level)),
      confirmLabel: l10n.save,
    );
    if (!ok || !mounted) return;
    setState(() => _busy = true);
    try {
      await ref.read(warningsRepositoryProvider).saveDepartment(
            stageId: stage.id,
            level: level,
            courseId: _courseId,
            standings: rows,
            actor: ref.read(signedInUserProvider).id,
          );
      if (mounted) showSnack(context, l10n.warnSaved);
    } on Object catch (e) {
      if (mounted) showSnack(context, l10n.errorGeneric('$e'));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final stages = ref.watch(permissionsProvider).manageableStages;
    final stage = _stage != null && stages.contains(_stage) ? _stage : stages.firstOrNull;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.warnTitle),
          actions: [
            if (stage != null)
              IconButton(
                key: const Key('warn.stats'),
                tooltip: l10n.reportStatsAction,
                icon: const Icon(Icons.bar_chart),
                onPressed: () {
                  final standings = ref.read(stageStandingsProvider(stage.id)).value;
                  if (standings == null) return;
                  exportReport(
                    context,
                    ref,
                    year: ref.read(activeYearProvider).value,
                    build: (_) => ReportBuilders.stageStatistics(l10n, stageLabel: l10n.stage(stage), standings: standings),
                  );
                },
              ),
          ],
          bottom: TabBar(tabs: [
            Tab(key: const Key('warn.tab.lists'), text: l10n.warnTabLists),
            Tab(key: const Key('warn.tab.decisions'), text: l10n.warnTabDecisions),
          ]),
        ),
        body: stage == null
            ? Center(child: MessageView(icon: Icons.lock_outline, title: l10n.assignmentsNoStages))
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: DropdownButtonFormField<StageRef>(
                      key: const Key('warn.stage'),
                      initialValue: stage,
                      isExpanded: true,
                      decoration: InputDecoration(labelText: l10n.fixStage, prefixIcon: const Icon(Icons.layers)),
                      items: [for (final s in stages) DropdownMenuItem(value: s, child: Text(l10n.stage(s)))],
                      onChanged: (s) => setState(() {
                        _stage = s;
                        _courseId = null;
                        _section = null;
                      }),
                    ),
                  ),
                  Expanded(
                    child: TabBarView(children: [
                      _lists(stage),
                      _DecisionsTab(stage: stage),
                    ]),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _lists(StageRef stage) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final palette = StatusPalette.of(context);
    final standings = ref.watch(stageStandingsProvider(stage.id));
    return AsyncBody<List<Standing>>(
      value: standings,
      data: (all) {
        final courses = {for (final s in all) s.course.id: s.course}.values.toList()
          ..sort((a, b) => a.code.compareTo(b.code));
        final sections = {for (final s in all) if (s.student.section.isNotEmpty) s.student.section}.toList()..sort();
        final counts = {for (final v in _View.values) v: all.where((s) => _matches(s, v)).length};
        final rows = all.where((s) => _matches(s, _view)).toList();
        final level = _levelOf(_view);
        return ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String?>(
                      key: const Key('warn.course'),
                      initialValue: courses.any((c) => c.id == _courseId) ? _courseId : null,
                      isExpanded: true,
                      decoration: InputDecoration(labelText: l10n.warnCourse, isDense: true),
                      items: [
                        DropdownMenuItem(value: null, child: Text(l10n.warnAllCourses)),
                        for (final c in courses) DropdownMenuItem(value: c.id, child: Text(c.name, overflow: TextOverflow.ellipsis)),
                      ],
                      onChanged: (v) => setState(() => _courseId = v),
                    ),
                  ),
                  if (sections.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 120,
                      child: DropdownButtonFormField<String?>(
                        key: const Key('warn.section'),
                        initialValue: sections.contains(_section) ? _section : null,
                        isExpanded: true,
                        decoration: InputDecoration(labelText: l10n.fieldSection, isDense: true),
                        items: [
                          DropdownMenuItem(value: null, child: Text(l10n.warnAll)),
                          for (final s in sections) DropdownMenuItem(value: s, child: Text(s)),
                        ],
                        onChanged: (v) => setState(() => _section = v),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final v in _View.values)
                    ChoiceChip(
                      key: Key('warn.view.${v.name}'),
                      avatar: Icon(
                        v == _View.edge ? Icons.trending_up : StatusPalette.iconForLevel(_levelOf(v)!),
                        size: 18,
                        color: v == _View.edge ? null : palette.forLevel(_levelOf(v)!),
                      ),
                      label: Text('${v == _View.edge ? l10n.warnEdge : l10n.warningLevel(_levelOf(v)!)} ${counts[v]}'),
                      selected: _view == v,
                      onSelected: (_) => setState(() => _view = v),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(_view == _View.edge ? l10n.warnEdgeHelp : l10n.warnHelp, style: theme.textTheme.bodySmall),
            ),
            if (rows.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32),
                child: MessageView(icon: Icons.verified, title: l10n.warnEmpty),
              )
            else ...[
              for (final s in rows)
                _StandingTile(
                  standing: s,
                  onTap: () => _studentActions(stage, s, all),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: OutlinedButton.icon(
                  key: const Key('warn.export'),
                  icon: const Icon(Icons.file_download_outlined),
                  label: Text(l10n.reportListAction),
                  onPressed: () => exportReport(
                    context,
                    ref,
                    year: ref.read(activeYearProvider).value,
                    build: (_) => ReportBuilders.standingsList(
                      l10n,
                      stageLabel: l10n.stage(stage),
                      listLabel: level == null ? l10n.warnEdge : l10n.warningLevel(level),
                      courseName: courses.where((c) => c.id == _courseId).firstOrNull?.name,
                      rows: rows,
                    ),
                  ),
                ),
              ),
              if (level != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: FilledButton.icon(
                    key: const Key('warn.save'),
                    icon: const Icon(Icons.gavel),
                    label: Text(l10n.warnSaveAction(l10n.warningLevel(level))),
                    onPressed: _busy ? null : () => _saveDecision(stage, level, rows),
                  ),
                ),
            ],
          ],
        );
      },
    );
  }
}

class _StandingTile extends StatelessWidget {
  const _StandingTile({required this.standing, this.onTap});

  final Standing standing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = StatusPalette.of(context);
    final s = standing.summary;
    final color = palette.forLevel(s.level);
    final next = s.nextLevel;
    return ListTile(
      key: Key('warn.row.${standing.student.id}.${standing.course.id}${standing.type == null ? '' : '.${standing.type}'}'),
      leading: CircleAvatar(
        backgroundColor: color?.withValues(alpha: 0.15),
        foregroundColor: color,
        child: Text(s.percent.toStringAsFixed(s.percent < 10 ? 1 : 0), style: const TextStyle(fontSize: 13)),
      ),
      title: Text(standing.student.fullName),
      subtitle: Text([
        [
          standing.course.name,
          if (standing.type != null) standing.type == 'theory' ? l10n.theoryLabel : l10n.practicalLabel,
        ].join(' · '),
        l10n.warnAbsences(s.absences, s.planned, s.percent.toStringAsFixed(1)),
        if (s.excused > 0) l10n.warnExcused(s.excused),
        if (next != null && s.untilNext == 1) l10n.warnOneMore(l10n.warningLevel(next)),
      ].join('\n')),
      isThreeLine: true,
      onTap: onTap,
    );
  }
}

class _DecisionsTab extends ConsumerWidget {
  const _DecisionsTab({required this.stage});

  final StageRef stage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final m = MaterialLocalizations.of(context);
    return AsyncBody<List<WarningList>>(
      value: ref.watch(stageDecisionsProvider(stage.id)),
      data: (lists) => lists.isEmpty
          ? Center(child: MessageView(icon: Icons.gavel, title: l10n.warnNoDecisions))
          : ListView(
              children: [
                for (final list in lists)
                  ListTile(
                    key: Key('decision.${list.id}'),
                    leading: Icon(list.isFinal ? Icons.lock : Icons.edit_note),
                    title: Text(l10n.warnDecisionTitle(
                      l10n.warningLevel(list.level),
                      list.courseId == null ? l10n.warnAllCourses : (list.entries.firstOrNull?.courseName ?? list.courseId!),
                      list.entries.length,
                    )),
                    subtitle: Text(list.isFinal
                        ? l10n.warnDeanery(list.orderNumber ?? '', list.orderDate == null ? '' : m.formatMediumDate(list.orderDate!))
                        : l10n.warnDepartment(list.createdAt == null ? '' : m.formatMediumDate(list.createdAt!.toLocal()))),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                      builder: (_) => DecisionScreen(stageId: stage.id, listId: list.id),
                    )),
                  ),
              ],
            ),
    );
  }
}

/// One saved decision: its students as saved, and (for a department decision)
/// regenerate from today's standings, convert to deanery, or delete.
class DecisionScreen extends ConsumerStatefulWidget {
  const DecisionScreen({super.key, required this.stageId, required this.listId});

  final String stageId;
  final String listId;

  @override
  ConsumerState<DecisionScreen> createState() => _DecisionScreenState();
}

class _DecisionScreenState extends ConsumerState<DecisionScreen> {
  bool _busy = false;

  Future<void> _run(Future<void> Function() action, String done) async {
    setState(() => _busy = true);
    try {
      await action();
      if (mounted) showSnack(context, done);
    } on Object catch (e) {
      if (mounted) showSnack(context, context.l10n.errorGeneric('$e'));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _regenerate(WarningList list) async {
    final l10n = context.l10n;
    final standings = ref.read(stageStandingsProvider(widget.stageId)).value;
    if (standings == null) {
      showSnack(context, l10n.loading);
      return;
    }
    final rows = [
      for (final s in standings)
        if (s.level == list.level && (list.courseId == null || s.course.id == list.courseId)) s,
    ];
    final ok = await confirmDialog(
      context,
      title: l10n.warnRegenerate,
      body: l10n.warnRegenerateBody(list.entries.length, rows.length),
      confirmLabel: l10n.warnRegenerate,
    );
    if (!ok || !mounted) return;
    await _run(
      () => ref.read(warningsRepositoryProvider).regenerate(list, rows, actor: ref.read(signedInUserProvider).id),
      l10n.warnRegenerated,
    );
  }

  Future<void> _finalize(WarningList list) async {
    final l10n = context.l10n;
    final order = await showDialog<(String, DateTime)>(context: context, builder: (_) => const _OrderDialog());
    if (order == null || !mounted) return;
    await _run(
      () => ref.read(warningsRepositoryProvider).finalize(
            list,
            orderNumber: order.$1,
            orderDate: order.$2,
            actor: ref.read(signedInUserProvider).id,
          ),
      l10n.warnFinalized,
    );
  }

  Future<void> _delete(WarningList list) async {
    final l10n = context.l10n;
    final ok = await confirmDialog(
      context,
      title: l10n.warnDeleteTitle,
      body: l10n.warnDeleteBody,
      confirmLabel: l10n.delete,
      destructive: true,
    );
    if (!ok || !mounted) return;
    await _run(() => ref.read(warningsRepositoryProvider).delete(list, actor: ref.read(signedInUserProvider).id),
        l10n.warnDeleted);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final m = MaterialLocalizations.of(context);
    final perms = ref.watch(permissionsProvider);
    final list = ref.watch(stageDecisionsProvider(widget.stageId)).value?.where((l) => l.id == widget.listId).firstOrNull;
    if (list == null) {
      return Scaffold(appBar: AppBar(), body: const Center(child: CircularProgressIndicator()));
    }
    // Keeps today's standings live for «إعادة التوليد».
    if (!list.isFinal) ref.watch(stageStandingsProvider(widget.stageId));
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.warnDecisionTitle(
          l10n.warningLevel(list.level),
          list.courseId == null ? l10n.warnAllCourses : (list.entries.firstOrNull?.courseName ?? list.courseId!),
          list.entries.length,
        )),
        actions: [
          IconButton(
            key: const Key('decision.export'),
            tooltip: l10n.reportExport,
            icon: const Icon(Icons.file_download_outlined),
            onPressed: () => exportReport(
              context,
              ref,
              year: ref.read(activeYearProvider).value,
              build: (_) => ReportBuilders.decision(
                l10n,
                list: list,
                stageLabel: l10n.stageId(list.stageId),
                dateText: list.isFinal
                    ? (list.orderDate == null ? '' : m.formatMediumDate(list.orderDate!))
                    : (list.createdAt == null ? '' : m.formatMediumDate(list.createdAt!.toLocal())),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            child: ListTile(
              leading: Icon(list.isFinal ? Icons.lock : Icons.edit_note),
              title: Text(list.isFinal ? l10n.warnDeaneryLabel : l10n.warnDepartmentLabel),
              subtitle: Text(list.isFinal
                  ? l10n.warnDeanery(list.orderNumber ?? '', list.orderDate == null ? '' : m.formatMediumDate(list.orderDate!))
                  : l10n.warnDepartmentHelp),
            ),
          ),
          for (final (i, e) in list.entries.indexed)
            ListTile(
              dense: true,
              leading: Text('${i + 1}'),
              title: Text(e.studentName),
              subtitle: Text([
                e.courseName,
                if (e.type != null) e.type == 'theory' ? l10n.theoryLabel : l10n.practicalLabel,
                l10n.warnAbsences(e.absences, e.planned, e.percent.toStringAsFixed(1)),
              ].join(' · ')),
            ),
          if (!list.isFinal)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    key: const Key('decision.regenerate'),
                    icon: const Icon(Icons.refresh),
                    label: Text(l10n.warnRegenerate),
                    onPressed: _busy ? null : () => _regenerate(list),
                  ),
                  if (perms.canFinalizeDeaneryDecision)
                    FilledButton.icon(
                      key: const Key('decision.finalize'),
                      icon: const Icon(Icons.lock),
                      label: Text(l10n.warnFinalize),
                      onPressed: _busy ? null : () => _finalize(list),
                    ),
                  TextButton.icon(
                    key: const Key('decision.delete'),
                    icon: const Icon(Icons.delete_outline),
                    label: Text(l10n.delete),
                    onPressed: _busy ? null : () => _delete(list),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _OrderDialog extends StatefulWidget {
  const _OrderDialog();

  @override
  State<_OrderDialog> createState() => _OrderDialogState();
}

class _OrderDialogState extends State<_OrderDialog> {
  final _number = TextEditingController();
  DateTime? _date;

  @override
  void dispose() {
    _number.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final m = MaterialLocalizations.of(context);
    final date = _date;
    return AlertDialog(
      title: Text(l10n.warnFinalize),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.warnFinalizeBody),
          const SizedBox(height: 12),
          TextField(
            key: const Key('order.number'),
            controller: _number,
            decoration: InputDecoration(labelText: l10n.warnOrderNumber),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            key: const Key('order.date'),
            icon: const Icon(Icons.event),
            label: Text(date == null ? l10n.warnOrderDate : m.formatMediumDate(date)),
            onPressed: () async {
              final now = DateTime.now();
              final picked = await showDatePicker(
                context: context,
                initialDate: now,
                firstDate: DateTime(now.year - 2),
                lastDate: DateTime(now.year + 1),
              );
              if (picked != null) setState(() => _date = picked);
            },
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
        FilledButton(
          key: const Key('order.ok'),
          onPressed: _number.text.trim().isEmpty || date == null
              ? null
              : () => Navigator.pop(context, (_number.text.trim(), DateTime.utc(date.year, date.month, date.day))),
          child: Text(l10n.warnFinalize),
        ),
      ],
    );
  }
}
