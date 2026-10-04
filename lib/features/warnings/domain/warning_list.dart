import '../../../core/config/app_config.dart';
import '../../../core/firebase/firestore_converters.dart';
import '../../stats/domain/student_course_stat.dart';

/// قرار القسم (أولي، قابل للتعديل) / قرار العمادة (نهائي ومقفل).
enum DecisionType { department, deanery }

final class WarningListEntry {
  const WarningListEntry({
    required this.studentId,
    required this.studentName,
    required this.courseId,
    required this.percent,
  });

  final String studentId;
  final String studentName;
  final String courseId;
  final double percent;

  factory WarningListEntry.fromMap(Map<String, Object?> map) => WarningListEntry(
        studentId: Fs.str(map['studentId']),
        studentName: Fs.str(map['studentName']),
        courseId: Fs.str(map['courseId']),
        percent: Fs.dbl(map['percent']),
      );

  Map<String, Object?> toMap() => {
        'studentId': studentId,
        'studentName': studentName,
        'courseId': courseId,
        'percent': percent,
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
