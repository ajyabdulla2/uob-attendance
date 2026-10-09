import 'package:flutter_test/flutter_test.dart';
import 'package:uob_attendance/core/domain/stage_ref.dart';
import 'package:uob_attendance/features/academic/domain/academic_year.dart';
import 'package:uob_attendance/features/auth/domain/app_user.dart';
import 'package:uob_attendance/features/auth/domain/permissions.dart';
import 'package:uob_attendance/features/courses/domain/group_distribution.dart';
import 'package:uob_attendance/features/import/domain/value_parsers.dart';
import 'package:uob_attendance/features/stats/domain/student_course_stat.dart';
import 'package:uob_attendance/features/students/domain/student.dart';

Student student(String name, String id, {bool carry = false, StudentStatus status = StudentStatus.continuing}) =>
    Student(universityId: id, fullName: name, stage: const StageRef(1, Shift.morning), carryOver: carry, status: status);

void main() {
  group('Permissions (mirror of the SPEC matrix)', () {
    Permissions p(Set<UserRole> roles, {List<String> scopes = const [], bool active = true}) =>
        Permissions(AppUser(email: 'a@b.iq', name: 'x', roles: roles, stageScopes: scopes, active: active));

    test('super admin can do everything', () {
      final perms = p({UserRole.superAdmin});
      expect(perms.isAdmin, isTrue);
      expect(perms.canImportTeachers && perms.canImportCourses && perms.canImportStudents, isTrue);
      expect(perms.manageableStages, hasLength(8));
      expect(UserRole.values.every(perms.canGrantRole), isTrue);
      expect(perms.canRestore, isTrue);
    });

    test('deputy admin: operational powers, but never grants admin roles nor restores', () {
      final perms = p({UserRole.deputyAdmin});
      expect(perms.canImportTeachers, isTrue);
      expect(perms.canGrantRole(UserRole.teacher), isTrue);
      expect(perms.canGrantRole(UserRole.stageManager), isTrue);
      expect(perms.canGrantRole(UserRole.deputyAdmin), isFalse);
      expect(perms.canGrantRole(UserRole.superAdmin), isFalse);
      expect(perms.canEditAccount(const AppUser(email: 's@b.iq', name: 's', roles: {UserRole.superAdmin})), isFalse);
      expect(perms.canEditAccount(const AppUser(email: 't@b.iq', name: 't')), isTrue);
      expect(perms.canBackup, isTrue);
      expect(perms.canRestore, isFalse);
    });

    test('stage manager: students of their stages and links only', () {
      final perms = p({UserRole.stageManager, UserRole.teacher}, scopes: ['3-morning', '3-evening']);
      expect(perms.canImportStudents, isTrue);
      expect(perms.canImportStudentsInto('3-morning'), isTrue);
      expect(perms.canImportStudentsInto('2-morning'), isFalse);
      expect(perms.canImportTeachers || perms.canImportCourses, isFalse);
      expect(perms.canManageAssignments, isTrue);
      expect(perms.manageableStages.map((s) => s.id), ['3-morning', '3-evening']);
      expect(perms.canManageAccounts, isFalse);
    });

    test('teacher records attendance only', () {
      final perms = p({UserRole.teacher});
      expect(perms.canRecordAttendance, isTrue);
      expect(perms.canImportAnything, isFalse);
      expect(perms.canManageAssignments, isFalse);
      expect(perms.manageableStages, isEmpty);
    });

    test('a suspended account has no powers at all', () {
      final perms = p({UserRole.superAdmin}, active: false);
      expect(perms.isAdmin, isFalse);
      expect(perms.canRecordAttendance, isFalse);
      expect(perms.manageableStages, isEmpty);
    });
  });

  group('distributeAlphabetically', () {
    test('splits evenly in alphabetical order; earlier groups take the remainder', () {
      final students = [
        student('هدى', '5'), student('باقر', '2'), student('أحمد', '1'), student('زينب', '4'),
        student('حسن', '3'), student('يوسف', '6'), student('مريم', '7'),
      ];
      final groups = distributeAlphabetically(students, 3);
      expect(groups.map((g) => g.length), [3, 2, 2]);
      expect(groups.expand((g) => g).map((s) => s.fullName), ['أحمد', 'باقر', 'حسن', 'زينب', 'مريم', 'هدى', 'يوسف']);
    });

    test('skips carry-over and non-attending students', () {
      final groups = distributeAlphabetically([
        student('أ', '1'),
        student('ب', '2', carry: true),
        student('ت', '3', status: StudentStatus.withdrawn),
        student('ث', '4', status: StudentStatus.transferredIn),
      ], 2);
      expect(groups.map((g) => g.map((s) => s.id).toList()), [['1'], ['4']]);
    });

    test('more groups than students gives empty groups; invalid count throws', () {
      expect(distributeAlphabetically([student('أ', '1')], 3).map((g) => g.length), [1, 0, 0]);
      expect(() => distributeAlphabetically(const [], 0), throwsArgumentError);
    });
  });

  group('AbsenceMath', () {
    const t = AbsenceThresholds(alert: 5, warning: 10, dismissal: 15);

    test('planned lectures from units and weeks', () {
      expect(AbsenceMath.plannedLectures(units: 3, weeks: 15), 45);
      expect(AbsenceMath.plannedLectures(units: 2, weeks: 15, lecturesPerUnitPerWeek: 0.5), 15);
    });

    test('one absence weighs more in a low-unit course', () {
      final low = AbsenceMath.percent(1, AbsenceMath.plannedLectures(units: 1, weeks: 15));
      final high = AbsenceMath.percent(1, AbsenceMath.plannedLectures(units: 4, weeks: 15));
      expect(low, greaterThan(high));
      expect(AbsenceMath.percent(3, 0), 0);
    });

    test('levels follow the thresholds', () {
      expect(AbsenceMath.levelFor(4.9, t), WarningLevel.none);
      expect(AbsenceMath.levelFor(5, t), WarningLevel.alert);
      expect(AbsenceMath.levelFor(10, t), WarningLevel.warning);
      expect(AbsenceMath.levelFor(15.1, t), WarningLevel.dismissal);
    });

    test('«سيصل للإنذار بعد غياب واحد»', () {
      // 30 planned lectures: warning at 10% = 3 absences.
      expect(AbsenceMath.absencesUntil(WarningLevel.warning, unexcusedAbsences: 2, plannedLectures: 30, thresholds: t), 1);
      expect(AbsenceMath.absencesUntil(WarningLevel.warning, unexcusedAbsences: 3, plannedLectures: 30, thresholds: t), 0);
      expect(AbsenceMath.absencesUntil(WarningLevel.dismissal, unexcusedAbsences: 0, plannedLectures: 45, thresholds: t), 7);
    });
  });

  group('ValueParsers', () {
    test('level', () {
      for (final v in ['1', '١', 'الأولى', 'الاولى', 'المرحلة الأولى', 'first', '1.0']) {
        expect(ValueParsers.level(v), 1, reason: v);
      }
      expect(ValueParsers.level('الرابعة'), 4);
      expect(ValueParsers.level('الثالثة'), 3);
      expect(ValueParsers.level('الثانية'), 2);
      for (final v in ['', '5', '13', 'خامسة']) {
        expect(ValueParsers.level(v), isNull, reason: v);
      }
    });

    test('shift(s)', () {
      expect(ValueParsers.shift('صباحي'), Shift.morning);
      expect(ValueParsers.shift('الدراسة الصباحية'), Shift.morning);
      expect(ValueParsers.shift('مسائي'), Shift.evening);
      expect(ValueParsers.shift('Evening'), Shift.evening);
      expect(ValueParsers.shift('ليلي'), isNull);
      expect(ValueParsers.shifts('كلاهما'), Shift.values);
      expect(ValueParsers.shifts('صباحي ومسائي'), Shift.values);
      expect(ValueParsers.shifts('مسائي'), [Shift.evening]);
    });

    test('status', () {
      expect(ValueParsers.status(''), StudentStatus.continuing);
      expect(ValueParsers.status('مؤجل'), StudentStatus.postponed);
      expect(ValueParsers.status('راسب بالغياب'), StudentStatus.failedByAbsence);
      expect(ValueParsers.status('منسحب'), StudentStatus.withdrawn);
      expect(ValueParsers.status('منقول إلى القسم'), StudentStatus.transferredIn);
      expect(ValueParsers.status('متخرج'), isNull);
    });

    test('yes/no, semester, units, email, phone', () {
      expect(ValueParsers.yesNo('نعم'), isTrue);
      expect(ValueParsers.yesNo('لا'), isFalse);
      expect(ValueParsers.yesNo(''), isFalse);
      expect(ValueParsers.yesNo('', fallback: true), isTrue);
      expect(ValueParsers.yesNo('ربما'), isNull);
      expect(ValueParsers.semester('الثاني'), 2);
      expect(ValueParsers.semester('', fallback: 1), 1);
      expect(ValueParsers.semester('3'), isNull);
      expect(ValueParsers.semester('سنوي'), 1);
      expect(ValueParsers.semester('Annual'), 1);
      expect(ValueParsers.units('٣'), 3);
      expect(ValueParsers.units('2.5'), isNull);
      expect(ValueParsers.units('0'), isNull);
      expect(ValueParsers.email(' A@B.iq '), 'a@b.iq');
      expect(ValueParsers.email('a@b'), isNull);
      expect(ValueParsers.phone('٠٧٧٠ ١٢٣ ٤٥٦٧'), '07701234567');
      expect(ValueParsers.phone('7701234567'), '07701234567');
      expect(ValueParsers.phone('+964 770 123 4567'), '+9647701234567');
    });
  });
}
