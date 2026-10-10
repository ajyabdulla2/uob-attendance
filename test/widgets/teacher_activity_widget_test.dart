import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uob_attendance/core/domain/stage_ref.dart';
import 'package:uob_attendance/features/assignments/domain/assignment.dart';
import 'package:uob_attendance/features/attendance/domain/attendance_session.dart';
import 'package:uob_attendance/features/auth/domain/app_user.dart';

import '../helpers/pump_app.dart';

void main() {
  const t1 = 't1@uobasrah.edu.iq';
  const t2 = 't2@uobasrah.edu.iq';
  final admin = AppUser(email: adminEmail, name: 'المدير', roles: const {UserRole.superAdmin});

  Future<FakeFirebaseFirestore> seed() async {
    final db = FakeFirebaseFirestore();
    await db.doc('users/$t1').set(AppUser(email: t1, name: 'علي حسن', roles: const {UserRole.teacher}).toMap());
    await db.doc('users/$t2').set(AppUser(email: t2, name: 'سارة كريم', roles: const {UserRole.teacher}).toMap());
    final seen = DateTime.now().subtract(const Duration(hours: 3));
    await db.doc('presence/$t1').set({
      'email': t1,
      'lastSeenAt': Timestamp.fromDate(seen),
      'lastUploadAt': Timestamp.fromDate(seen),
      'platform': 'android',
      'appVersion': '1.3.0',
    });
    final day = DateTime.utc(2026, 10, 5);
    final s = AttendanceSession(
      courseId: 'CS101_1-morning',
      stageId: const StageRef(1, Shift.morning).id,
      yearId: '2026-2027',
      type: AssignmentType.theory,
      target: 'all',
      date: day,
      lectureNo: 1,
      openedBy: t1,
      lockAt: AttendanceSession.lockAtFor(day, 48),
    );
    await db.doc('sessions/${s.id}').set(s.toMap());
    return db;
  }

  testWidgets('the super admin sees who opened the app and messages one teacher', (tester) async {
    final env = await pumpApp(tester,
        firestore: await seed(), user: MockUser(email: adminEmail, isEmailVerified: true), profile: admin);
    // Opening the app records the admin's own presence.
    expect((await env.db.doc('presence/$adminEmail').get()).data()!['platform'], isNotEmpty);

    await tester.tap(find.byKey(const Key('home.activity')));
    await tester.pumpAndSettle();
    expect(find.text('متابعة التدريسيين'), findsWidgets);
    // Never seen first.
    expect(
      tester.getTopLeft(find.byKey(const Key('activity.row.$t2'))).dy,
      lessThan(tester.getTopLeft(find.byKey(const Key('activity.row.$t1'))).dy),
    );
    expect(find.textContaining('آخر دخول: منذ 3 ساعة'), findsOneWidget);
    expect(find.textContaining('لم يدخل بعد'), findsWidgets);

    await tester.tap(find.byKey(const Key('activity.filter.never')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('activity.row.$t1')), findsNothing);
    await tester.tap(find.byKey(const Key('activity.filter.all')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('activity.row.$t1')));
    await tester.pumpAndSettle();
    expect(find.text('المحاضرات التي فتحها: 1'), findsOneWidget);
    await tester.tap(find.byKey(const Key('activity.message')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('activity.msgTitle')), 'تذكير بتسجيل الحضور');
    await tester.tap(find.byKey(const Key('activity.send')));
    await tester.pumpAndSettle();
    expect(find.text('أُرسل الإشعار إلى 1.'), findsOneWidget);

    final inbox = (await env.db.collection('inbox/$t1/items').get()).docs;
    expect(inbox.single.data()['title'], 'تذكير بتسجيل الحضور');
    expect(inbox.single.data()['createdBy'], adminEmail);
    expect(inbox.single.data().containsKey('audience'), isFalse);
    expect((await env.db.collection('inbox/$t2/items').get()).docs, isEmpty);
  });

  testWidgets('a teacher sees a personal message with a badge and can delete it', (tester) async {
    final db = await seed();
    await db.collection('inbox/$t2/items').doc('m1').set({
      'title': 'رسالة خاصة لك',
      'body': 'يرجى تسجيل محاضرات الأسبوع',
      'createdBy': adminEmail,
      'createdAt': Timestamp.now(),
    });
    await pumpApp(tester,
        firestore: db,
        user: MockUser(email: t2, isEmailVerified: true),
        profile: AppUser(email: t2, name: 'سارة كريم', roles: const {UserRole.teacher}));
    expect(find.byKey(const Key('home.activity')), findsNothing);
    await tester.tap(find.byKey(const Key('home.notifications')));
    await tester.pumpAndSettle();
    expect(find.text('رسالة خاصة لك'), findsOneWidget);
    expect(find.textContaining('رسالة خاصة ·'), findsOneWidget);
    await tester.tap(find.descendant(of: find.byKey(const Key('notif.message.m1')), matching: find.byIcon(Icons.delete_outline)));
    await tester.pumpAndSettle();
    await tester.tap(find.descendant(of: find.byType(AlertDialog), matching: find.byType(FilledButton)));
    await tester.pumpAndSettle();
    expect((await db.collection('inbox/$t2/items').get()).docs, isEmpty);
  });
}
