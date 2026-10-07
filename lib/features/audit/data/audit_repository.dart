import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/firebase/collections.dart';
import '../domain/audit_entry.dart';

/// One page of the audit log, newest first; [cursor] continues it.
final class AuditPage {
  const AuditPage(this.entries, this.cursor);

  final List<AuditEntry> entries;
  final DocumentSnapshot<Map<String, dynamic>>? cursor;
}

/// سجل التدقيق (read-only). Admins read all of it; a stage manager only
/// the entries of a stage in their scope (`stageId` + `at` composite index).
class AuditRepository {
  AuditRepository(this._fs);

  final FirebaseFirestore _fs;

  static const pageSize = 50;

  Future<AuditPage> page({String? stageId, DocumentSnapshot<Map<String, dynamic>>? after}) async {
    Query<Map<String, dynamic>> q = _fs.collection(Col.auditLog);
    if (stageId != null) q = q.where('stageId', isEqualTo: stageId);
    q = q.orderBy('at', descending: true);
    if (after != null) q = q.startAfterDocument(after);
    final docs = (await q.limit(pageSize).get()).docs;
    return AuditPage(
      [for (final d in docs) AuditEntry.fromMap(d.data())],
      docs.length < pageSize ? null : docs.last,
    );
  }
}
