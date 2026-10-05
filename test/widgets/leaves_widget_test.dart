import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uob_attendance/core/domain/stage_ref.dart';
import 'package:uob_attendance/features/auth/domain/app_user.dart';
import 'package:uob_attendance/features/leaves/data/leaves_repository.dart';
import 'package:uob_attendance/features/leaves/domain/leave.dart';
import 'package:uob_attendance/features/students/domain/student.dart';

import '../helpers/pump_app.dart';

void main() {
  const sm = 'sm@uobasrah.edu.iq';
  const stage = StageRef(3, Shift.morning);
  final student = Student(universityId: '1001', fullName: 'زينب صالح مهدي حسن', stage: stage);
  Leave leave({String id = ''}) => Leave(
        id: id,
        studentId: '1001',
        stageId: stage.id,
        type: LeaveType.sick,
        from: DateTime.utc(2026, 10, 4),
        to: DateTime.utc(2026, 10, 6),
        referenceNo: '55/ط',
      );

  test('a leave is approved by whoever enters it, with an audit entry', () async {
    final db = FakeFirebaseFirestore();
    await LeavesRepository(db).add(leave(), actor: sm);
    final saved = (await db.collection('leaves').get()).docs.single;
    final l = Leave.fromMap(saved.id, saved.data());
    expect(l.isApproved, isTrue);
    expect(l.approvedBy, sm);
    expect(l.days, 3);
    final audit = (await db.collection('auditLog').get()).docs.single.data();
    expect(audit['action'], 'leave.create');
    expect(audit['stageId'], stage.id);
  });

  testWidgets('a stage manager sees the stage\'s leaves and deletes one', (tester) async {
    final db = FakeFirebaseFirestore();
    await db.doc('students/1001').set(student.toMap());
    await db.doc('leaves/l1').set({...leave().toMap(), 'approvedBy': sm});
    await pumpApp(
      tester,
      firestore: db,
      user: MockUser(email: sm, isEmailVerified: true),
      profile: AppUser(email: sm, name: 'مسؤول', roles: const {UserRole.stageManager}, stageScopes: [stage.id]),
    );
    await tester.tap(find.byKey(const Key('home.leaves')));
    await tester.pumpAndSettle();

    expect(find.text('زينب صالح مهدي حسن'), findsOneWidget);
    expect(find.textContaining('مرضية · 3 يوم'), findsOneWidget);
    await tester.tap(find.byTooltip('حذف'));
    await tester.pumpAndSettle();
    await tester.tap(find.descendant(of: find.byType(AlertDialog), matching: find.byType(FilledButton)));
    await tester.pumpAndSettle();

    expect((await db.collection('leaves').get()).docs, isEmpty);
    expect((await db.collection('auditLog').get()).docs.single.data()['action'], 'leave.delete');
    expect(find.text('لا إجازات في هذه المرحلة.'), findsOneWidget);

    // Adding: pick the student by name in the dialog (the date range picker
    // is Material's own).
    await tester.tap(find.byKey(const Key('leaves.add')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('leave.student')), 'زينب');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('leave.pick.1001')));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(InputChip, 'زينب صالح مهدي حسن'), findsOneWidget);
    final save = tester.widget<FilledButton>(find.byKey(const Key('leave.save')));
    expect(save.onPressed, isNull, reason: 'no period picked yet');
  });
}
