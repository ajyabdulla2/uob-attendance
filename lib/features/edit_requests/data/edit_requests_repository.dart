import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/config/app_config.dart';
import '../../../core/firebase/collections.dart';
import '../../../core/firebase/doc_ids.dart';
import '../../attendance/domain/attendance_session.dart';
import '../../audit/domain/audit_entry.dart';
import '../domain/edit_request.dart';

/// طلبات التعديل: after a lecture locks, its teacher asks; the stage manager
/// (or an admin) approves — which changes the record, the student's stats
/// and the lecture's counts in one batch — or rejects.
class EditRequestsRepository {
  EditRequestsRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _requests => _db.collection(Col.editRequests);

  Future<void> file(EditRequest request) => _requests.doc().set({
        ...request.toMap(),
        'status': EditRequestStatus.pending.name,
        'createdAt': FieldValue.serverTimestamp(),
      });

  /// Requests of one stage awaiting a decision, oldest first.
  Stream<List<EditRequest>> watchPending(String stageId) => _requests
      .where('stageId', isEqualTo: stageId)
      .where('status', isEqualTo: EditRequestStatus.pending.name)
      .snapshots()
      .map((snap) => [for (final d in snap.docs) EditRequest.fromMap(d.id, d.data())]
        ..sort((a, b) => (a.createdAt ?? DateTime(9999)).compareTo(b.createdAt ?? DateTime(9999))));

  /// The signed-in teacher's own requests (to show what is pending).
  Stream<List<EditRequest>> watchMine(String email) => _requests
      .where('requestedBy', isEqualTo: email)
      .snapshots()
      .map((snap) => [for (final d in snap.docs) EditRequest.fromMap(d.id, d.data())]);

  Future<void> reject(EditRequest request, {required String note, required String actor}) {
    final batch = _db.batch()
      ..update(_requests.doc(request.id), _decision(EditRequestStatus.rejected, note, actor))
      ..set(_db.collection(Col.auditLog).doc(), _audit(actor, 'editRequest.reject', request));
    return batch.commit();
  }

  /// Applies the requested status: record, stats and the session's counts
  /// (and `updatedAt`, so the teachers' phones download the change).
  Future<void> approve(EditRequest request, {required String note, required String actor}) async {
    final session = _db.collection(Col.sessions).doc(request.sessionId);
    final records = await session.collection(Col.records).get();
    final statuses = {
      for (final d in records.docs)
        d.id: AttendanceStatus.values.firstWhere((s) => s.name == d.data()['status'], orElse: () => AttendanceStatus.present),
      request.studentId: request.requestedStatus,
    };
    final before = records.docs.where((d) => d.id == request.studentId).firstOrNull?.data()['status'];
    final counts = {for (final s in AttendanceStatus.values) s.name: statuses.values.where((v) => v == s).length};
    final stageId = request.stageId;
    final parts = EditRequest.parseSession(request.sessionId);
    final batch = _db.batch()
      ..set(session.collection(Col.records).doc(request.studentId), {
        'studentId': request.studentId,
        'status': request.requestedStatus.name,
        'updatedBy': actor,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true))
      ..update(session, {'counts': counts, 'updatedAt': FieldValue.serverTimestamp(), 'updatedBy': actor})
      ..set(_db.collection(Col.stats).doc(DocIds.stat(parts?.courseId ?? '', request.studentId)), {
        'courseId': parts?.courseId,
        'studentId': request.studentId,
        'stageId': stageId,
        'lastSessionId': request.sessionId,
        'bySession': {request.sessionId: request.requestedStatus.name},
        'updatedAt': FieldValue.serverTimestamp(),
        'departmentId': AppConfig.departmentId,
      }, SetOptions(merge: true))
      ..update(_requests.doc(request.id), _decision(EditRequestStatus.approved, note, actor))
      ..set(_db.collection(Col.auditLog).doc(), {
        ...AuditEntry(
          actor: actor,
          action: 'record.update',
          targetPath: '${Col.sessions}/${request.sessionId}/${Col.records}/${request.studentId}',
          stageId: stageId,
          before: {'status': before},
          after: {'status': request.requestedStatus.name, 'editRequest': request.id},
        ).toMap(),
        'at': FieldValue.serverTimestamp(),
      });
    await batch.commit();
  }

  Map<String, Object?> _decision(EditRequestStatus status, String note, String actor) => {
        'status': status.name,
        'decidedBy': actor,
        'decidedAt': FieldValue.serverTimestamp(),
        'decisionNote': note.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

  Map<String, Object?> _audit(String actor, String action, EditRequest r) => {
        ...AuditEntry(
          actor: actor,
          action: action,
          targetPath: '${Col.editRequests}/${r.id}',
          stageId: r.stageId,
          after: {'sessionId': r.sessionId, 'studentId': r.studentId, 'requestedStatus': r.requestedStatus.name},
        ).toMap(),
        'at': FieldValue.serverTimestamp(),
      };
}
