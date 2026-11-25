import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/firebase/collections.dart';
import '../../audit/domain/audit_entry.dart';
import '../domain/external_notice.dart';

/// «كتب خارجية»: letters issued outside the app, per stage. Added or
/// deleted (no edit) by whoever manages the stage, each with an audit entry.
class ExternalNoticesRepository {
  ExternalNoticesRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col => _db.collection(Col.externalNotices);

  Stream<List<ExternalNotice>> watchStage(String stageId) =>
      _col.where('stageId', isEqualTo: stageId).snapshots().map((snap) =>
          [for (final d in snap.docs) ExternalNotice.fromMap(d.id, d.data())]..sort((a, b) => b.date.compareTo(a.date)));

  Future<void> add(ExternalNotice n, {required String actor}) {
    final ref = _col.doc();
    final data = {...n.toMap(), 'createdBy': actor, 'createdAt': FieldValue.serverTimestamp()};
    final batch = _db.batch()
      ..set(ref, data)
      ..set(_db.collection(Col.auditLog).doc(), _audit(actor, 'notice.create', ref.id, n, after: n.toMap()..remove('date')));
    return batch.commit();
  }

  Future<void> delete(ExternalNotice n, {required String actor}) {
    final batch = _db.batch()
      ..delete(_col.doc(n.id))
      ..set(_db.collection(Col.auditLog).doc(), _audit(actor, 'notice.delete', n.id, n, before: n.toMap()..remove('date')));
    return batch.commit();
  }

  Map<String, Object?> _audit(String actor, String action, String id, ExternalNotice n,
          {Map<String, Object?>? before, Map<String, Object?>? after}) =>
      {
        ...AuditEntry(
          actor: actor,
          action: action,
          targetPath: '${Col.externalNotices}/$id',
          stageId: n.stageId,
          before: before == null ? null : {...before, 'date': n.dateKey},
          after: after == null ? null : {...after, 'date': n.dateKey},
        ).toMap(),
        'at': FieldValue.serverTimestamp(),
      };
}
