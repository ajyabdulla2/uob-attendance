import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../data/backup_repository.dart';

final backupRepositoryProvider = Provider<BackupRepository>(
  (ref) => BackupRepository(ref.watch(firestoreProvider)),
);

final lastBackupProvider = StreamProvider.autoDispose<LastBackup?>(
  (ref) => ref.watch(backupRepositoryProvider).watchLast(),
);
