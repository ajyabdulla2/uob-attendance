import '../../../core/firebase/doc_ids.dart';
import '../../academic/domain/academic_year.dart';
import '../../attendance/domain/attendance_session.dart';
import '../../leaves/domain/leave.dart';
import 'student_course_stat.dart';

/// One student's standing in one course (SPEC «قواعد التنبيه والإنذار والفصل»),
/// computed on read from the per-lecture statuses (`stats.bySession`, or the
/// phone's own records), the student's approved leaves and the year's policy.
final class AbsenceSummary {
  const AbsenceSummary({
    required this.absences,
    required this.excused,
    required this.byLeave,
    required this.lates,
    required this.planned,
    required this.percent,
    required this.level,
    required this.untilNext,
  });

  /// Absences that count towards the percentage.
  final int absences;

  /// Excused lectures that do not count (marked «مُجاز» or covered by a leave).
  final int excused;

  /// Of the absences marked «غائب», how many an approved leave excused.
  final int byLeave;
  final int lates;

  /// Lectures planned for the course this semester (from its units).
  final int planned;
  final double percent;
  final WarningLevel level;

  /// More absences until the next level (0 at «فصل»): drives
  /// «سيصل للإنذار بعد غياب واحد».
  final int untilNext;

  WarningLevel? get nextLevel => _after(level);

  static WarningLevel? _after(WarningLevel level) => switch (level) {
        WarningLevel.none => WarningLevel.alert,
        WarningLevel.alert => WarningLevel.warning,
        WarningLevel.warning => WarningLevel.dismissal,
        WarningLevel.dismissal => null,
      };

  static AbsenceSummary of({
    required Map<String, AttendanceStatus> bySession,
    required Iterable<Leave> leaves,
    required int units,
    required AcademicYear year,
    String? type,
  }) {
    final leaveDays = excusedLeaveDays(leaves, year.maxLeaveDays);
    var absent = 0, excused = 0, byLeave = 0, lates = 0;
    for (final MapEntry(key: sid, value: status) in bySession.entries) {
      final parts = sid.split('__');
      if (type != null && (parts.length < 2 || parts[1] != type)) continue;
      switch (status) {
        case AttendanceStatus.present:
          break;
        case AttendanceStatus.late:
          lates++;
        case AttendanceStatus.excused:
          excused++;
        case AttendanceStatus.absent:
          if (parts.length == 5 && leaveDays.contains(parts[3])) {
            excused++;
            byLeave++;
          } else {
            absent++;
          }
      }
    }
    final counted = absent + (year.leavesCountAgainst ? excused : 0);
    final planned = AbsenceMath.plannedLectures(
      units: units,
      weeks: year.weeksPerSemester,
      lecturesPerUnitPerWeek: year.lecturesPerUnitPerWeek,
    );
    final percent = AbsenceMath.percent(counted, planned);
    final level = AbsenceMath.levelFor(percent, year.thresholds);
    final next = _after(level);
    return AbsenceSummary(
      absences: counted,
      excused: year.leavesCountAgainst ? 0 : excused,
      byLeave: byLeave,
      lates: lates,
      planned: planned,
      percent: percent,
      level: level,
      untilNext: next == null
          ? 0
          : AbsenceMath.absencesUntil(next,
              unexcusedAbsences: counted, plannedLectures: planned, thresholds: year.thresholds),
    );
  }

  /// `yyyyMMdd` days excused by approved leaves, earliest first, up to the
  /// year's cap on accepted leave days (null = no cap).
  static Set<String> excusedLeaveDays(Iterable<Leave> leaves, int? maxDays) {
    final days = <DateTime>{};
    for (final l in leaves) {
      if (!l.isApproved) continue;
      for (var d = DateTime.utc(l.from.year, l.from.month, l.from.day);
          !d.isAfter(DateTime.utc(l.to.year, l.to.month, l.to.day));
          d = d.add(const Duration(days: 1))) {
        days.add(d);
      }
    }
    final sorted = days.toList()..sort();
    final kept = maxDays == null ? sorted : sorted.take(maxDays);
    return {for (final d in kept) DocIds.dateKey(d)};
  }
}
