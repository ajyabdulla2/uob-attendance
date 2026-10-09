import 'dart:math' as math;

import '../../../core/firebase/doc_ids.dart';
import '../../assignments/domain/assignment.dart';
import 'attendance_session.dart';

/// A lecture recorded after its day by a stage manager or an admin, for a
/// class that may not be theirs: «تسجيل محاضرة فائتة» on the stage dashboard.
abstract final class MissedLecture {
  /// How far back a missed lecture may be recorded.
  static const maxDaysBack = 365;

  /// One entry per class of a stage (course + type + target): several
  /// teachers may share a class. Sorted by course name, theory first, then
  /// section or group.
  static List<Assignment> classes(Iterable<Assignment> assignments) {
    final byKey = <String, Assignment>{};
    for (final a in assignments) {
      byKey.putIfAbsent('${a.courseId}|${a.type.name}|${a.target}', () => a);
    }
    String name(Assignment a) => a.courseName.isEmpty ? a.courseId : a.courseName;
    return byKey.values.toList()
      ..sort((x, y) {
        final byName = name(x).compareTo(name(y));
        if (byName != 0) return byName;
        if (x.type != y.type) return x.type.index.compareTo(y.type.index);
        return x.target.compareTo(y.target);
      });
  }

  /// The next free lecture number of [cls] on [date], given the stage's
  /// lectures on that day (1 when none was recorded).
  static int nextLectureNo(Assignment cls, Iterable<AttendanceSession> sessions, DateTime date) {
    final key = DocIds.dateKey(date);
    return sessions
            .where((s) =>
                s.dateKey == key && s.courseId == cls.courseId && s.type == cls.type && s.target == cls.target)
            .map((s) => s.lectureNo)
            .fold(0, math.max) +
        1;
  }

  /// Count of each status in [marks] (every status present, zero if unused).
  static Map<AttendanceStatus, int> counts(Map<String, AttendanceStatus> marks) => {
        for (final s in AttendanceStatus.values) s: marks.values.where((v) => v == s).length,
      };

  /// The status after [s] when a name is tapped: present → absent → late →
  /// excused → present.
  static AttendanceStatus next(AttendanceStatus s) =>
      AttendanceStatus.values[(s.index + 1) % AttendanceStatus.values.length];
}
