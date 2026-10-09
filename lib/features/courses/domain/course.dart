import '../../../core/config/app_config.dart';
import '../../../core/domain/stage_ref.dart';
import '../../../core/firebase/doc_ids.dart';
import '../../../core/firebase/firestore_converters.dart';
import '../../../core/utils/arabic_text.dart';

/// `courses/{code}_{stageId}` — a course offered to one stage (level + shift).
/// A course taught in both morning and evening study is two documents.
final class Course {
  Course({
    required String code,
    required String name,
    required this.stage,
    required this.semester,
    required this.units,
    required this.hasPractical,
    this.departmentId = AppConfig.departmentId,
  })  : code = DocIds.normalizeCourseCode(code),
        name = ArabicText.collapseSpaces(name);

  final String code;
  final String name;
  final StageRef stage;

  /// 1 or 2.
  final int semester;

  /// الوحدات — weight of one absence in the percentage.
  final int units;
  final bool hasPractical;
  final String departmentId;

  String get id => DocIds.course(code, stage.id);
  String get stageId => stage.id;

  factory Course.fromMap(String id, Map<String, Object?> map) => Course(
        code: Fs.str(map['code']),
        name: Fs.str(map['name']),
        stage: StageRef.tryParse(Fs.str(map['stageId'])) ?? const StageRef(1, Shift.morning),
        semester: Fs.integer(map['semester'], 1),
        units: Fs.integer(map['units'], 1),
        hasPractical: Fs.boolean(map['hasPractical']),
        departmentId: Fs.str(map['departmentId'], AppConfig.departmentId),
      );

  Map<String, Object?> toMap() => {
        'code': code,
        'name': name,
        'stageId': stageId,
        'level': stage.level,
        'shift': stage.shift.name,
        'semester': semester,
        'units': units,
        'hasPractical': hasPractical,
        'departmentId': departmentId,
      };
}
