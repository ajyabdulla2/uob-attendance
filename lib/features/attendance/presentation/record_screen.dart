import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/doc_ids.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/arabic_text.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../l10n/l10n.dart';
import '../../academic/domain/academic_year.dart';
import '../../assignments/domain/assignment.dart';
import '../../auth/application/auth_providers.dart';
import '../../students/domain/student.dart';
import '../application/attendance_providers.dart';
import '../data/attendance_store.dart';
import '../domain/attendance_session.dart';
import '../domain/save_plan.dart';

/// تسجيل الحضور: pick the day and the lecture; everyone starts present, a tap
/// switches present/absent, a long press offers late, excused and a note.
/// A save lands on the phone first and is uploaded when online.
class RecordScreen extends ConsumerStatefulWidget {
  const RecordScreen({super.key, required this.assignmentId, this.date, this.lectureNo});

  final String assignmentId;

  /// Opens this lecture (from the register); defaults to today's latest.
  final DateTime? date;
  final int? lectureNo;

  @override
  ConsumerState<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends ConsumerState<RecordScreen> {
  late DateTime _date = widget.date ?? _today();

  /// Chosen lecture; null = the day's latest (1 when none).
  late int? _lectureNo = widget.lectureNo;

  String? _loadingSid;
  String? _loadedSid;

  /// As last saved on this phone (empty for a lecture not yet saved).
  Map<String, Mark> _saved = const {};

  /// Current marks of the loaded lecture (students missing = present).
  Map<String, Mark> _marks = {};
  String _query = '';
  bool _saving = false;
  bool _pullStarted = false;

  static DateTime _today() {
    final now = DateTime.now();
    return DateTime.utc(now.year, now.month, now.day);
  }

  Mark _markOf(String id) => _marks[id] ?? Mark.present;

  bool get _dirty => _marks.entries.any((e) => e.value != (_saved[e.key] ?? Mark.present));

  void _ensureLoaded(String sid) {
    if (sid == _loadingSid) return;
    _loadingSid = sid;
    unawaited(ref.read(attendanceStoreProvider).marksOf(sid).then((saved) {
      if (!mounted || _loadingSid != sid) return;
      setState(() {
        _loadedSid = sid;
        _saved = saved;
        _marks = {...saved};
      });
    }));
  }

  /// Brings in lectures saved from other phones (shared classes, or this
  /// teacher's other device). Offline: the phone's copy is shown.
  Future<void> _pull(Assignment a) async {
    try {
      final stored = await ref
          .read(teacherDataSyncProvider)
          .pullClassSessions(a, ref.read(attendanceStoreProvider))
          .timeout(const Duration(seconds: 30));
      if (stored > 0 && mounted && !_dirty) setState(() => _loadingSid = null);
    } on Object {
      // Offline or refused: keep what the phone has.
    }
  }

  Future<bool> _confirmDiscard() async {
    if (!_dirty) return true;
    final l10n = context.l10n;
    return confirmDialog(
      context,
      title: l10n.recordDiscardTitle,
      body: l10n.recordDiscardBody,
      confirmLabel: l10n.recordDiscard,
      destructive: true,
    );
  }

  void _select({DateTime? date, int? lectureNo}) => setState(() {
        if (date != null) _date = date;
        _lectureNo = lectureNo;
        _loadingSid = null;
        _loadedSid = null;
        _saved = const {};
        _marks = {};
      });

  /// The first day a teacher may still record (the lock window).
  static DateTime _firstEditableDay(int lockHours) {
    final now = DateTime.now().toUtc();
    var day = _today();
    for (var i = 0; i < 60; i++) {
      final before = day.subtract(const Duration(days: 1));
      if (!AttendanceSession.lockAtFor(before, lockHours).isAfter(now)) break;
      day = before;
    }
    return day;
  }

  Future<void> _pickDate(AcademicYear year, bool canOverride) async {
    if (!await _confirmDiscard() || !mounted) return;
    final today = _today();
    var first = canOverride ? today.subtract(const Duration(days: 365)) : _firstEditableDay(year.lockHours);
    if (_date.isBefore(first)) first = _date;
    final picked = await showDatePicker(
      context: context,
      initialDate: _date.isAfter(today) ? today : _date,
      firstDate: first,
      lastDate: today,
    );
    if (picked == null || !mounted) return;
    _select(date: DateTime.utc(picked.year, picked.month, picked.day));
  }

  Future<void> _pickLecture(int lectureNo) async {
    if (!await _confirmDiscard() || !mounted) return;
    _select(lectureNo: lectureNo);
  }

  Future<void> _editMark(Student s) async {
    final mark = await showModalBottomSheet<Mark>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _MarkSheet(student: s, initial: _markOf(s.id)),
    );
    if (mark != null && mounted) setState(() => _marks[s.id] = mark);
  }

