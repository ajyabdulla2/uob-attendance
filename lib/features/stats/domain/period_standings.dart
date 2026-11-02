import '../../../core/firebase/doc_ids.dart';
import '../../academic/domain/academic_year.dart';
import '../../assignments/domain/assignment.dart';
import '../../attendance/domain/attendance_session.dart';
import '../../courses/domain/course.dart';
import '../../courses/domain/practical_group.dart';
import '../../leaves/domain/leave.dart';
import '../../students/domain/student.dart';
import 'absence_summary.dart';
import 'student_course_stat.dart';

/// One student's absences in one course (or course part) during a chosen
/// period: «غياب فترة». Informative only — the official percentage and the
/// warnings stay those of the whole semester.
final class PeriodStanding {
  const PeriodStanding({
    required this.student,
    required this.course,
    required this.absences,
    required this.lectures,
    this.type,
  });

  final Student student;
  final Course course;

  /// `theory` / `practical` when the year keeps two percentages, else null.
  final String? type;

  /// Counted absences in the period (as the semester percentage counts
  /// them: approved leaves excuse, unless leaves count against).
  final int absences;

  /// Lectures of the student's own classes held in the period (not counting
  /// lectures marked «لا تُحتسب»).
  final int lectures;

  double get percent => lectures == 0 ? 0 : absences * 100 / lectures;
}

/// Students with at least one counted absence between [from] and [to]
/// (whole days), highest percentage first. [sessions] are the stage's
/// lectures of the period; [groups] its practical groups by course.
List<PeriodStanding> buildPeriodStandings({
  required Iterable<Student> students,
  required Iterable<Course> courses,
  required Iterable<StudentCourseStat> stats,
  required Iterable<Leave> leaves,
  required Iterable<AttendanceSession> sessions,
  required Map<String, List<PracticalGroup>> groups,
  required AcademicYear year,
  required DateTime from,
  required DateTime to,
}) {
  final fromKey = DocIds.dateKey(from), toKey = DocIds.dateKey(to);
  bool inPeriod(String dateKey) => dateKey.compareTo(fromKey) >= 0 && dateKey.compareTo(toKey) <= 0;

  final byStudent = {for (final s in students) if (s.attendsLectures) s.id: s};
  final byCourse = {for (final c in courses) c.id: c};
  final leavesOf = <String, List<Leave>>{};
  for (final l in leaves) {
    (leavesOf[l.studentId] ??= []).add(l);
  }
  final sessionsOf = <String, List<AttendanceSession>>{};
  for (final s in sessions) {
    if (!s.excluded && inPeriod(s.dateKey)) (sessionsOf[s.courseId] ??= []).add(s);
  }
  final groupOf = <String, String>{
    for (final MapEntry(key: courseId, value: list) in groups.entries)
      for (final g in list)
        for (final id in g.studentIds) '$courseId/$id': g.name,
  };

  final out = <PeriodStanding>[];
  for (final stat in stats) {
    final student = byStudent[stat.studentId];
    final course = byCourse[stat.courseId];
    if (student == null || course == null) continue;
    final group = groupOf['${course.id}/${student.id}'];
    bool theirs(AttendanceSession s) =>
        stat.bySession.containsKey(s.id) ||
        (s.type == AssignmentType.theory
            ? s.target == DocIds.allSections || s.target == student.section
            : s.target == group);
    final held = [for (final s in sessionsOf[course.id] ?? const <AttendanceSession>[]) if (theirs(s)) s];
    final heldIds = {for (final s in held) s.id};
    final marks = {
      for (final MapEntry(key: sid, value: status) in stat.bySession.entries)
        if (heldIds.contains(sid)) sid: status,
    };
    for (final type in year.combinedTheoryPractical ? const [null] : const ['theory', 'practical']) {
      if (type == 'practical' && !course.hasPractical) continue;
      final summary = AbsenceSummary.of(
        bySession: marks,
        leaves: leavesOf[student.id] ?? const [],
        units: course.units,
        year: year,
        stageId: course.stageId,
        type: type,
      );
      if (summary.absences == 0) continue;
      out.add(PeriodStanding(
        student: student,
        course: course,
        type: type,
        absences: summary.absences,
        lectures: held.where((s) => type == null || s.type.name == type).length,
      ));
    }
  }
  out.sort((a, b) {
    final byPercent = b.percent.compareTo(a.percent);
    return byPercent != 0 ? byPercent : Student.compare(a.student, b.student);
  });
  return out;
}
