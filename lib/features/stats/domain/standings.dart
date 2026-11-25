import '../../academic/domain/academic_year.dart';
import '../../courses/domain/course.dart';
import '../../leaves/domain/leave.dart';
import '../../students/domain/student.dart';
import '../../warnings/domain/external_notice.dart';
import 'absence_summary.dart';
import 'student_course_stat.dart';

/// One student in one course (or one course part when theory and practical
/// have separate percentages).
final class Standing {
  Standing({
    required this.student,
    required this.course,
    required this.summary,
    this.type,
    this.notice,
    WarningLevel? level,
    int? untilNext,
  })  : level = level ?? summary.level,
        untilNext = untilNext ?? summary.untilNext;

  final Student student;
  final Course course;

  /// `theory` / `practical` when the year keeps two percentages, else null.
  final String? type;
  final AbsenceSummary summary;

  /// The level by the percentage, or higher by an external letter
  /// ([notice]).
  final WarningLevel level;

  /// More absences until the next level («على الحافة» at 1).
  final int untilNext;

  /// The letter issued outside the app that sets [level], if any.
  final ExternalNotice? notice;

  WarningLevel? get nextLevel => level == WarningLevel.dismissal ? null : ExternalNotice.next(level);
}

/// Builds the stage's standings from its `stats` documents: only students
/// who attend lectures and courses of the stage; highest percentage first.
List<Standing> buildStandings({
  required Iterable<Student> students,
  required Iterable<Course> courses,
  required Iterable<StudentCourseStat> stats,
  required Iterable<Leave> leaves,
  required AcademicYear year,
  Iterable<ExternalNotice> notices = const [],
}) {
  final byStudent = {for (final s in students) if (s.attendsLectures) s.id: s};
  final byCourse = {for (final c in courses) c.id: c};
  final leavesOf = <String, List<Leave>>{};
  for (final l in leaves) {
    (leavesOf[l.studentId] ??= []).add(l);
  }
  final noticesOf = <String, List<ExternalNotice>>{};
  for (final n in notices) {
    (noticesOf[n.studentId] ??= []).add(n);
  }
  // A letter for a course the student has no absence in yet still counts.
  final pairs = {for (final s in stats) '${s.courseId}__${s.studentId}': s};
  for (final n in notices) {
    for (final c in n.courseIds) {
      pairs.putIfAbsent('${c}__${n.studentId}', () => StudentCourseStat(courseId: c, studentId: n.studentId, stageId: n.stageId));
    }
  }
  final out = <Standing>[];
  for (final stat in pairs.values) {
    final student = byStudent[stat.studentId];
    final course = byCourse[stat.courseId];
    if (student == null || course == null) continue;
    final leaves = leavesOf[student.id] ?? const <Leave>[];
    for (final type in year.combinedTheoryPractical ? const [null] : const ['theory', 'practical']) {
      if (type == 'practical' && !course.hasPractical) continue;
      final summary = AbsenceSummary.of(
        bySession: stat.bySession,
        leaves: leaves,
        units: course.units,
        year: year,
        stageId: course.stageId,
        type: type,
      );
      final byLetter = ExternalNotice.standing(
        noticesOf[student.id] ?? const [],
        courseId: course.id,
        bySession: stat.bySession,
        excusedDays: AbsenceSummary.excusedLeaveDays(leaves, year.maxLeaveDays),
        type: type,
      );
      final raised = byLetter != null && byLetter.level.index > summary.level.index;
      out.add(Standing(
        student: student,
        course: course,
        type: type,
        summary: summary,
        notice: byLetter?.notice,
        level: raised ? byLetter.level : null,
        // Pinned by a letter with no absence since: one more moves them up.
        untilNext: raised ? (byLetter.level == WarningLevel.dismissal ? 0 : 1) : null,
      ));
    }
  }
  out.sort((a, b) {
    final byPercent = b.summary.percent.compareTo(a.summary.percent);
    return byPercent != 0 ? byPercent : Student.compare(a.student, b.student);
  });
  return out;
}
