import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uob_attendance/core/domain/stage_ref.dart';
import 'package:uob_attendance/features/academic/domain/academic_year.dart';
import 'package:uob_attendance/features/auth/domain/app_user.dart';
import 'package:uob_attendance/features/courses/domain/course.dart';
import 'package:uob_attendance/features/leaves/domain/leave.dart';
import 'package:uob_attendance/features/stats/domain/student_course_stat.dart';
import 'package:uob_attendance/features/students/domain/student.dart';
import 'package:uob_attendance/features/warnings/domain/warning_list.dart';

import '../helpers/pump_app.dart';

void main() {
  const stage = StageRef(3, Shift.morning);
  // 1 unit × 1 × 15 weeks = 15 lectures: one absence = 6.7%.
  final course = Course(code: 'CS301', name: 'هياكل البيانات', stage: stage, semester: 1, units: 1, hasPractical: false);
  final names = ['أحمد علي حسين جاسم', 'باقر محمد كاظم عبد', 'حسن جواد كريم علي'];
  String sid(int day) => '${course.id}__theory__all__202610${day.toString().padLeft(2, '0')}__1';

  Future<FakeFirebaseFirestore> seed() async {
    final db = FakeFirebaseFirestore();
    await db.doc('academicYears/2026-2027').set(const AcademicYear(id: '2026-2027', semester: 1, active: true).toMap());
    await db.doc('courses/${course.id}').set(course.toMap());
    for (final (i, n) in names.indexed) {
      await db.doc('students/${i + 1}').set(Student(universityId: '${i + 1}', fullName: n, stage: stage).toMap());
    }
    Future<void> stat(String id, List<int> absentDays) => db.doc('stats/${course.id}__$id').set({
          'courseId': course.id,
          'studentId': id,
          'stageId': stage.id,
          'bySession': {for (final d in absentDays) sid(d): 'absent'},
        });
    await stat('1', [1, 2]); // 13.3% → إنذار
    await stat('2', [1]); //    6.7% → تنبيه، one more → إنذار
    await stat('3', [5]); //    covered by a leave → 0%
    await db.doc('leaves/l1').set({
      ...Leave(id: 'l1', studentId: '3', stageId: stage.id, type: LeaveType.sick, from: DateTime.utc(2026, 10, 5), to: DateTime.utc(2026, 10, 5))
          .toMap(),
      'approvedBy': 'sm@uob.iq',
    });
    return db;
  }

  testWidgets('a stage manager sees the lists and saves a department decision', (tester) async {
    const sm = 'sm@uobasrah.edu.iq';
    final db = await seed();
    await pumpApp(
      tester,
      firestore: db,
      user: MockUser(email: sm, isEmailVerified: true),
      profile: AppUser(email: sm, name: 'مسؤول', roles: const {UserRole.stageManager}, stageScopes: [stage.id]),
    );
    await tester.tap(find.byKey(const Key('home.warnings')));
    await tester.pumpAndSettle();

    expect(find.text('تنبيه 1'), findsOneWidget);
    expect(find.text('إنذار 1'), findsOneWidget);
    expect(find.text('فصل 0'), findsOneWidget);
    // With 15 lectures every step is one absence: 13.3% → فصل, 6.7% → إنذار,
    // and 0% (the excused one) → تنبيه.
    expect(find.text('على الحافة 3'), findsOneWidget);
    expect(find.text(names[0]), findsOneWidget);
    expect(find.textContaining('الغياب 2 من 15 محاضرة = 13.3٪'), findsOneWidget);

    await tester.tap(find.byKey(const Key('warn.view.edge')));
    await tester.pumpAndSettle();
    expect(find.text(names[1]), findsOneWidget);
    expect(find.textContaining('يصل إلى إنذار بعد غياب واحد'), findsOneWidget);
    expect(find.textContaining('مُجاز (لا يُحتسب): 1'), findsOneWidget, reason: 'the leave excused their only absence');

    await tester.tap(find.byKey(const Key('warn.view.warning')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('warn.save')));
    await tester.pumpAndSettle();
    await tester.tap(find.descendant(of: find.byType(AlertDialog), matching: find.byType(FilledButton)));
    await tester.pumpAndSettle();

    final saved = (await db.collection('warningLists').get()).docs.single;
    final list = WarningList.fromMap(saved.id, saved.data());
    expect(list.decision, DecisionType.department);
    expect(list.entries.single.studentName, names[0]);
    expect(list.entries.single.absences, 2);
    expect(list.entries.single.courseName, 'هياكل البيانات');

    await tester.tap(find.byKey(const Key('warn.tab.decisions')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('decision.${list.id}')));
    await tester.pumpAndSettle();
    expect(find.text(names[0]), findsOneWidget);
    expect(find.byKey(const Key('decision.finalize')), findsNothing, reason: 'admins only');

    // Another absence for باقر, then regenerate: he joins the decision.
    await db.doc('stats/${course.id}__2').update({'bySession.${sid(8)}': 'absent'});
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('decision.regenerate')));
    await tester.pumpAndSettle();
    await tester.tap(find.descendant(of: find.byType(AlertDialog), matching: find.byType(FilledButton)));
    await tester.pumpAndSettle();
    expect(((await db.doc('warningLists/${list.id}').get()).data()!['entries'] as List), hasLength(2));
  });

  testWidgets('an admin turns a department decision into a locked deanery decision', (tester) async {
    final db = await seed();
    await db.doc('warningLists/w1').set(const WarningList(
      id: 'w1',
      stageId: '3-morning',
      level: WarningLevel.warning,
      decision: DecisionType.department,
      entries: [WarningListEntry(studentId: '1', studentName: 'أحمد', courseId: 'CS301_3-morning', percent: 13.3)],
    ).toMap());
    await pumpApp(
      tester,
      firestore: db,
      user: MockUser(email: adminEmail, isEmailVerified: true),
      profile: const AppUser(email: adminEmail, name: 'المدير', roles: {UserRole.deputyAdmin}),
    );
    await tester.tap(find.byKey(const Key('home.warnings')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('warn.stage')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('المرحلة الثالثة — صباحي').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('warn.tab.decisions')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('decision.w1')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('decision.finalize')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('order.number')), '3/4/1234');
    await tester.tap(find.byKey(const Key('order.date')));
    await tester.pumpAndSettle();
    final ok = MaterialLocalizations.of(tester.element(find.byType(DatePickerDialog))).okButtonLabel;
    await tester.tap(find.text(ok));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('order.ok')));
    await tester.pumpAndSettle();

    final w = WarningList.fromMap('w1', (await db.doc('warningLists/w1').get()).data()!);
    expect(w.decision, DecisionType.deanery);
    expect(w.orderNumber, '3/4/1234');
    expect(w.orderDate, isNotNull);
    expect(find.text('قرار عمادة (نهائي ومقفل)'), findsOneWidget);
    expect(find.byKey(const Key('decision.delete')), findsNothing);
  });
}
