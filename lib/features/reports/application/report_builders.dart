import '../../../l10n/l10n.dart';
import '../../assignments/domain/assignment.dart';
import '../../attendance/domain/attendance_session.dart';
import '../../courses/data/course_panel.dart';
import '../../stats/domain/absence_summary.dart';
import '../../stats/domain/standings.dart';
import '../../stats/domain/student_course_stat.dart';
import '../../students/domain/student.dart';
import '../../academic/domain/academic_year.dart';
import '../../warnings/domain/warning_list.dart';
import '../domain/report.dart';
import 'report_exporter.dart';

/// Turns app data into [Report]s. Pure apart from the localized labels, so
/// tests build them with `lookupAppLocalizations`.
abstract final class ReportBuilders {
  /// PDF pages hold this many lecture columns; Excel takes them all.
  static const lecturesPerPdfTable = 16;

  static ReportTone toneOfStatus(AttendanceStatus? s) => switch (s) {
        null => ReportTone.muted,
        AttendanceStatus.present => ReportTone.present,
        AttendanceStatus.absent => ReportTone.absent,
        AttendanceStatus.late => ReportTone.late,
        AttendanceStatus.excused => ReportTone.excused,
      };

  static ReportTone toneOfLevel(WarningLevel l) => switch (l) {
        WarningLevel.none => ReportTone.normal,
        WarningLevel.alert => ReportTone.alert,
        WarningLevel.warning => ReportTone.warning,
        WarningLevel.dismissal => ReportTone.dismissal,
      };

  static String letter(AppLocalizations l10n, AttendanceStatus? s) => switch (s) {
        null => '–',
        AttendanceStatus.present => l10n.reportLetterPresent,
        AttendanceStatus.absent => l10n.reportLetterAbsent,
        AttendanceStatus.late => l10n.reportLetterLate,
        AttendanceStatus.excused => l10n.reportLetterExcused,
      };

  static String percent(double p) => p.toStringAsFixed(1);

  /// سجل حضور مادة نظري / مجموعة عملي: students × lectures.
  static Report classRegister(
    AppLocalizations l10n, {
    required Assignment assignment,
    required String courseName,
    required List<Student> students,
    required List<AttendanceSession> sessions,
    required Map<String, Map<String, AttendanceStatus>> marks,
    required Map<String, AbsenceSummary> standings,
    required ReportFormat format,
    ({DateTime from, DateTime to})? period,
    String Function(DateTime)? formatDate,
  }) {
    // A period keeps the lectures from [from] to [to] (whole days, inclusive).
    bool inPeriod(AttendanceSession s) {
      if (period == null) return true;
      final day = DateTime.utc(s.date.year, s.date.month, s.date.day);
      return !day.isBefore(DateTime.utc(period.from.year, period.from.month, period.from.day)) &&
          !day.isAfter(DateTime.utc(period.to.year, period.to.month, period.to.day));
    }

    final ordered = [...sessions.where(inPeriod)]
      ..sort((a, b) => a.date != b.date ? a.date.compareTo(b.date) : a.lectureNo.compareTo(b.lectureNo));
    final chunks = <List<AttendanceSession>>[];
    final size = format == ReportFormat.pdf ? lecturesPerPdfTable : (ordered.isEmpty ? 1 : ordered.length);
    for (var i = 0; i < ordered.length; i += size) {
      chunks.add(ordered.sublist(i, (i + size).clamp(0, ordered.length)));
    }
    if (chunks.isEmpty) chunks.add(const []);

    int absences(String id) => ordered.where((s) => marks[s.id]?[id] == AttendanceStatus.absent).length;

    final tables = [
      for (final (n, chunk) in chunks.indexed)
        ReportTable(
          name: chunks.length == 1 ? l10n.reportRegisterSheet : '${l10n.reportRegisterSheet} ${n + 1}',
          heading: chunks.length == 1 || chunk.isEmpty
              ? null
              : l10n.reportLecturesRange(n * size + 1, n * size + chunk.length),
          columns: [
            const ReportColumn('ت', flex: 0.5, numeric: true),
            ReportColumn(l10n.registerStudent, flex: 4),
            for (final s in chunk) ReportColumn('${s.date.day}/${s.date.month}\n#${s.lectureNo}', flex: 0.6, numeric: true),
            ReportColumn(l10n.registerAbsences, flex: 0.9, numeric: true),
            ReportColumn(l10n.registerPercent, flex: 0.9, numeric: true),
          ],
          rows: [
            for (final (i, st) in students.indexed)
              [
                ReportCell('${i + 1}'),
                ReportCell(st.fullName),
                for (final s in chunk)
                  ReportCell(letter(l10n, marks[s.id]?[st.id]), tone: toneOfStatus(marks[s.id]?[st.id])),
                ReportCell('${absences(st.id)}'),
                switch (standings[st.id]) {
                  final sum? when sum.planned > 0 =>
                    ReportCell(percent(sum.percent), tone: toneOfLevel(sum.level), bold: sum.level != WarningLevel.none),
                  _ => const ReportCell('–'),
                },
              ],
          ],
        ),
    ];
    return Report(
      title: l10n.reportRegisterTitle(courseName),
      fileBase: '${l10n.reportRegisterSheet} $courseName ${assignment.stageId}',
      meta: [
        l10n.classLabel(assignment),
        if (period != null)
          l10n.reportPeriod((formatDate ?? _isoDate)(period.from), (formatDate ?? _isoDate)(period.to)),
        l10n.reportLectureCount(ordered.length),
      ],
      tables: tables,
      notes: [l10n.reportLegend, l10n.reportPercentNote, if (period != null) l10n.reportPeriodNote],
      signatures: [l10n.reportSignTeacher, l10n.reportSignStageManager, l10n.reportSignHead],
      orientation: ReportOrientation.landscape,
    );
  }

