import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uob_attendance/core/domain/stage_ref.dart';
import 'package:uob_attendance/features/auth/domain/app_user.dart';
import 'package:uob_attendance/features/courses/domain/course.dart';
import 'package:uob_attendance/features/department/application/department_providers.dart';
import 'package:uob_attendance/features/students/domain/student.dart';

import '../helpers/pump_app.dart';

void main() {
  const stage = StageRef(1, Shift.morning);
  const other = StageRef(2, Shift.evening);
  const sm = 'sm@uobasrah.edu.iq';
  final admin = AppUser(email: adminEmail, name: 'المدير', roles: const {UserRole.superAdmin});
  final course = Course(code: 'CS101', name: 'البرمجة', stage: stage, semester: 1, units: 3, hasPractical: false);

  Future<FakeFirebaseFirestore> seed() async {
    final db = FakeFirebaseFirestore();
    await db.doc('courses/${course.id}').set(course.toMap());
    await db.doc('students/1').set(Student(universityId: '1', fullName: 'أحمد علي حسين جاسم', stage: stage).toMap());
    await db.doc('students/2').set(Student(universityId: '2', fullName: 'زينب صالح مهدي حسن', stage: stage).toMap());
    await db.doc('editRequests/r1').set({'stageId': stage.id, 'status': 'pending'});
    await db.doc('editRequests/r2').set({'stageId': stage.id, 'status': 'approved'});
    await db.doc('accessRequests/x@uob.iq').set({'email': 'x@uob.iq', 'name': 'س'});
    await db.doc('auditLog/a1').set({
      'actor': adminEmail,
      'action': 'year.update',
      'targetPath': 'academicYears/2026-2027',
      'stageId': null,
      'at': Timestamp.fromDate(DateTime.utc(2026, 10, 1)),
    });
    await db.doc('auditLog/a2').set({
      'actor': sm,
      'action': 'leave.create',
      'targetPath': 'leaves/l1',
      'stageId': stage.id,
      'after': {'studentId': '2'},
      'at': Timestamp.fromDate(DateTime.utc(2026, 10, 2)),
    });
    await db.doc('auditLog/a3').set({
      'actor': adminEmail,
      'action': 'something.new',
      'targetPath': 'x/y',
      'stageId': other.id,
      'at': Timestamp.fromDate(DateTime.utc(2026, 10, 3)),
    });
    return db;
  }

  testWidgets('admins get the backup reminder and the department dashboard', (tester) async {
    await pumpApp(tester, firestore: await seed(), user: MockUser(email: adminEmail, isEmailVerified: true), profile: admin);
    expect(find.byKey(const Key('backup.reminder')), findsOneWidget);
    expect(find.text('لم تُحفظ نسخة احتياطية بعد.'), findsOneWidget);

    await tester.scrollUntilVisible(find.byKey(const Key('home.department')), 200);
    await tester.tap(find.byKey(const Key('home.department')));
    await tester.pumpAndSettle();
    expect(find.text('طلبات الانضمام المعلّقة: 1'), findsOneWidget);
    final card = find.byKey(Key('dept.stage.${stage.id}'));
    expect(find.descendant(of: card, matching: find.text('2 طالب')), findsOneWidget);
    expect(find.descendant(of: card, matching: find.text('1 مادة')), findsOneWidget);
    expect(find.descendant(of: card, matching: find.text('طلبات تعديل: 1')), findsOneWidget);
    expect(find.descendant(of: find.byKey(Key('dept.stage.${other.id}')), matching: find.text('لا بيانات بعد.')),
        findsOneWidget);
  });

  testWidgets('a recent backup silences the home reminder', (tester) async {
    final db = await seed();
    await db.doc('config/backup').set({'at': Timestamp.now(), 'by': adminEmail, 'documents': 10, 'withRecords': true});
    await pumpApp(tester, firestore: db, user: MockUser(email: adminEmail, isEmailVerified: true), profile: admin);
    expect(find.byKey(const Key('backup.reminder')), findsNothing);
  });

  test('backup is due after a week or when there is none', () {
    final now = DateTime(2026, 10, 7);
    expect(backupIsDue(null, now), isTrue);
    expect(backupIsDue(DateTime(2026, 10, 1), now), isFalse);
    expect(backupIsDue(DateTime(2026, 9, 29), now), isTrue);
  });

  testWidgets('backup screen: size estimate and password checks', (tester) async {
    await pumpApp(tester, firestore: await seed(), user: MockUser(email: adminEmail, isEmailVerified: true), profile: admin);
    await tester.scrollUntilVisible(find.byKey(const Key('home.backup')), 200);
    await tester.tap(find.byKey(const Key('home.backup')));
    await tester.pumpAndSettle();
    expect(find.text('الاستعادة من نسخة'), findsOneWidget); // super admin

    await tester.tap(find.byKey(const Key('backup.count')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('backup.estimate')), findsOneWidget);
    expect(find.text('تضمين سجلات الحضور التفصيلية (0)'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('backup.password')), 'short');
    await tester.tap(find.byKey(const Key('backup.create')));
    await tester.pump();
    expect(find.text('كلمة المرور 8 أحرف على الأقل.'), findsOneWidget);
    ScaffoldMessenger.of(tester.element(find.byKey(const Key('backup.create')))).clearSnackBars();
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('backup.password')), 'longenough1');
    await tester.enterText(find.byKey(const Key('backup.confirm')), 'different11');
    await tester.tap(find.byKey(const Key('backup.create')));
    await tester.pump();
    expect(find.text('كلمتا المرور غير متطابقتين.'), findsOneWidget);
    await tester.pumpAndSettle(const Duration(seconds: 5));
  });

  testWidgets('a deputy admin backs up but cannot restore', (tester) async {
    await pumpApp(
      tester,
      firestore: await seed(),
      user: MockUser(email: adminEmail, isEmailVerified: true),
      profile: AppUser(email: adminEmail, name: 'المعاون', roles: const {UserRole.deputyAdmin}),
    );
    await tester.scrollUntilVisible(find.byKey(const Key('home.backup')), 200);
    await tester.tap(find.byKey(const Key('home.backup')));
    await tester.pumpAndSettle();
    expect(find.text('إنشاء نسخة احتياطية'), findsOneWidget);
    expect(find.text('الاستعادة من نسخة'), findsNothing);
  });

  testWidgets('audit log: admins see everything, newest first; stage managers their stage', (tester) async {
    final db = await seed();
    await pumpApp(tester, firestore: db, user: MockUser(email: adminEmail, isEmailVerified: true), profile: admin);
    await tester.scrollUntilVisible(find.byKey(const Key('home.audit')), 200);
    await tester.tap(find.byKey(const Key('home.audit')));
    await tester.pumpAndSettle();
    final titles = find.descendant(of: find.byKey(const Key('audit.list')), matching: find.byType(ExpansionTile));
    expect(titles, findsNWidgets(3));
    expect(find.text('something.new'), findsOneWidget); // unknown code shown as is
    expect(find.text('إضافة إجازة'), findsOneWidget);
    expect(find.text('تعديل إعدادات السنة'), findsOneWidget);
    expect(tester.getTopLeft(find.text('something.new')).dy, lessThan(tester.getTopLeft(find.text('إضافة إجازة')).dy));

    await tester.tap(find.text('إضافة إجازة'));
    await tester.pumpAndSettle();
    expect(find.text('studentId: 2'), findsOneWidget);
  });

  testWidgets('stage managers read the audit log of their stage only', (tester) async {
    await pumpApp(
      tester,
      firestore: await seed(),
      user: MockUser(email: sm, isEmailVerified: true),
      profile: AppUser(email: sm, name: 'مسؤول', roles: const {UserRole.stageManager}, stageScopes: [stage.id]),
    );
    expect(find.byKey(const Key('home.backup')), findsNothing);
    expect(find.byKey(const Key('home.department')), findsNothing);
    await tester.scrollUntilVisible(find.byKey(const Key('home.audit')), 200);
    await tester.tap(find.byKey(const Key('home.audit')));
    await tester.pumpAndSettle();
    expect(find.text('إضافة إجازة'), findsOneWidget);
    expect(find.text('something.new'), findsNothing);
    expect(find.text('تعديل إعدادات السنة'), findsNothing);
  });
}
