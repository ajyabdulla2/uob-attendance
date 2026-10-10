import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:uob_attendance/core/database/app_database.dart';
import 'package:uob_attendance/core/database/database_provider.dart';
import 'package:uob_attendance/features/attendance/application/attendance_providers.dart';
import 'package:uob_attendance/features/push/application/push_providers.dart';
import 'package:uob_attendance/features/push/data/device_notifications.dart';
import 'package:uob_attendance/features/push/data/push_client.dart';
import 'package:uob_attendance/features/push/domain/unsent_reminder.dart';

void main() {
  group('unsent reminder', () {
    final now = DateTime(2026, 10, 10, 12);

    test('a day after the oldest write still on the phone', () {
      expect(UnsentReminder.at(null, now), isNull);
      expect(UnsentReminder.at(DateTime(2026, 10, 10, 9), now), DateTime(2026, 10, 11, 9));
    });

    test('already overdue: in a minute', () {
      expect(UnsentReminder.at(DateTime(2026, 10, 8), now), now.add(const Duration(minutes: 1)));
    });
  });

  group('push client', () {
    test('sends the ID token and reads the counts', () async {
      late http.Request seen;
      final client = PushClient(
        endpoint: 'https://uob-push.example.workers.dev/',
        idToken: () async => 'id-token',
        client: MockClient((r) async {
          seen = r;
          return http.Response(jsonEncode({'sent': 2, 'noDevice': 1, 'failed': 0}), 200);
        }),
      );
      final r = await client.send(to: ['a@x.iq', 'b@x.iq', 'c@x.iq'], title: ' تذكير ', body: '');
      expect(seen.url.toString(), 'https://uob-push.example.workers.dev/send');
      expect(seen.headers['authorization'], 'Bearer id-token');
      expect(jsonDecode(seen.body), {'to': ['a@x.iq', 'b@x.iq', 'c@x.iq'], 'title': 'تذكير', 'body': ''});
      expect((r.sent, r.noDevice, r.failed), (2, 1, 0));
    });

    test('a refusal is an error; no endpoint means not configured', () async {
      final refused = PushClient(
        endpoint: 'https://w.dev',
        idToken: () async => 't',
        client: MockClient((_) async => http.Response('{"error":"permission-denied"}', 403)),
      );
      await expectLater(refused.send(to: ['a@x.iq'], title: 'x', body: ''), throwsA(isA<PushException>()));
      final none = PushClient(endpoint: '', idToken: () async => 't');
      expect(none.configured, isFalse);
      await expectLater(none.send(to: ['a@x.iq'], title: 'x', body: ''), throwsStateError);
    });
  });

  test('every sync schedules the reminder from the outbox, or cancels it', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final device = _RecordingDevice();
    final container = ProviderContainer(overrides: [
      appDatabaseProvider.overrideWithValue(db),
      localFirstProvider.overrideWithValue(true),
      deviceNotificationsProvider.overrideWithValue(device),
    ]);
    addTearDown(container.dispose);
    final now = DateTime(2026, 10, 10, 12);
    final run = Provider((ref) => updateUnsentReminder(ref, now: now));

    await container.read(run);
    expect(device.log, ['cancel 1']);

    await db.into(db.outboxEntries).insert(OutboxEntriesCompanion.insert(
          batchId: 'b',
          op: OutboxOp.set,
          path: 'sessions/x',
          payloadJson: const Value('{}'),
          createdAt: DateTime(2026, 10, 10, 8),
        ));
    container.invalidate(run);
    await container.read(run);
    expect(device.log.last, 'schedule 1 ${DateTime(2026, 10, 11, 8)}');
  });
}

class _RecordingDevice extends NoDeviceNotifications {
  final log = <String>[];

  @override
  Future<void> schedule({required int id, required DateTime at, required String title, required String body}) async =>
      log.add('schedule $id $at');

  @override
  Future<void> cancel(int id) async => log.add('cancel $id');
}