  /// «لوحة المادة»: the course, its classes and teachers, its students with
  /// their percentages, and every lecture recorded in it.
  static Report coursePanel(
    AppLocalizations l10n, {
    required CoursePanel panel,
    required String stageLabel,
    required String courseInfo,
    String Function(DateTime)? formatDate,
  }) {
    final c = panel.course;
    final date = formatDate ?? _isoDate;
    // '' = one percentage; otherwise theory then practical.
    final keys = panel.students.isEmpty ? const <String>[] : panel.students.first.summaries.keys.toList();
    String suffix(String key) => switch (key) {
          '' => '',
          'theory' => '\n${l10n.theoryLabel}',
          _ => '\n${l10n.practicalLabel}',
        };
    return Report(
      title: l10n.coursePanelReportTitle(c.name),
      fileBase: '${l10n.coursePanelAction} ${c.name} ${c.stageId}',
      meta: [
        '$stageLabel · $courseInfo',
        for (final a in panel.classes)
          '${l10n.classLabel(a)}: ${a.teacherName.isEmpty ? a.teacherId : a.teacherName}',
        l10n.reportLectureCount(panel.sessions.length),
        l10n.reportStudentCount(panel.students.length),
      ],
      tables: [
        ReportTable(
          name: l10n.coursePanelStudentsSheet,
          heading: l10n.coursePanelStudentsSheet,
          columns: [
            const ReportColumn('ت', flex: 0.5, numeric: true),
            ReportColumn(l10n.registerStudent, flex: 3.5),
            ReportColumn(l10n.fieldUniversityId, flex: 1.4),
            ReportColumn(l10n.fieldSection, flex: 0.8),
            if (c.hasPractical) ReportColumn(l10n.coursePanelGroup, flex: 0.9),
            for (final k in keys) ...[
              ReportColumn('${l10n.registerAbsences}${suffix(k)}', flex: 0.9, numeric: true),
              ReportColumn('${l10n.registerPercent}${suffix(k)}', flex: 0.9, numeric: true),
            ],
          ],
          rows: [
            for (final (i, r) in panel.students.indexed)
              [
                ReportCell('${i + 1}'),
                ReportCell(r.student.fullName),
                ReportCell(r.student.universityId),
                ReportCell(r.student.section),
                if (c.hasPractical) ReportCell(r.group ?? '–'),
                for (final k in keys)
                  ...switch (r.summaries[k]) {
                    final sum? when sum.planned > 0 => [
                        ReportCell('${sum.absences}'),
                        ReportCell(percent(sum.percent), tone: toneOfLevel(sum.level), bold: sum.level != WarningLevel.none),
                      ],
                    _ => const [ReportCell('–'), ReportCell('–')],
                  },
              ],
          ],
        ),
        ReportTable(
          name: l10n.coursePanelLecturesSheet,
          heading: l10n.coursePanelLecturesSheet,
          columns: [
            const ReportColumn('ت', flex: 0.5, numeric: true),
            ReportColumn(l10n.coursePanelDate, flex: 1.6),
            ReportColumn(l10n.coursePanelLectureNo, flex: 0.8, numeric: true),
            ReportColumn(l10n.coursePanelClass, flex: 1.8),
            ReportColumn(l10n.coursePanelTeacher, flex: 2.6),
            for (final st in AttendanceStatus.values) ReportColumn(l10n.attendance(st), flex: 0.8, numeric: true),
          ],
          rows: [
            for (final (i, s) in [...panel.sessions.reversed].indexed)
              [
                ReportCell('${i + 1}'),
                ReportCell(date(s.date)),
                ReportCell('${s.lectureNo}'),
                ReportCell(l10n.sessionClassLabel(s)),
                ReportCell(panel.teacherOf(s)),
                for (final st in AttendanceStatus.values)
                  ReportCell('${panel.count(s, st)}', tone: panel.count(s, st) > 0 ? toneOfStatus(st) : ReportTone.normal),
              ],
          ],
        ),
      ],
      notes: [l10n.reportPercentNote],
      signatures: [l10n.reportSignStageManager, l10n.reportSignHead],
      orientation: ReportOrientation.landscape,
    );
  }

