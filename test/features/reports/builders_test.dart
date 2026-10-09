import 'dart:io';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:uob_attendance/core/domain/stage_ref.dart';
import 'package:uob_attendance/core/firebase/doc_ids.dart';
import 'package:uob_attendance/features/academic/domain/academic_year.dart';
import 'package:uob_attendance/features/assignments/domain/assignment.dart';
import 'package:uob_attendance/features/attendance/domain/attendance_session.dart';
import 'package:uob_attendance/features/courses/domain/course.dart';
import 'package:uob_attendance/features/reports/application/report_builders.dart';
import 'package:uob_attendance/features/reports/application/report_exporter.dart';
import 'package:uob_attendance/features/reports/data/pdf_renderer.dart';
import 'package:uob_attendance/features/reports/domain/report.dart';
import 'package:uob_attendance/features/stats/domain/absence_summary.dart';
import 'package:uob_attendance/features/stats/domain/standings.dart';
import 'package:uob_attendance/features/stats/domain/student_course_stat.dart';
import 'package:uob_attendance/features/students/domain/student.dart';
import 'package:uob_attendance/features/warnings/domain/warning_list.dart';
import 'package:uob_attendance/l10n/l10n.dart';

import 'renderers_test.dart' show branding;

void main() {
  final l10n = lookupAppLocalizations(const Locale('ar'));
  const stage = StageRef(3, Shift.morning);
  final course = Course(code: 'CS301', name: 'هياكل البيانات', stage: stage, semester: 1, units: 1, hasPractical: true);
  final assignment = Assignment.theory(teacherId: 't@uob.iq', courseId: course.id, stageId: stage.id, courseName: course.name);
  final students = [
    for (var i = 1; i <= 3; i++) Student(universityId: '$i', fullName: 'طالب $i محمد علي حسين', stage: stage, section: 'أ'),
  ];
  const year = AcademicYear(id: '2026-2027', semester: 1);
  final sessions = [
    for (var d = 1; d <= 20; d++)
      AttendanceSession(
        courseId: course.id,
        stageId: stage.id,
        yearId: year.id,
        type: AssignmentType.theory,
        target: DocIds.allSections,
        date: DateTime.utc(2026, 10, d),
        lectureNo: 1,
        openedBy: 't@uob.iq',
        lockAt: DateTime.utc(2026, 10, d + 3),
      ),
  ];
  final marks = {
    for (final s in sessions)
      s.id: {
        '1': s.date.day <= 3 ? AttendanceStatus.absent : AttendanceStatus.present,
        '2': s.date.day == 5 ? AttendanceStatus.late : AttendanceStatus.present,
        '3': AttendanceStatus.present,
      },
  };
  final standings = {
    for (final st in students)
      st.id: AbsenceSummary.of(
        bySession: {for (final e in marks.entries) e.key: e.value[st.id]!},
        leaves: const [],
        units: course.units,
        year: year,
      ),
  };

  Report register(ReportFormat f) => ReportBuilders.classRegister(
        l10n,
        assignment: assignment,
        courseName: course.name,
        students: students,
        sessions: sessions.reversed.toList(),
        marks: marks,
        standings: standings,
        format: f,
      );

  test('class register for a period keeps only its lectures and says so', () {
    final r = ReportBuilders.classRegister(
      l10n,
      assignment: assignment,
      courseName: course.name,
      students: students,
      sessions: sessions,
      marks: marks,
      standings: standings,
      format: ReportFormat.pdf,
      period: (from: DateTime(2026, 10, 2), to: DateTime(2026, 10, 5)),
    );
    expect(r.tables.single.columns, hasLength(2 + 4 + 2));
    expect(r.tables.single.columns[2].title, '2/10\n#1');
    expect(r.meta, contains('الفترة: من 2026/10/2 إلى 2026/10/5'));
    expect(r.meta, contains(l10n.reportLectureCount(4)));
    expect(r.tables.single.rows.first.reversed.elementAt(1).text, '2', reason: 'absences in the period');
    expect(r.notes, contains(l10n.reportPeriodNote));
  });

  test('class register: PDF splits lectures into tables of 16, Excel keeps one sheet', () {
    final pdf = register(ReportFormat.pdf);
    expect(pdf.tables, hasLength(2));
    expect(pdf.tables[0].columns, hasLength(2 + 16 + 2));
    expect(pdf.tables[1].columns, hasLength(2 + 4 + 2));
    expect(pdf.tables[0].heading, 'المحاضرات من 1 إلى 16');
    expect(pdf.tables[0].columns[2].title, '1/10\n#1', reason: 'lectures in date order');
    final first = pdf.tables[0].rows.first;
    expect(first[1].text, 'طالب 1 محمد علي حسين');
    expect(first[2].text, 'غ');
    expect(first[2].tone, ReportTone.absent);
    expect(pdf.tables[1].rows.first.reversed.elementAt(1).text, '3', reason: 'absences over all lectures');
    // 3 of 15 planned = 20% → فصل.
    expect(pdf.tables[1].rows.first.last.text, '20.0');
    expect(pdf.tables[1].rows.first.last.tone, ReportTone.dismissal);
    expect(pdf.orientation, ReportOrientation.landscape);
    expect(pdf.signatures, ['التدريسي', 'مسؤول المرحلة', 'رئيس القسم']);

    final xlsx = register(ReportFormat.excel);
    expect(xlsx.tables, hasLength(1));
    expect(xlsx.tables.single.columns, hasLength(2 + 20 + 2));
  });

  final standingRows = [
    for (final st in students)
      Standing(student: st, course: course, summary: standings[st.id]!),
  ]..sort((a, b) => b.summary.percent.compareTo(a.summary.percent));

  test('student summary, lists, decisions and stage statistics', () {
    final summary = ReportBuilders.studentSummary(l10n,
        student: students.first, stageLabel: l10n.stage(stage), standings: [standingRows.first]);
    expect(summary.title, 'ملخص غياب الطالب طالب 1 محمد علي حسين');
    expect(summary.tables.single.rows.single.last.text, 'فصل');

    final list = ReportBuilders.standingsList(l10n,
        stageLabel: l10n.stage(stage), listLabel: 'فصل', courseName: null, rows: [standingRows.first]);
    expect(list.tables.single.rows.single[4].text, 'هياكل البيانات');

    final decision = ReportBuilders.decision(
      l10n,
      list: WarningList(
        id: 'w1',
        stageId: stage.id,
        level: WarningLevel.dismissal,
        decision: DecisionType.deanery,
        orderNumber: '3/4/1234',
        entries: WarningsEntries.from(standingRows.take(1)),
      ),
      stageLabel: l10n.stage(stage),
      dateText: '1/11/2026',
    );
    expect(decision.meta.first, contains('3/4/1234'));
    expect(decision.signatures.last, 'عميد الكلية');

    final stats = ReportBuilders.stageStatistics(l10n, stageLabel: l10n.stage(stage), standings: standingRows);
    expect(stats.tables, hasLength(2));
    expect(stats.tables.first.rows.single[3].text, '3', reason: 'total absences of the course');
    expect(stats.tables.last.rows.map((r) => r[1].text), ['طالب 1 محمد علي حسين'], reason: 'only students with absences');
  });

  test('warning letter: wording from the year thresholds; dismissal notice at that level', () {
    final letter = ReportBuilders.warningLetter(l10n,
        standing: standingRows.first, stageLabel: l10n.stage(stage), thresholds: year.thresholds);
    expect(letter.title, 'إشعار رسوب بسبب الغياب');
    expect(letter.paragraphs[1], contains('20.0٪'));
    expect(letter.paragraphs[1], contains('(15٪)'));
    expect(letter.tables, isEmpty);

    final warned = Standing(
      student: students[1],
      course: course,
      summary: AbsenceSummary.of(
        bySession: {sessions[0].id: AttendanceStatus.absent, sessions[1].id: AttendanceStatus.absent},
        leaves: const [],
        units: 1,
        year: year,
      ),
    );
    final w = ReportBuilders.warningLetter(l10n, standing: warned, stageLabel: l10n.stage(stage), thresholds: year.thresholds);
    expect(w.title, 'إنذار بالغياب');
    expect(w.paragraphs[1], allOf(contains('(10٪)'), contains('15٪')));
  });

  test('renders the register and the summary as PDFs (preview with REPORT_PREVIEW)', () async {
    final renderer = PdfRenderer(
      regularFont: File('assets/fonts/cairo/Cairo-Regular.ttf').readAsBytesSync(),
      boldFont: File('assets/fonts/cairo/Cairo-Bold.ttf').readAsBytesSync(),
      logo: File('assets/images/dept_logo.png').readAsBytesSync(),
    );
    final bytes = await renderer.render(register(ReportFormat.pdf), branding);
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    final letters = await renderer.renderAll([
      for (final s in standingRows.take(2))
        ReportBuilders.warningLetter(l10n, standing: s, stageLabel: l10n.stage(stage), thresholds: year.thresholds),
    ], branding);
    expect(String.fromCharCodes(letters.take(5)), '%PDF-');
    final out = Platform.environment['REPORT_PREVIEW'];
    if (out != null) {
      File(out).writeAsBytesSync(bytes);
      File(out.replaceAll('.pdf', '_letters.pdf')).writeAsBytesSync(letters);
    }
  });
}

/// Same mapping the app uses when saving a decision.
abstract final class WarningsEntries {
  static List<WarningListEntry> from(Iterable<Standing> rows) => [
        for (final s in rows)
          WarningListEntry(
            studentId: s.student.id,
            studentName: s.student.fullName,
            courseId: s.course.id,
            courseName: s.course.name,
            percent: s.summary.percent,
            absences: s.summary.absences,
            planned: s.summary.planned,
            section: s.student.section,
          ),
      ];
}
