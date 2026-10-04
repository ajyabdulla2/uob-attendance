import '../../../core/config/app_config.dart';
import '../../../core/firebase/doc_ids.dart';
import '../../../core/firebase/firestore_converters.dart';

/// `groups/{courseId}__{name}` — a practical (lab) group of a course.
/// A student belongs to exactly one group per course.
final class PracticalGroup {
  const PracticalGroup({
    required this.courseId,
    required this.stageId,
    required this.name,
    this.studentIds = const [],
    this.departmentId = AppConfig.departmentId,
  });

  final String courseId;
  final String stageId;

  /// A, B, C…
  final String name;
  final List<String> studentIds;
  final String departmentId;

  String get id => DocIds.group(courseId, name);

  factory PracticalGroup.fromMap(String id, Map<String, Object?> map) => PracticalGroup(
        courseId: Fs.str(map['courseId']),
        stageId: Fs.str(map['stageId']),
        name: Fs.str(map['name']),
        studentIds: Fs.strings(map['studentIds']),
        departmentId: Fs.str(map['departmentId'], AppConfig.departmentId),
      );

  Map<String, Object?> toMap() => {
        'courseId': courseId,
        'stageId': stageId,
        'name': name,
        'studentIds': studentIds,
        'departmentId': departmentId,
      };

  PracticalGroup copyWith({List<String>? studentIds}) => PracticalGroup(
        courseId: courseId,
        stageId: stageId,
        name: name,
        studentIds: studentIds ?? this.studentIds,
        departmentId: departmentId,
      );

  /// Latin letters for group names: A, B, …, Z, AA, AB, …
  static String nameFor(int index) {
    var i = index;
    var name = '';
    do {
      name = String.fromCharCode(0x41 + i % 26) + name;
      i = i ~/ 26 - 1;
    } while (i >= 0);
    return name;
  }
}
