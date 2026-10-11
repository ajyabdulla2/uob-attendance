import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mock_exceptions/mock_exceptions.dart';
import 'package:uob_attendance/features/auth/domain/app_user.dart';

import '../helpers/pump_app.dart';

void main() {
  const email = 't@uobasrah.edu.iq';
  final profile = AppUser(email: email, name: 'تدريسي', roles: const {UserRole.teacher});

  Future<void> openDialog(WidgetTester tester) async {
    await tester.tap(find.text('الملف الشخصي').first);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('profile.deleteAccount')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('profile.deleteAccount')));
    await tester.pumpAndSettle();
  }

  testWidgets('deleting the account: password, inbox cleared, signed out; the staff entry stays', (tester) async {
    final user = MockUser(email: email, isEmailVerified: true);
    final app = await pumpApp(tester, user: user, profile: profile);
    await app.db.doc('inbox/$email/items/m1').set({'title': 'رسالة', 'body': 'نص'});
    await openDialog(tester);

    expect(tester.widget<FilledButton>(find.byKey(const Key('deleteAccount.confirm'))).onPressed, isNull);
    await tester.enterText(find.byKey(const Key('deleteAccount.password')), 'secret123');
    await tester.pump();
    // Signing out makes the shell's providers recompute once before the router
    // replaces it (same on «تسجيل الخروج»); those two reports are expected here.
    final report = FlutterError.onError;
    FlutterError.onError = (d) {
      if ('${d.exception}'.contains('No signed-in user')) return;
      report?.call(d);
    };
    addTearDown(() => FlutterError.onError = report);
    await tester.tap(find.byKey(const Key('deleteAccount.confirm')));
    await tester.pumpAndSettle();
    FlutterError.onError = report;

    expect(app.auth.currentUser, isNull);
    expect((await app.db.collection('inbox/$email/items').get()).docs, isEmpty);
    expect((await app.db.doc('users/$email').get()).exists, isTrue);
    expect(find.byKey(const Key('profile.deleteAccount')), findsNothing);
  });

  testWidgets('a wrong password deletes nothing', (tester) async {
    final user = MockUser(email: email, isEmailVerified: true);
    whenCalling(Invocation.method(#reauthenticateWithCredential, null))
        .on(user)
        .thenThrow(FirebaseAuthException(code: 'invalid-credential'));
    final app = await pumpApp(tester, user: user, profile: profile);
    await app.db.doc('inbox/$email/items/m1').set({'title': 'رسالة', 'body': 'نص'});
    await openDialog(tester);

    await tester.enterText(find.byKey(const Key('deleteAccount.password')), 'wrong');
    await tester.pump();
    await tester.tap(find.byKey(const Key('deleteAccount.confirm')));
    await tester.pumpAndSettle();

    expect(app.auth.currentUser, isNotNull);
    expect((await app.db.collection('inbox/$email/items').get()).docs, hasLength(1));
    expect(find.byKey(const Key('deleteAccount.password')), findsOneWidget);
  });
}
