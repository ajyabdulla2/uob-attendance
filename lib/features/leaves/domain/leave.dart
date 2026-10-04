import '../../../core/config/app_config.dart';
import '../../../core/firebase/firestore_converters.dart';

/// مرضية، رسمية، ظرف طارئ، مشاركة رسمية (نشاط أو وفد)، أخرى.
enum LeaveType { sick, official, emergency, officialParticipation, other }

/// `leaves/{id}` — no attachments (Cloud Storage is not on the Spark plan);
/// the official letter / medical report number is recorded instead.
final class Leave {
  const Leave({
    required this.id,
    required this.studentId,
    required this.stageId,
    required this.type,
    required this.from,
    required this.to,
    this.referenceNo = '',
    this.note = '',
    this.approvedBy,
    this.approvedAt,
    this.departmentId = AppConfig.departmentId,
  });

  final String id;
  final String studentId;
  final String stageId;
  final LeaveType type;
  final DateTime from;
  final DateTime to;

  /// رقم الكتاب أو التقرير الطبي.
  final String referenceNo;
  final String note;
  final String? approvedBy;
  final DateTime? approvedAt;
  final String departmentId;

  bool get isApproved => approvedBy != null;

  /// Whole days covered (inclusive).
  int get days => DateTime.utc(to.year, to.month, to.day)
          .difference(DateTime.utc(from.year, from.month, from.day))
          .inDays +
      1;

  bool covers(DateTime day) {
    final d = DateTime.utc(day.year, day.month, day.day);
    return !d.isBefore(DateTime.utc(from.year, from.month, from.day)) &&
        !d.isAfter(DateTime.utc(to.year, to.month, to.day));
  }

  factory Leave.fromMap(String id, Map<String, Object?> map) => Leave(
        id: id,
        studentId: Fs.str(map['studentId']),
        stageId: Fs.str(map['stageId']),
        type: Fs.enumByName(LeaveType.values, map['type'], LeaveType.other),
        from: Fs.date(map['from']) ?? DateTime.utc(1970),
        to: Fs.date(map['to']) ?? DateTime.utc(1970),
        referenceNo: Fs.str(map['referenceNo']),
        note: Fs.str(map['note']),
        approvedBy: Fs.strOrNull(map['approvedBy']),
        approvedAt: Fs.date(map['approvedAt']),
        departmentId: Fs.str(map['departmentId'], AppConfig.departmentId),
      );

  Map<String, Object?> toMap() => {
        'studentId': studentId,
        'stageId': stageId,
        'type': type.name,
        'from': Fs.timestamp(from),
        'to': Fs.timestamp(to),
        'referenceNo': referenceNo,
        'note': note,
        'approvedBy': approvedBy,
        'approvedAt': Fs.timestamp(approvedAt),
        'departmentId': departmentId,
      };
}