  static String _isoDate(DateTime d) => '${d.year}/${d.month}/${d.day}';

  static List<ReportColumn> _standingColumns(AppLocalizations l10n, {bool withCourse = true}) => [
        const ReportColumn('ت', flex: 0.5, numeric: true),
        ReportColumn(l10n.registerStudent, flex: 3.5),
        ReportColumn(l10n.fieldUniversityId, flex: 1.4),
        ReportColumn(l10n.fieldSection, flex: 0.8),
        if (withCourse) ReportColumn(l10n.warnCourse, flex: 2.4),
        ReportColumn(l10n.registerAbsences, flex: 0.9, numeric: true),
        ReportColumn(l10n.reportPlanned, flex: 0.9, numeric: true),
        ReportColumn(l10n.registerPercent, flex: 0.9, numeric: true),
      ];

  static String _courseLabel(AppLocalizations l10n, String name, String? type) =>
      type == null ? name : '$name · ${type == 'theory' ? l10n.theoryLabel : l10n.practicalLabel}';

  /// The list currently shown in «النسب والقوائم» (one level, maybe one course).
  static Report standingsList(
    AppLocalizations l10n, {
    required String stageLabel,
    required String listLabel,
    required String? courseName,
    required List<Standing> rows,
  }) =>
      Report(
        title: l10n.reportListTitle(listLabel, stageLabel),
        fileBase: '$listLabel $stageLabel ${courseName ?? ''}',
        meta: [courseName ?? l10n.warnAllCourses, l10n.reportStudentCount(rows.length)],
        tables: [
          ReportTable(
            name: listLabel,
            columns: _standingColumns(l10n),
            rows: [
              for (final (i, s) in rows.indexed)
                [
                  ReportCell('${i + 1}'),
                  ReportCell(s.student.fullName),
                  ReportCell(s.student.universityId),
                  ReportCell(s.student.section),
                  ReportCell(_courseLabel(l10n, s.course.name, s.type)),
                  ReportCell('${s.summary.absences}'),
                  ReportCell('${s.summary.planned}'),
                  ReportCell(percent(s.summary.percent), tone: toneOfLevel(s.level), bold: true),
                ],
            ],
          ),
        ],
        notes: [l10n.reportPercentNote],
        signatures: [l10n.reportSignStageManager, l10n.reportSignHead],
      );

