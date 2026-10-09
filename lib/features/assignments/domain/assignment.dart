import '../../../core/config/app_config.dart';
import '../../../core/firebase/doc_ids.dart';
import '../../../core/firebase/firestore_converters.dart';

/// نظري / عملي.
enum AssignmentType { theory, practical }

/// `assignments/{courseId}__{type}__{target}__{teacherEmail}` — links a teacher
/// to a course's theory lectures (whole stage or one section) or to one
/// practical group. A course may be taught by several teachers.
final class Assignment {
  const Assignment._({
    required this.teacherId,
    required this.courseId,
    required this.stageId,
    required this.type,
    required this.target,
    this.groupId,
    this.teacherName = '',
    this.courseName = '',
    this.departmentId = AppConfig.departmentId,
  });

  /// Theory lectures of [section] (null/empty = all sections of the stage).
  factory Assignment.theory({
    required String teacherId,
    required String courseId,
    required String stageId,
    String? section,
    String teacherName = '',
    String courseName = '',
  }) =>
      Assignment._(
        teacherId: DocIds.user(teacherId),
        courseId: courseId,
        stageId: stageId,
        type: AssignmentType.theory,
        target: (section == null || section.trim().isEmpty) ? DocIds.allSections : section.trim(),
        teacherName: teacherName,
        courseName: courseName,
      );

  /// One practical group ([groupName] is e.g. "A").
  factory Assignment.practical({
    required String teacherId,
    required String courseId,
    required String stageId,
    required String groupName,
    String teacherName = '',
    String courseName = '',
  }) =>
      Assignment._(
        teacherId: DocIds.user(teacherId),
        courseId: courseId,
        stageId: stageId,
        type: AssignmentType.practical,
        target: groupName.trim(),
        groupId: DocIds.group(courseId, groupName),
        teacherName: teacherName,
        courseName: courseName,
      );

  /// Teacher e-mail (users doc ID).
  final String teacherId;
  final String courseId;
  final String stageId;
  final AssignmentType type;

  /// Practical: group name. Theory: section, or [DocIds.allSections].
  final String target;
  final String? groupId;

  /// Denormalized for cheap list display.
  final String teacherName;
  final String courseName;
  final String departmentId;

  String get id => DocIds.assignment(
        courseId: courseId,
        type: type.name,
        target: target,
        teacherId: teacherId,
      );

  bool get coversAllSections => type == AssignmentType.theory && target == DocIds.allSections;

  factory Assignment.fromMap(String id, Map<String, Object?> map) => Assignment._(
        teacherId: Fs.str(map['teacherId']),
        courseId: Fs.str(map['courseId']),
        stageId: Fs.str(map['stageId']),
        type: Fs.enumByName(AssignmentType.values, map['type'], AssignmentType.theory),
        target: Fs.str(map['target'], DocIds.allSections),
        groupId: Fs.strOrNull(map['groupId']),
        teacherName: Fs.str(map['teacherName']),
        courseName: Fs.str(map['courseName']),
        departmentId: Fs.str(map['departmentId'], AppConfig.departmentId),
      );

  Map<String, Object?> toMap() => {
        'teacherId': teacherId,
        'courseId': courseId,
        'stageId': stageId,
        'type': type.name,
        'target': target,
        'groupId': groupId,
        'teacherName': teacherName,
        'courseName': courseName,
        'departmentId': departmentId,
      };
}
