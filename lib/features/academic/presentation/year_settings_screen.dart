import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/arabic_text.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../l10n/l10n.dart';
import '../../auth/application/auth_providers.dart';
import '../../stats/domain/student_course_stat.dart';
import '../application/academic_providers.dart';
import '../domain/academic_year.dart';

/// إعدادات السنة الدراسية (admins): the department's decisions that drive
/// the percentages — thresholds, planned lectures, lock window, leaves.
class YearSettingsScreen extends ConsumerWidget {
  const YearSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final year = ref.watch(activeYearProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.yearTitle)),
      body: AsyncBody<AcademicYear?>(
        value: year,
        data: (y) => y == null
            ? Center(child: MessageView(icon: Icons.event_busy, title: l10n.yearNone))
            : _YearForm(key: ValueKey(y.id), year: y),
      ),
    );
  }
}

class _YearForm extends ConsumerStatefulWidget {
  const _YearForm({super.key, required this.year});

  final AcademicYear year;

  @override
  ConsumerState<_YearForm> createState() => _YearFormState();
}

class _YearFormState extends ConsumerState<_YearForm> {
  final _formKey = GlobalKey<FormState>();
  late int _semester = widget.year.semester;
  late final _alert = _num(widget.year.thresholds.alert);
  late final _warning = _num(widget.year.thresholds.warning);
  late final _dismissal = _num(widget.year.thresholds.dismissal);
  late final _weeks = _num(widget.year.weeksPerSemester);
  late final _perUnit = _num(widget.year.lecturesPerUnitPerWeek);
  late final _lockHours = _num(widget.year.lockHours);
  late bool _leavesCount = widget.year.leavesCountAgainst;
  late final _maxLeave = TextEditingController(text: widget.year.maxLeaveDays?.toString() ?? '');
  late bool _combined = widget.year.combinedTheoryPractical;
  bool _saving = false;

  static TextEditingController _num(num v) =>
      TextEditingController(text: v == v.roundToDouble() ? '${v.round()}' : '$v');

  @override
  void dispose() {
    for (final c in [_alert, _warning, _dismissal, _weeks, _perUnit, _lockHours, _maxLeave]) {
      c.dispose();
    }
    super.dispose();
  }

  static String _clean(String s) => ArabicText.normalizeDigits(s.trim()).replaceAll('٫', '.').replaceAll(',', '.');
  static double? _parse(String s) => double.tryParse(_clean(s));
  static int? _int(String s) => int.tryParse(_clean(s));

  AcademicYear? _draft() {
    final a = _parse(_alert.text), w = _parse(_warning.text), d = _parse(_dismissal.text);
    final weeks = _int(_weeks.text), lock = _int(_lockHours.text);
    final perUnit = _parse(_perUnit.text);
    final max = _maxLeave.text.trim().isEmpty ? null : _int(_maxLeave.text);
    if (a == null || w == null || d == null || weeks == null || lock == null || perUnit == null) return null;
    if (_maxLeave.text.trim().isNotEmpty && max == null) return null;
    return widget.year.copyWith(
      semester: _semester,
      thresholds: AbsenceThresholds(alert: a, warning: w, dismissal: d),
      weeksPerSemester: weeks,
      lecturesPerUnitPerWeek: perUnit,
      lockHours: lock,
      leavesCountAgainst: _leavesCount,
      maxLeaveDays: () => max,
      combinedTheoryPractical: _combined,
    );
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    if (!_formKey.currentState!.validate()) return;
    final draft = _draft();
    if (draft == null || !draft.isValid) {
      showSnack(context, l10n.yearInvalid);
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(academicRepositoryProvider).saveSettings(
            widget.year,
            draft,
            actor: ref.read(signedInUserProvider).id,
          );
      if (mounted) showSnack(context, l10n.yearSaved);
    } on Object catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final draft = _draft();
    final example = draft == null || !draft.isValid
        ? null
        : AbsenceMath.plannedLectures(
            units: 3,
            weeks: draft.weeksPerSemester,
            lecturesPerUnitPerWeek: draft.lecturesPerUnitPerWeek,
          );

    String? numberIn(String? v, {double min = 0, double max = double.infinity, bool integer = false}) {
      final n = _parse(v ?? '');
      if (n == null || n < min || n > max || (integer && n != n.roundToDouble())) return l10n.yearBadNumber;
      return null;
    }

    Widget field(TextEditingController c, String label, String key,
            {String? suffix, String? helper, String? Function(String?)? validator, bool decimal = false}) =>
        TextFormField(
          key: Key('year.$key'),
          controller: c,
          keyboardType: TextInputType.numberWithOptions(decimal: decimal),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9٠-٩.,٫]'))],
          textDirection: TextDirection.ltr,
          decoration: InputDecoration(labelText: label, suffixText: suffix, helperText: helper, helperMaxLines: 3),
          validator: validator,
          onChanged: (_) => setState(() {}),
        );

