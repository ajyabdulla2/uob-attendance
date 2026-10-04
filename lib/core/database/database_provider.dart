import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_database.dart';

/// Single local database for the app's lifetime. Opened lazily on first use,
/// so screens that do not need it (e.g. the web admin) never load SQLite.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

/// «X سجلات بانتظار الرفع».
final pendingUploadsProvider = StreamProvider<int>(
  (ref) => ref.watch(appDatabaseProvider).watchPendingCount(),
);
