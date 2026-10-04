import '../../../core/config/app_config.dart';
import '../../../core/firebase/firestore_converters.dart';
import '../../attendance/domain/attendance_session.dart';

enum EditRequestStatus { pending, approved, rejected }

/// `editRequests/{id}` — asking to change a record after its session locked.
final class EditRequest {
  const EditRequest({
    required this.id,
    required this.sessionId,
    required this.studentId,
    required this.stageId,
    required this.requestedStatus,
    required this.reason,
    required this.requestedBy,
    this.status = EditRequestStatus.pending,
    this.decidedBy,
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
  final EditRequestStatus status;
  final String? decidedBy;
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
        status: Fs.enumByName(EditRequestStatus.values, map['status'], EditRequestStatus.pending),
        decidedBy: Fs.strOrNull(map['decidedBy']),
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
        'status': status.name,
        'decidedBy': decidedBy,
        'decisionNote': decisionNote,
        'departmentId': departmentId,
      };
}