  /// A saved decision exactly as it was saved.
  static Report decision(
    AppLocalizations l10n, {
    required WarningList list,
    required String stageLabel,
    required String dateText,
  }) =>
      Report(
        title: l10n.reportDecisionTitle(l10n.warningLevel(list.level), stageLabel),
        fileBase: '${l10n.warningLevel(list.level)} $stageLabel ${list.orderNumber ?? list.id}',
        meta: [
          if (list.isFinal) l10n.warnDeanery(list.orderNumber ?? '', dateText) else l10n.warnDepartment(dateText),
          if (list.courseId != null && list.entries.isNotEmpty) list.entries.first.courseName,
          l10n.reportStudentCount(list.entries.length),
        ],
        tables: [
          ReportTable(
            name: l10n.warningLevel(list.level),
            columns: _standingColumns(l10n),
            rows: [
              for (final (i, e) in list.entries.indexed)
                [
                  ReportCell('${i + 1}'),
                  ReportCell(e.studentName),
                  ReportCell(e.studentId),
                  ReportCell(e.section),
                  ReportCell(_courseLabel(l10n, e.courseName.isEmpty ? e.courseId : e.courseName, e.type)),
                  ReportCell('${e.absences}'),
                  ReportCell('${e.planned}'),
                  ReportCell(percent(e.percent), tone: toneOfLevel(list.level), bold: true),
                ],
            ],
          ),
        ],
        signatures: [
          l10n.reportSignStageManager,
          l10n.reportSignHead,
          if (list.isFinal) l10n.reportSignDean,
        ],
      );

  /// ملخص الطالب في كل مواده مع النسب.
  static Report studentSummary(
    AppLocalizations l10n, {
    required Student student,
    required String stageLabel,
    required List<Standing> standings,
  }) {
    final rows = [...standings]..sort((a, b) => a.course.code.compareTo(b.course.code));
    return Report(
      title: l10n.reportStudentTitle(student.fullName),
      fileBase: '${student.fullName} ${student.universityId}',
      meta: [
        '${l10n.fieldUniversityId}: ${student.universityId}',
        [stageLabel, if (student.section.isNotEmpty) '${l10n.fieldSection} ${student.section}'].join(' · '),
      ],
      tables: [
        ReportTable(
          name: l10n.reportStudentSheet,
          columns: [
            const ReportColumn('ت', flex: 0.5, numeric: true),
            ReportColumn(l10n.warnCourse, flex: 3.5),
            ReportColumn(l10n.fieldUnits, flex: 0.8, numeric: true),
            ReportColumn(l10n.reportPlanned, flex: 0.9, numeric: true),
            ReportColumn(l10n.registerAbsences, flex: 0.9, numeric: true),
            ReportColumn(l10n.reportExcused, flex: 0.9, numeric: true),
            ReportColumn(l10n.registerPercent, flex: 0.9, numeric: true),
            ReportColumn(l10n.reportLevel, flex: 1.1),
          ],
          rows: [
            for (final (i, s) in rows.indexed)
              [
                ReportCell('${i + 1}'),
                ReportCell(_courseLabel(l10n, s.course.name, s.type)),
                ReportCell('${s.course.units}'),
                ReportCell('${s.summary.planned}'),
                ReportCell('${s.summary.absences}'),
                ReportCell('${s.summary.excused}'),
                ReportCell(percent(s.summary.percent), tone: toneOfLevel(s.level), bold: s.level != WarningLevel.none),
                ReportCell(s.level == WarningLevel.none ? '–' : l10n.warningLevel(s.level), tone: toneOfLevel(s.level)),
              ],
          ],
        ),
      ],
      notes: [l10n.reportStudentNote, l10n.reportPercentNote],
      signatures: [l10n.reportSignStageManager, l10n.reportSignHead],
    );
  }

