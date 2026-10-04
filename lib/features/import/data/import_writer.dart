import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/firebase/collections.dart';
import '../../auth/domain/app_user.dart';
import '../../courses/domain/course.dart';
import '../../students/domain/student.dart';
import '../domain/import_models.dart';

/// Outcome of saving an import.
final class ImportWriteResult {
  const ImportWriteResult({required this.created, required this.updated, required this.failures});

  final int created;
  final int updated;

  /// Rows that could not be saved (e.g. `permission-denied` when a student ID
  /// already belongs to a stage the importer does not manage).
  final List<({int rowNumber, String code})> failures;

  int get written => created + updated;
}

/// One document write derived from a preview row.
final class _Op {
  const _Op(this.rowNumber, this.ref, this.data, {required this.merge, required this.isCreate});
  final int rowNumber;
  final DocumentReference<Map<String, dynamic>> ref;
  final Map<String, Object?> data;
  final bool merge;
  final bool isCreate;
}

/// Saves the writable rows of an [ImportPreview] with batched writes
/// (≤ [batchSize] per batch, below Firestore's 500 limit). If a batch is
/// rejected, its rows are retried one by one so a single bad row does not
/// block the rest, and the failing rows are reported.
class ImportWriter {
  ImportWriter(this._db, {this.batchSize = 400});

  final FirebaseFirestore _db;
  final int batchSize;

  Future<ImportWriteResult> commit(ImportPreview<Object?> preview, {required String actor}) async {
    final ops = <_Op>[];
    for (final row in preview.rowsToWrite) {
      final isCreate = row.action == RowAction.create;
      ops.addAll(_opsFor(row.entity, row.rowNumber, isCreate: isCreate, actor: actor));
    }

    final failedRows = <int, String>{};
    for (var start = 0; start < ops.length; start += batchSize) {
      final chunk = ops.sublist(start, (start + batchSize).clamp(0, ops.length));
      try {
        final batch = _db.batch();
        for (final op in chunk) {
          batch.set(op.ref, op.data, SetOptions(merge: op.merge));
        }
        await batch.commit();
      } on FirebaseException {
        for (final op in chunk) {
          try {
            await op.ref.set(op.data, SetOptions(merge: op.merge));
          } on FirebaseException catch (e) {
            failedRows.putIfAbsent(op.rowNumber, () => e.code);
          }
        }
      }
    }

    var created = 0;
    var updated = 0;
    for (final row in preview.rowsToWrite) {
      if (failedRows.containsKey(row.rowNumber)) continue;
      row.action == RowAction.create ? created++ : updated++;
    }

    await _audit(preview.kind, actor, created: created, updated: updated, failed: failedRows.length);

    return ImportWriteResult(
      created: created,
      updated: updated,
      failures: [for (final e in failedRows.entries) (rowNumber: e.key, code: e.value)]
        ..sort((a, b) => a.rowNumber.compareTo(b.rowNumber)),
    );
  }

  Iterable<_Op> _opsFor(Object? entity, int rowNumber, {required bool isCreate, required String actor}) sync* {
    final stamps = <String, Object?>{
      'updatedAt': FieldValue.serverTimestamp(),
      'updatedBy': actor,
      if (isCreate) 'createdAt': FieldValue.serverTimestamp(),
    };
    switch (entity) {
      case Student s:
        yield _Op(rowNumber, _db.collection(Col.students).doc(s.id), {...s.toMap(), ...stamps},
            merge: !isCreate, isCreate: isCreate);
      case AppUser u:
        // Updates refresh the profile only; roles/scopes are never touched.
        final data = isCreate
            ? u.toMap()
            : {'name': u.name, 'title': u.title, 'phone': u.phone};
        yield _Op(rowNumber, _db.collection(Col.users).doc(u.id), {...data, ...stamps},
            merge: !isCreate, isCreate: isCreate);
      case List<Course> courses:
        for (final c in courses) {
          yield _Op(rowNumber, _db.collection(Col.courses).doc(c.id), {...c.toMap(), ...stamps},
              merge: true, isCreate: isCreate);
        }
      default:
        throw ArgumentError.value(entity, 'entity', 'Unsupported import entity');
    }
  }

  Future<void> _audit(ImportKind kind, String actor,
      {required int created, required int updated, required int failed}) async {
    if (created + updated == 0) return;
    try {
      await _db.collection(Col.auditLog).add({
        'actor': actor,
        'action': 'import.${kind.name}',
        'targetPath': switch (kind) {
          ImportKind.students => Col.students,
          ImportKind.teachers => Col.users,
          ImportKind.courses => Col.courses,
        },
        'stageId': null,
        'before': null,
        'after': {'created': created, 'updated': updated, 'failed': failed},
        'at': FieldValue.serverTimestamp(),
      });
    } on FirebaseException {
      // The audit trail is best-effort; the import itself succeeded.
    }
  }
}
