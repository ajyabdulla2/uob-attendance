import '../../../core/config/app_config.dart';
import '../../../core/firebase/firestore_converters.dart';
import '../../attendance/domain/attendance_session.dart';

enum EditRequestStatus { pending, approved, rejected }

/// `editRequests/{id}` — asking to change a record after its session locked.
final class EditRequest {
  /// courseId__type__target__yyyyMMdd__n → the lecture's parts.
  static ({String courseId, String type, String target, String dateKey, int lectureNo})? parseSession(String sid) {
    final p = sid.split('__');
    if (p.length != 5) return null;
    return (courseId: p[0], type: p[1], target: p[2], dateKey: p[3], lectureNo: int.tryParse(p[4]) ?? 0);
  }

  const EditRequest({
    required this.id,
    required this.sessionId,
    required this.studentId,
    required this.stageId,
    required this.requestedStatus,
    required this.reason,
    required this.requestedBy,
    this.currentStatus,
    this.status = EditRequestStatus.pending,
    this.createdAt,
    this.decidedBy,
    this.decidedAt,
    this.decisionNote = '',
    this.departmentId = AppConfig.departmentId,
  });

  final String id;
  final String sessionId;
  final String studentId;
  final String stageId;
  final AttendanceStatus requestedStatus;
  final String reason;
  final String requestedBy;

  /// The record's status when the request was filed (for the reviewer).
  final AttendanceStatus? currentStatus;
  final EditRequestStatus status;
  final DateTime? createdAt;
  final String? decidedBy;
  final DateTime? decidedAt;
  final String decisionNote;
  final String departmentId;

  factory EditRequest.fromMap(String id, Map<String, Object?> map) => EditRequest(
        id: id,
        sessionId: Fs.str(map['sessionId']),
        studentId: Fs.str(map['studentId']),
        stageId: Fs.str(map['stageId']),
        requestedStatus:
            Fs.enumByName(AttendanceStatus.values, map['requestedStatus'], AttendanceStatus.present),
        reason: Fs.str(map['reason']),
        requestedBy: Fs.str(map['requestedBy']),
        currentStatus: map['currentStatus'] == null
            ? null
            : Fs.enumByName(AttendanceStatus.values, map['currentStatus'], AttendanceStatus.present),
        createdAt: Fs.date(map['createdAt']),
        status: Fs.enumByName(EditRequestStatus.values, map['status'], EditRequestStatus.pending),
        decidedBy: Fs.strOrNull(map['decidedBy']),
        decidedAt: Fs.date(map['decidedAt']),
        decisionNote: Fs.str(map['decisionNote']),
        departmentId: Fs.str(map['departmentId'], AppConfig.departmentId),
      );

  Map<String, Object?> toMap() => {
        'sessionId': sessionId,
        'studentId': studentId,
        'stageId': stageId,
        'requestedStatus': requestedStatus.name,
        'reason': reason,
        'requestedBy': requestedBy,
        'currentStatus': currentStatus?.name,
        'status': status.name,
        'decidedBy': decidedBy,
        'decisionNote': decisionNote,
        'departmentId': departmentId,
      };
}
