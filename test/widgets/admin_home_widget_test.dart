import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uob_attendance/core/domain/stage_ref.dart';
import 'package:uob_attendance/features/auth/domain/app_user.dart';

import '../helpers/pump_app.dart';

void main() {
  const stage = StageRef(1, Shift.morning);
  const admin = AppUser(email: adminEmail, name: 'المدير', roles: {UserRole.superAdmin, UserRole.teacher});

  /// pumpApp lays out a tablet (navigation rail); these tests are about the
  /// phone's bottom bar and back button.
  Future<void> phone(WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 1600);
    await tester.pumpAndSettle();
  }

  Future<void> pumpAdmin(WidgetTester tester) async {
    final db = FakeFirebaseFirestore();
    await db.doc('editRequests/r1').set({'stageId': stage.id, 'status': 'pending'});
    await db.doc('accessRequests/x@uob.iq').set({'email': 'x@uob.iq', 'name': 'س'});
    await pumpApp(tester, firestore: db, user: MockUser(email: adminEmail, isEmailVerified: true), profile: admin);
    await phone(tester);
  }

  Future<void> back(WidgetTester tester) async {
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
  }

  testWidgets('the home screen groups the tools; the classes have their own tab', (tester) async {
    await pumpAdmin(tester);
    for (final title in ['المتابعة اليومية', 'الطلبة والغياب', 'البيانات والحسابات']) {
      expect(find.text(title), findsOneWidget);
    }
    // Pending edit and join requests show on their tiles.
    final requests = find.byKey(const Key('home.requests'));
    expect(find.descendant(of: requests, matching: find.text('1')), findsOneWidget);
    await tester.scrollUntilVisible(find.byKey(const Key('home.accounts')), 200);
    expect(find.descendant(of: find.byKey(const Key('home.accounts')), matching: find.text('1')), findsOneWidget);
    // The bottom bar: home, my courses, profile — no tools any more.
    final bar = find.byType(NavigationBar);
    expect(find.descendant(of: bar, matching: find.text('موادي')), findsOneWidget);
    expect(find.descendant(of: bar, matching: find.text('الاستيراد')), findsNothing);
    expect(find.text('موادي'), findsOneWidget); // only the tab, no section on the home screen
    await tester.tap(find.descendant(of: bar, matching: find.text('موادي')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('home.accounts')), findsNothing);
  });

  testWidgets('back from a tool or another tab returns home; home asks before leaving', (tester) async {
    await pumpAdmin(tester);
    await tester.scrollUntilVisible(find.byKey(const Key('home.import')), 200);
    await tester.tap(find.byKey(const Key('home.import')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('home.import')), findsNothing);
    await back(tester);
    expect(find.byKey(const Key('home.import')), findsOneWidget);

    await tester.tap(find.descendant(of: find.byType(NavigationBar), matching: find.text('الملف الشخصي')));
    await tester.pumpAndSettle();
    await back(tester);
    expect(find.byKey(const Key('home.import')), findsOneWidget);

    await back(tester);
    expect(find.text('اضغط رجوع مرة أخرى للخروج'), findsOneWidget);
    expect(find.byKey(const Key('home.import')), findsOneWidget);
  });

  testWidgets('a plain teacher keeps their classes on the home screen and no extra tab', (tester) async {
    const teacher = 't1@uobasrah.edu.iq';
    await pumpApp(tester,
        user: MockUser(email: teacher, isEmailVerified: true), profile: const AppUser(email: teacher, name: 'م'));
    await phone(tester);
    expect(find.text('المتابعة اليومية'), findsNothing);
    expect(find.descendant(of: find.byType(NavigationBar), matching: find.text('موادي')), findsNothing);
    expect(find.text('موادي'), findsOneWidget); // the section title on the home screen
  });
}
