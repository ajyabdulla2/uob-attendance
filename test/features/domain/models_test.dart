import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uob_attendance/core/domain/stage_ref.dart';
import 'package:uob_attendance/features/academic/domain/academic_year.dart';
import 'package:uob_attendance/features/academic/domain/stage.dart';
import 'package:uob_attendance/features/assignments/domain/assignment.dart';
import 'package:uob_attendance/features/attendance/domain/attendance_session.dart';
import 'package:uob_attendance/features/audit/domain/audit_entry.dart';
import 'package:uob_attendance/features/auth/domain/app_user.dart';
import 'package:uob_attendance/features/courses/domain/course.dart';
import 'package:uob_attendance/features/courses/domain/practical_group.dart';
import 'package:uob_attendance/features/edit_requests/domain/edit_request.dart';
import 'package:uob_attendance/features/leaves/domain/leave.dart';
import 'package:uob_attendance/features/stats/domain/student_course_stat.dart';
import 'package:uob_attendance/features/students/domain/student.dart';
import 'package:uob_attendance/features/warnings/domain/warning_list.dart';

void main() {
  group('Firestore round-trips (toMap → fromMap → toMap)', () {
    test('AppUser', () {
      const u = AppUser(
        email: 'SM@uob.iq',
        name: 'علي',
        title: 'مدرس',
        roles: {UserRole.teacher, UserRole.stageManager},
        stageScopes: ['3-morning'],
        teachingStages: ['3-morning', '1-evening'],
      );
      final map = u.toMap();
      expect(map['email'], 'sm@uob.iq');
      expect(map['roles'], ['stageManager', 'teacher']); // canonical order
      expect(map['departmentId'], 'cs');
      final back = AppUser.fromMap(u.id, map);
      expect(back.toMap(), map);
      expect(back.displayName, 'مدرس علي');
    });

    test('AppUser ignores unknown roles and defaults to inactive when absent', () {
      final u = AppUser.fromMap('x@y.iq', {'name': 'x', 'roles': ['teacher', 'dean']});
      expect(u.roles, {UserRole.teacher});
      expect(u.active, isFalse);
    });

    test('Student', () {
      final s = Student(
        universityId: '٢٠٢٦٠٠١',
        fullName: ' علي  حسين جاسم محمد ',
        stage: const StageRef(2, Shift.evening),
        section: 'ب',
        status: StudentStatus.transferredIn,
      );
      final map = s.toMap();
      expect(s.id, '2026001');
      expect(map['fullName'], 'علي حسين جاسم محمد');
      expect(map['stageId'], '2-evening');
      expect(map['level'], 2);
      expect(map['shift'], 'evening');
      expect(map['sortKey'], startsWith('علي حسين جاسم محمد|'));
      expect(Student.fromMap(s.id, map).toMap(), map);
    });

    test('Student.attendsLectures excludes carry-over and inactive statuses', () {
      Student s({bool carry = false, StudentStatus status = StudentStatus.continuing}) => Student(
          universityId: '1', fullName: 'x', stage: const StageRef(1, Shift.morning), carryOver: carry, status: status);
      expect(s().attendsLectures, isTrue);
      expect(s(status: StudentStatus.transferredIn).attendsLectures, isTrue);
      expect(s(carry: true).attendsLectures, isFalse);
      expect(s(status: StudentStatus.postponed).attendsLectures, isFalse);
      expect(s(status: StudentStatus.withdrawn).attendsLectures, isFalse);
      expect(s(status: StudentStatus.failedByAbsence).attendsLectures, isFalse);
    });

    test('Course, PracticalGroup', () {
      final c = Course(code: 'cs301', name: 'هياكل', stage: const StageRef(3, Shift.morning), semester: 1, units: 3, hasPractical: true);
      expect(c.id, 'CS301_3-morning');
      expect(Course.fromMap(c.id, c.toMap()).toMap(), c.toMap());
      final g = PracticalGroup(courseId: c.id, stageId: c.stageId, name: 'B', studentIds: const ['1', '2']);
      expect(g.id, 'CS301_3-morning__B');
      expect(PracticalGroup.fromMap(g.id, g.toMap()).toMap(), g.toMap());
    });

    test('PracticalGroup names', () {
      expect([for (var i = 0; i < 3; i++) PracticalGroup.nameFor(i)], ['A', 'B', 'C']);
      expect(PracticalGroup.nameFor(25), 'Z');
      expect(PracticalGroup.nameFor(26), 'AA');
    });

    test('Assignment', () {
      final theory = Assignment.theory(teacherId: 'T@x.iq', courseId: 'CS301_3-morning', stageId: '3-morning');
      expect(theory.id, 'CS301_3-morning__theory__all__t@x.iq');
      expect(theory.coversAllSections, isTrue);
      final section = Assignment.theory(teacherId: 't@x.iq', courseId: 'C_1-morning', stageId: '1-morning', section: ' أ ');
      expect(section.target, 'أ');
      final practical = Assignment.practical(teacherId: 't@x.iq', courseId: 'C_1-morning', stageId: '1-morning', groupName: 'A');
      expect(practical.id, 'C_1-morning__practical__A__t@x.iq');
      expect(practical.groupId, 'C_1-morning__A');
      expect(Assignment.fromMap(practical.id, practical.toMap()).toMap(), practical.toMap());
    });

    test('AcademicYear and Stage', () {
      const y = AcademicYear(id: '2026-2027', semester: 1, active: true, maxLeaveDays: 10);
      expect(AcademicYear.fromMap(y.id, y.toMap()).toMap(), y.toMap());
      expect(AcademicYear.idFor(DateTime(2026, 10, 4)), '2026-2027');
      expect(AcademicYear.idFor(DateTime(2027, 3, 1)), '2026-2027');
      const st = Stage(ref: StageRef(4, Shift.evening), sections: ['أ'], thresholds: AbsenceThresholds(alert: 4, warning: 8, dismissal: 12));
      expect(Stage.fromMap(st.id, st.toMap()).toMap(), st.toMap());
      expect(const AbsenceThresholds().isValid, isTrue);
      expect(const AbsenceThresholds(alert: 10, warning: 5, dismissal: 15).isValid, isFalse);
    });

    test('AttendanceSession: id, lock deadline and Timestamp fields', () {
      final date = DateTime(2026, 10, 4, 13, 30);
      final s = AttendanceSession(
        courseId: 'CS301_3-morning',
        stageId: '3-morning',
        yearId: '2026-2027',
        type: AssignmentType.theory,
        target: 'all',
        date: date,
        lectureNo: 1,
        openedBy: 't@x.iq',
        lockAt: AttendanceSession.lockAtFor(date, 48),
        counts: const {AttendanceStatus.absent: 3},
      );
      expect(s.id, 'CS301_3-morning__theory__all__20261004__1');
      expect(s.date, DateTime.utc(2026, 10, 4));
      expect(s.lockAt, DateTime.utc(2026, 10, 7)); // end of day + 48 h
      expect(s.isLockedAt(DateTime.utc(2026, 10, 6, 23)), isFalse);
      expect(s.isLockedAt(DateTime.utc(2026, 10, 7, 0, 1)), isTrue);
      final map = s.toMap();
      expect(map['date'], isA<Timestamp>());
      expect(map['dateKey'], '20261004');
      final back = AttendanceSession.fromMap(s.id, map);
      expect(back.counts[AttendanceStatus.absent], 3);
      expect(back.lockAt.toUtc(), s.lockAt);
    });

    test('AttendanceRecord, Leave, Stat, WarningList, EditRequest, AuditEntry', () {
      const r = AttendanceRecord(studentId: '1', status: AttendanceStatus.late, updatedBy: 't@x.iq', note: 'n');
      expect(AttendanceRecord.fromMap('1', r.toMap()).toMap(), r.toMap());

      final l = Leave(
        id: 'l1', studentId: '1', stageId: '1-morning', type: LeaveType.sick,
        from: DateTime.utc(2026, 10, 1), to: DateTime.utc(2026, 10, 3), approvedBy: 'sm@x.iq',
      );
      expect(l.days, 3);
      expect(l.covers(DateTime(2026, 10, 2, 22)), isTrue);
      expect(l.covers(DateTime(2026, 10, 4)), isFalse);
      expect(l.isApproved, isTrue);
      expect(Leave.fromMap('l1', l.toMap()).days, 3);

      const st = StudentCourseStat(courseId: 'c', studentId: '1', stageId: '1-morning', absences: 2, percent: 6.7, level: WarningLevel.alert);
      expect(st.id, 'c__1');
      expect(StudentCourseStat.fromMap(st.id, st.toMap()).toMap(), st.toMap());

      final w = WarningList(
        id: 'w', stageId: '1-morning', level: WarningLevel.warning, decision: DecisionType.deanery,
        orderNumber: '3/1', orderDate: DateTime.utc(2026, 12, 1),
        entries: const [WarningListEntry(studentId: '1', studentName: 'x', courseId: 'c', percent: 11)],
      );
      expect(w.isFinal, isTrue);
      expect(WarningList.fromMap('w', w.toMap()).entries.single.percent, 11);

      const e = EditRequest(
        id: 'e', sessionId: 's', studentId: '1', stageId: '1-morning',
        requestedStatus: AttendanceStatus.present, reason: 'r', requestedBy: 't@x.iq',
      );
      expect(EditRequest.fromMap('e', e.toMap()).toMap(), e.toMap());

      const a = AuditEntry(actor: 'a', action: 'x', targetPath: 'p', before: {'s': 1});
      expect(AuditEntry.fromMap(a.toMap()).toMap(), a.toMap());
    });
  });
}
