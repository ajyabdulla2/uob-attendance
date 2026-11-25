import 'package:flutter_test/flutter_test.dart';
import 'package:uob_attendance/core/domain/stage_ref.dart';
import 'package:uob_attendance/features/academic/domain/academic_year.dart';
import 'package:uob_attendance/features/attendance/domain/attendance_session.dart';
import 'package:uob_attendance/features/courses/domain/course.dart';
import 'package:uob_attendance/features/leaves/domain/leave.dart';
import 'package:uob_attendance/features/stats/domain/standings.dart';
import 'package:uob_attendance/features/stats/domain/student_course_stat.dart';
import 'package:uob_attendance/features/students/domain/student.dart';
import 'package:uob_attendance/features/warnings/domain/external_notice.dart';

void main() {
  const stage = StageRef(2, Shift.morning);
  // 3 units × 1 × 15 weeks = 45 lectures: one absence is 2.2% (no level).
  const year = AcademicYear(id: '2026-2027', semester: 1, active: true);
  final db = Course(code: 'CS201', name: 'قواعد البيانات', stage: stage, semester: 1, units: 3, hasPractical: false);
  final os = Course(code: 'CS202', name: 'نظم التشغيل', stage: stage, semester: 1, units: 3, hasPractical: false);
  final ahmed = Student(universityId: '1', fullName: 'أحمد علي حسين جاسم', stage: stage);
  String sid(Course c, int day) => '${c.id}__theory__all__202611${day.toString().padLeft(2, '0')}__1';
  final letter = ExternalNotice(
    id: 'n1',
    studentId: ahmed.id,
    stageId: stage.id,
    courseIds: [db.id],
    level: WarningLevel.alert,
    date: DateTime.utc(2026, 11, 10),
  );

  List<Standing> build(Map<String, AttendanceStatus> bySession, {List<Leave> leaves = const []}) => buildStandings(
        students: [ahmed],
        courses: [db, os],
        stats: [
          if (bySession.isNotEmpty) StudentCourseStat(courseId: db.id, studentId: ahmed.id, stageId: stage.id, bySession: bySession),
        ],
        leaves: leaves,
        year: year,
        notices: [letter],
      );

  test('a letter issued outside the app pins the level, even with no absence in the app', () {
    final s = build(const <String, AttendanceStatus>{}).single;
    expect(s.course.id, db.id, reason: 'only the courses the letter covers');
    expect(s.level, WarningLevel.alert);
    expect(s.notice?.id, 'n1');
    expect(s.untilNext, 1, reason: 'one more absence → إنذار');
  });

  test('an absence after the letter moves the student to the next level; one before it does not', () {
    expect(build({sid(db, 3): AttendanceStatus.absent}).single.level, WarningLevel.alert);
    final after = build({sid(db, 3): AttendanceStatus.absent, sid(db, 12): AttendanceStatus.absent}).single;
    expect(after.level, WarningLevel.warning);
    expect(after.summary.level, WarningLevel.none, reason: 'the percentage alone gives nothing');
    expect(build({sid(db, 12): AttendanceStatus.late}).single.level, WarningLevel.alert, reason: 'late is no absence');
  });

  test('an absence after the letter on a day an approved leave covers does not count', () {
    final s = build(
      {sid(db, 12): AttendanceStatus.absent},
      leaves: [
        Leave(
          id: 'l',
          studentId: ahmed.id,
          stageId: stage.id,
          type: LeaveType.sick,
          from: DateTime.utc(2026, 11, 12),
          to: DateTime.utc(2026, 11, 12),
          approvedBy: 'sm@uob.iq',
        ),
      ],
    ).single;
    expect(s.level, WarningLevel.alert);
  });

  test('the higher of the letter and the percentage wins', () {
    final many = {for (var d = 1; d <= 9; d++) sid(db, d): AttendanceStatus.absent}; // 20% → فصل
    final s = build(many).single;
    expect(s.level, WarningLevel.dismissal);
    expect(s.untilNext, s.summary.untilNext);
  });
}
