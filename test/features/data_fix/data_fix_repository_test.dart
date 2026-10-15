import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uob_attendance/core/domain/stage_ref.dart';
import 'package:uob_attendance/core/firebase/doc_ids.dart';
import 'package:uob_attendance/features/assignments/domain/assignment.dart';
import 'package:uob_attendance/features/attendance/domain/attendance_session.dart';
import 'package:uob_attendance/features/auth/domain/app_user.dart';
import 'package:uob_attendance/features/courses/domain/course.dart';
import 'package:uob_attendance/features/courses/domain/practical_group.dart';
import 'package:uob_attendance/features/data_fix/data/data_fix_repository.dart';
import 'package:uob_attendance/features/data_fix/domain/fix_plan.dart';
import 'package:uob_attendance/features/students/domain/student.dart';

const admin = 'admin@uobasrah.edu.iq';
const teacherEmail = 't@uobasrah.edu.iq';
const stage = StageRef(1, Shift.morning);

final course = Course(code: 'CS101', name: 'البرمجة', stage: stage, semester: 1, units: 3, hasPractical: true);
final day = DateTime.utc(2026, 10, 4);

AttendanceSession sessionOf(Assignment a, {int lectureNo = 1}) => AttendanceSession(
      courseId: a.courseId,
      stageId: a.stageId,
      yearId: '2026-2027',
      type: a.type,
      target: a.target,
      groupId: a.groupId,
      date: day,
      lectureNo: lectureNo,
      openedBy: teacherEmail,
      lockAt: AttendanceSession.lockAtFor(day, 48),
    );

Future<void> addSession(FakeFirebaseFirestore fs, AttendanceSession s, Map<String, String> statuses) async {
  await fs.doc('sessions/${s.id}').set({...s.toMap(), 'updatedAt': Timestamp.fromDate(day)});
  for (final e in statuses.entries) {
    await fs.doc('sessions/${s.id}/records/${e.key}').set({
      'studentId': e.key,
      'status': e.value,
      'note': '',
      'updatedBy': teacherEmail,
      'updatedAt': Timestamp.fromDate(day),
    });
  }
}

Future<Map<String, dynamic>?> data(FakeFirebaseFirestore fs, String path) async => (await fs.doc(path).get()).data();

Future<List<Map<String, dynamic>>> audit(FakeFirebaseFirestore fs) async =>
    [for (final d in (await fs.collection('auditLog').get()).docs) d.data()];