  /// كتاب إنذار (or, at the dismissal level, notice of failing by absence)
  /// for one student in one course. A default wording until the department
  /// supplies its official form; the number and date are left to fill in.
  static Report warningLetter(
    AppLocalizations l10n, {
    required Standing standing,
    required String stageLabel,
    required AbsenceThresholds thresholds,
  }) {
    final s = standing.summary;
    final dismissal = standing.level == WarningLevel.dismissal;
    final course = _courseLabel(l10n, standing.course.name, standing.type);
    String pct(double v) => v == v.roundToDouble() ? '${v.round()}' : v.toStringAsFixed(1);
    return Report(
      title: dismissal ? l10n.letterDismissalTitle : l10n.letterWarningTitle,
      fileBase: '${dismissal ? l10n.letterDismissalTitle : l10n.letterWarningTitle} ${standing.student.fullName} ${standing.course.code}',
      meta: [l10n.letterNumberDate],
      paragraphs: [
        l10n.letterTo(standing.student.fullName, standing.student.universityId, stageLabel),
        if (dismissal)
          l10n.letterDismissalBody(course, percent(s.percent), s.absences, s.planned, pct(thresholds.dismissal))
        else
          l10n.letterWarningBody(course, percent(s.percent), s.absences, s.planned, pct(thresholds.warning), pct(thresholds.dismissal)),
        dismissal ? l10n.letterDismissalClosing : l10n.letterWarningClosing,
      ],
      tables: const [],
      signatures: [l10n.reportSignStageManager, l10n.reportSignHead],
    );
  }

  /// إحصائية المرحلة: courses by absences, and the students most absent.
  static Report stageStatistics(
    AppLocalizations l10n, {
    required String stageLabel,
    required List<Standing> standings,
    int topStudents = 20,
  }) {
    final byCourse = <String, List<Standing>>{};
    for (final s in standings) {
      (byCourse['${s.course.id}|${s.type ?? ''}'] ??= []).add(s);
    }
    final courseRows = byCourse.values.toList()
      ..sort((a, b) => b.fold<int>(0, (n, s) => n + s.summary.absences).compareTo(a.fold<int>(0, (n, s) => n + s.summary.absences)));
    int count(List<Standing> l, WarningLevel level) => l.where((s) => s.level == level).length;
    final top = standings.where((s) => s.summary.absences > 0).take(topStudents).toList();
    return Report(
      title: l10n.reportStatsTitle(stageLabel),
      fileBase: '${l10n.reportStatsSheet} $stageLabel',
      meta: [
        l10n.reportStatsLevels(
          count(standings, WarningLevel.alert),
          count(standings, WarningLevel.warning),
          count(standings, WarningLevel.dismissal),
        ),
      ],
      tables: [
        ReportTable(
          name: l10n.reportStatsSheet,
          heading: l10n.reportStatsByCourse,
          columns: [
            const ReportColumn('ت', flex: 0.5, numeric: true),
            ReportColumn(l10n.warnCourse, flex: 3.5),
            ReportColumn(l10n.reportAbsentStudents, flex: 1.2, numeric: true),
            ReportColumn(l10n.reportTotalAbsences, flex: 1.2, numeric: true),
            ReportColumn(l10n.levelAlert, flex: 0.9, numeric: true),
            ReportColumn(l10n.levelWarning, flex: 0.9, numeric: true),
            ReportColumn(l10n.levelDismissal, flex: 0.9, numeric: true),
          ],
          rows: [
            for (final (i, list) in courseRows.indexed)
              [
                ReportCell('${i + 1}'),
                ReportCell(_courseLabel(l10n, list.first.course.name, list.first.type)),
                ReportCell('${list.where((s) => s.summary.absences > 0).length}'),
                ReportCell('${list.fold<int>(0, (n, s) => n + s.summary.absences)}', bold: true),
                ReportCell('${count(list, WarningLevel.alert)}', tone: ReportTone.alert),
                ReportCell('${count(list, WarningLevel.warning)}', tone: ReportTone.warning),
                ReportCell('${count(list, WarningLevel.dismissal)}', tone: ReportTone.dismissal),
              ],
          ],
        ),
        ReportTable(
          name: l10n.reportTopSheet,
          heading: l10n.reportTopStudents(top.length),
          columns: _standingColumns(l10n),
          rows: [
            for (final (i, s) in top.indexed)
              [
                ReportCell('${i + 1}'),
                ReportCell(s.student.fullName),
                ReportCell(s.student.universityId),
                ReportCell(s.student.section),
                ReportCell(_courseLabel(l10n, s.course.name, s.type)),
                ReportCell('${s.summary.absences}'),
                ReportCell('${s.summary.planned}'),
                ReportCell(percent(s.summary.percent), tone: toneOfLevel(s.level), bold: true),
              ],
          ],
        ),
      ],
      notes: [l10n.reportPercentNote],
      signatures: [l10n.reportSignStageManager, l10n.reportSignHead],
    );
  }
}
