import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/firebase/collections.dart';
import '../../audit/domain/audit_entry.dart';
import '../domain/leave.dart';

/// Leaves are entered by the stage manager or an admin and are approved as
/// they are entered (SPEC §5): an approved leave turns the student's
/// absences on its days into «مُجاز» when percentages are computed.
class LeavesRepository {
  LeavesRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _leaves => _db.collection(Col.leaves);

  /// Leaves of one stage, latest first. The `stageId` filter is what the
  /// rules need to authorize the query.
  Stream<List<Leave>> watchStage(String stageId) =>
      _leaves.where('stageId', isEqualTo: stageId).snapshots().map((snap) {
        final list = [for (final d in snap.docs) Leave.fromMap(d.id, d.data())];
        return list..sort((a, b) => b.from.compareTo(a.from));
      });

  /// One read for the phone (leaves of a stage the teacher teaches).
  Future<List<Leave>> fetchStage(String stageId, {GetOptions? options}) async {
    final snap = await _leaves.where('stageId', isEqualTo: stageId).get(options);
    return [for (final d in snap.docs) Leave.fromMap(d.id, d.data())];
  }

  Future<void> add(Leave leave, {required String actor}) {
    final ref = _leaves.doc();
    final data = {
      ...leave.toMap(),
      'approvedBy': actor,
      'approvedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'updatedBy': actor,
    };
    final batch = _db.batch()
      ..set(ref, data)
      ..set(_db.collection(Col.auditLog).doc(), _audit(actor, 'leave.create', ref.id, leave, after: true));
    return batch.commit();
  }

  Future<void> delete(Leave leave, {required String actor}) {
    final batch = _db.batch()
      ..delete(_leaves.doc(leave.id))
      ..set(_db.collection(Col.auditLog).doc(), _audit(actor, 'leave.delete', leave.id, leave, after: false));
    return batch.commit();
  }

  Map<String, Object?> _audit(String actor, String action, String id, Leave leave, {required bool after}) {
    final snapshot = {
      'studentId': leave.studentId,
      'type': leave.type.name,
      'from': leave.from.toIso8601String(),
      'to': leave.to.toIso8601String(),
      'referenceNo': leave.referenceNo,
    };
    return {
      ...AuditEntry(
        actor: actor,
        action: action,
        targetPath: '${Col.leaves}/$id',
        stageId: leave.stageId,
        before: after ? null : snapshot,
        after: after ? snapshot : null,
      ).toMap(),
      'at': FieldValue.serverTimestamp(),
    };
  }
}
