import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/firebase/collections.dart';
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
}
