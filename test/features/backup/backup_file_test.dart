import 'dart:typed_data';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uob_attendance/features/backup/domain/backup_file.dart';

void main() {
  final data = BackupData(
    createdAt: DateTime.utc(2026, 10, 6, 9),
    createdBy: 'admin@uob.iq',
    collections: {
      'students': {
        '1001': {'fullName': 'زينب صالح', 'stageId': '3-morning', 'carryOver': false, 'n': 3, 'x': 1.5},
      },
      'sessions': {
        's1': {
          'date': Timestamp.fromDate(DateTime.utc(2026, 10, 1)),
          'counts': {'present': 2, 'absent': 1},
          'tags': ['a', 'b'],
          'nothing': null,
        },
      },
    },
    records: {
      's1': {
        '1001': {'status': 'absent', 'updatedAt': Timestamp.fromMicrosecondsSinceEpoch(123456789)},
      },
    },
  );

  test('round trip keeps every value, timestamps included', () async {
    final bytes = await BackupFile.encrypt(data, 'كلمة سر 123', random: Random(1));
    expect(String.fromCharCodes(bytes.take(5)), 'UOBK1');
    final back = await BackupFile.decrypt(bytes, 'كلمة سر 123');
    expect(back.createdBy, 'admin@uob.iq');
    expect(back.createdAt, data.createdAt);
    expect(back.collections['students']!['1001'], data.collections['students']!['1001']);
    final s1 = back.collections['sessions']!['s1']!;
    expect(s1['date'], Timestamp.fromDate(DateTime.utc(2026, 10, 1)));
    expect(s1['counts'], {'present': 2, 'absent': 1});
    expect(s1['tags'], ['a', 'b']);
    expect(s1.containsKey('nothing'), isTrue);
    expect(back.records['s1']!['1001']!['updatedAt'], Timestamp.fromMicrosecondsSinceEpoch(123456789));
    expect(back.documentCount, 3);
  });

  test('a wrong password or a damaged file is refused', () async {
    final bytes = await BackupFile.encrypt(data, 'right');
    await expectLater(BackupFile.decrypt(bytes, 'wrong'), throwsA(isA<BackupPasswordException>()));
    final damaged = Uint8List.fromList(bytes)..[bytes.length - 20] ^= 0xFF;
    await expectLater(BackupFile.decrypt(damaged, 'right'), throwsA(isA<BackupPasswordException>()));
    await expectLater(BackupFile.decrypt(Uint8List.fromList([1, 2, 3]), 'right'), throwsA(isA<BackupFormatException>()));
  });
}
