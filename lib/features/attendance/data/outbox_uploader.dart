import 'dart:async';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/database/app_database.dart';
import '../../../core/firebase/collections.dart';
import '../../../core/firebase/rules_version.dart';
import '../domain/attendance_session.dart';
import 'outbox_codec.dart';

/// One resolved write of an upload chunk.
final class RemoteWrite {
  const RemoteWrite.set(this.path, this.data) : kind = RemoteWriteKind.set;
  const RemoteWrite.merge(this.path, this.data) : kind = RemoteWriteKind.merge;
  const RemoteWrite.update(this.path, this.data) : kind = RemoteWriteKind.update;
  const RemoteWrite.delete(this.path)
      : kind = RemoteWriteKind.delete,
        data = const {};

  final RemoteWriteKind kind;
  final String path;
  final Map<String, Object?> data;
}

enum RemoteWriteKind { set, merge, update, delete }

/// The Firestore side of the uploader (a seam for tests).
abstract interface class RemoteWriter {
  /// The document at [path] on the server (not the local cache), or null
  /// when it does not exist. Throws a [FirebaseException] (`unavailable`)
  /// when offline.
  Future<Map<String, Object?>?> readOnServer(String path);

  /// Commits [writes] atomically.
  Future<void> commit(List<RemoteWrite> writes);
}

class FirestoreRemoteWriter implements RemoteWriter {
  FirestoreRemoteWriter(this._fs);

  final FirebaseFirestore _fs;

  @override
  Future<Map<String, Object?>?> readOnServer(String path) async =>
      (await _fs.doc(path).get(const GetOptions(source: Source.server))).data();

  @override
  Future<void> commit(List<RemoteWrite> writes) {
    final batch = _fs.batch();
    for (final w in writes) {
      final ref = _fs.doc(w.path);
      switch (w.kind) {
        case RemoteWriteKind.set:
          batch.set(ref, w.data);
        case RemoteWriteKind.merge:
          batch.set(ref, w.data, SetOptions(merge: true));
        case RemoteWriteKind.update:
          batch.update(ref, w.data);
        case RemoteWriteKind.delete:
          batch.delete(ref);
      }
    }
    return batch.commit();
  }
}

/// Outcome of one upload run.
final class UploadReport {
  const UploadReport({this.uploaded = 0, this.rejected = 0, this.stoppedBy});

  /// Batches sent / refused by the server during this run.
  final int uploaded;
  final int rejected;

  /// Why the run stopped early (offline, timeout…); null when the queue
  /// was emptied.
  final String? stoppedBy;

  bool get completed => stoppedBy == null;
}

/// Sends the outbox to Firestore, oldest batch first.
///
/// * Every queued write is idempotent (records and stats are merged with
///   fixed values; no increments), so re-sending a batch whose commit
///   already reached the server — possible after a timeout or an app kill,
///   since the SDK also retries on its own — changes nothing.
/// * A batch the server refuses (rules: e.g. the session locked before the
///   upload) is kept and flagged; the rest of the queue continues.
/// * Network problems stop the run; the batch stays queued for next time.
/// * Large lectures are sent in chunks; each committed chunk leaves the
///   queue at once.
class OutboxUploader {
  OutboxUploader(
    this._db,
    this._remote, {
    this.chunkSize = 450,
    this.timeout = const Duration(seconds: 45),
    this.clock = DateTime.now,
  });

  final AppDatabase _db;
  final RemoteWriter _remote;
  final int chunkSize;
  final Duration timeout;

  /// Tells a refusal after the lock deadline from any other refusal.
  final DateTime Function() clock;

  static const _permanent = {
    'permission-denied',
    'invalid-argument',
    'failed-precondition',
    'not-found',
    'already-exists',
    'out-of-range',
    'data-loss',
  };

  static bool isPermanent(String code) => _permanent.contains(code);

  /// Stored instead of `permission-denied` when the lecture's lock deadline
  /// had passed (or a stage manager locked it) before the upload: only a
  /// stage manager can still save it.
  static const lockedReason = 'session-locked';

  /// Lock state of the lecture in the batch being sent (from the server).
  DateTime? _lockAt;
  bool _locked = false;

