import '../../courses/domain/course.dart';
import '../../stats/domain/standings.dart';
import '../../stats/domain/student_course_stat.dart';
import '../../students/domain/student.dart';

/// One bar: a course (or a stage) and its students' mean absence percentage.
final class AbsenceRate {
  const AbsenceRate({required this.label, required this.mean, required this.atAlert, required this.students});

  final String label;

  /// Mean of every attending student's percentage — those with no absence
  /// count as 0 (they have no `stats` document).
  final double mean;

  /// Students at alert level or above.
  final int atAlert;
  final int students;
}

abstract final class AbsenceRates {
  /// Per course of a stage, highest first. When theory and practical have
  /// separate percentages, each part is its own bar.
  static List<AbsenceRate> byCourse({
    required Iterable<Standing> standings,
    required Iterable<Student> students,
    required Iterable<Course> courses,
    required bool combined,
    String Function(Course course, String? type)? label,
  }) {
    final attending = students.where((s) => s.attendsLectures).length;
    if (attending == 0) return const [];
    final out = <AbsenceRate>[];
    for (final c in courses) {
      for (final type in combined ? const [null] : const ['theory', 'practical']) {
        if (type == 'practical' && !c.hasPractical) continue;
        final mine = standings.where((s) => s.course.id == c.id && s.type == type);
        final sum = mine.fold<double>(0, (n, s) => n + s.summary.percent);
        out.add(AbsenceRate(
          label: label?.call(c, type) ?? c.name,
          mean: sum / attending,
          atAlert: mine.where((s) => s.level != WarningLevel.none).length,
          students: attending,
        ));
      }
    }
    out.sort((a, b) => b.mean.compareTo(a.mean));
    return out;
  }

  /// A stage: the mean of its course bars; students at alert counted once.
  static AbsenceRate stage(String label, List<AbsenceRate> courses, Iterable<Standing> standings, int students) =>
      AbsenceRate(
        label: label,
        mean: courses.isEmpty ? 0 : courses.fold<double>(0, (n, c) => n + c.mean) / courses.length,
        atAlert: {for (final s in standings) if (s.level != WarningLevel.none) s.student.id}.length,
        students: students,
      );
}
