import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uob_attendance/features/auth/domain/app_user.dart';

import '../helpers/pump_app.dart';

const newcomer = 'new@uobasrah.edu.iq';
const admin = AppUser(email: adminEmail, name: 'المدير', roles: {UserRole.superAdmin, UserRole.teacher});

/// A floating SnackBar may cover the FAB; clear it before the next tap.
Future<void> clearSnacks(WidgetTester tester) async {
  ScaffoldMessenger.of(tester.element(find.byType(Scaffold).last)).clearSnackBars();
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('an unprovisioned account sends a join request, sees it pending, and can cancel it', (tester) async {
    final env = await pumpApp(tester, user: MockUser(email: newcomer, isEmailVerified: true));
    expect(find.text('الحساب غير مضاف'), findsOneWidget);

    await tester.tap(find.byKey(const Key('join.submit')));
    await tester.pump();
    expect(find.text('هذا الحقل مطلوب'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('join.name')), 'زيد علي حسن');
    await tester.enterText(find.byKey(const Key('join.note')), 'مدرس المرحلة الثانية');
    await tester.tap(find.byKey(const Key('join.submit')));
    await tester.pumpAndSettle();
    final saved = (await env.db.doc('accessRequests/$newcomer').get()).data();
    expect(saved, containsPair('name', 'زيد علي حسن'));
    expect(saved, containsPair('note', 'مدرس المرحلة الثانية'));
    expect(find.byKey(const Key('join.cancel')), findsOneWidget);

    await tester.tap(find.byKey(const Key('join.cancel')));
    await tester.pumpAndSettle();
    expect((await env.db.doc('accessRequests/$newcomer').get()).exists, isFalse);
    expect(find.byKey(const Key('join.submit')), findsOneWidget);
  });

  testWidgets('admin approves a request as stage manager from the home card', (tester) async {
    final env = await pumpApp(tester, user: MockUser(email: adminEmail, isEmailVerified: true), profile: admin);
    await env.db.doc('accessRequests/$newcomer').set({
      'email': newcomer,
      'name': 'زيد علي حسن',
      'note': 'مسؤول المرحلة الثالثة',
      'requestedAt': Timestamp.now(),
    });
    await tester.pumpAndSettle();

    await tester.tap(find.text('طلبات انضمام بانتظار موافقتك: 1'));
    await tester.pumpAndSettle();
    expect(find.text('طلبات الانضمام (1)'), findsOneWidget);
    expect(find.text('مسؤول المرحلة الثالثة'), findsOneWidget);

    await tester.tap(find.byKey(const Key('accounts.approve.$newcomer')));
    await tester.pumpAndSettle();
    expect(find.text('قبول طلب الانضمام'), findsOneWidget);
    await tester.tap(find.byKey(const Key('account.role.stageManager')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('account.save')));
    await tester.pumpAndSettle();
    expect(find.text('اختر مرحلة واحدة على الأقل لمسؤول المرحلة.'), findsOneWidget);

    await tester.tap(find.byKey(const Key('account.scope.3-morning')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('account.save')));
    await tester.pumpAndSettle();

    final user = (await env.db.doc('users/$newcomer').get()).data();
    expect(user!['name'], 'زيد علي حسن');
    expect(user['roles'], ['stageManager', 'teacher']);
    expect(user['stageScopes'], ['3-morning']);
    expect((await env.db.doc('accessRequests/$newcomer').get()).exists, isFalse);
    expect(find.byKey(const Key('accounts.requests')), findsNothing);
    expect(find.byKey(const Key('accounts.user.$newcomer')), findsOneWidget);
  });

  testWidgets('admin adds an account, cannot add it twice, suspends it, and cannot lock themselves out',
      (tester) async {
    final env = await pumpApp(tester, user: MockUser(email: adminEmail, isEmailVerified: true), profile: admin);
    await tester.tap(find.text('الحسابات'));
    await tester.pumpAndSettle();
    expect(find.text('الحسابات والصلاحيات'), findsOneWidget);

    Future<void> add(String email, String name) async {
      await clearSnacks(tester);
      await tester.tap(find.byKey(const Key('accounts.add')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('account.email')), email);
      await tester.enterText(find.byKey(const Key('account.name')), name);
      await tester.tap(find.byKey(const Key('account.save')));
      await tester.pumpAndSettle();
    }

    await add(' T.New@UOBasrah.edu.iq ', 'تدريسي جديد');
    final created = (await env.db.doc('users/t.new@uobasrah.edu.iq').get()).data();
    expect(created, containsPair('roles', ['teacher']));
    expect(created, containsPair('active', true));

    await add('t.new@uobasrah.edu.iq', 'مكرر');
    expect(find.text('يوجد حساب بهذا البريد؛ عدّله من القائمة.'), findsOneWidget);
    expect((await env.db.doc('users/t.new@uobasrah.edu.iq').get()).data()!['name'], 'تدريسي جديد');

    // Suspend the new account.
    await clearSnacks(tester);
    await tester.tap(find.byKey(const Key('accounts.user.t.new@uobasrah.edu.iq')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('account.active')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('account.save')));
    await tester.pumpAndSettle();
    expect((await env.db.doc('users/t.new@uobasrah.edu.iq').get()).data()!['active'], isFalse);
    expect(find.text('موقوف'), findsOneWidget);

    // Own account: name editable, roles and status locked.
    await clearSnacks(tester);
    await tester.tap(find.byKey(const Key('accounts.user.$adminEmail')));
    await tester.pumpAndSettle();
    expect(find.text('لا يمكنك تغيير صلاحياتك أو إيقاف حسابك بنفسك.'), findsOneWidget);
    expect(tester.widget<CheckboxListTile>(find.byKey(const Key('account.role.superAdmin'))).onChanged, isNull);
    expect(tester.widget<SwitchListTile>(find.byKey(const Key('account.active'))).onChanged, isNull);
  });

  testWidgets('a deputy admin cannot open admin accounts or grant admin roles', (tester) async {
    final env = await pumpApp(
      tester,
      user: MockUser(email: 'deputy@uobasrah.edu.iq', isEmailVerified: true),
      profile: const AppUser(email: 'deputy@uobasrah.edu.iq', name: 'المعاون', roles: {UserRole.deputyAdmin}),
    );
    await env.db.doc('users/$adminEmail').set(admin.toMap());
    await tester.tap(find.text('الحسابات'));
    await tester.pumpAndSettle();
    expect(tester.widget<ListTile>(find.byKey(const Key('accounts.user.$adminEmail'))).onTap, isNull);

    await tester.tap(find.byKey(const Key('accounts.add')));
    await tester.pumpAndSettle();
    expect(tester.widget<CheckboxListTile>(find.byKey(const Key('account.role.superAdmin'))).onChanged, isNull);
    expect(tester.widget<CheckboxListTile>(find.byKey(const Key('account.role.stageManager'))).onChanged, isNotNull);
  });

  testWidgets('teachers do not get the accounts tab', (tester) async {
    await pumpApp(
      tester,
      user: MockUser(email: 't@uobasrah.edu.iq', isEmailVerified: true),
      profile: const AppUser(email: 't@uobasrah.edu.iq', name: 'علي'),
    );
    expect(find.text('الحسابات'), findsNothing);
  });

  testWidgets('the super admin deletes an account imported with a wrong e-mail', (tester) async {
    const wrong = 'wrong.teacher@uobasrah.edu.iq';
    final env = await pumpApp(tester, user: MockUser(email: adminEmail, isEmailVerified: true), profile: admin);
    await env.db.doc('users/$wrong').set(const AppUser(email: wrong, name: 'تدريسي خطأ').toMap());
    await env.db.doc('assignments/CS101_1-morning__theory__all__$wrong').set({
      'teacherId': wrong, 'courseId': 'CS101_1-morning', 'stageId': '1-morning', 'type': 'theory', 'target': 'all',
    });
    await tester.tap(find.text('الحسابات'));
    await tester.pumpAndSettle();

    // No delete for one's own account.
    await tester.tap(find.byKey(const Key('accounts.user.$adminEmail')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('account.delete')), findsNothing);
    await tester.tap(find.text('إلغاء'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('accounts.user.$wrong')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('account.delete')));
    await tester.pumpAndSettle();
    expect(find.textContaining('مع إسناداته (1)'), findsOneWidget);
    await tester.tap(find.descendant(of: find.byType(AlertDialog), matching: find.byType(FilledButton)));
    await tester.pumpAndSettle();

    expect(find.text('حُذف الحساب.'), findsOneWidget);
    expect((await env.db.doc('users/$wrong').get()).exists, isFalse);
    expect((await env.db.collection('assignments').get()).docs, isEmpty);
    expect(find.byKey(const Key('accounts.user.$wrong')), findsNothing);
  });
}