  Future<UploadReport> run() async {
    var uploaded = 0;
    var rejected = 0;
    while (true) {
      final batch = await _db.nextBatch();
      if (batch.isEmpty) return UploadReport(uploaded: uploaded, rejected: rejected);
      final batchId = batch.first.batchId;
      _lockAt = null;
      _locked = false;
      try {
        await _send(batch);
        uploaded++;
      } on FirebaseException catch (e) {
        if (isPermanent(e.code)) {
          final lockedBefore = _locked || (_lockAt != null && !_lockAt!.isAfter(clock()));
          await _db.rejectBatch(batchId, e.code == 'permission-denied' && lockedBefore ? lockedReason : e.code);
          rejected++;
          continue;
        }
        await _db.failBatch(batchId, e.code);
        return UploadReport(uploaded: uploaded, rejected: rejected, stoppedBy: e.code);
      } on TimeoutException {
        await _db.failBatch(batchId, 'timeout');
        return UploadReport(uploaded: uploaded, rejected: rejected, stoppedBy: 'timeout');
      }
    }
  }

  /// «تشخيص» for a refused save: reads, as the signed-in teacher, every
  /// document the security rules consult, then sends the lecture, its
  /// records and its statistics as three separate commits so the refused
  /// part shows. Parts that go through leave the queue (all writes are
  /// idempotent); if all do, the save is uploaded. Returns a plain-text
  /// report for the developer.
  Future<String> diagnose(String batchId, {required String actor, DateTime? now}) async {
    final rows = await _db.batchRows(batchId);
    final at = (now ?? DateTime.now()).toUtc();
    final out = <String>['save diagnosis', 'batch: $batchId', 'actor: $actor', 'now (UTC): ${at.toIso8601String()}'];
    try {
      await _remote.readOnServer(RulesVersion.path).timeout(timeout);
      out.add(RulesVersion.describe(true));
    } on FirebaseException catch (e) {
      out.add(RulesVersion.describe(e.code == 'permission-denied' ? false : null));
    } on Object {
      out.add(RulesVersion.describe(null));
    }
    if (rows.isEmpty) return (out..add('nothing queued for this batch')).join('\n');

    String show(Object? v) => switch (v) {
          Timestamp t => t.toDate().toUtc().toIso8601String(),
          Map m => '{${m.keys.join(', ')}}',
          _ => '$v',
        };
    Future<Map<String, Object?>?> read(String label, String path, List<String> fields) async {
      try {
        final d = await _remote.readOnServer(path).timeout(timeout);
        out.add(d == null
            ? '$label: missing ($path)'
            : '$label: ok — ${[for (final f in fields) '$f=${show(d[f])}'].join(', ')}');
        return d;
      } on Object catch (e) {
        out.add('$label: READ FAILED ${e is FirebaseException ? e.code : e} ($path)');
        return null;
      }
    }

    final sessionRow = rows.where((r) => r.op == OutboxOp.createOrUpdate).firstOrNull;
    final create = sessionRow == null
        ? const <String, Object?>{}
        : (OutboxCodec.decode(sessionRow.payloadJson)['create'] as Map).cast<String, Object?>();
    out.add('rows: ${rows.length} (${rows.where((r) => r.path.contains('/${Col.records}/')).length} records, '
        '${rows.where((r) => r.path.startsWith('${Col.stats}/')).length} stats)');
    if (sessionRow != null) {
      out.add('session: ${sessionRow.path}');
      out.add('payload: ${[for (final f in ['courseId', 'stageId', 'yearId', 'type', 'target', 'dateKey', 'lectureNo', 'date', 'lockAt', 'openedBy', 'locked']) '$f=${show(create[f])}'].join(', ')}');
    }

    await read('user', '${Col.users}/$actor', ['active', 'roles', 'stageScopes', 'teachingStages']);
    final courseId = create['courseId'];
    if (courseId is String) {
      await read('course', '${Col.courses}/$courseId', ['stageId', 'code']);
      await read('assignment', '${Col.assignments}/${courseId}__${create['type']}__${create['target']}__$actor',
          ['teacherId', 'stageId', 'type', 'target']);
      if (create['type'] == 'practical') {
        await read('group', '${Col.groups}/${courseId}__${create['target']}', ['stageId', 'name']);
      }
    }
    final yearId = create['yearId'];
    if (yearId is String) {
      final year = await read('year', '${Col.academicYears}/$yearId', ['lockHours', 'active']);
      final date = create['date'];
      if (date is Timestamp) {
        final hours = (year?['lockHours'] as num?)?.toInt() ?? 48;
        final expected = AttendanceSession.lockAtFor(date.toDate().toUtc(), hours);
        out.add('lockAt expected by rules: ${expected.toIso8601String()} — ${expected.isAfter(at) ? 'still open' : 'ALREADY PASSED'}');
      }
    }
    if (sessionRow != null) await read('session on server', sessionRow.path, ['locked', 'lockAt', 'openedBy', 'stageId']);

    // The writes, in three parts.
    final parts = <String, List<OutboxEntry>>{
      'session': [for (final r in rows) if (r.op == OutboxOp.createOrUpdate) r],
      'records': [for (final r in rows) if (r.path.contains('/${Col.records}/')) r],
      'stats': [for (final r in rows) if (r.path.startsWith('${Col.stats}/')) r],
    };
    final other = [for (final r in rows) if (!parts.values.any((p) => p.contains(r))) r];
    if (other.isNotEmpty) parts['other'] = other;
    for (final part in parts.entries) {
      if (part.value.isEmpty) continue;
      try {
        await _send(part.value);
        out.add('write ${part.key} (${part.value.length}): OK');
      } on Object catch (e) {
        out.add('write ${part.key} (${part.value.length}): REFUSED ${e is FirebaseException ? '${e.code} ${e.message ?? ''}' : e}');
      }
    }
    final left = await _db.batchRows(batchId);
    out.add(left.isEmpty ? 'result: uploaded — nothing left on the phone' : 'result: ${left.length} rows still on the phone');
    return out.join('\n');
  }

