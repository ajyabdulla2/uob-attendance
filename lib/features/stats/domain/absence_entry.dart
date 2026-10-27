import '../../../core/firebase/doc_ids.dart';
import '../../attendance/domain/attendance_session.dart';
import '../../edit_requests/domain/edit_request.dart';

/// One lecture the student did not simply attend.
final class AbsenceEntry {
  const AbsenceEntry({
    required this.sessionId,
    required this.date,
    required this.lectureNo,
    required this.type,
    required this.status,
    required this.onLeave,
  });

  final String sessionId;
  final DateTime? date;
  final int lectureNo;
  final String type;
  final AttendanceStatus status;

  /// An absence on a day an approved leave covers (counted as excused).
  final bool onLeave;

  /// Newest first; only [type] when the year keeps theory and practical
  /// apart.
  static List<AbsenceEntry> of(Map<String, AttendanceStatus> bySession, {required Set<String> leaveDays, String? type}) {
    final out = <AbsenceEntry>[];
    for (final MapEntry(key: sid, value: status) in bySession.entries) {
      if (status == AttendanceStatus.present) continue;
      final p = EditRequest.parseSession(sid);
      if (p == null || (type != null && p.type != type)) continue;
      out.add(AbsenceEntry(
        sessionId: sid,
        date: DocIds.parseDateKey(p.dateKey),
        lectureNo: p.lectureNo,
        type: p.type,
        status: status,
        onLeave: status == AttendanceStatus.absent && leaveDays.contains(p.dateKey),
      ));
    }
    out.sort((a, b) {
      final byDate = (b.date ?? DateTime(0)).compareTo(a.date ?? DateTime(0));
      return byDate != 0 ? byDate : b.lectureNo.compareTo(a.lectureNo);
    });
    return out;
  }
}
