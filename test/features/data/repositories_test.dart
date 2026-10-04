import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uob_attendance/core/domain/stage_ref.dart';
import 'package:uob_attendance/features/academic/data/academic_repository.dart';
import 'package:uob_attendance/features/assignments/data/assignments_repository.dart';
import 'package:uob_attendance/features/assignments/domain/assignment.dart';
import 'package:uob_attendance/features/auth/domain/app_user.dart';
import 'package:uob_attendance/features/courses/data/courses_repository.dart';
import 'package:uob_attendance/features/courses/domain/course.dart';
import 'package:uob_attendance/features/import/data/import_writer.dart';
import 'package:uob_attendance/features/import/domain/import_models.dart';
import 'package:uob_attendance/features/import/domain/import_parsers.dart';
import 'package:uob_attendance/features/students/data/students_repository.dart';
import 'package:uob_attendance/features/students/domain/student.dart';
import 'package:uob_attendance/features/users/data/users_repository.dart';

const actor = 'admin@uob.iq';

Future<Map<String, Object?>> data(FakeFirebaseFirestore db, String path) async =>
    (await db.doc(path).get()).data() ?? const {};

void main() {
  late FakeFirebaseFirestore db;
  setUp(() => db = FakeFirebaseFirestore());

  group('ImportWriter', () {
    test('creates students with server stamps and writes an audit entry', () async {
      final preview = parseStudents(
        SheetTable(headers: const ['الاسم الرباعي', 'الرقم الجامعي', 'المرحلة', 'الدراسة'], rows: const [
          ['علي حسين جاسم محمد', '1', '1', 'صباحي'],
          ['', '2', '1', 'صباحي'], // invalid: never written
        ]),
        existing: const {},
      );
      final result = await ImportWriter(db).commit(preview, actor: actor);
      expect(result.created, 1);
      expect(result.failures, isEmpty);

      final doc = await data(db, 'students/1');
      expect(doc['fullName'], 'علي حسين جاسم محمد');
      expect(doc['stageId'], '1-morning');
      expect(doc['updatedBy'], actor);
      expect(doc['createdAt'], isA<Timestamp>());
      expect((await db.doc('students/2').get()).exists, isFalse);

      final audit = await db.collection('auditLog').get();
      expect(audit.docs.single.data()['action'], 'import.students');
      expect(audit.docs.single.data()['after'], {'created': 1, 'updated': 0, 'failed': 0});
    });

    test('teacher updates refresh the profile but never touch roles or scopes', () async {
      await db.doc('users/sm@uob.iq').set(const AppUser(
        email: 'sm@uob.iq',
        name: 'قديم',
        roles: {UserRole.stageManager, UserRole.teacher},
        stageScopes: ['3-morning'],
      ).toMap());
      final existing = {
        for (final d in (await db.collection('users').get()).docs) d.id: AppUser.fromMap(d.id, d.data()),
      };
      final preview = parseTeachers(
        SheetTable(headers: const ['الاسم', 'البريد الجامعي', 'الهاتف'], rows: const [
          ['جديد', 'SM@uob.iq', '07700000000'],
          ['تدريسي', 'new@uob.iq', ''],
        ]),
        existing: existing,
        options: const ImportOptions(updateExisting: true),
      );
      // Simulate a role change by someone else between preview and save.
      await db.doc('users/sm@uob.iq').update({'stageScopes': ['3-morning', '3-evening']});

      final result = await ImportWriter(db).commit(preview, actor: actor);
      expect((result.created, result.updated), (1, 1));
      final sm = AppUser.fromMap('sm@uob.iq', await data(db, 'users/sm@uob.iq'));
      expect(sm.name, 'جديد');
      expect(sm.phone, '07700000000');
      expect(sm.roles, {UserRole.stageManager, UserRole.teacher});
      expect(sm.stageScopes, ['3-morning', '3-evening']);
      final created = AppUser.fromMap('new@uob.iq', await data(db, 'users/new@uob.iq'));
      expect(created.roles, {UserRole.teacher});
      expect(created.active, isTrue);
    });

    test('a course row for both shifts writes two documents, in several batches', () async {
      final preview = parseCourses(
        SheetTable(headers: const ['رمز المادة', 'اسم المادة', 'المرحلة', 'الوحدات'], rows: [
          for (var i = 0; i < 5; i++) ['C$i', 'مادة $i', '1', '2'],
        ]),
        existing: const {},
      );
      final result = await ImportWriter(db, batchSize: 3).commit(preview, actor: actor);
      expect(result.created, 5);
      expect((await db.collection('courses').get()).docs, hasLength(10));
      expect((await data(db, 'courses/C0_1-evening'))['name'], 'مادة 0');
    });
  });

  group('StudentsRepository', () {
    test('fetches by stage and watches a stage in register order', () async {
      final repo = StudentsRepository(db);
      for (final st in [
        Student(universityId: '2', fullName: 'زينب', stage: const StageRef(1, Shift.morning)),
        Student(universityId: '1', fullName: 'أحمد', stage: const StageRef(1, Shift.morning)),
        Student(universityId: '3', fullName: 'حسن', stage: const StageRef(2, Shift.morning)),
      ]) {
        await db.doc('students/${st.id}').set(st.toMap());
      }
      expect((await repo.fetchByStages(['1-morning'])).keys, unorderedEquals(['1', '2']));
      expect((await repo.fetchByStages(null)).keys, hasLength(3));
      expect((await repo.watchStage('1-morning').first).map((s) => s.fullName), ['أحمد', 'زينب']);
    });
  });

  group('Assignments + teachingStages', () {
    late AssignmentsRepository repo;
    const teacher = AppUser(email: 't@uob.iq', name: 'ت');
    final course = Course(code: 'CS3', name: 'م', stage: const StageRef(3, Shift.morning), semester: 1, units: 2, hasPractical: true);

    setUp(() async {
      repo = AssignmentsRepository(db);
      await db.doc('users/${teacher.id}').set(teacher.toMap());
    });

    test('assigning adds the stage once; removing the last link drops it', () async {
      final theory = Assignment.theory(teacherId: teacher.id, courseId: course.id, stageId: course.stageId);
      final practical = Assignment.practical(teacherId: teacher.id, courseId: course.id, stageId: course.stageId, groupName: 'A');
      await repo.assign(theory, teacher: teacher, actor: actor);
      final afterFirst = AppUser.fromMap(teacher.id, await data(db, 'users/${teacher.id}'));
      expect(afterFirst.teachingStages, ['3-morning']);
      await repo.assign(practical, teacher: afterFirst, actor: actor);

      expect((await repo.watchTeacher(teacher.id).first), hasLength(2));
      expect((await repo.watchStage('3-morning').first), hasLength(2));

      await repo.unassign(theory);
      expect(AppUser.fromMap(teacher.id, await data(db, 'users/${teacher.id}')).teachingStages, ['3-morning']);
      await repo.unassign(practical);
      expect(AppUser.fromMap(teacher.id, await data(db, 'users/${teacher.id}')).teachingStages, isEmpty);
    });

    test('admins who teach are linked without touching their user doc', () async {
      const boss = AppUser(email: 'boss@uob.iq', name: 'م', roles: {UserRole.superAdmin, UserRole.teacher});
      await db.doc('users/${boss.id}').set(boss.toMap());
      await repo.assign(Assignment.theory(teacherId: boss.id, courseId: course.id, stageId: course.stageId),
          teacher: boss, actor: actor);
      expect(AppUser.fromMap(boss.id, await data(db, 'users/${boss.id}')).teachingStages, isEmpty);
    });
  });

  group('CoursesRepository.distributeGroups', () {
    test('creates groups alphabetically; shrinking deletes extra groups and their assignments', () async {
      final repo = CoursesRepository(db);
      final course = Course(code: 'CS3', name: 'م', stage: const StageRef(3, Shift.morning), semester: 1, units: 2, hasPractical: true);
      final students = [
        for (final (i, n) in ['هدى', 'أحمد', 'زينب', 'باقر', 'حسن'].indexed)
          Student(universityId: '$i', fullName: n, stage: course.stage),
        Student(universityId: '9', fullName: 'محمّل', stage: course.stage, carryOver: true),
      ];
      await repo.distributeGroups(course: course, students: students, groupCount: 3, actor: actor);
      var groups = await repo.watchGroups(courseId: course.id, stageId: course.stageId).first;
      expect(groups.map((g) => g.name), ['A', 'B', 'C']);
      expect(groups.map((g) => g.studentIds.length), [2, 2, 1]);
      expect(groups.first.studentIds, ['1', '3']); // أحمد، باقر

      final onC = Assignment.practical(teacherId: 't@uob.iq', courseId: course.id, stageId: course.stageId, groupName: 'C');
      await db.doc('assignments/${onC.id}').set(onC.toMap());

      final removed = await repo.distributeGroups(course: course, students: students, groupCount: 2, actor: actor);
      groups = await repo.watchGroups(courseId: course.id, stageId: course.stageId).first;
      expect(groups.map((g) => g.name), ['A', 'B']);
      expect(groups.map((g) => g.studentIds.length), [3, 2]);
      expect(removed, {'t@uob.iq'});
      expect((await db.doc('assignments/${onC.id}').get()).exists, isFalse);
    });
  });

  group('AcademicRepository', () {
    test('initializes eight stages and an active year without overwriting', () async {
      final repo = AcademicRepository(db);
      await db.doc('stages/3-morning').set({'level': 3, 'shift': 'morning', 'sections': ['أ', 'ب']});
      expect((await repo.setupStatus()).missingStages, hasLength(7));

      await repo.initializeDefaults(now: DateTime(2026, 10, 4), actor: actor);
      final status = await repo.setupStatus();
      expect(status.isComplete, isTrue);
      expect((await data(db, 'stages/3-morning'))['sections'], ['أ', 'ب']);
      final year = await repo.watchActiveYear().first;
      expect(year!.id, '2026-2027');
      expect(year.semester, 1);
      expect(year.lockHours, 48);
      expect((await repo.watchStages().first), hasLength(8));
    });
  });

  test('UsersRepository watches a profile and updates the phone', () async {
    final repo = UsersRepository(db);
    expect(await repo.watch('x@uob.iq').first, isNull);
    await db.doc('users/x@uob.iq').set(const AppUser(email: 'x@uob.iq', name: 'س').toMap());
    await repo.updatePhone('X@uob.iq', ' 0770 ');
    expect((await repo.watch('x@uob.iq').first)!.phone, '0770');
  });
}
