import '../../../core/config/app_config.dart';
import '../../../core/domain/stage_ref.dart';
import '../../../core/firebase/firestore_converters.dart';
import 'academic_year.dart';

/// `stages/{level-shift}` — sections (شعب) and optional per-stage thresholds.
final class Stage {
  const Stage({
    required this.ref,
    this.sections = const [],
    this.thresholds,
    this.departmentId = AppConfig.departmentId,
  });

  final StageRef ref;

  /// e.g. ["أ", "ب"]; empty when the stage is not divided.
  final List<String> sections;

  /// Overrides the academic-year thresholds when set.
  final AbsenceThresholds? thresholds;
  final String departmentId;

  String get id => ref.id;

  factory Stage.fromMap(String id, Map<String, Object?> map) => Stage(
        ref: StageRef.parse(id),
        sections: Fs.strings(map['sections']),
        thresholds: map['thresholds'] is Map
            ? AbsenceThresholds.fromMap(Fs.map(map['thresholds']))
            : null,
        departmentId: Fs.str(map['departmentId'], AppConfig.departmentId),
      );

  Map<String, Object?> toMap() => {
        'level': ref.level,
        'shift': ref.shift.name,
        'sections': sections,
        'thresholds': thresholds?.toMap(),
        'departmentId': departmentId,
      };
}
