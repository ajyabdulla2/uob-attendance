import 'package:flutter_test/flutter_test.dart';
import 'package:uob_attendance/core/domain/stage_ref.dart';
import 'package:uob_attendance/features/academic/domain/academic_year.dart';
import 'package:uob_attendance/features/assignments/domain/assignment.dart';
import 'package:uob_attendance/features/attendance/domain/attendance_session.dart';
import 'package:uob_attendance/features/courses/domain/course.dart';
import 'package:uob_attendance/features/courses/domain/practical_group.dart';
import 'package:uob_attendance/features/leaves/domain/leave.dart';
import 'package:uob_attendance/features/stats/domain/period_standings.dart';
import 'package:uob_attendance/features/stats/domain/student_course_stat.dart';
import 'package:uob_attendance/features/students/domain/student.dart';

void main() {
  const stage = StageRef(2, Shift.morning);
  final course = Course(code: 'CS201', name: 'قواعد البيانات', stage: stage, semester: 1, units: 2, hasPractical: true);
  final ali = Student(universityId: '1', fullName: 'علي حسن كاظم جاسم', stage: stage);
  final zahra = Student(universityId: '2', fullName: 'زهراء صالح مهدي حسن', stage: stage);
  final sami = Student(universityId: '3', fullName: 'سامي كريم عبد علي', stage: stage);

  AttendanceSession lecture(AssignmentType type, String target, int day, {bool excluded = false}) => AttendanceSession(
        courseId: course.id,
        stageId: stage.id,
        yearId: '2026-2027',
        type: type,
        target: target,
        date: DateTime.utc(2026, 10, day),
        lectureNo: 1,
        openedBy: 't@uob.iq',
        lockAt: AttendanceSession.lockAtFor(DateTime.utc(2026, 10, day), 48),
        excluded: excluded,
      );
  // Period 1–30/10: theory on 5, 12, 19 (19 not counted), practical A on
  // 6 and 13, B on 7; theory on 2/11 is after the period.
  final t5 = lecture(AssignmentType.theory, 'all', 5);
  final t12 = lecture(AssignmentType.theory, 'all', 12);
  final t19 = lecture(AssignmentType.theory, 'all', 19, excluded: true);
  final a6 = lecture(AssignmentType.practical, 'A', 6);
  final a13 = lecture(AssignmentType.practical, 'A', 13);
  final b7 = lecture(AssignmentType.practical, 'B', 7);
  final later = AttendanceSession(
    courseId: course.id,
    stageId: stage.id,
    yearId: '2026-2027',
    type: AssignmentType.theory,
    target: 'all',
    date: DateTime.utc(2026, 11, 2),
    lectureNo: 1,
    openedBy: 't@uob.iq',
    lockAt: AttendanceSession.lockAtFor(DateTime.utc(2026, 11, 2), 48),
  );

  StudentCourseStat stat(Student s, Map<AttendanceSession, AttendanceStatus> marks) => StudentCourseStat.fromMap(
        '${course.id}__${s.id}',
        {
          'courseId': course.id,
          'studentId': s.id,
          'stageId': stage.id,
          'bySession': {for (final MapEntry(:key, :value) in marks.entries) key.id: value.name},
        },
      );

  List<PeriodStanding> build({bool combined = true}) => buildPeriodStandings(
        students: [ali, zahra, sami],
        courses: [course],
        stats: [
          // Ali (group A): absent on 5, 13 and the uncounted 19, and after the period.
          stat(ali, {
            t5: AttendanceStatus.absent,
            a13: AttendanceStatus.absent,
            t19: AttendanceStatus.absent,
            later: AttendanceStatus.absent,
          }),
          // Zahra (group B): absent on 12, excused by a leave; late on 7.
          stat(zahra, {t12: AttendanceStatus.absent, b7: AttendanceStatus.late}),
          // Sami: only absent after the period.
          stat(sami, {later: AttendanceStatus.absent}),
        ],
        leaves: [
          Leave(
            id: 'l',
            studentId: zahra.id,
            stageId: stage.id,
            type: LeaveType.sick,
            from: DateTime.utc(2026, 10, 12),
            to: DateTime.utc(2026, 10, 12),
            approvedBy: 'sm@uob.iq',
          ),
        ],
        sessions: [t5, t12, t19, a6, a13, b7, later],
        groups: {
          course.id: [
            PracticalGroup(courseId: course.id, stageId: stage.id, name: 'A', studentIds: [ali.id]),
            PracticalGroup(courseId: course.id, stageId: stage.id, name: 'B', studentIds: [zahra.id, sami.id]),
          ],
        },
        year: AcademicYear(id: '2026-2027', semester: 1, active: true, combinedTheoryPractical: combined),
        from: DateTime.utc(2026, 10, 1),
        to: DateTime.utc(2026, 10, 30),
      );

  test('absences in the period against the lectures of the student\'s own classes', () {
    final rows = build();
    expect(rows, hasLength(1), reason: 'Zahra\'s absence is excused, Sami\'s is after the period');
    final r = rows.single;
    expect(r.student.id, ali.id);
    // Theory 5 and 12 (19 does not count) + group A's 6 and 13 = 4 lectures.
    expect(r.absences, 2);
    expect(r.lectures, 4);
    expect(r.percent, 50);
  });

  test('two percentages when the year keeps theory and practical apart', () {
    final rows = build(combined: false);
    expect([for (final r in rows) (r.type, r.absences, r.lectures)], [
      ('theory', 1, 2),
      ('practical', 1, 2),
    ]);
  });
}
