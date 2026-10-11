import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uob_attendance/features/auth/domain/app_user.dart';

import '../helpers/pump_app.dart';

void main() {
  final admin = AppUser(email: adminEmail, name: 'المدير', roles: const {UserRole.superAdmin});
  const drive = 'https://drive.google.com/uc?export=download&id=abc';

  testWidgets('an admin publishes a new version from the app, with an audit entry', (tester) async {
    final db = FakeFirebaseFirestore();
    await db.doc('config/app').set({'latestVersion': '1.3.0', 'androidUrl': 'https://old.example/a.apk', 'notes': ''});
    final env = await pumpApp(tester, firestore: db, user: MockUser(email: adminEmail, isEmailVerified: true), profile: admin);

    await tester.tap(find.byKey(const Key('home.release')));
    await tester.pumpAndSettle();
    expect(find.text('إصدار التطبيق'), findsWidgets);
    // Starts from what is saved.
    expect(find.text('1.3.0'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('release.latest')), '1.4.0');
    await tester.enterText(find.byKey(const Key('release.android')), 'http://insecure.example/a.apk');
    await tester.enterText(find.byKey(const Key('release.notes')), 'إشعارات الهاتف');
    await tester.ensureVisible(find.byKey(const Key('release.save')));
    await tester.tap(find.byKey(const Key('release.save')));
    await tester.pumpAndSettle();
    expect(find.text('الرابط يجب أن يبدأ بـ https://'), findsWidgets);
    expect((await env.db.doc('config/app').get()).data()!['latestVersion'], '1.3.0', reason: 'nothing saved');

    await tester.enterText(find.byKey(const Key('release.android')), drive);
    await tester.ensureVisible(find.byKey(const Key('release.save')));
    await tester.tap(find.byKey(const Key('release.save')));
    await tester.pumpAndSettle();

    final saved = (await env.db.doc('config/app').get()).data()!;
    expect(saved['latestVersion'], '1.4.0');
    expect(saved['androidUrl'], drive);
    expect(saved['notes'], 'إشعارات الهاتف');
    expect(saved.containsKey('minVersion'), isFalse, reason: 'an empty minimum is removed, not stored');
    expect(saved['updatedBy'], adminEmail);
    final audit = (await env.db.collection('auditLog').where('action', isEqualTo: 'config.update').get()).docs;
    expect(audit.single.data()['actor'], adminEmail);
  });

  testWidgets('setting a minimum asks first; cancelling saves nothing', (tester) async {
    final db = FakeFirebaseFirestore();
    await db.doc('config/app').set({'latestVersion': '1.4.0', 'androidUrl': drive});
    final env = await pumpApp(tester, firestore: db, user: MockUser(email: adminEmail, isEmailVerified: true), profile: admin);
    await tester.tap(find.byKey(const Key('home.release')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('release.minimum')), '1.5.0');
    await tester.ensureVisible(find.byKey(const Key('release.save')));
    await tester.tap(find.byKey(const Key('release.save')));
    await tester.pumpAndSettle();
    expect(find.text('أقدم إصدار مسموح لا يكون أحدث من أحدث إصدار.'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('release.minimum')), '1.4.0');
    await tester.ensureVisible(find.byKey(const Key('release.save')));
    await tester.tap(find.byKey(const Key('release.save')));
    await tester.pumpAndSettle();
    expect(find.text('إيقاف النسخ القديمة؟'), findsOneWidget);
    await tester.tap(find.text('إلغاء'));
    await tester.pumpAndSettle();
    expect((await env.db.doc('config/app').get()).data()!.containsKey('minVersion'), isFalse);

    await tester.tap(find.byKey(const Key('release.save')));
    await tester.pumpAndSettle();
    await tester.tap(find.descendant(of: find.byType(AlertDialog), matching: find.byType(FilledButton)));
    await tester.pumpAndSettle();
    expect((await env.db.doc('config/app').get()).data()!['minVersion'], '1.4.0');
  });

  testWidgets('teachers and stage managers do not see it', (tester) async {
    await pumpApp(tester,
        firestore: FakeFirebaseFirestore(),
        user: MockUser(email: 't1@uobasrah.edu.iq', isEmailVerified: true),
        profile: AppUser(email: 't1@uobasrah.edu.iq', name: 'علي', roles: const {UserRole.teacher, UserRole.stageManager}));
    expect(find.byKey(const Key('home.release')), findsNothing);
  });
}
