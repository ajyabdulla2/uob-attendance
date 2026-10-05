import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uob_attendance/core/database/app_database.dart';
import 'package:uob_attendance/core/domain/stage_ref.dart';
import 'package:uob_attendance/core/firebase/doc_ids.dart';
import 'package:uob_attendance/features/academic/domain/academic_year.dart';
import 'package:uob_attendance/features/assignments/domain/assignment.dart';
import 'package:uob_attendance/features/attendance/domain/attendance_session.dart';
import 'package:uob_attendance/features/auth/domain/app_user.dart';
import 'package:uob_attendance/features/courses/domain/course.dart';
import 'package:uob_attendance/features/students/domain/student.dart';

import '../helpers/pump_app.dart';

const teacherEmail = 'teacher@uobasrah.edu.iq';
const teacher = AppUser(email: teacherEmail, name: 'أحمد', teachingStages: ['1-morning']);
const stage = StageRef(1, Shift.morning);

final course = Course(code: 'CS101', name: 'البرمجة', stage: stage, semester: 1, units: 3, hasPractical: false);
final assignment = Assignment.theory(
  teacherId: teacherEmail,
  courseId: course.id,
  stageId: stage.id,
  courseName: course.name,
);
final students = [
  Student(universityId: '1001', fullName: 'أحمد علي حسن جاسم', stage: stage),
  Student(universityId: '1002', fullName: 'بشرى كاظم عبد الله محمد', stage: stage),
  Student(universityId: '1003', fullName: 'زينب حيدر سالم كريم', stage: stage),
];

/// Firestore as the department set it up: an active year, one course with
/// three students, and the teacher's assignment.
Future<FakeFirebaseFirestore> seededFirestore() async {
  final fs = FakeFirebaseFirestore();
  const year = AcademicYear(id: '2026-2027', semester: 1, active: true);
  await fs.doc('academicYears/${year.id}').set(year.toMap());
  await fs.doc('courses/${course.id}').set(course.toMap());
  for (final s in students) {
    await fs.doc('students/${s.id}').set(s.toMap());
  }
  await fs.doc('assignments/${assignment.id}').set(assignment.toMap());
  return fs;
}

DateTime today() {
  final now = DateTime.now();
  return DateTime.utc(now.year, now.month, now.day);
}

Future<({FakeFirebaseFirestore fs, AppDatabase db})> openAsTeacher(WidgetTester tester) async {
  final fs = await seededFirestore();
  final db = AppDatabase(NativeDatabase.memory());
  await pumpApp(
    tester,
    user: MockUser(email: teacherEmail, isEmailVerified: true),
    profile: teacher,
    firestore: fs,
    localDb: db,
  );
  // The first sync downloads the teacher's classes.
  await tester.pumpAndSettle();
  return (fs: fs, db: db);
}

Finder studentTile(Student s) => find.byKey(Key('record.student.${s.id}'));

