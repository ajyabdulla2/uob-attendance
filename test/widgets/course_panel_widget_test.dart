import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uob_attendance/core/domain/stage_ref.dart';
import 'package:uob_attendance/features/academic/domain/academic_year.dart';
import 'package:uob_attendance/features/assignments/domain/assignment.dart';
import 'package:uob_attendance/features/attendance/domain/attendance_session.dart';
import 'package:uob_attendance/features/auth/domain/app_user.dart';
import 'package:uob_attendance/features/courses/data/course_panel.dart';
import 'package:uob_attendance/features/courses/domain/course.dart';
import 'package:uob_attendance/features/reports/application/report_builders.dart';
import 'package:uob_attendance/features/students/domain/student.dart';
import 'package:uob_attendance/l10n/app_localizations.dart';

import '../helpers/pump_app.dart';

void main() {
  const stage = StageRef(1, Shift.morning);
  const t1 = 't1@uobasrah.edu.iq';
  const t2 = 't2@uobasrah.edu.iq';
  final course = Course(code: 'CS101', name: 'البرمجة', stage: stage, semester: 1, units: 3, hasPractical: true);
  final theory = Assignment.theory(teacherId: t1, courseId: course.id, stageId: stage.id, teacherName: 'علي حسن', courseName: 'البرمجة');
  final groupA = Assignment.practical(teacherId: t2, courseId: course.id, stageId: stage.id, groupName: 'A', teacherName: 'سارة كريم', courseName: 'البرمجة');
  final day = DateTime.utc(2026, 10, 5);
  AttendanceSession session(AssignmentType type, String target, DateTime date, String by) => AttendanceSession(
        courseId: course.id,
        stageId: stage.id,
        yearId: '2026-2027',
        type: type,
        target: target,
        date: date,
        lectureNo: 1,
        openedBy: by,
        lockAt: AttendanceSession.lockAtFor(date, 48),
        counts: const {AttendanceStatus.present: 1, AttendanceStatus.absent: 1},
      );
  final s1 = session(AssignmentType.theory, 'all', day, t1);
  final s2 = session(AssignmentType.practical, 'A', day.add(const Duration(days: 1)), t2);

  Future<FakeFirebaseFirestore> seed() async {
    final db = FakeFirebaseFirestore();
    await db.doc('academicYears/2026-2027').set(const AcademicYear(id: '2026-2027', semester: 1, active: true).toMap());
    await db.doc('courses/${course.id}').set(course.toMap());
    await db.doc('students/1').set(Student(universityId: '1', fullName: 'أحمد علي حسين جاسم', stage: stage).toMap());
    await db.doc('students/2').set(Student(universityId: '2', fullName: 'زينب صالح مهدي حسن', stage: stage).toMap());
    for (final (name, ids) in [('A', ['1', '2']), ('B', <String>[])]) {
      await db.doc('groups/${course.id}__$name').set({
        'courseId': course.id,
        'stageId': stage.id,
        'name': name,
        'studentIds': ids,
      });
    }
    for (final a in [theory, groupA]) {
      await db.doc('assignments/${a.id}').set(a.toMap());
    }
    for (final s in [s1, s2]) {
      await db.doc('sessions/${s.id}').set(s.toMap());
      await db.doc('sessions/${s.id}/records/1').set({'studentId': '1', 'status': 'present'});
      await db.doc('sessions/${s.id}/records/2').set({'studentId': '2', 'status': 'absent'});
    }
    await db.doc('stats/${course.id}__2').set({
      'courseId': course.id,
      'studentId': '2',
      'stageId': stage.id,
      'bySession': {s1.id: 'absent', s2.id: 'absent'},
    });
    // Another stage's lecture of a same-named course is not counted.
    await db.doc('sessions/other').set({...s1.toMap(), 'stageId': '2-morning', 'courseId': 'CS101_2-morning'});
    return db;
  }

  test('the panel reads the course, its classes, lectures and percentages', () async {
    final p = (await CoursePanelRepository(await seed()).load(course.id))!;
    expect(p.classes.map((a) => a.id), [theory.id, groupA.id]);
    expect(p.groups.map((g) => g.name), ['A', 'B']);
    expect(p.sessions.map((s) => s.id), [s2.id, s1.id], reason: 'newest first');
    expect(p.lecturesOf(theory), 1);
    expect(p.teacherOf(s2), 'سارة كريم');
    expect(p.students.map((r) => r.student.id), ['1', '2']);
    expect(p.students.last.group, 'A');
    expect(p.students.last.summaries['']!.absences, 2);
    expect(await CoursePanelRepository(FakeFirebaseFirestore()).load('nope'), isNull);

    final l10n = lookupAppLocalizations(const Locale('ar'));
    final report = ReportBuilders.coursePanel(l10n, panel: p, stageLabel: 'الأولى', courseInfo: 'CS101');
    expect(report.title, 'لوحة مادة البرمجة');
    expect(report.tables, hasLength(2));
    expect(report.tables.first.rows, hasLength(2));
    // Lectures oldest first in the file, with who taught each.
    expect(report.tables.last.rows.first[4].text, 'علي حسن');
    expect(report.tables.last.rows.last[3].text, 'عملي · مجموعة A');
    expect(report.meta, contains('عدد المحاضرات المسجلة: 2'));
  });

  testWidgets('a stage manager opens «لوحة المادة»: info, lectures with absentees, students', (tester) async {
    await pumpApp(
      tester,
      firestore: await seed(),
      user: MockUser(email: 'sm@uobasrah.edu.iq', isEmailVerified: true),
      profile: AppUser(
        email: 'sm@uobasrah.edu.iq',
        name: 'مسؤول المرحلة',
        roles: const {UserRole.stageManager},
        stageScopes: [stage.id],
      ),
    );
    final tile = find.byKey(const Key('home.coursePanel'));
    await tester.ensureVisible(tile);
    await tester.pumpAndSettle();
    await tester.tap(tile);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('coursePanel.pick.${course.id}')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('coursePanel.info')), findsOneWidget);
    expect(find.text('نظري وعملي (2 مجاميع)'), findsOneWidget);
    expect(find.text('عدد المحاضرات المسجلة: 2'), findsOneWidget);
    expect(find.byKey(Key('coursePanel.class.${theory.id}')), findsOneWidget);
    // Two groups: one «عملي» row listing them.
    expect(find.byKey(Key('coursePanel.class.${groupA.id}')), findsNothing);
    await tester.tap(find.byKey(const Key('coursePanel.practical')));
    await tester.pumpAndSettle();
    expect(find.byKey(Key('coursePanel.class.${groupA.id}')), findsOneWidget);
    expect(find.text('بلا تدريسي'), findsOneWidget);
    expect(find.byKey(const Key('coursePanel.export')), findsOneWidget);

    await tester.tap(find.byKey(const Key('coursePanel.tab.lectures')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('coursePanel.session.${s1.id}')));
    await tester.pumpAndSettle();
    expect(find.descendant(of: find.byKey(const Key('coursePanel.lecture')), matching: find.text('زينب صالح مهدي حسن')),
        findsOneWidget);
    expect(find.descendant(of: find.byKey(const Key('coursePanel.lecture')), matching: find.text('أحمد علي حسين جاسم')),
        findsNothing);
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('coursePanel.tab.students')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('coursePanel.student.2')), findsOneWidget);
    await tester.enterText(find.byKey(const Key('coursePanel.search')), 'احمد');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('coursePanel.student.1')), findsOneWidget);
    expect(find.byKey(const Key('coursePanel.student.2')), findsNothing);

    // A class opens its register from the server.
    await tester.tap(find.byKey(const Key('coursePanel.tab.info')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('coursePanel.class.${theory.id}')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('register.table')), findsOneWidget);
  });

  testWidgets('an admin deletes one lecture from the panel; the other stays', (tester) async {
    final env = await pumpApp(
      tester,
      firestore: await seed(),
      user: MockUser(email: adminEmail, isEmailVerified: true),
      profile: AppUser(email: adminEmail, name: 'المدير', roles: const {UserRole.superAdmin}),
    );
    final tile = find.byKey(const Key('home.coursePanel'));
    await tester.ensureVisible(tile);
    await tester.pumpAndSettle();
    await tester.tap(tile);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('coursePanel.pick.${course.id}')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('coursePanel.tab.lectures')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('coursePanel.session.${s1.id}')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('coursePanel.deleteLecture')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'حذف'));
    await tester.pumpAndSettle();

    expect((await env.db.doc('sessions/${s1.id}').get()).exists, isFalse);
    expect((await env.db.doc('sessions/${s1.id}/records/2').get()).exists, isFalse);
    expect((await env.db.doc('sessions/${s2.id}').get()).exists, isTrue);
    expect((await env.db.doc('stats/${course.id}__2').get()).data()!['bySession'], {s2.id: 'absent'});
    expect(find.text('حُذفت المحاضرة.'), findsOneWidget);
    expect(find.byKey(Key('coursePanel.session.${s1.id}')), findsNothing);
    expect(find.byKey(Key('coursePanel.session.${s2.id}')), findsOneWidget);
  });

  testWidgets('a stage manager sees no delete button', (tester) async {
    await pumpApp(
      tester,
      firestore: await seed(),
      user: MockUser(email: 'sm@uobasrah.edu.iq', isEmailVerified: true),
      profile: AppUser(email: 'sm@uobasrah.edu.iq', name: 'م', roles: const {UserRole.stageManager}, stageScopes: [stage.id]),
    );
    final tile = find.byKey(const Key('home.coursePanel'));
    await tester.ensureVisible(tile);
    await tester.pumpAndSettle();
    await tester.tap(tile);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('coursePanel.pick.${course.id}')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('coursePanel.tab.lectures')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('coursePanel.session.${s1.id}')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('coursePanel.deleteLecture')), findsNothing);
  });
}
