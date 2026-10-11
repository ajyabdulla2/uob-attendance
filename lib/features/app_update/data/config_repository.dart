import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/firebase/collections.dart';
import '../../audit/domain/audit_entry.dart';
import '../domain/app_update_policy.dart';

/// Small `config` collection for app-wide settings set by admins.
class ConfigRepository {
  ConfigRepository(this._db);

  final FirebaseFirestore _db;

  static const appDocId = 'app';

  /// `config/app` (null when the admins have not set it yet).
  Stream<AppUpdatePolicy?> watchAppPolicy() => _db.collection(Col.config).doc(appDocId).snapshots().map(
        (snap) => snap.exists ? AppUpdatePolicy.fromMap(snap.data()!) : null,
      );

  /// Saves `config/app` from «إصدار التطبيق» (empty fields are removed),
  /// with an audit entry in the same batch.
  Future<void> saveAppPolicy(AppUpdatePolicy? before, AppUpdatePolicy after, {required String actor}) {
    final fields = after.toMap();
    final batch = _db.batch()
      ..set(
        _db.collection(Col.config).doc(appDocId),
        {
          for (final e in fields.entries) e.key: e.value ?? FieldValue.delete(),
          'updatedBy': actor,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      )
      ..set(_db.collection(Col.auditLog).doc(), {
        ...AuditEntry(
          actor: actor,
          action: 'config.update',
          targetPath: '${Col.config}/$appDocId',
          before: before?.toMap() ?? const {},
          after: fields,
        ).toMap(),
        'at': FieldValue.serverTimestamp(),
      });
    return batch.commit();
  }
}
