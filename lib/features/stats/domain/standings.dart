import '../../academic/domain/academic_year.dart';
import '../../courses/domain/course.dart';
import '../../leaves/domain/leave.dart';
import '../../students/domain/student.dart';
import 'absence_summary.dart';
import 'student_course_stat.dart';

/// One student in one course (or one course part when theory and practical
/// have separate percentages).
final class Standing {
  const Standing({required this.student, required this.course, required this.summary, this.type});

  final Student student;
  final Course course;

  /// `theory` / `practical` when the year keeps two percentages, else null.
  final String? type;
  final AbsenceSummary summary;

  WarningLevel get level => summary.level;
}

/// Builds the stage's standings from its `stats` documents: only students
/// who attend lectures and courses of the stage; highest percentage first.
List<Standing> buildStandings({
  required Iterable<Student> students,
  required Iterable<Course> courses,
  required Iterable<StudentCourseStat> stats,
  required Iterable<Leave> leaves,
  required AcademicYear year,
}) {
  final byStudent = {for (final s in students) if (s.attendsLectures) s.id: s};
  final byCourse = {for (final c in courses) c.id: c};
  final leavesOf = <String, List<Leave>>{};
  for (final l in leaves) {
    (leavesOf[l.studentId] ??= []).add(l);
  }
  final out = <Standing>[];
  for (final stat in stats) {
    final student = byStudent[stat.studentId];
    final course = byCourse[stat.courseId];
    if (student == null || course == null) continue;
    for (final type in year.combinedTheoryPractical ? const [null] : const ['theory', 'practical']) {
      if (type == 'practical' && !course.hasPractical) continue;
      out.add(Standing(
        student: student,
        course: course,
        type: type,
        summary: AbsenceSummary.of(
          bySession: stat.bySession,
          leaves: leavesOf[student.id] ?? const [],
          units: course.units,
          year: year,
          type: type,
        ),
      ));
    }
  }
  out.sort((a, b) {
    final byPercent = b.summary.percent.compareTo(a.summary.percent);
    return byPercent != 0 ? byPercent : Student.compare(a.student, b.student);
  });
  return out;
}
