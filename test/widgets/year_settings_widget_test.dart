import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uob_attendance/features/academic/domain/academic_year.dart';
import 'package:uob_attendance/features/auth/domain/app_user.dart';

import '../helpers/pump_app.dart';

void main() {
  Future<FakeFirebaseFirestore> open(WidgetTester tester, {Set<UserRole> roles = const {UserRole.deputyAdmin}}) async {
    final db = FakeFirebaseFirestore();
    await db.doc('academicYears/2026-2027').set(const AcademicYear(id: '2026-2027', semester: 1, active: true).toMap());
    await pumpApp(
      tester,
      firestore: db,
      user: MockUser(email: adminEmail, isEmailVerified: true),
      profile: AppUser(email: adminEmail, name: 'المدير', roles: roles),
    );
    return db;
  }

  testWidgets('an admin sets the thresholds and planned lectures; an audit entry records it', (tester) async {
    final db = await open(tester);
    await tester.tap(find.byKey(const Key('home.year')));
    await tester.pumpAndSettle();
    expect(find.text('السنة 2026-2027'), findsOneWidget);
    // Defaults: 3 units × 1 × 15 weeks.
    expect(find.text('مثال: مادة بثلاث وحدات = 45 محاضرة في الفصل، والغياب الواحد = 2.2٪.'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('year.alert')), '4');
    await tester.enterText(find.byKey(const Key('year.weeks')), '١٦'); // Arabic digits accepted
    await tester.enterText(find.byKey(const Key('year.perUnit')), '0.5');
    await tester.enterText(find.byKey(const Key('year.lockHours')), '72');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('year.example')), findsOneWidget);
    expect(find.textContaining('= 24 محاضرة'), findsOneWidget);

    await tester.tap(find.byKey(const Key('year.leavesCount')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('year.maxLeave')), findsNothing, reason: 'a cap only matters when leaves excuse');
    await tester.tap(find.text('الفصل 2'));
    await tester.ensureVisible(find.byKey(const Key('year.missed')));
    expect(find.text('معطّل: المحاضرة التي فات موعد إقفالها تُصحَّح بطلبات التعديل فقط.'), findsOneWidget);
    await tester.tap(find.byKey(const Key('year.missed')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('year.save')));
    await tester.tap(find.byKey(const Key('year.save')));
    await tester.pumpAndSettle();

    expect(find.text('حُفظت إعدادات السنة.'), findsOneWidget);
    final y = AcademicYear.fromMap('2026-2027', (await db.doc('academicYears/2026-2027').get()).data()!);
    expect(y.thresholds.alert, 4);
    expect(y.weeksPerSemester, 16);
    expect(y.lecturesPerUnitPerWeek, 0.5);
    expect(y.lockHours, 72);
    expect(y.leavesCountAgainst, isTrue);
    expect(y.semester, 2);
    expect(y.allowMissedLectures, isTrue);
    expect(y.active, isTrue, reason: 'settings never touch the active flag');
    final audit = (await db.collection('auditLog').get()).docs.single.data();
    expect(audit['action'], 'year.update');
    expect((audit['before'] as Map)['lockHours'], 48);
    expect((audit['after'] as Map)['lockHours'], 72);
  });

  testWidgets('thresholds out of order are refused before saving', (tester) async {
    final db = await open(tester);
    await tester.tap(find.byKey(const Key('home.year')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('year.alert')), '12');
    await tester.ensureVisible(find.byKey(const Key('year.save')));
    await tester.tap(find.byKey(const Key('year.save')));
    await tester.pumpAndSettle();
    expect(find.textContaining('العتبات تصاعدية'), findsOneWidget);
    expect((await db.collection('auditLog').get()).docs, isEmpty);
  });

  testWidgets('stage managers do not get the year settings', (tester) async {
    await open(tester, roles: {UserRole.stageManager});
    expect(find.byKey(const Key('home.year')), findsNothing);
  });
}
