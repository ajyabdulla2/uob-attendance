import 'package:flutter_test/flutter_test.dart';
import 'package:uob_attendance/features/academic/domain/academic_year.dart';
import 'package:uob_attendance/features/attendance/domain/attendance_session.dart';
import 'package:uob_attendance/features/leaves/domain/leave.dart';
import 'package:uob_attendance/features/stats/domain/absence_summary.dart';
import 'package:uob_attendance/features/stats/domain/student_course_stat.dart';

String sid(String day, {String type = 'theory', int n = 1}) => 'CS1_1-morning__${type}__all__${day}__$n';

Leave leave(DateTime from, DateTime to, {bool approved = true}) => Leave(
      id: 'l',
      studentId: '1',
      stageId: '1-morning',
      type: LeaveType.sick,
      from: from,
      to: to,
      approvedBy: approved ? 'sm@uob.iq' : null,
    );

void main() {
  // 2 units × 1 × 10 weeks = 20 planned lectures → each absence is 5%.
  const year = AcademicYear(id: '2026-2027', semester: 1, weeksPerSemester: 10);

  test('absences over planned lectures; late and present do not count', () {
    final s = AbsenceSummary.of(
      bySession: {
        sid('20261001'): AttendanceStatus.absent,
        sid('20261002'): AttendanceStatus.absent,
        sid('20261003'): AttendanceStatus.late,
        sid('20261004'): AttendanceStatus.present,
        sid('20261005'): AttendanceStatus.excused,
      },
      leaves: const [],
      units: 2,
      year: year,
    );
    expect(s.planned, 20);
    expect(s.absences, 2);
    expect(s.excused, 1);
    expect(s.lates, 1);
    expect(s.percent, 10);
    expect(s.level, WarningLevel.warning);
    expect(s.nextLevel, WarningLevel.dismissal);
    expect(s.untilNext, 1, reason: '3 × 5% = 15% → فصل');
  });

  test('an approved leave turns its days\' absences into excused; pending ones do not', () {
    final marks = {
      sid('20261001'): AttendanceStatus.absent,
      sid('20261002'): AttendanceStatus.absent,
      sid('20261006'): AttendanceStatus.absent,
    };
    final approved = AbsenceSummary.of(
      bySession: marks,
      leaves: [leave(DateTime.utc(2026, 10, 1), DateTime.utc(2026, 10, 2))],
      units: 2,
      year: year,
    );
    expect(approved.absences, 1);
    expect(approved.byLeave, 2);
    expect(approved.level, WarningLevel.alert);

    final pending = AbsenceSummary.of(
      bySession: marks,
      leaves: [leave(DateTime.utc(2026, 10, 1), DateTime.utc(2026, 10, 2), approved: false)],
      units: 2,
      year: year,
    );
    expect(pending.absences, 3);
  });

  test('leave cap: only the earliest maxLeaveDays days excuse', () {
    const capped = AcademicYear(id: 'y', semester: 1, weeksPerSemester: 10, maxLeaveDays: 1);
    final s = AbsenceSummary.of(
      bySession: {sid('20261001'): AttendanceStatus.absent, sid('20261002'): AttendanceStatus.absent},
      leaves: [leave(DateTime.utc(2026, 10, 1), DateTime.utc(2026, 10, 5))],
      units: 2,
      year: capped,
    );
    expect(s.absences, 1);
    expect(s.byLeave, 1);
  });

  test('when leaves count against the student, excused lectures are absences', () {
    const strict = AcademicYear(id: 'y', semester: 1, weeksPerSemester: 10, leavesCountAgainst: true);
    final s = AbsenceSummary.of(
      bySession: {sid('20261001'): AttendanceStatus.excused, sid('20261002'): AttendanceStatus.absent},
      leaves: [leave(DateTime.utc(2026, 10, 2), DateTime.utc(2026, 10, 2))],
      units: 2,
      year: strict,
    );
    expect(s.absences, 2);
    expect(s.excused, 0);
  });

  test('separate theory/practical: a type filter keeps only that type\'s lectures', () {
    final marks = {
      sid('20261001'): AttendanceStatus.absent,
      sid('20261001', type: 'practical'): AttendanceStatus.absent,
      sid('20261008', type: 'practical'): AttendanceStatus.absent,
    };
    expect(AbsenceSummary.of(bySession: marks, leaves: const [], units: 2, year: year).absences, 3);
    expect(AbsenceSummary.of(bySession: marks, leaves: const [], units: 2, year: year, type: 'practical').absences, 2);
  });

  test('stats documents parse bySession', () {
    final stat = StudentCourseStat.fromMap('CS1_1-morning__1', {
      'courseId': 'CS1_1-morning',
      'studentId': '1',
      'stageId': '1-morning',
      'bySession': {sid('20261001'): 'absent', sid('20261002'): 'excused'},
    });
    expect(stat.bySession.values, [AttendanceStatus.absent, AttendanceStatus.excused]);
  });
}
