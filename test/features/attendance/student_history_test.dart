import 'package:flutter_test/flutter_test.dart';
import 'package:uob_attendance/features/attendance/domain/attendance_session.dart';
import 'package:uob_attendance/features/stats/domain/absence_entry.dart';
import 'package:uob_attendance/features/stats/domain/student_course_stat.dart';

void main() {
  const c = 'CS101_1-morning';
  test('absences newest first, present skipped, leave days marked, type filter', () {
    final entries = AbsenceEntry.of({
      '${c}__theory__all__20261001__1': AttendanceStatus.absent,
      '${c}__theory__all__20261005__2': AttendanceStatus.late,
      '${c}__theory__all__20261005__1': AttendanceStatus.absent,
      '${c}__practical__A__20261003__1': AttendanceStatus.excused,
      '${c}__theory__all__20261004__1': AttendanceStatus.present,
    }, leaveDays: {'20261001'});
    expect(entries.map((e) => '${e.date!.day}/${e.lectureNo}/${e.status.name}'),
        ['5/2/late', '5/1/absent', '3/1/excused', '1/1/absent']);
    expect(entries.last.onLeave, isTrue);
    expect(entries.first.onLeave, isFalse);

    final theory = AbsenceEntry.of({
      '${c}__theory__all__20261001__1': AttendanceStatus.absent,
      '${c}__practical__A__20261003__1': AttendanceStatus.absent,
    }, leaveDays: const {}, type: 'practical');
    expect(theory.single.type, 'practical');
  });

  test('an excluded lecture («لا تُحتسب») is left out of a student\'s statuses', () {
    final stat = StudentCourseStat.fromMap('${c}__1', {
      'courseId': c,
      'studentId': '1',
      'stageId': '1-morning',
      'bySession': {
        '${c}__theory__all__20261001__1': 'absent',
        '${c}__theory__all__20261002__1': AttendanceSession.excludedValue,
      },
    });
    expect(stat.bySession.keys, ['${c}__theory__all__20261001__1']);
    expect(AttendanceSession.fromMap('x', {'excluded': true}).excluded, isTrue);
    expect(AttendanceSession.fromMap('x', {}).excluded, isFalse);
  });
}