void main() {
  // Every test opens its own in-memory database.
  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  testWidgets('a teacher records a lecture offline-first and it reaches Firestore with stats', (tester) async {
    final env = await openAsTeacher(tester);
    expect(find.byKey(const Key('sync.card')), findsOneWidget);
    await tester.tap(find.byKey(Key('home.class.${assignment.id}')));
    await tester.pumpAndSettle();

    // Everyone starts present.
    expect(find.text('المحاضرة 1'), findsOneWidget);
    for (final s in students) {
      expect(studentTile(s), findsOneWidget);
    }
    expect(find.text('حاضر 3'), findsOneWidget);

    // Tap → absent; long press → late with a note.
    await tester.tap(studentTile(students[1]));
    await tester.pump();
    await tester.longPress(studentTile(students[2]));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('mark.late')));
    await tester.enterText(find.byKey(const Key('mark.note')), 'تأخر بسبب الزحام');
    await tester.tap(find.byKey(const Key('mark.done')));
    await tester.pumpAndSettle();
    expect(find.text('حاضر 1'), findsOneWidget);
    expect(find.text('غائب 1'), findsOneWidget);
    expect(find.text('متأخر 1'), findsOneWidget);

    await tester.tap(find.byKey(const Key('record.save')));
    await tester.pumpAndSettle();
    expect(find.text('حُفظ على الهاتف، ويُرفع تلقائياً عند توفّر الاتصال.'), findsOneWidget);

    // The save triggered an upload.
    final sid = DocIds.session(
      courseId: course.id,
      type: 'theory',
      target: DocIds.allSections,
      date: today(),
      lectureNo: 1,
    );
    final session = (await env.fs.doc('sessions/$sid').get()).data()!;
    expect(session['counts'], {'present': 1, 'absent': 1, 'late': 1, 'excused': 0});
    expect(session['openedBy'], teacherEmail);
    final records = await env.fs.collection('sessions/$sid/records').get();
    expect(records.docs, hasLength(3));
    expect((await env.fs.doc('sessions/$sid/records/1003').get()).data()!['note'], 'تأخر بسبب الزحام');
    expect((await env.fs.doc('stats/${course.id}__1002').get()).data()!['bySession'], {sid: 'absent'});
    expect((await env.fs.doc('stats/${course.id}__1003').get()).data()!['bySession'], {sid: 'late'});
    expect((await env.fs.doc('stats/${course.id}__1001').get()).exists, isFalse);
    expect(await env.db.oldestPendingAt(), isNull);

    // Saving again without changes queues nothing.
    await tester.tap(find.byKey(const Key('record.save')));
    await tester.pumpAndSettle();
    expect(find.text('لا تغييرات منذ آخر حفظ.'), findsOneWidget);

    // The register shows the lecture and the absence.
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('كل السجلات مرفوعة'), findsOneWidget);
    await tester.tap(find.byKey(Key('home.register.${assignment.id}')));
    await tester.pumpAndSettle();
    expect(find.byKey(Key('register.session.$sid')), findsOneWidget);
    expect(find.text(students[1].fullName), findsOneWidget);
    // 3 units × 15 weeks = 45 lectures: the one absence is 2.2% (the late
    // student stays at 0%); fetched stats/leaves are merged with this phone.
    expect(find.text('2.2%'), findsOneWidget);
    expect(find.text('0.0%'), findsNWidgets(2));

    await unmountApp(tester);
  });

  testWidgets('leaving with unsaved marks asks first; a second lecture gets the next number', (tester) async {
    final env = await openAsTeacher(tester);
    await tester.tap(find.byKey(Key('home.class.${assignment.id}')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('record.save')));
    await tester.pumpAndSettle();

    // A second lecture the same day.
    await tester.tap(find.byKey(const Key('record.newLecture')));
    await tester.pumpAndSettle();
    expect(find.text('المحاضرة 1'), findsOneWidget);
    await tester.tap(studentTile(students[0]));
    await tester.pump();

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('تجاهل التغييرات؟'), findsOneWidget);
    await tester.tap(find.text('إلغاء'));
    await tester.pumpAndSettle();
    expect(studentTile(students[0]), findsOneWidget);

    await tester.tap(find.byKey(const Key('record.save')));
    await tester.pumpAndSettle();
    expect(find.text('المحاضرة 2'), findsOneWidget);
    final second = await env.fs.collection('sessions').where('lectureNo', isEqualTo: 2).get();
    expect(second.docs.single.data()['counts'], {'present': 2, 'absent': 1, 'late': 0, 'excused': 0});

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('تجاهل التغييرات؟'), findsNothing);
    expect(find.byKey(const Key('sync.card')), findsOneWidget);

    await unmountApp(tester);
  });

  testWidgets('a lecture past its lock window opens read-only from the register', (tester) async {
    final fs = await seededFirestore();
    final old = today().subtract(const Duration(days: 10));
    final session = AttendanceSession(
      courseId: course.id,
      stageId: stage.id,
      yearId: '2026-2027',
      type: AssignmentType.theory,
      target: DocIds.allSections,
      date: old,
      lectureNo: 1,
      openedBy: 'other@uobasrah.edu.iq',
      lockAt: AttendanceSession.lockAtFor(old, 48),
      counts: const {AttendanceStatus.present: 2, AttendanceStatus.absent: 1},
    );
    await fs.doc('sessions/${session.id}').set({...session.toMap(), 'updatedAt': DateTime.now()});
    for (final s in students) {
      await fs.doc('sessions/${session.id}/records/${s.id}').set(AttendanceRecord(
        studentId: s.id,
        status: s.id == '1003' ? AttendanceStatus.absent : AttendanceStatus.present,
        updatedBy: 'other@uobasrah.edu.iq',
      ).toMap());
    }
    final db = AppDatabase(NativeDatabase.memory());
    await pumpApp(
      tester,
      user: MockUser(email: teacherEmail, isEmailVerified: true),
      profile: teacher,
      firestore: fs,
      localDb: db,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('home.register.${assignment.id}')));
    await tester.pumpAndSettle();
    expect(find.byKey(Key('register.session.${session.id}')), findsOneWidget);

    await tester.tap(find.byKey(Key('register.session.${session.id}')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('record.locked')), findsOneWidget);
    expect(find.byKey(const Key('record.save')), findsNothing);
    expect(find.text('غائب 1'), findsOneWidget);
    await tester.tap(studentTile(students[0]));
    await tester.pump();
    expect(find.text('غائب 1'), findsOneWidget);

    await unmountApp(tester);
  });

  testWidgets('a save the server refused is listed and can be removed from the phone', (tester) async {
    final fs = await seededFirestore();
    final db = AppDatabase(NativeDatabase.memory());
    final sid = '${course.id}__theory__all__20260101__1';
    await db.enqueue('$sid#1', [
      (op: OutboxOp.merge, path: 'sessions/$sid/records/1001', data: {'status': 'absent'}),
    ], now: DateTime.now());
    await db.rejectBatch('$sid#1', 'permission-denied');
    await pumpApp(
      tester,
      user: MockUser(email: teacherEmail, isEmailVerified: true),
      profile: teacher,
      firestore: fs,
      localDb: db,
    );
    await tester.pumpAndSettle();

    expect(find.text('رفض الخادم 1 عملية حفظ'), findsOneWidget);
    await tester.tap(find.byKey(const Key('sync.rejected')));
    await tester.pumpAndSettle();
    expect(find.text('permission-denied'), findsOneWidget);
    await tester.tap(find.text('حذف من الهاتف').first);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'حذف من الهاتف'));
    await tester.pumpAndSettle();
    expect(await db.oldestPendingAt(), isNull);
    expect(find.text('كل السجلات مرفوعة'), findsWidgets);

    await unmountApp(tester);
  });
}