    Widget section(String title) => Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 8),
          child: Text(title, style: theme.textTheme.titleMedium),
        );

    return Form(
      key: _formKey,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(l10n.yearHeader(widget.year.id), style: theme.textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(l10n.yearHelp, style: theme.textTheme.bodySmall),
              const SizedBox(height: 12),
              SegmentedButton<int>(
                key: const Key('year.semester'),
                segments: [
                  ButtonSegment(value: 1, label: Text(l10n.yearSemesterN(1))),
                  ButtonSegment(value: 2, label: Text(l10n.yearSemesterN(2))),
                ],
                selected: {_semester},
                onSelectionChanged: (s) => setState(() => _semester = s.first),
              ),
              section(l10n.yearThresholds),
              Row(
                children: [
                  Expanded(
                    child: field(_alert, l10n.levelAlert, 'alert',
                        suffix: '%', decimal: true, validator: (v) => numberIn(v, min: 0.1, max: 100)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: field(_warning, l10n.levelWarning, 'warning',
                        suffix: '%', decimal: true, validator: (v) => numberIn(v, min: 0.1, max: 100)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: field(_dismissal, l10n.levelDismissal, 'dismissal',
                        suffix: '%', decimal: true, validator: (v) => numberIn(v, min: 0.1, max: 100)),
                  ),
                ],
              ),
              section(l10n.yearPlanned),
              field(_weeks, l10n.yearWeeks, 'weeks', validator: (v) => numberIn(v, min: 1, max: 30, integer: true)),
              const SizedBox(height: 12),
              field(_perUnit, l10n.yearPerUnit, 'perUnit',
                  decimal: true, helper: l10n.yearPerUnitHelp, validator: (v) => numberIn(v, min: 0.1, max: 10)),
              if (example != null) ...[
                const SizedBox(height: 8),
                Text(
                  l10n.yearExample(example, example == 0 ? '–' : (100 / example).toStringAsFixed(1)),
                  key: const Key('year.example'),
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary),
                ),
              ],
              const SizedBox(height: 8),
              SwitchListTile(
                key: const Key('year.combined'),
                contentPadding: EdgeInsets.zero,
                value: _combined,
                title: Text(l10n.yearCombined),
                subtitle: Text(_combined ? l10n.yearCombinedOn : l10n.yearCombinedOff),
                onChanged: (v) => setState(() => _combined = v),
              ),
              section(l10n.yearLock),
              field(_lockHours, l10n.yearLockHours, 'lockHours',
                  suffix: l10n.yearHoursSuffix,
                  helper: l10n.yearLockHelp,
                  validator: (v) => numberIn(v, min: 1, max: 720, integer: true)),
              section(l10n.yearLeaves),
              SwitchListTile(
                key: const Key('year.leavesCount'),
                contentPadding: EdgeInsets.zero,
                value: _leavesCount,
                title: Text(l10n.yearLeavesCount),
                subtitle: Text(_leavesCount ? l10n.yearLeavesCountOn : l10n.yearLeavesCountOff),
                onChanged: (v) => setState(() => _leavesCount = v),
              ),
              if (!_leavesCount)
                field(_maxLeave, l10n.yearMaxLeave, 'maxLeave',
                    helper: l10n.yearMaxLeaveHelp,
                    validator: (v) =>
                        (v ?? '').trim().isEmpty ? null : numberIn(v, min: 0, max: 365, integer: true)),
              const SizedBox(height: 24),
              FilledButton.icon(
                key: const Key('year.save'),
                icon: _saving
                    ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.save),
                label: Text(l10n.save),
                onPressed: _saving ? null : _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
