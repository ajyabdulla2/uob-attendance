import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uob_attendance/features/backup/data/backup_repository.dart';
import 'package:uob_attendance/features/backup/domain/backup_file.dart';
import 'package:uob_attendance/features/backup/domain/restore_plan.dart';
import 'package:uob_attendance/features/data_fix/domain/fix_plan.dart';

const admin = 'admin@uob.iq';
const teacher = 't@uob.iq';
const sid = 'CS101_1-morning__theory__all__20261004__1';

Future<void> seed(FakeFirebaseFirestore fs) async {
  final at = Timestamp.fromDate(DateTime.utc(2026, 10, 4));
  await fs.doc('users/$admin').set({'email': admin, 'name': 'المدير', 'roles': ['superAdmin'], 'active': true});
  await fs.doc('users/$teacher').set({'email': teacher, 'name': 'تدريسي', 'roles': ['teacher'], 'active': true});
  await fs.doc('courses/CS101_1-morning').set({'code': 'CS101', 'name': 'البرمجة', 'stageId': '1-morning'});
  await fs.doc('students/1001').set({'universityId': '1001', 'fullName': 'زينب', 'stageId': '1-morning'});
  await fs.doc('sessions/$sid').set({'courseId': 'CS101_1-morning', 'stageId': '1-morning', 'updatedAt': at});
  await fs.doc('sessions/$sid/records/1001').set({'studentId': '1001', 'status': 'absent', 'updatedBy': teacher, 'updatedAt': at});
  await fs.doc('leaves/l1').set({'studentId': '1001', 'stageId': '1-morning', 'approvedBy': 'old@uob.iq'});
  await fs.doc('leaves/l2').set({'studentId': '1001', 'stageId': '1-morning', 'approvedBy': null});
  await fs.doc('warningLists/d1').set({'stageId': '1-morning', 'decision': 'deanery', 'entries': []});
  await fs.doc('warningLists/d2').set({'stageId': '1-morning', 'decision': 'department', 'entries': []});
  await fs.doc('auditLog/a1').set({'actor': admin, 'action': 'x'});
  await fs.doc('editRequests/r1').set({'status': 'pending'});
}

void main() {
  late FakeFirebaseFirestore fs;
  late BackupRepository repo;

  setUp(() async {
    fs = FakeFirebaseFirestore();
    repo = BackupRepository(fs);
    await seed(fs);
  });

  test('collect reads every collection and, when asked, the records', () async {
    final data = await repo.collect(actor: admin, includeRecords: true);
    expect(data.collections['users']!.keys, unorderedEquals([admin, teacher]));
    expect(data.collections['auditLog']!.keys, ['a1']);
    expect(data.records[sid]!['1001']!['status'], 'absent');
    expect(data.documentCount, 12);

    final light = await repo.collect(actor: admin, includeRecords: false);
    expect(light.records, isEmpty);
  });

  test('collect pages through large collections', () async {
    for (var i = 0; i < BackupRepository.pageSize + 5; i++) {
      await fs.doc('stats/s$i').set({'n': i});
    }
    final data = await repo.collect(actor: admin, includeRecords: false);
    expect(data.collections['stats']!.length, BackupRepository.pageSize + 5);
  });

  test('restore phases: parents first, rule-pinned fields rewritten, history skipped', () async {
    final data = await repo.collect(actor: admin, includeRecords: true);
    final phases = restorePhases(data, actor: 'boss@uob.iq', serverTime: 'NOW', skipPaths: {'warningLists/d1'});
    List<String> paths(int i) => [for (final item in phases[i]) for (final w in item) w.path];

    expect(paths(0), containsAll(['users/$admin', 'courses/CS101_1-morning', 'students/1001']));
    expect(phases.expand((p) => p).expand((i) => i).any((w) => w.path.startsWith('auditLog/')), isFalse);
    expect(phases.expand((p) => p).expand((i) => i).any((w) => w.path.startsWith('editRequests/')), isFalse);
    expect(paths(1), containsAll(['leaves/l1', 'leaves/l2', 'warningLists/d2']));
    expect(paths(1), isNot(contains('warningLists/d1')));
    expect(paths(2), ['sessions/$sid']);
    expect(paths(3), ['sessions/$sid/records/1001']);

    FixWrite at(String path) => phases.expand((p) => p).expand((i) => i).firstWhere((w) => w.path == path);
    expect(at('sessions/$sid').data['updatedAt'], 'NOW');
    expect(at('sessions/$sid/records/1001').data, containsPair('updatedBy', 'boss@uob.iq'));
    expect(at('sessions/$sid/records/1001').data, containsPair('status', 'absent'));
    expect(at('leaves/l1').data['approvedBy'], 'boss@uob.iq');
    expect(at('leaves/l2').data['approvedBy'], isNull);
  });

  test('the restorer\'s own account is never overwritten', () {
    final data = BackupData(
      createdAt: DateTime.utc(2026),
      createdBy: admin,
      collections: {
        'users': {
          admin: {'roles': <String>[]},
          teacher: {'roles': ['teacher']},
        },
      },
      records: const {},
    );
    final phases = restorePhases(data, actor: admin, serverTime: 'NOW');
    expect([for (final i in phases.single) i.single.path], ['users/$teacher']);
  });

  test('restore brings deleted and changed documents back, keeps frozen decisions', () async {
    final bytes = await BackupFile.encrypt(await repo.collect(actor: admin, includeRecords: true), 'pw');
    await fs.doc('students/1001').update({'fullName': 'خطأ'});
    await fs.doc('sessions/$sid/records/1001').delete();
    await fs.doc('leaves/l1').delete();
    await fs.doc('warningLists/d1').update({'orderNumber': '7'});
    await fs.doc('students/2002').set({'fullName': 'بعد النسخة'});

    final progress = <int>[];
    final writes = await repo.restore(await BackupFile.decrypt(bytes, 'pw'), actor: admin, onProgress: (d, _) => progress.add(d));
    expect(writes, greaterThan(0));
    expect(progress, isNotEmpty);

    expect((await fs.doc('students/1001').get()).data()!['fullName'], 'زينب');
    expect((await fs.doc('sessions/$sid/records/1001').get()).data()!['updatedBy'], admin);
    expect((await fs.doc('leaves/l1').get()).data()!['approvedBy'], admin);
    expect((await fs.doc('warningLists/d1').get()).data()!['orderNumber'], '7');
    expect((await fs.doc('students/2002').get()).exists, isTrue);
    final audit = (await fs.collection('auditLog').where('action', isEqualTo: 'backup.restore').get()).docs;
    expect(audit, hasLength(1));
  });

  test('markSaved records the last backup', () async {
    final data = await repo.collect(actor: admin, includeRecords: false);
    await repo.markSaved(data, actor: admin);
    final last = await repo.watchLast().first;
    expect(last!.by, admin);
    expect(last.documents, data.documentCount);
    expect(last.withRecords, isFalse);
    expect(last.at, isNotNull);
  });
}
