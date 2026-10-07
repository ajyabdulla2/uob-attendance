import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uob_attendance/features/auth/domain/app_user.dart';
import 'package:uob_attendance/features/notifications/domain/app_message.dart';

import '../helpers/pump_app.dart';

void main() {
  const teacher = 't@uobasrah.edu.iq';
  final admin = AppUser(email: adminEmail, name: 'المدير', roles: const {UserRole.superAdmin});
  final teacherUser = AppUser(email: teacher, name: 'تدريسي', roles: const {UserRole.teacher}, teachingStages: ['1-morning']);

  test('who sees which message', () {
    AppMessage m(MessageAudience a, [String? stage]) =>
        AppMessage(id: 'x', title: 't', body: '', audience: a, stageId: stage, createdBy: adminEmail);
    final sm = AppUser(email: 'sm@x.iq', name: 's', roles: const {UserRole.stageManager}, stageScopes: ['3-morning']);
    expect(m(MessageAudience.all).isFor(teacherUser), isTrue);
    expect(m(MessageAudience.teachers).isFor(teacherUser), isTrue);
    expect(m(MessageAudience.stageManagers).isFor(teacherUser), isFalse);
    expect(m(MessageAudience.stageManagers).isFor(sm), isTrue);
    expect(m(MessageAudience.stage, '1-morning').isFor(teacherUser), isTrue);
    expect(m(MessageAudience.stage, '3-morning').isFor(teacherUser), isFalse);
    expect(m(MessageAudience.stage, '3-morning').isFor(sm), isTrue);
    expect(m(MessageAudience.stage, '4-evening').isFor(admin), isTrue, reason: 'admins see all');
  });

  testWidgets('an admin sends a message to teachers', (tester) async {
    final db = FakeFirebaseFirestore();
    await pumpApp(tester, firestore: db, user: MockUser(email: adminEmail, isEmailVerified: true), profile: admin);
    await tester.tap(find.byKey(const Key('home.notifications')));
    await tester.pumpAndSettle();
    expect(find.text('لا رسائل.'), findsOneWidget);
    await tester.tap(find.byKey(const Key('notif.compose')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('notif.audience')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('التدريسيون').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('notif.title')), 'اجتماع القسم');
    await tester.enterText(find.byKey(const Key('notif.body')), 'غداً الساعة العاشرة');
    await tester.tap(find.byKey(const Key('notif.send')));
    await tester.pumpAndSettle();
    final doc = (await db.collection('messages').get()).docs.single.data();
    expect(doc['audience'], 'teachers');
    expect(doc['createdBy'], adminEmail);
    expect(doc.containsKey('stageId'), isFalse);
    expect(find.text('اجتماع القسم'), findsOneWidget);
  });

  testWidgets('a teacher gets a badge for new messages and decisions', (tester) async {
    final db = FakeFirebaseFirestore();
    final now = DateTime.now();
    await db.doc('messages/m1').set({
      'title': 'تذكير بالتسجيل',
      'body': '',
      'audience': 'teachers',
      'createdBy': adminEmail,
      'createdAt': Timestamp.fromDate(now),
    });
    await db.doc('messages/m2').set({
      'title': 'لمسؤولي المراحل فقط',
      'audience': 'stageManagers',
      'createdBy': adminEmail,
      'createdAt': Timestamp.fromDate(now),
    });
    await db.doc('editRequests/r1').set({
      'sessionId': 'CS101_1-morning__theory__all__20261005__1',
      'studentId': '1001',
      'stageId': '1-morning',
      'requestedStatus': 'excused',
      'reason': 'تقرير',
      'requestedBy': teacher,
      'status': 'approved',
      'decidedAt': Timestamp.fromDate(now),
    });
    await pumpApp(tester, firestore: db, user: MockUser(email: teacher, isEmailVerified: true), profile: teacherUser);
    expect(find.descendant(of: find.byKey(const Key('home.notifications')), matching: find.text('2')), findsOneWidget);

    await tester.tap(find.byKey(const Key('home.notifications')));
    await tester.pumpAndSettle();
    expect(find.text('تذكير بالتسجيل'), findsOneWidget);
    expect(find.text('لمسؤولي المراحل فقط'), findsNothing);
    expect(find.text('وافق مسؤول المرحلة على طلبك'), findsOneWidget);
    expect(find.byKey(const Key('notif.compose')), findsNothing);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.descendant(of: find.byKey(const Key('home.notifications')), matching: find.text('2')), findsNothing,
        reason: 'seen');
  });
}
