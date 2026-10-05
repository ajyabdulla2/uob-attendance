import 'dart:async';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/database/app_database.dart';
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
  /// Whether [path] exists on the server (not the local cache). Throws a
  /// [FirebaseException] (`unavailable`) when offline.
  Future<bool> existsOnServer(String path);

  /// Commits [writes] atomically.
  Future<void> commit(List<RemoteWrite> writes);
}

class FirestoreRemoteWriter implements RemoteWriter {
  FirestoreRemoteWriter(this._fs);

  final FirebaseFirestore _fs;

  @override
  Future<bool> existsOnServer(String path) async =>
      (await _fs.doc(path).get(const GetOptions(source: Source.server))).exists;

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
  });

  final AppDatabase _db;
  final RemoteWriter _remote;
  final int chunkSize;
  final Duration timeout;

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

  Future<UploadReport> run() async {
    var uploaded = 0;
    var rejected = 0;
    while (true) {
      final batch = await _db.nextBatch();
      if (batch.isEmpty) return UploadReport(uploaded: uploaded, rejected: rejected);
      final batchId = batch.first.batchId;
      try {
        await _send(batch);
        uploaded++;
      } on FirebaseException catch (e) {
        if (isPermanent(e.code)) {
          await _db.rejectBatch(batchId, e.code);
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
      OutboxOp.createOrUpdate => await _remote.existsOnServer(row.path).timeout(timeout)
          ? RemoteWrite.update(row.path, (data['update'] as Map).cast<String, Object?>())
          : RemoteWrite.set(row.path, (data['create'] as Map).cast<String, Object?>()),
    };
  }
}
