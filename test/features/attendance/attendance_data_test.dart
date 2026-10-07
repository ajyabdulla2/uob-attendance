import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uob_attendance/core/database/app_database.dart';
import 'package:uob_attendance/core/firebase/server_time.dart';
import 'package:uob_attendance/features/assignments/domain/assignment.dart';
import 'package:uob_attendance/features/attendance/data/attendance_store.dart';
import 'package:uob_attendance/features/attendance/data/outbox_codec.dart';
import 'package:uob_attendance/features/attendance/data/outbox_uploader.dart';
import 'package:uob_attendance/features/attendance/data/teacher_data_sync.dart';
import 'package:uob_attendance/features/attendance/domain/attendance_session.dart';
import 'package:uob_attendance/features/attendance/domain/save_plan.dart';

const t1 = 't1@uob.iq';
const course = 'CS301_3-morning';
final theory = Assignment.theory(teacherId: t1, courseId: course, stageId: '3-morning', courseName: 'هياكل');
final today = DateTime(2026, 10, 12, 10, 30); // device local time
final day = DateTime.utc(2026, 10, 12);

Map<String, Mark> marks(Map<String, AttendanceStatus> m) => {for (final e in m.entries) e.key: Mark(e.value)};

/// A remote that records commits and can fail on demand.
class FakeRemote implements RemoteWriter {
  final docs = <String, Map<String, Object?>>{};
  Set<String> get existing => docs.keys.toSet();
  final commits = <List<RemoteWrite>>[];
  FirebaseException? failCommit;
  FirebaseException? failExists;

  @override
  Future<Map<String, Object?>?> readOnServer(String path) async {
    if (failExists != null) throw failExists!;
    return docs[path];
  }

  @override
  Future<void> commit(List<RemoteWrite> writes) async {
    if (failCommit != null) throw failCommit!;
    commits.add(writes);
    for (final w in writes) {
      if (w.kind == RemoteWriteKind.delete) {
        docs.remove(w.path);
      } else {
        docs[w.path] = {...?docs[w.path], ...w.data};
      }
    }
  }
}

