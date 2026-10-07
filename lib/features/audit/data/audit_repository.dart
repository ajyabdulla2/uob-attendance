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

  /// [actor] and the [from]–[to] days (inclusive) filter on the server
  /// (indexes: stageId/actor + at); a student is matched in the app with
  /// [AuditFilter.matches], since entries have no student field.
  Future<AuditPage> page({
    String? stageId,
    String? actor,
    DateTime? from,
    DateTime? to,
    DocumentSnapshot<Map<String, dynamic>>? after,
  }) async {
    Query<Map<String, dynamic>> q = _fs.collection(Col.auditLog);
    if (stageId != null) q = q.where('stageId', isEqualTo: stageId);
    if (actor != null && actor.isNotEmpty) q = q.where('actor', isEqualTo: actor.trim().toLowerCase());
    if (from != null) q = q.where('at', isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime(from.year, from.month, from.day)));
    if (to != null) q = q.where('at', isLessThan: Timestamp.fromDate(DateTime(to.year, to.month, to.day + 1)));
    q = q.orderBy('at', descending: true);
    if (after != null) q = q.startAfterDocument(after);
    final docs = (await q.limit(pageSize).get()).docs;
    return AuditPage(
      [for (final d in docs) AuditEntry.fromMap(d.data())],
      docs.length < pageSize ? null : docs.last,
    );
  }
}