  Future<void> _send(List<OutboxEntry> rows) async {
    final writes = <({int rowId, RemoteWrite write})>[];
    for (final row in rows) {
      writes.add((rowId: row.id, write: await _resolve(row)));
    }
    for (var i = 0; i < writes.length; i += chunkSize) {
      final chunk = writes.sublist(i, math.min(i + chunkSize, writes.length));
      await _remote.commit([for (final w in chunk) w.write]).timeout(timeout);
      await _db.completeRows([for (final w in chunk) w.rowId]);
    }
  }

  Future<RemoteWrite> _resolve(OutboxEntry row) async {
    final data = OutboxCodec.decode(row.payloadJson);
    return switch (row.op) {
      OutboxOp.set => RemoteWrite.set(row.path, data),
      OutboxOp.merge => RemoteWrite.merge(row.path, data),
      OutboxOp.delete => RemoteWrite.delete(row.path),
      OutboxOp.createOrUpdate => await _createOrUpdate(row.path, data),
    };
  }

  /// A lecture: only its bookkeeping fields when it already exists on the
  /// server, else the whole document. A new lecture's lock deadline is
  /// recomputed from the year's lock hours on the server — the rules demand
  /// exactly that value, and the copy on the phone may predate an admin's
  /// change in «إعدادات السنة».
  Future<RemoteWrite> _createOrUpdate(String path, Map<String, Object?> data) async {
    final current = await _remote.readOnServer(path).timeout(timeout);
    if (current != null) {
      _locked = current['locked'] == true;
      _lockAt = (current['lockAt'] as Timestamp?)?.toDate();
      return RemoteWrite.update(path, (data['update'] as Map).cast<String, Object?>());
    }
    final create = {...(data['create'] as Map).cast<String, Object?>()};
    final yearId = create['yearId'];
    final date = create['date'];
    if (yearId is String && date is Timestamp) {
      final year = await _remote.readOnServer('${Col.academicYears}/$yearId').timeout(timeout);
      final hours = (year?['lockHours'] as num?)?.toInt() ?? 48;
      create['lockAt'] = Timestamp.fromDate(AttendanceSession.lockAtFor(date.toDate().toUtc(), hours));
    }
    _lockAt = (create['lockAt'] as Timestamp?)?.toDate();
    return RemoteWrite.set(path, create);
  }
}
