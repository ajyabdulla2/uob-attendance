import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uob_attendance/core/domain/stage_ref.dart';
import 'package:uob_attendance/features/courses/domain/course.dart';
import 'package:uob_attendance/features/students/data/students_repository.dart';
import 'package:uob_attendance/features/students/domain/student.dart';

void main() {
  const evening = StageRef(1, Shift.evening);
  const morning = StageRef(1, Shift.morning);

  test('a hosted student moves from the evening study to the morning one with their absences', () async {
    final db = FakeFirebaseFirestore();
    final student = Student(universityId: '7', fullName: 'سارة علي حسن كاظم', stage: evening, section: 'ب');
    await db.doc('students/7').set(student.toMap());
    for (final (code, stage) in [('CS101', evening), ('CS102', evening), ('CS101', morning)]) {
      final c = Course(code: code, name: code, stage: stage, semester: 1, units: 2, hasPractical: true);
      await db.doc('courses/${c.id}').set(c.toMap());
    }
    await db.doc('groups/CS101_1-evening__B').set({
      'courseId': 'CS101_1-evening', 'stageId': evening.id, 'name': 'B', 'studentIds': ['7', '8'],
    });
    await db.doc('groups/CS101_1-morning__A').set({
      'courseId': 'CS101_1-morning', 'stageId': morning.id, 'name': 'A', 'studentIds': ['1'],
    });
    const absent = 'CS101_1-evening__theory__all__20261101__1';
    await db.doc('stats/CS101_1-evening__7').set({
      'courseId': 'CS101_1-evening', 'studentId': '7', 'stageId': evening.id, 'bySession': {absent: 'absent'},
    });
    await db.doc('stats/CS102_1-evening__7').set({
      'courseId': 'CS102_1-evening', 'studentId': '7', 'stageId': evening.id,
      'bySession': {'CS102_1-evening__theory__all__20261102__1': 'absent'},
    });
    await db.doc('leaves/l1').set({'studentId': '7', 'stageId': evening.id, 'type': 'sick'});

    final notCarried = await StudentsRepository(db).transfer(
      student,
      to: morning,
      section: 'أ',
      groupIds: ['CS101_1-morning__A'],
      actor: 'sm@uob.iq',
    );

    expect(notCarried, ['CS102'], reason: 'the morning stage has no CS102');
    final moved = (await db.doc('students/7').get()).data()!;
    expect([moved['stageId'], moved['shift'], moved['section']], [morning.id, 'morning', 'أ']);
    expect((await db.doc('groups/CS101_1-evening__B').get()).data()!['studentIds'], ['8']);
    expect((await db.doc('groups/CS101_1-morning__A').get()).data()!['studentIds'], ['1', '7']);
    final carried = (await db.doc('stats/CS101_1-morning__7').get()).data()!;
    expect(carried['stageId'], morning.id);
    expect(carried['bySession'], {absent: 'absent'}, reason: 'the percentage carries on');
    expect((await db.doc('stats/CS101_1-evening__7').get()).exists, isTrue, reason: 'history stays');
    expect((await db.doc('leaves/l1').get()).data()!['stageId'], morning.id);
    final audit = (await db.collection('auditLog').get()).docs.single.data();
    expect(audit['action'], 'student.transfer');
  });
}
