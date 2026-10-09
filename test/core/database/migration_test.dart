import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uob_attendance/core/database/app_database.dart';

import 'generated/schema.dart';
import 'generated/schema_v1.dart' as v1;

/// Phones already have the v1 database (with possibly unsent attendance
/// writes) — upgrading must keep every queued write.
void main() {
  late SchemaVerifier verifier;

  setUpAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    verifier = SchemaVerifier(GeneratedHelper());
  });

  test('v1 → v2 produces exactly the current schema', () async {
    final connection = await verifier.startAt(1);
    final db = AppDatabase(connection);
    await verifier.migrateAndValidate(db, 2);
    await db.close();
  });

  test('queued writes survive the upgrade and stay pending (not rejected)', () async {
    final schema = await verifier.schemaAt(1);
    final old = v1.DatabaseAtV1(schema.newConnection());
    await old.into(old.outboxEntries).insert(v1.OutboxEntriesCompanion.insert(
          batchId: 'b1',
          op: 'merge',
          path: 'sessions/x/records/1001',
          payloadJson: const Value('{"status":"absent"}'),
          createdAt: 1700000000,
        ));
    await old.close();

    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 2);
    final batch = await db.nextBatch();
    expect(batch.single.path, 'sessions/x/records/1001');
    expect(batch.single.failed, isFalse);
    expect(await db.recordsOfSession('x'), isEmpty);
    await db.close();
  });
}
