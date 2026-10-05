import '../../../core/config/app_config.dart';
import '../../../core/firebase/firestore_converters.dart';
import '../../stats/domain/student_course_stat.dart';

/// قرار القسم (أولي، قابل للتعديل) / قرار العمادة (نهائي ومقفل).
enum DecisionType { department, deanery }

/// A student in a decision, as it stood when the list was saved (names and
/// numbers are copied so the decision reads the same years later).
final class WarningListEntry {
  const WarningListEntry({
    required this.studentId,
    required this.studentName,
    required this.courseId,
    required this.percent,
    this.courseName = '',
    this.type,
    this.absences = 0,
    this.planned = 0,
    this.section = '',
  });

  final String studentId;
  final String studentName;
  final String courseId;
  final double percent;
  final String courseName;

  /// `theory` / `practical` when the year keeps separate percentages.
  final String? type;
  final int absences;
  final int planned;
  final String section;

  factory WarningListEntry.fromMap(Map<String, Object?> map) => WarningListEntry(
        studentId: Fs.str(map['studentId']),
        studentName: Fs.str(map['studentName']),
        courseId: Fs.str(map['courseId']),
        percent: Fs.dbl(map['percent']),
        courseName: Fs.str(map['courseName']),
        type: Fs.strOrNull(map['type']),
        absences: Fs.integer(map['absences']),
        planned: Fs.integer(map['planned']),
        section: Fs.str(map['section']),
      );

  Map<String, Object?> toMap() => {
        'studentId': studentId,
        'studentName': studentName,
        'courseId': courseId,
        'percent': percent,
        'courseName': courseName,
        'type': type,
        'absences': absences,
        'planned': planned,
        'section': section,
      };
}

/// `warningLists/{id}`.
final class WarningList {
  const WarningList({
    required this.id,
    required this.stageId,
    required this.level,
    required this.decision,
    this.courseId,
    this.orderNumber,
    this.orderDate,
    this.entries = const [],
    this.createdBy = '',
    this.createdAt,
    this.departmentId = AppConfig.departmentId,
  });

  final String id;
  final String stageId;
  final String? courseId;
  final WarningLevel level;
  final DecisionType decision;

  /// رقم الأمر الإداري وتاريخه — required for a deanery decision.
  final String? orderNumber;
  final DateTime? orderDate;
  final List<WarningListEntry> entries;
  final String createdBy;
  final DateTime? createdAt;
  final String departmentId;

  /// Deanery decisions are frozen; any change needs a new decision.
  bool get isFinal => decision == DecisionType.deanery;

  factory WarningList.fromMap(String id, Map<String, Object?> map) => WarningList(
        id: id,
        stageId: Fs.str(map['stageId']),
        courseId: Fs.strOrNull(map['courseId']),
        level: Fs.enumByName(WarningLevel.values, map['level'], WarningLevel.warning),
        decision: Fs.enumByName(DecisionType.values, map['decision'], DecisionType.department),
        orderNumber: Fs.strOrNull(map['orderNumber']),
        orderDate: Fs.date(map['orderDate']),
        entries: [
          for (final e in (map['entries'] is List ? map['entries'] as List : const []))
            if (e is Map) WarningListEntry.fromMap(Fs.map(e)),
        ],
        createdBy: Fs.str(map['createdBy']),
        createdAt: Fs.date(map['createdAt']),
        departmentId: Fs.str(map['departmentId'], AppConfig.departmentId),
      );

  Map<String, Object?> toMap() => {
        'stageId': stageId,
        'courseId': courseId,
        'level': level.name,
        'decision': decision.name,
        'orderNumber': orderNumber,
        'orderDate': Fs.timestamp(orderDate),
        'entries': [for (final e in entries) e.toMap()],
        'createdBy': createdBy,
        'departmentId': departmentId,
      };
}
