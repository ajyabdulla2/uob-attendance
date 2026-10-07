import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/firebase/collections.dart';
import '../../audit/domain/audit_entry.dart';
import '../../data_fix/domain/fix_plan.dart';
import '../domain/backup_file.dart';
import '../domain/restore_plan.dart';

/// `config/backup`: when the department last saved a backup (the
/// department dashboard reminds admins after a week).
final class LastBackup {
  const LastBackup({required this.at, required this.by, required this.documents, required this.withRecords});

  final DateTime? at;
  final String by;
  final int documents;
  final bool withRecords;

  factory LastBackup.fromMap(Map<String, Object?> m) => LastBackup(
        at: (m['at'] as Timestamp?)?.toDate(),
        by: m['by'] as String? ?? '',
        documents: (m['documents'] as num?)?.toInt() ?? 0,
        withRecords: m['withRecords'] == true,
      );
}

/// النسخ الاحتياطي: reads every collection (and, optionally, every attendance
/// record) into a [BackupData]; restores one with the ordered writes of
/// [restorePhases]. Only Firestore — the file is encrypted and saved by the
/// app (Spark plan: no Cloud Storage).
class BackupRepository {
  BackupRepository(this._fs);

  final FirebaseFirestore _fs;

  static const pageSize = 1000;
  static const backupDoc = '${Col.config}/backup';

  /// Documents per collection (plus `records`), from count() aggregations
  /// that cost one read per 1000 documents: the admin sees how many reads a
  /// backup will spend (Spark: 50,000 a day) before starting it.
  Future<Map<String, int>> estimate() async {
    Future<int> count(Query<Map<String, dynamic>> q) async => (await q.count().get()).count ?? 0;
    final counts = await Future.wait([
      for (final c in BackupScope.collections) count(_fs.collection(c)),
      count(_fs.collectionGroup(Col.records)),
    ]);
    return {
      for (var i = 0; i < BackupScope.collections.length; i++) BackupScope.collections[i]: counts[i],
      Col.records: counts.last,
    };
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _all(Query<Map<String, dynamic>> query) async {
    final docs = <QueryDocumentSnapshot<Map<String, dynamic>>>[];
    while (true) {
      // Firestore's default order is by document name, which the cursor uses.
      var q = query;
      if (docs.isNotEmpty) q = q.startAfterDocument(docs.last);
      final page = (await q.limit(pageSize).get()).docs;
      docs.addAll(page);
      if (page.length < pageSize) return docs;
    }
  }

  Future<BackupData> collect({
    required String actor,
    required bool includeRecords,
    DateTime? now,
    void Function(String collection)? onStep,
  }) async {
    final collections = <String, Map<String, Map<String, Object?>>>{};
    for (final c in BackupScope.collections) {
      onStep?.call(c);
      collections[c] = {for (final d in await _all(_fs.collection(c))) d.id: d.data()};
    }
    final records = <String, Map<String, Map<String, Object?>>>{};
    if (includeRecords) {
      onStep?.call(Col.records);
      for (final d in await _all(_fs.collectionGroup(Col.records))) {
        final sessionId = d.reference.parent.parent?.id;
        if (sessionId == null) continue;
        (records[sessionId] ??= {})[d.id] = d.data();
      }
    }
    return BackupData(
      createdAt: now ?? DateTime.now(),
      createdBy: actor,
      collections: collections,
      records: records,
    );
  }

  /// Called once the file is saved: `config/backup` + an audit entry.
  Future<void> markSaved(BackupData data, {required String actor}) {
    final batch = _fs.batch()
      ..set(_fs.doc(backupDoc), {
        'at': FieldValue.serverTimestamp(),
        'by': actor,
        'documents': data.documentCount,
        'withRecords': data.records.isNotEmpty,
      })
      ..set(_fs.collection(Col.auditLog).doc(), {
        ...AuditEntry(
          actor: actor,
          action: 'backup.export',
          targetPath: backupDoc,
          after: {'documents': data.documentCount, 'records': data.records.isNotEmpty},
        ).toMap(),
        'at': FieldValue.serverTimestamp(),
      });
    return batch.commit();
  }

  Stream<LastBackup?> watchLast() =>
      _fs.doc(backupDoc).snapshots().map((s) => s.exists ? LastBackup.fromMap(s.data()!) : null);

  /// The restore writes. Reads the deanery decisions first: they are frozen,
  /// so writing one that exists would fail its whole batch.
  Future<List<List<List<FixWrite>>>> planRestore(BackupData data, {required String actor}) async {
    final frozen = await _fs.collection(Col.warningLists).where('decision', isEqualTo: 'deanery').get();
    return restorePhases(
      data,
      actor: actor,
      serverTime: FieldValue.serverTimestamp(),
      skipPaths: {for (final d in frozen.docs) d.reference.path},
    );
  }

  /// Commits the restore batch by batch, then writes one audit entry. Every
  /// write overwrites a whole document, so an interrupted restore (or one
  /// stopped by the daily write quota) can simply be run again.
  Future<int> restore(
    BackupData data, {
    required String actor,
    void Function(int done, int total)? onProgress,
  }) async {
    final phases = await planRestore(data, actor: actor);
    final batches = FixPlan.pack(phases);
    var writes = 0;
    for (var i = 0; i < batches.length; i++) {
      final batch = _fs.batch();
      for (final w in batches[i]) {
        batch.set(_fs.doc(w.path), w.data);
      }
      await batch.commit();
      writes += batches[i].length;
      onProgress?.call(i + 1, batches.length);
    }
    await _fs.collection(Col.auditLog).add({
      ...AuditEntry(
        actor: actor,
        action: 'backup.restore',
        targetPath: backupDoc,
        after: {
          'createdAt': data.createdAt.toUtc().toIso8601String(),
          'createdBy': data.createdBy,
          'writes': writes,
        },
      ).toMap(),
      'at': FieldValue.serverTimestamp(),
    });
    return writes;
  }
}
