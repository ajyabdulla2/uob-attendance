import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:uob_attendance/features/auth/domain/app_user.dart';

import '../helpers/pump_app.dart';

void main() {
  final admin = AppUser(email: adminEmail, name: 'المدير', roles: const {UserRole.deputyAdmin});

  testWidgets('an admin publishes, edits and deletes an announcement, and opens the QR', (tester) async {
    final db = FakeFirebaseFirestore();
    await db.collection('announcements').doc('old').set({
      'title': 'إعلان سابق',
      'body': 'نص سابق',
      'createdBy': adminEmail,
      'createdAt': Timestamp.fromDate(DateTime(2026, 9, 1)),
    });
    final env = await pumpApp(tester,
        firestore: db, user: MockUser(email: adminEmail, isEmailVerified: true), profile: admin);

    await tester.tap(find.byKey(const Key('home.announcements')));
    await tester.pumpAndSettle();
    expect(find.text('إعلان سابق'), findsOneWidget);

    await tester.tap(find.byKey(const Key('ann.add')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('ann.title')), '  موعد الامتحانات  ');
    await tester.enterText(find.byKey(const Key('ann.body')), 'تبدأ يوم الأحد');
    await tester.tap(find.byKey(const Key('ann.save')));
    await tester.pumpAndSettle();
    final added = (await env.db.collection('announcements').where('title', isEqualTo: 'موعد الامتحانات').get()).docs.single;
    expect(added.data()['body'], 'تبدأ يوم الأحد');
    expect(added.data()['createdBy'], adminEmail);
    expect(find.text('موعد الامتحانات'), findsOneWidget);
    // Newest first.
    expect(tester.getTopLeft(find.text('موعد الامتحانات')).dy, lessThan(tester.getTopLeft(find.text('إعلان سابق')).dy));

    await tester.tap(find.byKey(const Key('ann.edit.old')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('ann.title')), 'إعلان معدّل');
    await tester.tap(find.byKey(const Key('ann.save')));
    await tester.pumpAndSettle();
    final edited = (await env.db.doc('announcements/old').get()).data()!;
    expect(edited['title'], 'إعلان معدّل');
    expect(edited['createdBy'], adminEmail);
    expect(edited['updatedBy'], adminEmail);

    await tester.tap(find.byKey(const Key('ann.delete.old')));
    await tester.pumpAndSettle();
    await tester.tap(find.descendant(of: find.byType(AlertDialog), matching: find.byType(FilledButton)));
    await tester.pumpAndSettle();
    expect((await env.db.doc('announcements/old').get()).exists, isFalse);

    await tester.tap(find.byKey(const Key('ann.qr')));
    await tester.pumpAndSettle();
    final qr = tester.widget<QrImageView>(find.byType(QrImageView));
    expect(qr, isNotNull);
    expect(find.text('https://basrah-researches.web.app/announcements.html'), findsOneWidget);
  });

  testWidgets('teachers and stage managers do not see it', (tester) async {
    await pumpApp(tester,
        firestore: FakeFirebaseFirestore(),
        user: MockUser(email: 't1@uobasrah.edu.iq', isEmailVerified: true),
        profile: AppUser(email: 't1@uobasrah.edu.iq', name: 'علي', roles: const {UserRole.teacher, UserRole.stageManager}));
    expect(find.byKey(const Key('home.announcements')), findsNothing);
  });
}