void main() {
  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  group('SavePlan', () {
    SavePlan build(Map<String, Mark> now, {Map<String, Mark> previous = const {}, DateTime? date, DateTime? at}) =>
        SavePlan.build(
          assignment: theory,
          yearId: '2026-2027',
          lockHours: 48,
          date: date ?? today,
          lectureNo: 1,
          marks: now,
          previous: previous,
          actor: t1,
          now: at ?? today,
        );

    test('first save: session + every record + stats only for students not present', () {
      final plan = build(marks({'1': AttendanceStatus.present, '2': AttendanceStatus.absent, '3': AttendanceStatus.late}));
      final sid = '${course}__theory__all__20261012__1';
      expect(plan.session.id, sid);
      expect(plan.session.lockAt, day.add(const Duration(hours: 72)));
      expect(plan.writes.map((w) => w.path), [
        'sessions/$sid',
        'sessions/$sid/records/1',
        'sessions/$sid/records/2',
        'stats/${course}__2',
        'sessions/$sid/records/3',
        'stats/${course}__3',
      ]);
      final session = plan.writes.first;
      expect(session.kind, WriteKind.createOrUpdate);
      final create = session.data['create'] as Map;
      expect(create['openedBy'], t1);
      expect(create['updatedAt'], same(serverTime));
      expect(create['counts'], {'present': 1, 'absent': 1, 'late': 1, 'excused': 0});
      expect((session.data['update'] as Map).keys, unorderedEquals(['counts', 'updatedAt', 'updatedBy']));
      final stat = plan.writes[3].data;
      expect(stat['bySession'], {sid: 'absent'});
      expect(stat['lastSessionId'], sid);
    });

    test('later save: only changed records; stats only when the status changed', () {
      final before = marks({'1': AttendanceStatus.absent, '2': AttendanceStatus.present});
      final after = {'1': Mark.present, '2': const Mark(AttendanceStatus.present, 'مريض')};
      final plan = build(after, previous: before);
      expect(plan.writes.map((w) => w.path.split('/').last), [plan.session.id, '1', '${course}__1', '2']);
      expect(plan.writes[2].data['bySession'], {plan.session.id: 'present'});
      expect(build(before, previous: before).isEmpty, isTrue);
    });

    test('refuses future dates, locked lectures and empty classes', () {
      Matcher refused(SaveRefusal r) => throwsA(isA<SaveRefusedException>().having((e) => e.reason, 'reason', r));
      expect(() => build(marks({'1': AttendanceStatus.absent}), date: today.add(const Duration(days: 1))),
          refused(SaveRefusal.futureDate));
      expect(() => build(marks({'1': AttendanceStatus.absent}), at: today.add(const Duration(days: 4))),
          refused(SaveRefusal.locked));
      expect(() => build(const {}), refused(SaveRefusal.noStudents));
    });
  });

  test('OutboxCodec round-trips server time and timestamps', () {
    final json = OutboxCodec.encode({
      'a': serverTime,
      'b': DateTime.utc(2026, 1, 2, 3),
      'c': Timestamp.fromDate(DateTime.utc(2026, 5, 6)),
      'n': {'x': 1, 'l': [true, null, 'y']},
    });
    final back = OutboxCodec.decode(json);
    expect(back['a'], isA<FieldValue>());
    expect((back['b'] as Timestamp).toDate().toUtc(), DateTime.utc(2026, 1, 2, 3));
    expect((back['c'] as Timestamp).toDate().toUtc(), DateTime.utc(2026, 5, 6));
    expect(back['n'], {'x': 1, 'l': [true, null, 'y']});
  });

  group('AttendanceStore + OutboxUploader', () {
    late AppDatabase db;
    late AttendanceStore store;
    late FakeRemote remote;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      store = AttendanceStore(db);
      remote = FakeRemote();
    });
    tearDown(() => db.close());

    Future<SavePlan> save(Map<String, Mark> m, {DateTime? at}) => store.save(
          assignment: theory,
          yearId: '2026-2027',
          lockHours: 48,
          date: today,
          lectureNo: 1,
          marks: m,
          actor: t1,
          now: at ?? today,
        );

    test('a save is stored locally and queued; the register reads it offline', () async {
      final plan = await save(marks({'1': AttendanceStatus.absent, '2': AttendanceStatus.present}));
      expect(await db.watchPendingCount().first, plan.writes.length);
      expect((await store.marksOf(plan.session.id))['1'], const Mark(AttendanceStatus.absent));
      final sessions = await store.watchClassSessions(theory).first;
      expect(sessions.single.counts[AttendanceStatus.absent], 1);
      expect(sessions.single.date, day);
      final register = await store.watchMarks([plan.session.id]).first;
      expect(register[plan.session.id], {'1': AttendanceStatus.absent, '2': AttendanceStatus.present});
      // Saving the same marks again queues nothing.
      expect((await save(marks({'1': AttendanceStatus.absent, '2': AttendanceStatus.present}))).isEmpty, isTrue);
    });

    test('upload: creates a new session, but only updates one another device opened', () async {
      final plan = await save(marks({'1': AttendanceStatus.absent}));
      final report = await OutboxUploader(db, remote).run();
      expect(report.uploaded, 1);
      expect(report.completed, isTrue);
      expect(await db.watchPendingCount().first, 0);
      final first = remote.commits.single;
      expect(first.first.kind, RemoteWriteKind.set);
      expect(first.first.data['openedBy'], t1);

      await save(marks({'1': AttendanceStatus.present}));
      await OutboxUploader(db, remote).run();
      final second = remote.commits.last;
      expect(second.first.kind, RemoteWriteKind.update);
      expect(second.first.data.keys, unorderedEquals(['counts', 'updatedAt', 'updatedBy']));
      expect(second.map((w) => w.path), ['sessions/${plan.session.id}', 'sessions/${plan.session.id}/records/1', 'stats/${course}__1']);
    });

    test('offline: the run stops and keeps the batch; a rejection is flagged and skipped', () async {
      await save(marks({'1': AttendanceStatus.absent}));
      remote.failExists = FirebaseException(plugin: 'cloud_firestore', code: 'unavailable');
      final offline = await OutboxUploader(db, remote).run();
      expect(offline.stoppedBy, 'unavailable');
      expect(await db.watchPendingCount().first, greaterThan(0));
      expect(await db.watchRejected().first, isEmpty);

      remote.failExists = null;
      remote.failCommit = FirebaseException(plugin: 'cloud_firestore', code: 'permission-denied');
      final denied = await OutboxUploader(db, remote).run();
      expect(denied.rejected, 1);
      expect(denied.completed, isTrue);
      expect((await db.watchRejected().first).single.lastError, 'permission-denied');
      expect(await db.nextBatch(), isEmpty, reason: 'rejected batches are not retried automatically');

      remote.failCommit = null;
      await db.retryRejected();
      expect((await OutboxUploader(db, remote).run()).uploaded, 1);
      expect(await db.watchPendingCount().first, 0);
    });

    test('a new lecture takes its lock deadline from the year on the server', () async {
      // An admin changed «مدة الإقفال» after the phone downloaded the year.
      remote.docs['academicYears/2026-2027'] = {'lockHours': 72};
      final plan = await save(marks({'1': AttendanceStatus.absent}));
      expect((await OutboxUploader(db, remote).run()).uploaded, 1);
      final session = remote.commits.single.first;
      expect(session.path, 'sessions/${plan.session.id}');
      expect((session.data['lockAt'] as Timestamp).toDate().toUtc(), day.add(const Duration(hours: 24 + 72)));
    });

    test('a refusal because the lecture was already locked says so', () async {
      final plan = await save(marks({'1': AttendanceStatus.absent}));
      remote.docs['sessions/${plan.session.id}'] = {'locked': true, 'lockAt': Timestamp.fromDate(day)};
      remote.failCommit = FirebaseException(plugin: 'cloud_firestore', code: 'permission-denied');
      expect((await OutboxUploader(db, remote).run()).rejected, 1);
      expect((await db.watchRejected().first).single.lastError, OutboxUploader.lockedReason);
    });

    test('diagnosis reads what the rules check and sends the save in parts', () async {
      remote.docs['users/$t1'] = {'active': true, 'roles': ['teacher']};
      remote.docs['academicYears/2026-2027'] = {'lockHours': 48};
      final plan = await save(marks({'1': AttendanceStatus.absent, '2': AttendanceStatus.present}));
      remote.failCommit = FirebaseException(plugin: 'cloud_firestore', code: 'permission-denied');
      await OutboxUploader(db, remote).run();
      final batchId = (await db.watchRejected().first).single.batchId;

      remote.failCommit = null;
      final report = await OutboxUploader(db, remote).diagnose(batchId, actor: t1, now: today);
      expect(report, contains('rules on server: current'));
      expect(report, contains('user: ok — active=true'));
      expect(report, contains('assignment: missing (assignments/${course}__theory__all__$t1)'));
      expect(report, contains('session: sessions/${plan.session.id}'));
      expect(report, contains('write session (1): OK'));
      expect(report, contains('write records (2): OK'));
      expect(report, contains('write stats (1): OK'));
      expect(report, contains('result: uploaded'));
      expect(await db.watchRejected().first, isEmpty);
    });

    test('large lectures go in chunks; committed chunks leave the queue', () async {
      final many = {for (var i = 0; i < 25; i++) '$i': const Mark(AttendanceStatus.absent)};
      await save(many);
      final queued = await db.watchPendingCount().first; // 1 + 25 records + 25 stats
      expect(queued, 51);
      await OutboxUploader(db, remote, chunkSize: 20).run();
      expect(remote.commits.map((c) => c.length), [20, 20, 11]);
      expect(await db.watchPendingCount().first, 0);
    });

    test('a download never overwrites unsent local changes', () async {
      final plan = await save(marks({'1': AttendanceStatus.absent}));
      final server = AttendanceSession.fromMap(plan.session.id, plan.session.toMap());
      const record = AttendanceRecord(studentId: '1', status: AttendanceStatus.present, updatedBy: 'other@uob.iq');
      expect(await store.storeDownloaded(server, [record]), isFalse);
      await OutboxUploader(db, remote).run();
      expect(await store.storeDownloaded(server, [record]), isTrue);
      expect((await store.marksOf(plan.session.id))['1'], Mark.present);
    });
  });

  group('TeacherDataSync', () {
    late AppDatabase db;
    late FakeFirebaseFirestore fs;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      fs = FakeFirebaseFirestore();
      await fs.doc('academicYears/2026-2027').set({'active': true, 'semester': 1, 'lockHours': 24});
      await fs.doc('assignments/${theory.id}').set(theory.toMap());
      final practical = Assignment.practical(teacherId: t1, courseId: course, stageId: '3-morning', groupName: 'A');
      await fs.doc('assignments/${practical.id}').set(practical.toMap());
      await fs.doc('assignments/other').set({...theory.toMap(), 'teacherId': 'x@uob.iq'});
      await fs.doc('courses/$course').set({'code': 'CS301', 'name': 'هياكل', 'stageId': '3-morning', 'semester': 1, 'units': 3, 'hasPractical': true});
      await fs.doc('groups/${course}__A').set({'courseId': course, 'stageId': '3-morning', 'name': 'A', 'studentIds': ['1']});
      for (final id in ['1', '2']) {
        await fs.doc('students/$id').set({'universityId': id, 'fullName': 'طالب $id', 'stageId': '3-morning', 'status': 'continuing'});
      }
      await fs.doc('students/9').set({'universityId': '9', 'fullName': 'آخر', 'stageId': '1-evening', 'status': 'continuing'});
    });
    tearDown(() => db.close());

    test('downloads only the teacher\'s classes, their stage students, groups and the year', () async {
      final sync = TeacherDataSync(db, fs);
      await sync.refresh(t1, now: DateTime.utc(2026, 10, 12));
      expect((await sync.cachedYear())!.lockHours, 24);
      expect(await sync.lastDownloadAt(), DateTime.utc(2026, 10, 12));
      expect((await db.watchAssignmentsOfTeacher(t1).first).length, 2);
      expect((await db.watchStudentsOfStage('3-morning').first).map((s) => s.id), ['1', '2']);
      expect(await db.watchStudentsOfStage('1-evening').first, isEmpty);
      expect((await db.groupById('${course}__A'))!.studentIds, ['1']);
      expect((await db.coursesOfStage('3-morning')).single.units, 3);
    });

    test('pulls the sessions of one class with their records', () async {
      final sid = AttendanceStore.sessionIdFor(theory, day, 1);
      await fs.doc('sessions/$sid').set({
        ...AttendanceSession(
          courseId: course, stageId: '3-morning', yearId: '2026-2027', type: AssignmentType.theory, target: 'all',
          date: day, lectureNo: 1, openedBy: 'other@uob.iq', lockAt: day.add(const Duration(hours: 72)),
        ).toMap(),
        'updatedAt': Timestamp.fromDate(DateTime.utc(2026, 10, 12, 9)),
      });
      await fs.doc('sessions/$sid/records/1').set({'studentId': '1', 'status': 'excused', 'updatedBy': 'other@uob.iq'});
      final store = AttendanceStore(db);
      expect(await TeacherDataSync(db, fs).pullClassSessions(theory, store), 1);
      expect((await store.marksOf(sid))['1'], const Mark(AttendanceStatus.excused));
      expect(await TeacherDataSync(db, fs).pullClassSessions(theory, store), 0, reason: 'unchanged since last pull');
    });

    test('the register caches the course\'s stats and the stage\'s approved leaves for percentages', () async {
      final sid = AttendanceStore.sessionIdFor(theory, day, 1);
      await fs.doc('stats/${course}__1').set({
        'courseId': course, 'studentId': '1', 'stageId': '3-morning', 'bySession': {sid: 'absent'},
      });
      await fs.doc('stats/OTHER__1').set({'courseId': 'OTHER', 'studentId': '1', 'stageId': '3-morning', 'bySession': {}});
      await fs.doc('leaves/l1').set({
        'studentId': '1', 'stageId': '3-morning', 'type': 'sick', 'approvedBy': 'sm@uob.iq',
        'from': Timestamp.fromDate(DateTime.utc(2026, 10, 1)), 'to': Timestamp.fromDate(DateTime.utc(2026, 10, 2)),
      });
      await fs.doc('leaves/l2').set({
        'studentId': '2', 'stageId': '3-morning', 'type': 'sick',
        'from': Timestamp.fromDate(DateTime.utc(2026, 10, 1)), 'to': Timestamp.fromDate(DateTime.utc(2026, 10, 2)),
      });
      final sync = TeacherDataSync(db, fs);
      await sync.pullStanding(theory);
      expect(await sync.cachedCourseStats(course), {'1': {sid: AttendanceStatus.absent}});
      final leaves = await sync.cachedLeaves('3-morning');
      expect(leaves.single.studentId, '1', reason: 'only approved leaves');
      expect(leaves.single.days, 2);
    });

    test('opening a practical class refreshes its group members (moved by a manager)', () async {
      final sync = TeacherDataSync(db, fs);
      await sync.refresh(t1);
      await fs.doc('groups/${course}__A').update({'studentIds': ['1', '2']});
      final practical = Assignment.practical(teacherId: t1, courseId: course, stageId: '3-morning', groupName: 'A');
      await sync.pullClassSessions(practical, AttendanceStore(db));
      expect((await db.groupById('${course}__A'))!.studentIds, ['1', '2']);
    });
  });
}
