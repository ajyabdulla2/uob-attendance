import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uob_attendance/core/domain/stage_ref.dart';
import 'package:uob_attendance/core/firebase/doc_ids.dart';
import 'package:uob_attendance/features/academic/domain/academic_year.dart';
import 'package:uob_attendance/features/assignments/domain/assignment.dart';
import 'package:uob_attendance/features/attendance/domain/attendance_session.dart';
import 'package:uob_attendance/features/auth/domain/app_user.dart';
import 'package:uob_attendance/features/courses/domain/course.dart';
import 'package:uob_attendance/features/edit_requests/domain/edit_request.dart';
import 'package:uob_attendance/features/students/domain/student.dart';

import '../helpers/pump_app.dart';

void main() {
  const sm = 'sm@uobasrah.edu.iq';
  const teacher = 't@uobasrah.edu.iq';
  const stage = StageRef(1, Shift.morning);
  final course = Course(code: 'CS101', name: 'البرمجة', stage: stage, semester: 1, units: 3, hasPractical: false);
  final day = DateTime.utc(2026, 9, 28);
  final session = AttendanceSession(
    courseId: course.id,
    stageId: stage.id,
    yearId: '2026-2027',
    type: AssignmentType.theory,
    target: DocIds.allSections,
    date: day,
    lectureNo: 1,
    openedBy: teacher,
    lockAt: AttendanceSession.lockAtFor(day, 48),
    counts: const {AttendanceStatus.present: 1, AttendanceStatus.absent: 1},
  );

  Future<FakeFirebaseFirestore> seed() async {
    final db = FakeFirebaseFirestore();
    await db.doc('academicYears/2026-2027').set(const AcademicYear(id: '2026-2027', semester: 1, active: true).toMap());
    await db.doc('courses/${course.id}').set(course.toMap());
    await db.doc('students/1').set(Student(universityId: '1', fullName: 'أحمد علي حسين جاسم', stage: stage).toMap());
    await db.doc('students/2').set(Student(universityId: '2', fullName: 'زينب صالح مهدي حسن', stage: stage).toMap());
    await db.doc('sessions/${session.id}').set(session.toMap());
    await db.doc('sessions/${session.id}/records/1').set({'studentId': '1', 'status': 'present'});
    await db.doc('sessions/${session.id}/records/2').set({'studentId': '2', 'status': 'absent'});
    await db.doc('stats/${course.id}__2').set({
      'courseId': course.id,
      'studentId': '2',
      'stageId': stage.id,
      'bySession': {session.id: 'absent'},
    });
    await db.doc('editRequests/r1').set(EditRequest(
      id: 'r1',
      sessionId: session.id,
      studentId: '2',
      stageId: stage.id,
      requestedStatus: AttendanceStatus.excused,
      currentStatus: AttendanceStatus.absent,
      reason: 'لديها تقرير طبي',
      requestedBy: teacher,
    ).toMap());
    return db;
  }

  testWidgets('the stage manager approves: record, stats and the lecture change together', (tester) async {
    final db = await seed();
    await pumpApp(
      tester,
      firestore: db,
      user: MockUser(email: sm, isEmailVerified: true),
      profile: AppUser(email: sm, name: 'مسؤول', roles: const {UserRole.stageManager}, stageScopes: [stage.id]),
    );
    await tester.tap(find.byKey(const Key('home.dashboard')));
    await tester.pumpAndSettle();
    expect(find.text('طلبات تعديل معلّقة: 1'), findsOneWidget);
    expect(find.text('محاضرات مسجّلة اليوم: 0'), findsOneWidget);
    await tester.tap(find.byKey(const Key('dash.requests')));
    await tester.pumpAndSettle();

    expect(find.text('زينب صالح مهدي حسن'), findsOneWidget);
    expect(find.text('السبب: لديها تقرير طبي'), findsOneWidget);
    expect(find.textContaining('البرمجة'), findsOneWidget);
    await tester.tap(find.byKey(const Key('request.approve.r1')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('request.note')), 'التقرير مرفق بالبريد');
    await tester.tap(find.byKey(const Key('request.confirm')));
    await tester.pumpAndSettle();

    expect(find.text('لا طلبات معلّقة.'), findsOneWidget);
    final record = (await db.doc('sessions/${session.id}/records/2').get()).data()!;
    expect(record['status'], 'excused');
    expect(record['updatedBy'], sm);
    final s = (await db.doc('sessions/${session.id}').get()).data()!;
    expect(s['counts'], {'present': 1, 'absent': 0, 'late': 0, 'excused': 1});
    expect(s['updatedBy'], sm);
    expect(((await db.doc('stats/${course.id}__2').get()).data()!['bySession'] as Map)[session.id], 'excused');
    final r = EditRequest.fromMap('r1', (await db.doc('editRequests/r1').get()).data()!);
    expect(r.status, EditRequestStatus.approved);
    expect(r.decidedBy, sm);
    expect(r.decisionNote, 'التقرير مرفق بالبريد');
    final audit = (await db.collection('auditLog').get()).docs.single.data();
    expect(audit['action'], 'record.update');
    expect((audit['before'] as Map)['status'], 'absent');
  });

  testWidgets('a rejection leaves the record as it was', (tester) async {
    final db = await seed();
    await pumpApp(
      tester,
      firestore: db,
      user: MockUser(email: sm, isEmailVerified: true),
      profile: AppUser(email: sm, name: 'مسؤول', roles: const {UserRole.stageManager}, stageScopes: [stage.id]),
    );
    await tester.tap(find.byKey(const Key('home.requests')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('request.reject.r1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('request.confirm')));
    await tester.pumpAndSettle();
    expect((await db.doc('sessions/${session.id}/records/2').get()).data()!['status'], 'absent');
    expect((await db.doc('editRequests/r1').get()).data()!['status'], 'rejected');
  });
}
