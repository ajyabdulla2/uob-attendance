import '../../../core/config/app_config.dart';
import '../../../core/firebase/firestore_converters.dart';

/// Alert / warning / dismissal percentages (SPEC «قواعد التنبيه والإنذار والفصل»).
/// The defaults are the SPEC's *examples*; the department sets the real ones.
final class AbsenceThresholds {
  const AbsenceThresholds({this.alert = 5, this.warning = 10, this.dismissal = 15});

  final double alert;
  final double warning;
  final double dismissal;

  /// Thresholds must be positive and strictly increasing.
  bool get isValid => alert > 0 && alert < warning && warning < dismissal && dismissal <= 100;

  factory AbsenceThresholds.fromMap(Map<String, Object?> map) {
    const d = AbsenceThresholds();
    return AbsenceThresholds(
      alert: Fs.dbl(map['alert'], d.alert),
      warning: Fs.dbl(map['warning'], d.warning),
      dismissal: Fs.dbl(map['dismissal'], d.dismissal),
    );
  }

  Map<String, Object?> toMap() => {'alert': alert, 'warning': warning, 'dismissal': dismissal};
}

/// `academicYears/{id}` — one active year; previous years are archived read-only.
final class AcademicYear {
  const AcademicYear({
    required this.id,
    required this.semester,
    this.active = false,
    this.archived = false,
    this.thresholds = const AbsenceThresholds(),
    this.weeksPerSemester = 15,
    this.lecturesPerUnitPerWeek = 1,
    this.lockHours = 48,
    this.leavesCountAgainst = false,
    this.maxLeaveDays,
    this.combinedTheoryPractical = true,
    this.departmentId = AppConfig.departmentId,
  });

  /// e.g. `2026-2027`.
  final String id;

  /// 1 or 2.
  final int semester;
  final bool active;
  final bool archived;
  final AbsenceThresholds thresholds;
  final int weeksPerSemester;

  /// How many lectures one credit unit means per week (department decision).
  final double lecturesPerUnitPerWeek;

  /// Hours after the lecture day ends before a session locks.
  final int lockHours;

  /// Whether approved leaves count towards the absence percentage.
  final bool leavesCountAgainst;

  /// Upper bound on accepted leave days (null = no limit).
  final int? maxLeaveDays;

  /// One combined percentage for theory + practical, or two separate ones.
  final bool combinedTheoryPractical;
  final String departmentId;

  /// Within what the security rules accept (they use [lockHours] to compute
  /// every session's lock time).
  bool get isValid =>
      thresholds.isValid &&
      (semester == 1 || semester == 2) &&
      weeksPerSemester >= 1 &&
      weeksPerSemester <= 30 &&
      lecturesPerUnitPerWeek > 0 &&
      lecturesPerUnitPerWeek <= 10 &&
      lockHours >= 1 &&
      lockHours <= 720 &&
      (maxLeaveDays == null || maxLeaveDays! >= 0);

  AcademicYear copyWith({
    int? semester,
    AbsenceThresholds? thresholds,
    int? weeksPerSemester,
    double? lecturesPerUnitPerWeek,
    int? lockHours,
    bool? leavesCountAgainst,
    int? Function()? maxLeaveDays,
    bool? combinedTheoryPractical,
  }) =>
      AcademicYear(
        id: id,
        semester: semester ?? this.semester,
        active: active,
        archived: archived,
        thresholds: thresholds ?? this.thresholds,
        weeksPerSemester: weeksPerSemester ?? this.weeksPerSemester,
        lecturesPerUnitPerWeek: lecturesPerUnitPerWeek ?? this.lecturesPerUnitPerWeek,
        lockHours: lockHours ?? this.lockHours,
        leavesCountAgainst: leavesCountAgainst ?? this.leavesCountAgainst,
        maxLeaveDays: maxLeaveDays == null ? this.maxLeaveDays : maxLeaveDays(),
        combinedTheoryPractical: combinedTheoryPractical ?? this.combinedTheoryPractical,
        departmentId: departmentId,
      );

  /// Builds a default year ID for [now] (Iraqi academic years start in autumn).
  static String idFor(DateTime now) {
    final start = now.month >= 9 ? now.year : now.year - 1;
    return '$start-${start + 1}';
  }

  factory AcademicYear.fromMap(String id, Map<String, Object?> map) => AcademicYear(
        id: id,
        semester: Fs.integer(map['semester'], 1),
        active: Fs.boolean(map['active']),
        archived: Fs.boolean(map['archived']),
        thresholds: AbsenceThresholds.fromMap(Fs.map(map['thresholds'])),
        weeksPerSemester: Fs.integer(map['weeksPerSemester'], 15),
        lecturesPerUnitPerWeek: Fs.dbl(map['lecturesPerUnitPerWeek'], 1),
        lockHours: Fs.integer(map['lockHours'], 48),
        leavesCountAgainst: Fs.boolean(map['leavesCountAgainst']),
        maxLeaveDays: map['maxLeaveDays'] is int ? map['maxLeaveDays'] as int : null,
        combinedTheoryPractical: Fs.boolean(map['combinedTheoryPractical'], true),
        departmentId: Fs.str(map['departmentId'], AppConfig.departmentId),
      );

  Map<String, Object?> toMap() => {
        'label': id,
        'semester': semester,
        'active': active,
        'archived': archived,
        'thresholds': thresholds.toMap(),
        'weeksPerSemester': weeksPerSemester,
        'lecturesPerUnitPerWeek': lecturesPerUnitPerWeek,
        'lockHours': lockHours,
        'leavesCountAgainst': leavesCountAgainst,
        'maxLeaveDays': maxLeaveDays,
        'combinedTheoryPractical': combinedTheoryPractical,
        'departmentId': departmentId,
      };
}
