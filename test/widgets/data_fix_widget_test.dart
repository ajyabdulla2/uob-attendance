import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uob_attendance/core/domain/stage_ref.dart';
import 'package:uob_attendance/features/auth/domain/app_user.dart';
import 'package:uob_attendance/features/students/domain/student.dart';

import '../helpers/pump_app.dart';

const admin = AppUser(email: adminEmail, name: 'المدير', roles: {UserRole.superAdmin});
const stage = StageRef(1, Shift.morning);

void main() {
  testWidgets('an admin previews and applies a university ID change', (tester) async {
    final fs = FakeFirebaseFirestore();
    await fs.doc('students/T-001').set(Student(universityId: 'T-001', fullName: 'أحمد علي حسن جاسم', stage: stage).toMap());
    await fs.doc('students/2002').set(Student(universityId: '2002', fullName: 'بشرى كاظم عبد الله محمد', stage: stage).toMap());
    await pumpApp(tester, user: MockUser(email: adminEmail, isEmailVerified: true), profile: admin, firestore: fs);

    await tester.tap(find.byKey(const Key('home.dataFix')));
    await tester.pumpAndSettle();
    expect(find.text('بريد تدريسي'), findsOneWidget); // super admin only

    // Another student's ID is refused, with their name.
    await tester.enterText(find.byKey(const Key('fix.old')), 'T-001');
    await tester.enterText(find.byKey(const Key('fix.new')), '2002');
    await tester.tap(find.byKey(const Key('fix.preview')));
    await tester.pumpAndSettle();
    expect(find.textContaining('بشرى كاظم'), findsOneWidget);
    expect(find.byKey(const Key('fix.apply')), findsNothing);

    await tester.enterText(find.byKey(const Key('fix.new')), '٢٠٠١');
    await tester.tap(find.byKey(const Key('fix.preview')));
    await tester.pumpAndSettle();
    expect(find.text('• الطلبة: 1'), findsOneWidget);
    await tester.tap(find.byKey(const Key('fix.apply')));
    await tester.pumpAndSettle();
    await tester.tap(find.descendant(of: find.byType(AlertDialog), matching: find.byType(FilledButton)));
    await tester.pumpAndSettle();

    expect(find.textContaining('اكتمل التصحيح'), findsOneWidget);
    expect((await fs.doc('students/T-001').get()).exists, isFalse);
    expect((await fs.doc('students/2001').get()).data()!['fullName'], 'أحمد علي حسن جاسم');
    expect((await fs.collection('auditLog').get()).docs.single.data()['action'], 'student.rename');
  });

  testWidgets('a deputy admin cannot move accounts; teachers do not get the tool', (tester) async {
    await pumpApp(
      tester,
      user: MockUser(email: 'deputy@uobasrah.edu.iq', isEmailVerified: true),
      profile: const AppUser(email: 'deputy@uobasrah.edu.iq', name: 'نائب', roles: {UserRole.deputyAdmin}),
    );
    await tester.tap(find.byKey(const Key('home.dataFix')));
    await tester.pumpAndSettle();
    expect(find.text('رقم جامعي'), findsOneWidget);
    expect(find.text('بريد تدريسي'), findsNothing);
  });

  testWidgets('teachers have no data-fix entry', (tester) async {
    await pumpApp(
      tester,
      user: MockUser(email: 't@uobasrah.edu.iq', isEmailVerified: true),
      profile: const AppUser(email: 't@uobasrah.edu.iq', name: 'أستاذ'),
    );
    expect(find.byKey(const Key('home.dataFix')), findsNothing);
  });
}
