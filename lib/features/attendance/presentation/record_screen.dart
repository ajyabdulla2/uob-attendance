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
import '../../edit_requests/application/edit_requests_providers.dart';
import '../../edit_requests/domain/edit_request.dart';
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

  /// A locked lecture: ask the stage manager to change one student's status.
  Future<void> _requestEdit(Assignment a, String sid, Student s) async {
    final l10n = context.l10n;
    final current = _markOf(s.id).status;
    final picked = await showModalBottomSheet<(AttendanceStatus, String)>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _EditRequestSheet(student: s, current: current),
    );
    if (picked == null || !mounted) return;
    try {
      await ref.read(editRequestsRepositoryProvider).file(EditRequest(
            id: '',
            sessionId: sid,
            studentId: s.id,
            stageId: a.stageId,
            requestedStatus: picked.$1,
            currentStatus: current,
            reason: picked.$2,
            requestedBy: ref.read(signedInUserProvider).id,
          ));
      if (mounted) showSnack(context, l10n.editRequestSent);
    } on Object catch (e) {
      if (mounted) showError(context, e);
    }
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
      if (mounted) showError(context, e);
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
    final pending = readOnly
        ? {
            for (final r in ref.watch(myEditRequestsProvider).value ?? const <EditRequest>[])
              if (r.sessionId == sid && r.status == EditRequestStatus.pending) r.studentId,
          }
        : const <String>{};

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

    // The student list gets the screen: day/lecture stay on one line above
    // it, the lock time, search and hint scroll away with the list, and the
    // counters share the bottom bar with the save button.
    final header = <Widget>[
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
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
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
        child: Text(
          [
            if (!locked)
              l10n.recordLocksAt(
                m.formatShortDate(lockAt.toLocal()),
                m.formatTimeOfDay(TimeOfDay.fromDateTime(lockAt.toLocal())),
              ),
            if (!readOnly) l10n.recordTapHint else if (existing != null) l10n.recordRequestHint,
          ].join('\n'),
          style: theme.textTheme.bodySmall,
        ),
      ),
    ];

    return scaffold(
      Column(
        children: [
          controls,
          if (locked)
            Material(
              key: const Key('record.locked'),
              color: theme.colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  children: [
                    Icon(Icons.lock_clock, size: 18, color: theme.colorScheme.onErrorContainer),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        canOverride ? l10n.recordLockedOverride : l10n.recordLocked,
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onErrorContainer),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: !loaded
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: header.length + shown.length,
                    itemBuilder: (context, i) {
                      if (i < header.length) return header[i];
                      final s = shown[i - header.length];
                      final mark = _markOf(s.id);
                      final color = palette.forStatus(mark.status);
                      return ListTile(
                        key: Key('record.student.${s.id}'),
                        visualDensity: VisualDensity.compact,
                        leading: Icon(StatusPalette.iconForStatus(mark.status), color: color),
                        title: Text(s.fullName),
                        subtitle: Text([
                          bidiIsolate(s.universityId),
                          if (mark.note.isNotEmpty) mark.note,
                          if (pending.contains(s.id)) l10n.editRequestPending,
                        ].join(' · ')),
                        trailing: Text(l10n.attendance(mark.status), style: TextStyle(color: color)),
                        onTap: readOnly
                            ? (existing == null || pending.contains(s.id) ? null : () => _requestEdit(a, sid, s))
                            : () => _toggle(s),
                        onLongPress: readOnly ? null : () => _editMark(s),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottom: Material(
        elevation: 3,
        color: theme.colorScheme.surfaceContainer,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 10,
                  runSpacing: 2,
                  children: [
                    for (final st in AttendanceStatus.values)
                      Row(
                        key: Key('record.count.${st.name}'),
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(StatusPalette.iconForStatus(st), color: palette.forStatus(st), size: 16),
                          const SizedBox(width: 2),
                          Text('${l10n.attendance(st)} ${counts[st]}', style: theme.textTheme.bodySmall),
                        ],
                      ),
                  ],
                ),
              ),
              if (!readOnly) ...[
                const SizedBox(width: 8),
                FilledButton.icon(
                  key: const Key('record.save'),
                  icon: _saving
                      ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.save),
                  label: Text(l10n.recordSave),
                  onPressed: _saving || !loaded ? null : () => _save(a, y, list, lectureNo, canOverride),
                ),
              ],
            ],
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
    final chips = <Widget>[
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
    ];
    // One line that scrolls sideways when a day has many lectures.
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 8, 4),
      child: Row(
        children: [
          for (final chip in chips) Padding(padding: const EdgeInsetsDirectional.only(end: 8), child: chip),
        ],
      ),
    );
  }
}

/// Requested status and reason for a change to a locked lecture.
class _EditRequestSheet extends StatefulWidget {
  const _EditRequestSheet({required this.student, required this.current});

  final Student student;
  final AttendanceStatus current;

  @override
  State<_EditRequestSheet> createState() => _EditRequestSheetState();
}

class _EditRequestSheetState extends State<_EditRequestSheet> {
  late AttendanceStatus _status =
      widget.current == AttendanceStatus.present ? AttendanceStatus.absent : AttendanceStatus.present;
  final _reason = TextEditingController();

  @override
  void dispose() {
    _reason.dispose();
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
          Text(l10n.editRequestTitle, style: Theme.of(context).textTheme.titleMedium),
          Text('${widget.student.fullName} · ${l10n.editRequestNow(l10n.attendance(widget.current))}',
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final s in AttendanceStatus.values)
                if (s != widget.current)
                  ChoiceChip(
                    key: Key('request.${s.name}'),
                    avatar: Icon(StatusPalette.iconForStatus(s), color: palette.forStatus(s), size: 18),
                    label: Text(l10n.attendance(s)),
                    selected: _status == s,
                    onSelected: (_) => setState(() => _status = s),
                  ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('request.reason'),
            controller: _reason,
            decoration: InputDecoration(labelText: l10n.editRequestReason),
            maxLength: 300,
            onChanged: (_) => setState(() {}),
          ),
          FilledButton(
            key: const Key('request.send'),
            onPressed: _reason.text.trim().isEmpty ? null : () => Navigator.pop(context, (_status, _reason.text.trim())),
            child: Text(l10n.editRequestSend),
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
