import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uob_attendance/core/domain/stage_ref.dart';
import 'package:uob_attendance/features/auth/domain/app_user.dart';
import 'package:uob_attendance/features/courses/domain/course.dart';
import 'package:uob_attendance/features/courses/domain/practical_group.dart';
import 'package:uob_attendance/features/students/domain/student.dart';

import '../helpers/pump_app.dart';

void main() {
  const stage = StageRef(1, Shift.morning);
  final course = Course(code: 'CS101', name: 'أساسيات البرمجة', stage: stage, semester: 1, units: 3, hasPractical: true);
  final students = [
    for (final (i, n) in ['أحمد علي حسين جاسم', 'باقر محمد كاظم عبد', 'حسن جواد كريم علي', 'زينب صالح مهدي حسن'].indexed)
      Student(universityId: '${i + 1}', fullName: n, stage: stage),
  ];

  testWidgets('a manager moves students between groups and adds a group', (tester) async {
    final env = await pumpApp(
      tester,
      user: MockUser(email: adminEmail, isEmailVerified: true),
      profile: const AppUser(email: adminEmail, name: 'المدير', roles: {UserRole.deputyAdmin}),
    );
    await env.db.doc('courses/${course.id}').set(course.toMap());
    for (final s in students) {
      await env.db.doc('students/${s.id}').set(s.toMap());
    }
    final a = PracticalGroup(courseId: course.id, stageId: stage.id, name: 'A', studentIds: const ['1', '2']);
    final b = PracticalGroup(courseId: course.id, stageId: stage.id, name: 'B', studentIds: const ['3']);
    await env.db.doc('groups/${a.id}').set(a.toMap());
    await env.db.doc('groups/${b.id}').set(b.toMap());

    await tester.tap(find.text('الربط'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('أساسيات البرمجة'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('assignments.members.${course.id}')));
    await tester.pumpAndSettle();

    expect(find.text('أعضاء المجاميع'), findsOneWidget);
    expect(find.text('مجموعة A · عدد الطلبة: 2'), findsOneWidget);
    expect(find.text('بلا مجموعة · عدد الطلبة: 1'), findsOneWidget); // زينب

    // A → B for أحمد, and زينب (no group) → B: groups become 1 and 3.
    await tester.tap(find.byKey(const Key('groups.student.1')));
    await tester.tap(find.byKey(const Key('groups.student.4')));
    await tester.pumpAndSettle();
    expect(find.text('المحدَّدون: 2'), findsOneWidget);
    await tester.tap(find.byKey(const Key('groups.move')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('groups.to.B')));
    await tester.pumpAndSettle();

    expect(find.text('نُقل 2 إلى مجموعة B.'), findsOneWidget);
    expect((await env.db.doc('groups/${a.id}').get()).data()!['studentIds'], ['2']);
    expect((await env.db.doc('groups/${b.id}').get()).data()!['studentIds'], ['3', '1', '4']);
    expect((await env.db.doc('groups/${b.id}').get()).data()!['updatedBy'], adminEmail);
    expect(find.text('مجموعة B · عدد الطلبة: 3'), findsOneWidget);
    expect(find.byKey(const Key('groups.header.none')), findsNothing);
    expect(find.byKey(const Key('groups.move')), findsNothing, reason: 'selection cleared');

    await tester.tap(find.byKey(const Key('groups.add')));
    await tester.pumpAndSettle();
    final c = await env.db.doc('groups/${course.id}__C').get();
    expect(c.data()!['studentIds'], isEmpty);
    expect(find.text('مجموعة C · عدد الطلبة: 0'), findsOneWidget);
  });
}
