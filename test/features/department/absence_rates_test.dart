import 'package:flutter_test/flutter_test.dart';
import 'package:uob_attendance/core/domain/stage_ref.dart';
import 'package:uob_attendance/features/academic/domain/academic_year.dart';
import 'package:uob_attendance/features/attendance/domain/attendance_session.dart';
import 'package:uob_attendance/features/courses/domain/course.dart';
import 'package:uob_attendance/features/department/domain/absence_rates.dart';
import 'package:uob_attendance/features/stats/domain/standings.dart';
import 'package:uob_attendance/features/stats/domain/student_course_stat.dart';
import 'package:uob_attendance/features/students/domain/student.dart';

void main() {
  const stage = StageRef(1, Shift.morning);
  final a = Course(code: 'A1', name: 'برمجة', stage: stage, semester: 1, units: 1, hasPractical: false);
  final b = Course(code: 'B1', name: 'رياضيات', stage: stage, semester: 1, units: 1, hasPractical: false);
  final students = [for (var i = 1; i <= 4; i++) Student(universityId: '$i', fullName: 'طالب $i', stage: stage)];
  const year = AcademicYear(id: '2026-2027', semester: 1);

  test('means count students without absences as zero; highest course first', () {
    // 15 planned lectures (1 unit × 15 weeks): 3 absences = 20%, 1 = 6.7%.
    String sid(Course c, int d) => '${c.id}__theory__all__202610${d.toString().padLeft(2, '0')}__1';
    final standings = buildStandings(
      students: students,
      courses: [a, b],
      stats: [
        StudentCourseStat(courseId: a.id, studentId: '1', stageId: stage.id,
            bySession: {for (var d = 1; d <= 3; d++) sid(a, d): AttendanceStatus.absent}),
        StudentCourseStat(courseId: b.id, studentId: '2', stageId: stage.id,
            bySession: {sid(b, 1): AttendanceStatus.absent}),
      ],
      leaves: const [],
      year: year,
    );
    final rates = AbsenceRates.byCourse(standings: standings, students: students, courses: [a, b], combined: true);
    expect(rates.map((r) => r.label), ['برمجة', 'رياضيات']);
    expect(rates.first.mean, closeTo(20 / 4, 0.01));
    expect(rates.first.atAlert, 1, reason: '20% is dismissal');
    expect(rates.last.mean, closeTo(6.667 / 4, 0.01));
    final s = AbsenceRates.stage('المرحلة', rates, standings, 4);
    expect(s.mean, closeTo((5 + 1.667) / 2, 0.01));
    expect(s.atAlert, 2);
  });
}
