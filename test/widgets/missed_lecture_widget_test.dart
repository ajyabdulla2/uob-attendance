import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:uob_attendance/core/domain/stage_ref.dart';
import 'package:uob_attendance/core/firebase/doc_ids.dart';
import 'package:uob_attendance/core/router/app_router.dart';
import 'package:uob_attendance/features/academic/domain/academic_year.dart';
import 'package:uob_attendance/features/assignments/domain/assignment.dart';
import 'package:uob_attendance/features/attendance/domain/attendance_session.dart';
import 'package:uob_attendance/features/attendance/presentation/missed_lecture_screen.dart';
import 'package:uob_attendance/features/auth/domain/app_user.dart';
import 'package:uob_attendance/features/courses/domain/course.dart';
import 'package:uob_attendance/features/students/domain/student.dart';

import '../helpers/pump_app.dart';

void main() {
  const sm = 'sm@uobasrah.edu.iq';
  const teacher = 't@uobasrah.edu.iq';
  const stage = StageRef(1, Shift.morning);
  final smProfile = AppUser(email: sm, name: 'مسؤول', roles: const {UserRole.stageManager}, stageScopes: [stage.id]);
  final course = Course(code: 'CS101', name: 'البرمجة', stage: stage, semester: 1, units: 3, hasPractical: false);
  final cls = Assignment.theory(teacherId: teacher, courseId: course.id, stageId: stage.id, courseName: course.name);
  final now = DateTime.now();
  final day = DateTime.utc(now.year, now.month, now.day).subtract(const Duration(days: 10));

  Future<FakeFirebaseFirestore> seed() async {
    final db = FakeFirebaseFirestore();
    await db.doc('academicYears/2026-2027').set(const AcademicYear(id: '2026-2027', semester: 1, active: true).toMap());
    await db.doc('courses/${course.id}').set(course.toMap());
    await db.doc('students/1').set(Student(universityId: '1', fullName: 'أحمد علي حسين جاسم', stage: stage).toMap());
    await db.doc('students/2').set(Student(universityId: '2', fullName: 'زينب صالح مهدي حسن', stage: stage).toMap());
    await db.doc('assignments/${cls.id}').set(cls.toMap());
    // The teacher recorded lecture 1 that day; the missed one becomes 2.
    final first = AttendanceSession(
      courseId: course.id,
      stageId: stage.id,
      yearId: '2026-2027',
      type: AssignmentType.theory,
      target: DocIds.allSections,
      date: day,
      lectureNo: 1,
      openedBy: teacher,
      lockAt: AttendanceSession.lockAtFor(day, 48),
    );
    await db.doc('sessions/${first.id}').set(first.toMap());
    return db;
  }

  testWidgets('the dashboard opens it; an idle class opens it on that class', (tester) async {
    await pumpApp(tester, firestore: await seed(), user: MockUser(email: sm, isEmailVerified: true), profile: smProfile);
    await tester.tap(find.byKey(const Key('home.dashboard')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('dash.missed')), findsOneWidget);

    await tester.tap(find.byKey(Key('dash.idle.${cls.id}')));
    await tester.pumpAndSettle();
    expect(find.text('تسجيل محاضرة فائتة'), findsWidgets);
    expect(find.text('البرمجة · نظري · كل الشعب'), findsOneWidget);
  });

  testWidgets('a stage manager records a missed lecture: session, records, stats and audit', (tester) async {
    final env = await pumpApp(tester, firestore: await seed(), user: MockUser(email: sm, isEmailVerified: true), profile: smProfile);
    GoRouter.of(tester.element(find.byType(Scaffold).first))
        .push(Routes.missedLectureFor(stageId: stage.id, classKey: classKeyOf(cls), date: day));
    await tester.pumpAndSettle();

    expect(find.text('ستُحفظ المحاضرة رقم 2 لهذا الصف في هذا اليوم.'), findsOneWidget);
    // Tap → absent; twice → late.
    for (final id in ['1', '2', '2']) {
      await tester.tap(find.byKey(Key('missed.student.$id')));
      await tester.pump();
    }
    expect(find.text('غائب 1'), findsOneWidget);
    expect(find.text('متأخر 1'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('missed.save')));
    await tester.tap(find.byKey(const Key('missed.save')));
    await tester.pumpAndSettle();
    await tester.tap(find.descendant(of: find.byType(AlertDialog), matching: find.text('حفظ المحاضرة')));
    await tester.pumpAndSettle();
    expect(find.text('حُفظت المحاضرة.'), findsOneWidget);

    final sid = DocIds.session(courseId: course.id, type: 'theory', target: DocIds.allSections, date: day, lectureNo: 2);
    final session = (await env.db.doc('sessions/$sid').get()).data()!;
    expect(session['openedBy'], sm);
    expect(session['lectureNo'], 2);
    expect(session['counts'], {'present': 0, 'absent': 1, 'late': 1, 'excused': 0});
    expect((await env.db.doc('sessions/$sid/records/1').get()).data()!['status'], 'absent');
    expect((await env.db.doc('sessions/$sid/records/2').get()).data()!['status'], 'late');
    expect((await env.db.doc('stats/${course.id}__1').get()).data()!['bySession'], {sid: 'absent'});
    expect((await env.db.doc('stats/${course.id}__2').get()).data()!['bySession'], {sid: 'late'});
    final audit = await env.db.collection('auditLog').where('action', isEqualTo: 'session.missed').get();
    expect(audit.docs.single.data()['actor'], sm);
  });

  testWidgets('teachers cannot open it', (tester) async {
    await pumpApp(
      tester,
      firestore: await seed(),
      user: MockUser(email: teacher, isEmailVerified: true),
      profile: AppUser(email: teacher, name: 'تدريسي', teachingStages: [stage.id]),
    );
    GoRouter.of(tester.element(find.byType(Scaffold).first)).go(Routes.missedLecture);
    await tester.pumpAndSettle();
    expect(find.text('تسجيل محاضرة فائتة'), findsNothing);
  });
}
