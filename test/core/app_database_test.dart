import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uob_attendance/core/database/app_database.dart';
import 'package:uob_attendance/core/domain/stage_ref.dart';
import 'package:uob_attendance/features/assignments/domain/assignment.dart';
import 'package:uob_attendance/features/courses/domain/course.dart';
import 'package:uob_attendance/features/courses/domain/practical_group.dart';
import 'package:uob_attendance/features/students/domain/student.dart';

void main() {
  late AppDatabase db;

  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);
  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Student s(String name, String id, {String stage = '3-morning', bool carry = false}) =>
      Student(universityId: id, fullName: name, stage: StageRef.parse(stage), carryOver: carry);

  test('students mirror: replace per stage, ordered by sortKey, attending filter', () async {
    await db.replaceStudentsOfStage('3-morning', [s('زينب', '3'), s('أحمد', '1'), s('باقر', '2', carry: true)]);
    await db.replaceStudentsOfStage('1-evening', [s('حسن', '9', stage: '1-evening')]);

    final all = await db.watchStudentsOfStage('3-morning').first;
    expect(all.map((x) => x.fullName), ['أحمد', 'باقر', 'زينب']);
    final attending = await db.watchStudentsOfStage('3-morning', attendingOnly: true).first;
    expect(attending.map((x) => x.id), ['1', '3']);

    // Replacing one stage leaves the others untouched.
    await db.replaceStudentsOfStage('3-morning', [s('علي', '4')]);
    expect((await db.watchStudentsOfStage('3-morning').first).map((x) => x.id), ['4']);
    expect((await db.watchStudentsOfStage('1-evening').first).map((x) => x.id), ['9']);
  });

  test('courses, groups and assignments mirrors', () async {
    final course = Course(code: 'CS301', name: 'هياكل', stage: const StageRef(3, Shift.morning), semester: 1, units: 3, hasPractical: true);
    await db.upsertCourses([course]);
    await db.upsertCourses([Course(code: 'CS301', name: 'هياكل البيانات', stage: const StageRef(3, Shift.morning), semester: 1, units: 3, hasPractical: true)]);
    final courses = await db.coursesOfStage('3-morning');
    expect(courses.single.name, 'هياكل البيانات');

    await db.upsertGroups([PracticalGroup(courseId: course.id, stageId: '3-morning', name: 'A', studentIds: const ['1', '2'])]);
    expect((await db.groupById('${course.id}__A'))!.studentIds, ['1', '2']);
    expect(await db.groupById('nope'), isNull);

    final a = Assignment.practical(teacherId: 't@x.iq', courseId: course.id, stageId: '3-morning', groupName: 'A', courseName: 'هياكل');
    await db.replaceAssignmentsOfTeacher('t@x.iq', [a]);
    final mine = await db.watchAssignmentsOfTeacher('t@x.iq').first;
    expect(mine.single.id, a.id);
    expect(mine.single.groupId, '${course.id}__A');
  });

  test('outbox: batches are queued, counted, taken in order, completed or failed', () async {
    expect(await db.watchPendingCount().first, 0);
    expect(await db.nextBatch(), isEmpty);
    final t0 = DateTime(2026, 10, 4, 9);
    await db.enqueue('b1', [
      (op: OutboxOp.set, path: 'sessions/s1', data: {'locked': false}),
      (op: OutboxOp.set, path: 'sessions/s1/records/1', data: {'status': 'absent'}),
    ], now: t0);
    await db.enqueue('b2', [(op: OutboxOp.merge, path: 'stats/x', data: {'absences': 1})], now: t0.add(const Duration(hours: 1)));

    expect(await db.watchPendingCount().first, 3);
    expect(await db.oldestPendingAt(), t0);

    final first = await db.nextBatch();
    expect(first.map((e) => e.path), ['sessions/s1', 'sessions/s1/records/1']);
    expect(first.first.op, OutboxOp.set);

    await db.failBatch('b1', 'unavailable');
    final retried = await db.nextBatch();
    expect(retried.first.attempts, 1);
    expect(retried.first.lastError, 'unavailable');

    await db.completeBatch('b1');
    expect((await db.nextBatch()).single.batchId, 'b2');
    expect(await db.watchPendingCount().first, 1);
  });

  test('sync state and clearAll', () async {
    await db.writeState('lastSync', '2026-10-04');
    await db.writeState('lastSync', '2026-10-05');
    expect(await db.readState('lastSync'), '2026-10-05');
    await db.replaceStudentsOfStage('3-morning', [s('أ', '1')]);
    await db.clearAll();
    expect(await db.readState('lastSync'), isNull);
    expect(await db.watchStudentsOfStage('3-morning').first, isEmpty);
  });
}