void main() {
  late FakeFirebaseFirestore fs;
  late DataFixRepository repo;

  setUp(() {
    fs = FakeFirebaseFirestore();
    repo = DataFixRepository(fs);
  });

  group('FixPlan.pack', () {
    List<FixWrite> item(int n, String tag) => [for (var i = 0; i < n; i++) FixWrite.delete('$tag/$i')];

    test('keeps items whole, never mixes phases, splits only oversized items', () {
      final batches = FixPlan.pack([
        [item(3, 'a'), item(3, 'b')],
        [item(2, 'c')],
        [item(9, 'd')],
      ], limit: 5);
      expect([for (final b in batches) b.length], [3, 3, 2, 5, 4]);
      expect(batches[0].every((w) => w.path.startsWith('a/')), isTrue);
      expect(batches[2].every((w) => w.path.startsWith('c/')), isTrue);
    });
  });

  group('student ID', () {
    final s1 = Student(universityId: '1001', fullName: 'أحمد علي حسن جاسم', stage: stage);
    final s2 = Student(universityId: '1002', fullName: 'بشرى كاظم عبد الله محمد', stage: stage);
    final theory = Assignment.theory(teacherId: teacherEmail, courseId: course.id, stageId: stage.id);

    Future<void> seed() async {
      await fs.doc('students/1001').set(s1.toMap());
      await fs.doc('students/1002').set(s2.toMap());
      await fs.doc('groups/${course.id}__A').set(PracticalGroup(
        courseId: course.id,
        stageId: stage.id,
        name: 'A',
        studentIds: const ['1001', '1002'],
      ).toMap());
      final s = sessionOf(theory);
      await addSession(fs, s, {'1001': 'absent', '1002': 'present'});
      await fs.doc('stats/${course.id}__1001').set({
        'courseId': course.id,
        'studentId': '1001',
        'stageId': stage.id,
        'lastSessionId': s.id,
        'bySession': {s.id: 'absent'},
      });
      await fs.collection('leaves').doc('L1').set({'studentId': '1001', 'stageId': stage.id, 'type': 'sick'});
    }

    test('moves the student, attendance, stats, groups and leaves to the new ID', () async {
      await seed();
      final plan = await repo.planStudentRename('1001', '٢٠٠١', actor: admin);
      expect(plan.problems, isEmpty);
      expect(plan.mergeInto, isNull);
      expect(plan.counts, {
        FixCount.students: 1,
        FixCount.stats: 1,
        FixCount.groups: 1,
        FixCount.leaves: 1,
        FixCount.records: 1,
      });
      await repo.apply(plan);

      final sid = sessionOf(theory).id;
      expect(await data(fs, 'students/1001'), isNull);
      final moved = (await data(fs, 'students/2001'))!;
      expect(moved['universityId'], '2001');
      expect(moved['fullName'], s1.fullName);
      expect(moved['sortKey'], isNot(s1.sortKey));
      expect((await data(fs, 'groups/${course.id}__A'))!['studentIds'], ['2001', '1002']);
      expect(await data(fs, 'stats/${course.id}__1001'), isNull);
      final stat = (await data(fs, 'stats/${course.id}__2001'))!;
      expect(stat['studentId'], '2001');
      expect(stat['bySession'], {sid: 'absent'});
      expect((await data(fs, 'leaves/L1'))!['studentId'], '2001');
      expect(await data(fs, 'sessions/$sid/records/1001'), isNull);
      final record = (await data(fs, 'sessions/$sid/records/2001'))!;
      expect(record['status'], 'absent');
      expect(record['updatedBy'], admin);
      expect((await data(fs, 'sessions/$sid/records/1002'))!['updatedBy'], teacherEmail);
      expect((await data(fs, 'sessions/$sid'))!['updatedBy'], admin);
      expect(await audit(fs), [
        containsPair('action', 'student.rename'),
      ]);
    });

    test('refuses the same, a missing or another student\'s ID; merges a duplicate of the same name', () async {
      await seed();
      expect((await repo.planStudentRename('1001', ' 1001 ', actor: admin)).problems, [FixProblem.sameId]);
      expect((await repo.planStudentRename('9999', '2001', actor: admin)).problems, [FixProblem.notFound]);
      expect((await repo.planStudentRename('', '2001', actor: admin)).problems, [FixProblem.invalidId]);
      final taken = await repo.planStudentRename('1001', '1002', actor: admin);
      expect(taken.problems, [FixProblem.targetExists]);
      expect(taken.mergeInto, s2.fullName);
      expect(taken.canApply, isFalse);

      // A re-import created the same student under the right ID.
      await fs.doc('students/2001').set(Student(universityId: '2001', fullName: s1.fullName, stage: stage).toMap());
      final merge = await repo.planStudentRename('1001', '2001', actor: admin);
      expect(merge.problems, isEmpty);
      expect(merge.mergeInto, s1.fullName);
      await repo.apply(merge);
      expect(await data(fs, 'students/1001'), isNull);
      expect((await data(fs, 'students/2001'))!['fullName'], s1.fullName);
    });
  });

  group('course code', () {
    final theory = Assignment.theory(teacherId: teacherEmail, courseId: course.id, stageId: stage.id);
    final practical =
        Assignment.practical(teacherId: teacherEmail, courseId: course.id, stageId: stage.id, groupName: 'A');

    test('moves groups, assignments, lectures with records, and re-keys the stats', () async {
      await fs.doc('courses/${course.id}').set(course.toMap());
      await fs.doc('groups/${course.id}__A').set(PracticalGroup(
        courseId: course.id,
        stageId: stage.id,
        name: 'A',
        studentIds: const ['1001'],
      ).toMap());
      await fs.doc('assignments/${theory.id}').set(theory.toMap());
      await fs.doc('assignments/${practical.id}').set(practical.toMap());
      final t = sessionOf(theory);
      final p = sessionOf(practical);
      await addSession(fs, t, {'1001': 'absent', '1002': 'present'});
      await addSession(fs, p, {'1001': 'late'});
      await fs.doc('stats/${course.id}__1001').set({
        'courseId': course.id,
        'studentId': '1001',
        'stageId': stage.id,
        'lastSessionId': p.id,
        'bySession': {t.id: 'absent', p.id: 'late'},
      });

      final plan = await repo.planCourseRename(stage.id, 'cs101', 'CS 111', actor: admin);
      expect(plan.problems, isEmpty);
      expect(plan.counts, {
        FixCount.courses: 1,
        FixCount.groups: 1,
        FixCount.assignments: 2,
        FixCount.sessions: 2,
        FixCount.records: 3,
        FixCount.stats: 1,
      });
      await repo.apply(plan);

      final to = DocIds.course('CS111', stage.id);
      expect(await data(fs, 'courses/${course.id}'), isNull);
      expect((await data(fs, 'courses/$to'))!['code'], 'CS111');
      expect((await data(fs, 'groups/${to}__A'))!['courseId'], to);
      expect(await data(fs, 'groups/${course.id}__A'), isNull);
      final movedPractical = (await data(fs, 'assignments/${to}__practical__A__$teacherEmail'))!;
      expect(movedPractical['courseId'], to);
      expect(movedPractical['groupId'], '${to}__A');
      expect(await data(fs, 'assignments/${to}__theory__all__$teacherEmail'), isNotNull);
      expect((await fs.collection('assignments').where('courseId', isEqualTo: course.id).get()).docs, isEmpty);

      final newT = '$to${t.id.substring(course.id.length)}';
      final newP = '$to${p.id.substring(course.id.length)}';
      expect((await data(fs, 'sessions/$newT'))!['courseId'], to);
      expect((await data(fs, 'sessions/$newP'))!['groupId'], '${to}__A');
      expect((await data(fs, 'sessions/$newT/records/1001'))!['status'], 'absent');
      expect((await data(fs, 'sessions/$newT/records/1002'))!['status'], 'present');
      expect(await data(fs, 'sessions/${t.id}'), isNull);
      expect(await data(fs, 'sessions/${t.id}/records/1001'), isNull);

      final stat = (await data(fs, 'stats/${to}__1001'))!;
      expect(stat['courseId'], to);
      expect(stat['lastSessionId'], newP);
      expect(stat['bySession'], {newT: 'absent', newP: 'late'});
      expect(await data(fs, 'stats/${course.id}__1001'), isNull);
      expect(await audit(fs), [containsPair('action', 'course.rename')]);
    });

    test('refuses a code used by another course', () async {
      await fs.doc('courses/${course.id}').set(course.toMap());
      final other = Course(code: 'CS102', name: 'هياكل البيانات', stage: stage, semester: 1, units: 3, hasPractical: false);
      await fs.doc('courses/${other.id}').set(other.toMap());
      final plan = await repo.planCourseRename(stage.id, 'CS101', 'CS102', actor: admin);
      expect(plan.problems, [FixProblem.targetExists]);
      expect(plan.mergeInto, 'هياكل البيانات');
      expect((await repo.planCourseRename(stage.id, 'CS999', 'CS102', actor: admin)).problems, [FixProblem.notFound]);
    });
  });

  group('teacher e-mail', () {
    test('moves the account and its classes; removes the satisfied join request', () async {
      const fake = 'generated1@uobasrah.edu.iq';
      const real = 'real.name@gmail.com';
      await fs.doc('users/$fake').set(const AppUser(
        email: fake,
        name: 'زيد',
        teachingStages: ['1-morning'],
      ).toMap());
      final a = Assignment.theory(teacherId: fake, courseId: course.id, stageId: stage.id);
      await fs.doc('assignments/${a.id}').set(a.toMap());
      await fs.doc('accessRequests/$real').set({'email': real, 'name': 'زيد', 'note': ''});

      final plan = await repo.planTeacherRename(fake, ' Real.Name@Gmail.com ', actor: admin);
      expect(plan.problems, isEmpty);
      expect(plan.counts, {FixCount.users: 1, FixCount.assignments: 1});
      await repo.apply(plan);

      expect(await data(fs, 'users/$fake'), isNull);
      final user = (await data(fs, 'users/$real'))!;
      expect(user['email'], real);
      expect(user['teachingStages'], ['1-morning']);
      expect((await data(fs, 'assignments/${course.id}__theory__all__$real'))!['teacherId'], real);
      expect(await data(fs, 'assignments/${a.id}'), isNull);
      expect(await data(fs, 'accessRequests/$real'), isNull);
      expect(await audit(fs), [containsPair('action', 'user.rename')]);
    });

    test('never renames the signed-in admin; validates e-mails', () async {
      await fs.doc('users/$admin').set(const AppUser(email: admin, name: 'المدير', roles: {UserRole.superAdmin}).toMap());
      expect((await repo.planTeacherRename(admin, 'x@y.iq', actor: admin)).problems, [FixProblem.ownAccount]);
      expect((await repo.planTeacherRename('nope', 'x@y.iq', actor: admin)).problems, [FixProblem.invalidId]);
      expect((await repo.planTeacherRename('a@b.iq', 'x@y.iq', actor: admin)).problems, [FixProblem.notFound]);
    });
  });

  group('deleting teacher accounts', () {
    const wrong1 = 'wrong1@uobasrah.edu.iq';
    const wrong2 = 'wrong2@uobasrah.edu.iq';
    const active = 'active@uobasrah.edu.iq';
    const manager = 'manager@uobasrah.edu.iq';

    Future<void> seed() async {
      await fs.doc('users/$admin').set(const AppUser(email: admin, name: 'المدير', roles: {UserRole.superAdmin, UserRole.teacher}).toMap());
      for (final e in [wrong1, wrong2, active]) {
        await fs.doc('users/$e').set(AppUser(email: e, name: e, teachingStages: const ['1-morning']).toMap());
      }
      await fs.doc('users/$manager').set(const AppUser(
        email: manager,
        name: 'مسؤول',
        roles: {UserRole.stageManager, UserRole.teacher},
        stageScopes: ['1-morning'],
      ).toMap());
      for (final e in [wrong1, active]) {
        final a = Assignment.theory(teacherId: e, courseId: course.id, stageId: stage.id);
        await fs.doc('assignments/${a.id}').set(a.toMap());
      }
      final recorded = Assignment.theory(teacherId: active, courseId: course.id, stageId: stage.id);
      await fs.doc('sessions/x').set({...sessionOf(recorded).toMap(), 'openedBy': active, 'updatedBy': active});
    }

    test('without an e-mail: plain teachers who never recorded, with their links', () async {
      await seed();
      final plan = await repo.planTeacherDeletion(actor: admin);
      expect(plan.counts, {FixCount.users: 2, FixCount.assignments: 1, FixCount.kept: 1});
      await repo.apply(plan);
      expect(await data(fs, 'users/$wrong1'), isNull);
      expect(await data(fs, 'users/$wrong2'), isNull);
      expect(await data(fs, 'assignments/${course.id}__theory__all__$wrong1'), isNull);
      // Kept: recorded lectures, a stage manager, the admin.
      expect(await data(fs, 'users/$active'), isNotNull);
      expect(await data(fs, 'assignments/${course.id}__theory__all__$active'), isNotNull);
      expect(await data(fs, 'users/$manager'), isNotNull);
      expect(await data(fs, 'users/$admin'), isNotNull);
      expect(await audit(fs), [containsPair('action', 'users.delete')]);
    });

    test('one e-mail: refused when it recorded lectures, for oneself, or when missing', () async {
      await seed();
      final one = await repo.planTeacherDeletion(onlyEmail: ' Wrong1@UOBasrah.edu.iq ', actor: admin);
      expect(one.counts, {FixCount.users: 1, FixCount.assignments: 1, FixCount.kept: 0});
      expect((await repo.planTeacherDeletion(onlyEmail: active, actor: admin)).problems, [FixProblem.hasHistory]);
      expect((await repo.planTeacherDeletion(onlyEmail: admin, actor: admin)).problems, [FixProblem.ownAccount]);
      expect((await repo.planTeacherDeletion(onlyEmail: 'no@x.iq', actor: admin)).problems, [FixProblem.notFound]);
      // A stage manager or admin can be removed one by one (super admin).
      expect((await repo.planTeacherDeletion(onlyEmail: manager, actor: admin)).problems, isEmpty);
    });
  });

  group('undo a wrong import', () {
    test('deletes only students without attendance, stats or leaves', () async {
      for (final id in ['1001', '1002', '1003', '1004']) {
        await fs.doc('students/$id').set(Student(universityId: id, fullName: 'طالب $id', stage: stage).toMap());
      }
      await fs.doc('students/2001').set(
          Student(universityId: '2001', fullName: 'طالب آخر', stage: const StageRef(2, Shift.morning)).toMap());
      final theory = Assignment.theory(teacherId: teacherEmail, courseId: course.id, stageId: stage.id);
      await addSession(fs, sessionOf(theory), {'1001': 'present'});
      await fs.doc('stats/${course.id}__1002').set({'courseId': course.id, 'studentId': '1002', 'stageId': stage.id});
      await fs.collection('leaves').add({'studentId': '1003', 'stageId': stage.id});
      await fs.doc('groups/${course.id}__A').set(PracticalGroup(
        courseId: course.id,
        stageId: stage.id,
        name: 'A',
        studentIds: const ['1001', '1004'],
      ).toMap());

      final plan = await repo.planStudentDeletion(stage.id, actor: admin);
      expect(plan.counts, {FixCount.students: 1, FixCount.groups: 1, FixCount.kept: 3});
      await repo.apply(plan);
      expect(await data(fs, 'students/1004'), isNull);
      for (final id in ['1001', '1002', '1003', '2001']) {
        expect(await data(fs, 'students/$id'), isNotNull, reason: id);
      }
      expect((await data(fs, 'groups/${course.id}__A'))!['studentIds'], ['1001']);
      expect(await audit(fs), [containsPair('action', 'students.delete')]);

      expect((await repo.planStudentDeletion(stage.id, onlyId: '1001', actor: admin)).problems,
          [FixProblem.nothingToDelete]);
      expect((await repo.planStudentDeletion(stage.id, onlyId: '2001', actor: admin)).problems,
          [FixProblem.notFound]);
    });

    test('deletes courses never taught, with their groups and links; teachers keep only stages they teach', () async {
      final taught = Course(code: 'CS102', name: 'هياكل', stage: stage, semester: 1, units: 2, hasPractical: false);
      await fs.doc('courses/${course.id}').set(course.toMap());
      await fs.doc('courses/${taught.id}').set(taught.toMap());
      await fs.doc('groups/${course.id}__A').set(
          PracticalGroup(courseId: course.id, stageId: stage.id, name: 'A', studentIds: const []).toMap());
      final a = Assignment.practical(teacherId: teacherEmail, courseId: course.id, stageId: stage.id, groupName: 'A');
      await fs.doc('assignments/${a.id}').set(a.toMap());
      await fs.doc('users/$teacherEmail').set(const AppUser(
        email: teacherEmail,
        name: 'أستاذ',
        teachingStages: ['1-morning', '2-morning'],
      ).toMap());
      final other = Assignment.theory(teacherId: 'b@uobasrah.edu.iq', courseId: taught.id, stageId: stage.id);
      await addSession(fs, sessionOf(other), {'1001': 'present'});

      final plan = await repo.planCourseDeletion(stage.id, actor: admin);
      expect(plan.counts, {FixCount.courses: 1, FixCount.groups: 1, FixCount.assignments: 1, FixCount.kept: 1});
      await repo.apply(plan);
      expect(await data(fs, 'courses/${course.id}'), isNull);
      expect(await data(fs, 'courses/${taught.id}'), isNotNull);
      expect(await data(fs, 'groups/${course.id}__A'), isNull);
      expect(await data(fs, 'assignments/${a.id}'), isNull);
      expect((await data(fs, 'users/$teacherEmail'))!['teachingStages'], ['2-morning']);
    });
  });

  group('deleting lectures of trial days', () {
    final theory = Assignment.theory(teacherId: teacherEmail, courseId: course.id, stageId: stage.id);
    AttendanceSession on(DateTime date, {int no = 1}) => AttendanceSession(
          courseId: course.id,
          stageId: stage.id,
          yearId: '2026-2027',
          type: AssignmentType.theory,
          target: 'all',
          date: date,
          lectureNo: no,
          openedBy: teacherEmail,
          lockAt: AttendanceSession.lockAtFor(date, 48),
        );

    test('deletes the days\' lectures, their records, stats entries and pending requests', () async {
      final d1 = on(DateTime.utc(2026, 10, 1));
      final d2 = on(DateTime.utc(2026, 10, 2), no: 2);
      final keep = on(DateTime.utc(2026, 10, 5));
      for (final s in [d1, d2, keep]) {
        await addSession(fs, s, {'1': 'absent', '2': 'present'});
      }
      await fs.doc('stats/${course.id}__1').set({
        'courseId': course.id,
        'studentId': '1',
        'stageId': stage.id,
        'bySession': {d1.id: 'absent', d2.id: 'absent', keep.id: 'absent'},
      });
      await fs.doc('stats/${course.id}__2').set({
        'courseId': course.id,
        'studentId': '2',
        'stageId': stage.id,
        'bySession': {keep.id: 'late'},
      });
      await fs.doc('editRequests/r1').set({'sessionId': d1.id, 'stageId': stage.id, 'status': 'pending'});
      await fs.doc('editRequests/r2').set({'sessionId': keep.id, 'stageId': stage.id, 'status': 'pending'});

      final plan = await repo.planLectureDeletion(DateTime(2026, 10, 1), DateTime(2026, 10, 2),
          actor: admin, rejectNote: 'حُذفت');
      expect(plan.canApply, isTrue);
      expect(plan.sessionIds, [d1.id, d2.id]);
      expect(plan.counts[FixCount.sessions], 2);
      expect(plan.counts[FixCount.records], 4);
      expect(plan.counts[FixCount.stats], 1);
      await repo.apply(plan);

      expect(await data(fs, 'sessions/${d1.id}'), isNull);
      expect(await data(fs, 'sessions/${d2.id}/records/1'), isNull);
      expect(await data(fs, 'sessions/${keep.id}'), isNotNull);
      expect((await data(fs, 'stats/${course.id}__1'))!['bySession'], {keep.id: 'absent'});
      expect((await data(fs, 'stats/${course.id}__2'))!['bySession'], {keep.id: 'late'});
      expect((await data(fs, 'editRequests/r1'))!['status'], 'rejected');
      expect((await data(fs, 'editRequests/r1'))!['decisionNote'], 'حُذفت');
      expect((await data(fs, 'editRequests/r2'))!['status'], 'pending');
      expect((await audit(fs)).single['action'], 'sessions.delete');

      // Running it again finds nothing left.
      final again = await repo.planLectureDeletion(DateTime(2026, 10, 1), DateTime(2026, 10, 2),
          actor: admin, rejectNote: 'حُذفت');
      expect(again.problems, [FixProblem.nothingToDelete]);
      expect(theory.courseId, course.id);
    });

    test('one stage only', () async {
      final here = on(DateTime.utc(2026, 10, 1));
      final other = AttendanceSession(
        courseId: 'CS201_2-morning',
        stageId: '2-morning',
        yearId: '2026-2027',
        type: AssignmentType.theory,
        target: 'all',
        date: DateTime.utc(2026, 10, 1),
        lectureNo: 1,
        openedBy: teacherEmail,
        lockAt: AttendanceSession.lockAtFor(DateTime.utc(2026, 10, 1), 48),
      );
      await addSession(fs, here, {'1': 'present'});
      await addSession(fs, other, {'9': 'present'});
      final plan = await repo.planLectureDeletion(DateTime(2026, 10, 1), DateTime(2026, 10, 1),
          stageId: '2-morning', actor: admin, rejectNote: '');
      expect(plan.sessionIds, [other.id]);
    });

    test('one lecture by ID, even when its stored date does not match', () async {
      final s = on(DateTime.utc(2026, 10, 5));
      await addSession(fs, s, {'1': 'absent'});
      // An older copy written with another day key (e.g. a time-zone shift).
      await fs.doc('sessions/${s.id}').update({'dateKey': '20261004'});
      final plan = await repo.planLectureDeletion(DateTime.utc(2026, 10, 5), DateTime.utc(2026, 10, 5),
          stageId: stage.id, courseId: course.id, onlySessionIds: {s.id}, actor: admin, rejectNote: '');
      expect(plan.sessionIds, [s.id]);
      await repo.apply(plan);
      expect(await data(fs, 'sessions/${s.id}'), isNull);

      final missing = await repo.planLectureDeletion(DateTime.utc(2026, 10, 5), DateTime.utc(2026, 10, 5),
          onlySessionIds: {s.id}, actor: admin, rejectNote: '');
      expect(missing.canApply, isFalse);
    });

    test('one course only: other courses of the same day stay', () async {
      final mine = on(DateTime.utc(2026, 10, 1));
      final otherCourse = AttendanceSession(
        courseId: 'CS102_1-morning',
        stageId: stage.id,
        yearId: '2026-2027',
        type: AssignmentType.theory,
        target: 'all',
        date: DateTime.utc(2026, 10, 1),
        lectureNo: 1,
        openedBy: teacherEmail,
        lockAt: AttendanceSession.lockAtFor(DateTime.utc(2026, 10, 1), 48),
      );
      await addSession(fs, mine, {'1': 'absent'});
      await addSession(fs, otherCourse, {'1': 'absent'});
      final plan = await repo.planLectureDeletion(DateTime(2026, 10, 1), DateTime(2026, 10, 1),
          stageId: stage.id, courseId: course.id, actor: admin, rejectNote: '');
      expect(plan.sessionIds, [mine.id]);
      await repo.apply(plan);
      expect(await data(fs, 'sessions/${otherCourse.id}'), isNotNull);
      expect((await audit(fs)).single['before']['courseId'], course.id);
    });
  });
}