  void _toggle(Student s) => setState(() {
        final m = _markOf(s.id);
        _marks[s.id] = m.copyWith(
          status: m.status == AttendanceStatus.present ? AttendanceStatus.absent : AttendanceStatus.present,
        );
      });

  Future<void> _save(Assignment a, AcademicYear year, List<Student> students, int lectureNo, bool canOverride) async {
    final l10n = context.l10n;
    final marks = {for (final s in students) s.id: _markOf(s.id)};
    setState(() => _saving = true);
    try {
      final plan = await ref.read(attendanceStoreProvider).save(
            assignment: a,
            yearId: year.id,
            lockHours: year.lockHours,
            date: _date,
            lectureNo: lectureNo,
            marks: marks,
            actor: ref.read(signedInUserProvider).id,
            canOverrideLock: canOverride,
          );
      if (!mounted) return;
      setState(() {
        _lectureNo = lectureNo;
        _loadingSid = _loadedSid = plan.session.id;
        _saved = marks;
        _marks = {...marks};
      });
      showSnack(context, plan.isEmpty ? l10n.recordNothingChanged : l10n.recordSaved);
      if (!plan.isEmpty) unawaited(ref.read(syncControllerProvider.notifier).sync());
    } on SaveRefusedException catch (e) {
      if (mounted) {
        showSnack(context, switch (e.reason) {
          SaveRefusal.futureDate => l10n.recordFuture,
          SaveRefusal.locked => l10n.recordLocked,
          SaveRefusal.noStudents => l10n.recordNoStudents,
        });
      }
    } on Object catch (e) {
      if (mounted) showSnack(context, l10n.errorGeneric('$e'));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (!ref.watch(localFirstProvider)) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.recordAction)),
        body: Center(child: MessageView(icon: Icons.phone_android, title: l10n.homeRecordOnPhone)),
      );
    }

    final classes = ref.watch(localClassesProvider);
    final a = ref.watch(localClassProvider(widget.assignmentId));
    final year = ref.watch(cachedYearProvider);
    final students = ref.watch(classStudentsProvider(widget.assignmentId));
    final sessions = ref.watch(classSessionsProvider(widget.assignmentId));

    Widget scaffold(Widget body, {Widget? bottom}) => PopScope(
          canPop: !_dirty,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) return;
            if (await _confirmDiscard() && context.mounted) Navigator.of(context).pop();
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text(a == null ? l10n.recordAction : (a.courseName.isEmpty ? a.courseId : a.courseName)),
              bottom: a == null
                  ? null
                  : PreferredSize(
                      preferredSize: const Size.fromHeight(24),
                      child: Padding(
                        padding: const EdgeInsetsDirectional.only(start: 16, end: 16, bottom: 8),
                        child: Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(l10n.classLabel(a), style: Theme.of(context).textTheme.bodySmall),
                        ),
                      ),
                    ),
            ),
            body: body,
            bottomNavigationBar: bottom,
          ),
        );

    if (!classes.hasValue || !year.hasValue || !students.hasValue || !sessions.hasValue) {
      return scaffold(const Center(child: CircularProgressIndicator()));
    }
    if (a == null) {
      return scaffold(Center(child: MessageView(icon: Icons.link_off, title: l10n.recordClassMissing)));
    }
    final y = year.value;
    if (y == null) {
      return scaffold(Center(
        child: MessageView(icon: Icons.cloud_download_outlined, title: l10n.recordNeedSync, actions: [
          FilledButton(
            onPressed: () => ref.read(syncControllerProvider.notifier).sync(forceDownload: true),
            child: Text(l10n.syncNow),
          ),
        ]),
      ));
    }
    if (!_pullStarted) {
      _pullStarted = true;
      Future.microtask(() => _pull(a));
    }

    final list = students.value!;
    final dayKey = DocIds.dateKey(_date);
    final ofDay = [for (final s in sessions.value!) if (s.dateKey == dayKey) s]
      ..sort((x, z) => x.lectureNo.compareTo(z.lectureNo));
    final lectureNo = _lectureNo ?? (ofDay.isEmpty ? 1 : ofDay.last.lectureNo);
    final nextNo = ofDay.isEmpty ? 1 : ofDay.last.lectureNo + 1;
    final existing = ofDay.where((s) => s.lectureNo == lectureNo).firstOrNull;
    final sid = AttendanceStore.sessionIdFor(a, _date, lectureNo);
    _ensureLoaded(sid);

    final canOverride = ref.watch(permissionsProvider).canManageStage(a.stageId);
    final lockAt = existing?.lockAt ?? AttendanceSession.lockAtFor(_date, y.lockHours);
    final locked = (existing?.locked ?? false) || DateTime.now().toUtc().isAfter(lockAt);
    final readOnly = locked && !canOverride;

    final controls = _Controls(
      date: _date,
      lectures: [for (final s in ofDay) s.lectureNo],
      selected: lectureNo,
      nextNo: nextNo,
      onPickDate: () => _pickDate(y, canOverride),
      onPickLecture: _pickLecture,
    );

    if (list.isEmpty) {
      return scaffold(Column(children: [
        controls,
        Expanded(child: Center(child: MessageView(icon: Icons.group_off, title: l10n.recordNoStudents))),
      ]));
    }

    final loaded = _loadedSid == sid;
    final counts = {for (final s in AttendanceStatus.values) s: 0};
    for (final s in list) {
      counts[_markOf(s.id).status] = counts[_markOf(s.id).status]! + 1;
    }
    final q = ArabicText.normalizeForCompare(_query);
    final qDigits = ArabicText.normalizeDigits(_query.trim());
    final shown = q.isEmpty
        ? list
        : [
            for (final s in list)
              if (ArabicText.normalizeForCompare(s.fullName).contains(q) || s.universityId.contains(qDigits)) s,
          ];
    final palette = StatusPalette.of(context);
    final theme = Theme.of(context);
    final m = MaterialLocalizations.of(context);

    return scaffold(
      Column(
        children: [
          controls,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: locked
                ? Card(
                    key: const Key('record.locked'),
                    color: theme.colorScheme.errorContainer,
                    child: ListTile(
                      dense: true,
                      leading: const Icon(Icons.lock_clock),
                      title: Text(canOverride ? l10n.recordLockedOverride : l10n.recordLocked),
                    ),
                  )
                : Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      l10n.recordLocksAt(
                        m.formatShortDate(lockAt.toLocal()),
                        m.formatTimeOfDay(TimeOfDay.fromDateTime(lockAt.toLocal())),
                      ),
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final s in AttendanceStatus.values)
                  Chip(
                    key: Key('record.count.${s.name}'),
                    avatar: Icon(StatusPalette.iconForStatus(s), color: palette.forStatus(s), size: 18),
                    label: Text('${l10n.attendance(s)} ${counts[s]}'),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              key: const Key('record.search'),
              decoration: InputDecoration(
                isDense: true,
                prefixIcon: const Icon(Icons.search),
                hintText: l10n.recordSearch,
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          if (!readOnly)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(l10n.recordTapHint, style: theme.textTheme.bodySmall),
            ),
          Expanded(
            child: !loaded
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: shown.length,
                    itemBuilder: (context, i) {
                      final s = shown[i];
                      final mark = _markOf(s.id);
                      final color = palette.forStatus(mark.status);
                      return ListTile(
                        key: Key('record.student.${s.id}'),
                        leading: Icon(StatusPalette.iconForStatus(mark.status), color: color),
                        title: Text(s.fullName),
                        subtitle: Text(
                          mark.note.isEmpty ? bidiIsolate(s.universityId) : '${bidiIsolate(s.universityId)} · ${mark.note}',
                        ),
                        trailing: Text(l10n.attendance(mark.status), style: TextStyle(color: color)),
                        onTap: readOnly ? null : () => _toggle(s),
                        onLongPress: readOnly ? null : () => _editMark(s),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottom: readOnly
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: FilledButton.icon(
                  key: const Key('record.save'),
                  icon: _saving
                      ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.save),
                  label: Text(l10n.recordSave),
                  onPressed: _saving || !loaded ? null : () => _save(a, y, list, lectureNo, canOverride),
                ),
              ),
            ),
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({
    required this.date,
    required this.lectures,
    required this.selected,
    required this.nextNo,
    required this.onPickDate,
    required this.onPickLecture,
  });

  final DateTime date;
  final List<int> lectures;
  final int selected;
  final int nextNo;
  final VoidCallback onPickDate;
  final ValueChanged<int> onPickLecture;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final m = MaterialLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ActionChip(
            key: const Key('record.date'),
            avatar: const Icon(Icons.calendar_today, size: 18),
            label: Text('${l10n.recordDate}: ${m.formatMediumDate(date)}'),
            onPressed: onPickDate,
          ),
          for (final n in lectures)
            ChoiceChip(
              key: Key('record.lecture.$n'),
              label: Text(l10n.recordLectureN(n)),
              selected: n == selected,
              onSelected: (_) => onPickLecture(n),
            ),
          ChoiceChip(
            key: const Key('record.newLecture'),
            avatar: const Icon(Icons.add, size: 18),
            label: Text(lectures.isEmpty ? l10n.recordLectureN(nextNo) : l10n.recordNewLecture),
            selected: !lectures.contains(selected),
            onSelected: (_) => onPickLecture(lectures.contains(selected) ? nextNo : selected),
          ),
        ],
      ),
    );
  }
}

/// Late / excused / note for one student.
class _MarkSheet extends StatefulWidget {
  const _MarkSheet({required this.student, required this.initial});

  final Student student;
  final Mark initial;

  @override
  State<_MarkSheet> createState() => _MarkSheetState();
}

class _MarkSheetState extends State<_MarkSheet> {
  late AttendanceStatus _status = widget.initial.status;
  late final _note = TextEditingController(text: widget.initial.note);

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = StatusPalette.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.student.fullName, style: Theme.of(context).textTheme.titleMedium),
          Text(bidiIsolate(widget.student.universityId), style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final s in AttendanceStatus.values)
                ChoiceChip(
                  key: Key('mark.${s.name}'),
                  avatar: Icon(StatusPalette.iconForStatus(s), color: palette.forStatus(s), size: 18),
                  label: Text(l10n.attendance(s)),
                  selected: _status == s,
                  onSelected: (_) => setState(() => _status = s),
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('mark.note'),
            controller: _note,
            decoration: InputDecoration(labelText: l10n.recordNote),
            maxLength: 200,
          ),
          FilledButton(
            key: const Key('mark.done'),
            onPressed: () => Navigator.pop(context, Mark(_status, _note.text.trim())),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }
}
