import 'package:flutter_test/flutter_test.dart';
import 'package:uob_attendance/core/firebase/doc_ids.dart';
import 'package:uob_attendance/features/assignments/domain/assignment.dart';
import 'package:uob_attendance/features/attendance/domain/attendance_session.dart';
import 'package:uob_attendance/features/attendance/domain/missed_lecture.dart';

void main() {
  const stage = '1-morning';
  Assignment theory(String teacher, {String course = 'CS101_1-morning', String name = 'البرمجة'}) =>
      Assignment.theory(teacherId: teacher, courseId: course, stageId: stage, courseName: name);
  Assignment practical(String group, {String course = 'CS101_1-morning'}) => Assignment.practical(
      teacherId: 't@x', courseId: course, stageId: stage, groupName: group, courseName: 'البرمجة');
  final day = DateTime.utc(2026, 10, 5);
  AttendanceSession session(Assignment a, int no, {DateTime? date}) => AttendanceSession(
        courseId: a.courseId,
        stageId: stage,
        yearId: '2026-2027',
        type: a.type,
        target: a.target,
        groupId: a.groupId,
        date: date ?? day,
        lectureNo: no,
        openedBy: 't@x',
        lockAt: AttendanceSession.lockAtFor(date ?? day, 48),
      );

  test('one entry per class, theory before practical groups, by course name', () {
    final list = MissedLecture.classes([
      practical('B'),
      theory('a@x'),
      theory('b@x'), // a second teacher of the same theory class
      practical('A'),
      theory('c@x', course: 'CS100_1-morning', name: 'الأساسيات'),
    ]);
    expect([for (final a in list) '${a.courseId} ${a.type.name} ${a.target}'], [
      'CS100_1-morning theory ${DocIds.allSections}',
      'CS101_1-morning theory ${DocIds.allSections}',
      'CS101_1-morning practical A',
      'CS101_1-morning practical B',
    ]);
  });

  test('the next lecture number counts only that class on that day', () {
    final cls = theory('a@x');
    expect(MissedLecture.nextLectureNo(cls, const [], day), 1);
    final sessions = [
      session(cls, 1),
      session(cls, 2),
      session(practical('A'), 5), // another class
      session(cls, 7, date: day.add(const Duration(days: 1))), // another day
    ];
    expect(MissedLecture.nextLectureNo(cls, sessions, day), 3);
  });

  test('counts and the tap cycle', () {
    expect(MissedLecture.counts({'1': AttendanceStatus.absent, '2': AttendanceStatus.absent, '3': AttendanceStatus.present}), {
      AttendanceStatus.present: 1,
      AttendanceStatus.absent: 2,
      AttendanceStatus.late: 0,
      AttendanceStatus.excused: 0,
    });
    expect(MissedLecture.next(AttendanceStatus.present), AttendanceStatus.absent);
    expect(MissedLecture.next(AttendanceStatus.absent), AttendanceStatus.late);
    expect(MissedLecture.next(AttendanceStatus.late), AttendanceStatus.excused);
    expect(MissedLecture.next(AttendanceStatus.excused), AttendanceStatus.present);
  });
}
