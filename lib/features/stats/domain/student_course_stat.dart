import '../../../core/config/app_config.dart';
import '../../../core/firebase/doc_ids.dart';
import '../../../core/firebase/firestore_converters.dart';
import '../../academic/domain/academic_year.dart';
import '../../attendance/domain/attendance_session.dart';

/// None, تنبيه، إنذار، فصل.
enum WarningLevel { none, alert, warning, dismissal }

/// Absence percentage maths (SPEC «قواعد التنبيه والإنذار والفصل»):
///
///   percent = unexcused absences ÷ planned lectures × 100
///   planned lectures = units × lecturesPerUnitPerWeek × weeks
abstract final class AbsenceMath {
  static int plannedLectures({
    required int units,
    required int weeks,
    double lecturesPerUnitPerWeek = 1,
  }) =>
      (units * lecturesPerUnitPerWeek * weeks).round();

  static double percent(int unexcusedAbsences, int plannedLectures) =>
      plannedLectures <= 0 ? 0 : unexcusedAbsences * 100 / plannedLectures;

  static WarningLevel levelFor(double percent, AbsenceThresholds t) {
    if (percent >= t.dismissal) return WarningLevel.dismissal;
    if (percent >= t.warning) return WarningLevel.warning;
    if (percent >= t.alert) return WarningLevel.alert;
    return WarningLevel.none;
  }

  /// How many more absences reach [target] (0 if already there).
  /// Drives the «سيصل للإنذار بعد غياب واحد» indicator.
  static int absencesUntil(
    WarningLevel target, {
    required int unexcusedAbsences,
    required int plannedLectures,
    required AbsenceThresholds thresholds,
  }) {
    final threshold = switch (target) {
      WarningLevel.none => 0.0,
      WarningLevel.alert => thresholds.alert,
      WarningLevel.warning => thresholds.warning,
      WarningLevel.dismissal => thresholds.dismissal,
    };
    if (plannedLectures <= 0) return 0;
    final needed = (threshold * plannedLectures / 100 - 1e-9).ceil();
    return needed <= unexcusedAbsences ? 0 : needed - unexcusedAbsences;
  }
}

/// `stats/{courseId}__{studentId}` — see `AbsenceSummary` for the maths;
/// counters updated in the same batch as
/// attendance records, so the warnings screen reads one doc per student
/// and course instead of every record.
final class StudentCourseStat {
  const StudentCourseStat({
    required this.courseId,
    required this.studentId,
    required this.stageId,
    this.absences = 0,
    this.excused = 0,
    this.lates = 0,
    this.percent = 0,
    this.level = WarningLevel.none,
    this.lastSessionId,
    this.bySession = const {},
    this.departmentId = AppConfig.departmentId,
  });

  final String courseId;
  final String studentId;
  final String stageId;

  /// Unexcused absences.
  final int absences;
  final int excused;
  final int lates;
  final double percent;
  final WarningLevel level;

  /// Session whose save last touched the counters (rules use it to authorize
  /// teacher writes).
  final String? lastSessionId;

  /// Status per lecture (`sessionId → status`) — the source of truth; the
  /// counters above are not maintained (see [AbsenceSummary]).
  final Map<String, AttendanceStatus> bySession;
  final String departmentId;

  String get id => DocIds.stat(courseId, studentId);

  factory StudentCourseStat.fromMap(String id, Map<String, Object?> map) => StudentCourseStat(
        courseId: Fs.str(map['courseId']),
        studentId: Fs.str(map['studentId']),
        stageId: Fs.str(map['stageId']),
        absences: Fs.integer(map['absences']),
        excused: Fs.integer(map['excused']),
        lates: Fs.integer(map['lates']),
        percent: Fs.dbl(map['percent']),
        level: Fs.enumByName(WarningLevel.values, map['level'], WarningLevel.none),
        lastSessionId: Fs.strOrNull(map['lastSessionId']),
        // An excluded lecture counts for nobody: it is left out entirely.
        bySession: {
          for (final MapEntry(:key, :value) in Fs.map(map['bySession']).entries)
            if (value != AttendanceSession.excludedValue)
              key: Fs.enumByName(AttendanceStatus.values, value, AttendanceStatus.present),
        },
        departmentId: Fs.str(map['departmentId'], AppConfig.departmentId),
      );

  Map<String, Object?> toMap() => {
        'courseId': courseId,
        'studentId': studentId,
        'stageId': stageId,
        'absences': absences,
        'excused': excused,
        'lates': lates,
        'percent': percent,
        'level': level.name,
        'lastSessionId': lastSessionId,
        'departmentId': departmentId,
      };
}
