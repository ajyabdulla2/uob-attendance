import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uob_attendance/core/domain/stage_ref.dart';
import 'package:uob_attendance/features/auth/domain/app_user.dart';
import 'package:uob_attendance/features/courses/domain/course.dart';
import 'package:uob_attendance/features/students/data/students_repository.dart';
import 'package:uob_attendance/features/students/domain/student.dart';

import '../helpers/pump_app.dart';

void main() {
  const stage = StageRef(2, Shift.morning);
  const sm = 'sm@uobasrah.edu.iq';
  final course = Course(code: 'CS201', name: 'قواعد البيانات', stage: stage, semester: 1, units: 3, hasPractical: true);

  Future<FakeFirebaseFirestore> seed() async {
    final db = FakeFirebaseFirestore();
    await db.doc('courses/${course.id}').set(course.toMap());
    for (final name in ['A', 'B']) {
      await db.doc('groups/${course.id}__$name').set({
        'courseId': course.id,
        'stageId': stage.id,
        'name': name,
        'studentIds': <String>[],
      });
    }
    await db.doc('students/100').set(Student(universityId: '100', fullName: 'علي حسن كريم جاسم', stage: stage, section: 'أ').toMap());
    await db.doc('students/900').set(Student(universityId: '900', fullName: 'سارة علي كاظم حسن', stage: const StageRef(4, Shift.evening)).toMap());
    return db;
  }

  testWidgets('a stage manager adds a transferred student into a practical group', (tester) async {
    final env = await pumpApp(
      tester,
      firestore: await seed(),
      user: MockUser(email: sm, isEmailVerified: true),
      profile: AppUser(email: sm, name: 'مسؤول', roles: const {UserRole.stageManager}, stageScopes: [stage.id]),
    );
    final tile = find.byKey(const Key('home.students'));
    await tester.ensureVisible(tile);
    await tester.pumpAndSettle();
    await tester.tap(tile);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('students.row.100')), findsOneWidget);
    expect(find.byKey(const Key('students.row.900')), findsNothing, reason: 'another stage');

    await tester.tap(find.byKey(const Key('students.add')));
    await tester.pumpAndSettle();
    // The same university ID is refused.
    await tester.enterText(find.byKey(const Key('student.id')), '١٠٠');
    await tester.enterText(find.byKey(const Key('student.name')), 'طالب مكرر');
    await tester.tap(find.byKey(const Key('student.save')));
    await tester.pumpAndSettle();
    expect(find.textContaining('علي حسن كريم جاسم'), findsWidgets);
    expect(find.byKey(const Key('student.error')), findsOneWidget);

    await tester.enterText(find.byKey(const Key('student.id')), '205');
    await tester.enterText(find.byKey(const Key('student.name')), 'زينب صالح مهدي حسن');
    await tester.tap(find.byKey(Key('student.group.${course.id}')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('مجموعة B (0)').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('student.save')));
    await tester.pumpAndSettle();

    final saved = (await env.db.doc('students/205').get()).data()!;
    expect(saved['fullName'], 'زينب صالح مهدي حسن');
    expect(saved['stageId'], stage.id);
    expect(saved['status'], 'transferredIn', reason: 'joined after the import');
    expect((await env.db.doc('groups/${course.id}__B').get()).data()!['studentIds'], ['205']);
    expect((await env.db.doc('groups/${course.id}__A').get()).data()!['studentIds'], isEmpty);
    final audit = (await env.db.collection('auditLog').get()).docs.single.data();
    expect(audit['action'], 'student.create');
    expect(find.byKey(const Key('students.row.205')), findsOneWidget);

    // Editing: the status changes, the ID stays.
    await tester.tap(find.byKey(const Key('students.row.205')));
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(find.byKey(const Key('student.id'))).enabled, isFalse);
    await tester.tap(find.byKey(const Key('student.status')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('منسحب').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('student.save')));
    await tester.pumpAndSettle();
    expect((await env.db.doc('students/205').get()).data()!['status'], 'withdrawn');
  });

  test('an admin cannot add an ID used in another stage', () async {
    final db = await seed();
    final repo = StudentsRepository(db);
    await expectLater(
      repo.add(Student(universityId: '900', fullName: 'آخر', stage: stage), actor: 'a@uob.iq', stageStudents: const []),
      throwsA(isA<StudentExists>().having((e) => e.existing.stageId, 'stage', '4-evening')),
    );
    expect((await db.doc('students/900').get()).data()!['fullName'], 'سارة علي كاظم حسن');
  });
}
