import 'package:flutter_test/flutter_test.dart';
import 'package:uob_attendance/core/domain/stage_ref.dart';
import 'package:uob_attendance/features/auth/domain/app_user.dart';
import 'package:uob_attendance/features/courses/domain/course.dart';
import 'package:uob_attendance/features/import/domain/import_models.dart';
import 'package:uob_attendance/features/import/domain/import_parsers.dart';
import 'package:uob_attendance/features/students/domain/student.dart';

SheetTable table(List<String> headers, List<List<String>> rows) =>
    SheetTable(headers: headers, rows: rows);

List<IssueCode> codes(ImportRow<Object?> row) => [for (final i in row.issues) i.code];

const studentHeaders = ['الاسم الرباعي', 'الرقم الجامعي', 'المرحلة', 'الدراسة', 'الشعبة', 'الحالة', 'محمّل'];

void main() {
  group('parseStudents', () {
    test('parses valid rows into students to create', () {
      final preview = parseStudents(
        table(studentHeaders, [
          ['علي حسين جاسم محمد', '٢٠٢٦٠٠١', 'الأولى', 'صباحي', 'أ', 'مستمر', 'لا'],
          ['زينب كاظم عبد الله علي', '2026002.0', '3', 'مسائي', '', 'منقول إلى القسم', 'نعم'],
        ]),
        existing: const {},
      );
      expect(preview.fileIssues, isEmpty);
      expect(preview.count(RowAction.create), 2);
      final first = preview.rows[0].entity!;
      expect(first.universityId, '2026001');
      expect(first.stageId, '1-morning');
      expect(first.section, 'أ');
      final second = preview.rows[1].entity!;
      expect(second.universityId, '2026002');
      expect(second.stageId, '3-evening');
      expect(second.status, StudentStatus.transferredIn);
      expect(second.carryOver, isTrue);
      expect(second.attendsLectures, isFalse); // محمّل
      expect(preview.canCommit, isTrue);
      expect(preview.rows[0].rowNumber, 2);
    });

    test('reports missing required columns as a file error', () {
      final preview = parseStudents(table(['الاسم'], [['علي']]), existing: const {});
      expect(preview.hasFileErrors, isTrue);
      expect(preview.fileIssues.single.code, IssueCode.missingColumn);
      expect(preview.fileIssues.single.params['column'], 'الرقم الجامعي');
      expect(preview.canCommit, isFalse);
    });

    test('accepts English headers and ignores unknown columns', () {
      final preview = parseStudents(
        table(['Notes', 'Full Name', 'University ID', 'Level', 'Shift'], [
          ['x', 'Ali Hussein Jasim Mohammed', '1', 'first', 'morning'],
        ]),
        existing: const {},
      );
      expect(preview.fileIssues, isEmpty);
      expect(preview.rows.single.entity!.stageId, '1-morning');
    });

    test('flags empty fields and invalid values per row, skipping blank rows', () {
      final preview = parseStudents(
        table(studentHeaders, [
          ['', '1', '1', 'صباحي', '', '', ''],
          ['', '', '', '', '', '', ''],
          ['اسم رباعي كامل هنا', '2', 'خامسة', 'ليلي', '', 'متخرج', 'ربما'],
        ]),
        existing: const {},
      );
      expect(preview.rows, hasLength(2)); // blank row skipped
      expect(codes(preview.rows[0]), [IssueCode.emptyField]);
      expect(preview.rows[0].action, RowAction.invalid);
      expect(preview.rows[1].rowNumber, 4);
      expect(
        codes(preview.rows[1]),
        containsAll([IssueCode.invalidLevel, IssueCode.invalidShift, IssueCode.invalidStatus, IssueCode.invalidYesNo]),
      );
      expect(preview.canCommit, isFalse);
    });

    test('detects duplicate university IDs and names inside the file', () {
      final preview = parseStudents(
        table(studentHeaders, [
          ['علي حسين جاسم محمد', '100', '1', 'صباحي', '', '', ''],
          ['علي حسين جاسم محمد', '100', '1', 'صباحي', '', '', ''],
          ['عليّ حسين جاسم محمد', '101', '1', 'صباحي', '', '', ''],
        ]),
        existing: const {},
      );
      expect(preview.rows[0].action, RowAction.create);
      expect(preview.rows[1].action, RowAction.invalid);
      expect(preview.rows[1].issues.single.code, IssueCode.duplicateIdInFile);
      expect(preview.rows[1].issues.single.params['row'], '2');
      // Same name (diacritics ignored) with another ID: warning only.
      expect(preview.rows[2].action, RowAction.create);
      expect(codes(preview.rows[2]), [IssueCode.duplicateNameInFile]);
    });

    test('existing IDs are skipped by default and updated with «تحديث الموجود»', () {
      final existing = {
        '100': Student(
          universityId: '100',
          fullName: 'علي حسين جاسم محمد',
          stage: const StageRef(1, Shift.morning),
          status: StudentStatus.withdrawn,
          section: 'ب',
        ),
      };
      final rows = [
        ['علي حسين جاسم محمد', '100', '', '', '', '', ''],
      ];
      // File without status/section columns.
      final narrow = table(['الاسم الرباعي', 'الرقم الجامعي'], [
        ['علي حسين جاسم محمد', '100'],
      ]);

      final skip = parseStudents(table(studentHeaders, rows), existing: existing);
      expect(skip.rows.single.action, RowAction.skip);
      expect(codes(skip.rows.single), contains(IssueCode.existsWillSkip));
      expect(skip.canCommit, isFalse);

      final update = parseStudents(narrow, existing: existing, options: const ImportOptions(updateExisting: true));
      final row = update.rows.single;
      expect(row.action, RowAction.update);
      // Columns absent from the file keep their current values.
      expect(row.entity!.status, StudentStatus.withdrawn);
      expect(row.entity!.section, 'ب');
      expect(row.entity!.stageId, '1-morning');
    });

    test('warns when a name already exists under another university ID', () {
      final existing = {
        '555': Student(universityId: '555', fullName: 'علي حسين جاسم محمد', stage: const StageRef(1, Shift.morning)),
      };
      final preview = parseStudents(
        table(studentHeaders, [
          ['علي حسين جاسم محمّد', '556', '1', 'صباحي', '', '', ''],
        ]),
        existing: existing,
      );
      expect(preview.rows.single.action, RowAction.create);
      expect(codes(preview.rows.single), [IssueCode.nameMatchesOtherRecord]);
      expect(preview.rows.single.issues.single.params['value'], '555');
    });

    test('uses the default stage when the file has no stage columns', () {
      final preview = parseStudents(
        table(['الاسم الرباعي', 'الرقم الجامعي'], [
          ['علي حسين جاسم محمد', '1'],
        ]),
        existing: const {},
        options: const ImportOptions(defaultStage: StageRef(2, Shift.evening)),
      );
      expect(preview.rows.single.entity!.stageId, '2-evening');

      final noDefault = parseStudents(
        table(['الاسم الرباعي', 'الرقم الجامعي'], [
          ['علي حسين جاسم محمد', '1'],
        ]),
        existing: const {},
      );
      expect(noDefault.rows.single.action, RowAction.invalid);
    });

    test('stage managers cannot import into stages outside their scope', () {
      final preview = parseStudents(
        table(studentHeaders, [
          ['علي حسين جاسم محمد', '1', '3', 'صباحي', '', '', ''],
          ['علي حسين جاسم حسن', '2', '4', 'صباحي', '', '', ''],
        ]),
        existing: const {},
        options: const ImportOptions(allowedStageIds: {'3-morning'}),
      );
      expect(preview.rows[0].action, RowAction.create);
      expect(preview.rows[1].action, RowAction.invalid);
      expect(codes(preview.rows[1]), [IssueCode.stageNotAllowed]);
    });

    test('warns about names that are not four-part and about stage moves', () {
      final existing = {
        '1': Student(universityId: '1', fullName: 'علي حسين', stage: const StageRef(1, Shift.morning)),
      };
      final preview = parseStudents(
        table(studentHeaders, [
          ['علي حسين', '1', '2', 'صباحي', '', '', ''],
        ]),
        existing: existing,
        options: const ImportOptions(updateExisting: true),
      );
      expect(codes(preview.rows.single),
          containsAll([IssueCode.movesStage, IssueCode.nameNotFourPart, IssueCode.existsWillUpdate]));
    });
  });

  group('parseTeachers', () {
    const headers = ['الاسم', 'اللقب العلمي', 'البريد الجامعي', 'الهاتف'];

    test('creates teacher accounts keyed by lower-cased e-mail', () {
      final preview = parseTeachers(
        table(headers, [
          ['محمد سلمان', 'مدرس', 'M.Salman@UoBasrah.edu.iq', '7701234567'],
        ]),
        existing: const {},
      );
      final user = preview.rows.single.entity!;
      expect(user.id, 'm.salman@uobasrah.edu.iq');
      expect(user.roles, {UserRole.teacher});
      expect(user.active, isTrue);
      expect(user.phone, '07701234567');
      expect(preview.rows.single.action, RowAction.create);
    });

    test('rejects invalid and duplicate e-mails', () {
      final preview = parseTeachers(
        table(headers, [
          ['أ', '', 'not-an-email', ''],
          ['ب', '', 'x@uob.iq', ''],
          ['ج', '', 'X@uob.iq ', ''],
        ]),
        existing: const {},
      );
      expect(codes(preview.rows[0]), [IssueCode.invalidEmail]);
      expect(preview.rows[1].action, RowAction.create);
      expect(codes(preview.rows[2]), [IssueCode.duplicateEmailInFile]);
    });

    test('updating keeps roles and scopes, refreshing profile fields only', () {
      final existing = {
        'sm@uob.iq': const AppUser(
          email: 'sm@uob.iq',
          name: 'قديم',
          phone: '0780',
          roles: {UserRole.stageManager, UserRole.teacher},
          stageScopes: ['3-morning'],
        ),
      };
      final preview = parseTeachers(
        table(['الاسم', 'البريد الجامعي'], [
          ['جديد', 'sm@uob.iq'],
        ]),
        existing: existing,
        options: const ImportOptions(updateExisting: true),
      );
      final user = preview.rows.single.entity!;
      expect(preview.rows.single.action, RowAction.update);
      expect(user.name, 'جديد');
      expect(user.phone, '0780'); // column absent → kept
      expect(user.roles, {UserRole.stageManager, UserRole.teacher});
      expect(user.stageScopes, ['3-morning']);
    });

    test('only the super admin may update admin accounts', () {
      final existing = {
        'boss@uob.iq': const AppUser(email: 'boss@uob.iq', name: 'المدير', roles: {UserRole.superAdmin}),
      };
      final rows = table(headers, [
        ['المدير', '', 'boss@uob.iq', ''],
      ]);
      final deputy = parseTeachers(rows, existing: existing, options: const ImportOptions(updateExisting: true));
      expect(codes(deputy.rows.single), [IssueCode.protectedAdminAccount]);
      final superAdmin = parseTeachers(rows,
          existing: existing, options: const ImportOptions(updateExisting: true, canEditAdmins: true));
      expect(superAdmin.rows.single.action, RowAction.update);
    });
  });

  group('parseCourses', () {
    const headers = ['رمز المادة', 'اسم المادة', 'المرحلة', 'الدراسة', 'الفصل', 'الوحدات', 'فيها عملي'];

    test('«كلاهما» (or empty) produces one course per shift', () {
      final preview = parseCourses(
        table(headers, [
          ['cs 101', 'أساسيات البرمجة', 'الأولى', 'كلاهما', '1', '3', 'نعم'],
          ['CS305', 'الاحتسابية', '3', 'صباحي', 'الثاني', '2', 'لا'],
          ['CS205', 'قواعد البيانات', '2', '', '', '3.0', ''],
        ]),
        existing: const {},
        options: const ImportOptions(defaultSemester: 2),
      );
      expect(preview.rows.map((r) => r.action), everyElement(RowAction.create));
      expect([for (final c in preview.rows[0].entity!) c.id], ['CS101_1-morning', 'CS101_1-evening']);
      expect(preview.rows[0].entity!.first.hasPractical, isTrue);
      final cs305 = preview.rows[1].entity!.single;
      expect(cs305.semester, 2);
      expect(cs305.units, 2);
      final cs205 = preview.rows[2].entity!;
      expect(cs205, hasLength(2));
      expect(cs205.first.semester, 2); // default
      expect(cs205.first.hasPractical, isFalse);
    });

    test('validates units and detects duplicate course codes per stage', () {
      final preview = parseCourses(
        table(headers, [
          ['CS1', 'أ', '1', 'صباحي', '1', '0', ''],
          ['CS2', 'ب', '1', 'صباحي', '1', 'ثلاث', ''],
          ['CS3', 'ج', '1', 'كلاهما', '1', '2', ''],
          ['cs3', 'ج', '1', 'مسائي', '1', '2', ''],
        ]),
        existing: const {},
      );
      expect(codes(preview.rows[0]), [IssueCode.invalidUnits]);
      expect(codes(preview.rows[1]), [IssueCode.invalidUnits]);
      expect(preview.rows[2].action, RowAction.create);
      expect(codes(preview.rows[3]), [IssueCode.duplicateCodeInFile]);
    });

    test('existing courses are updated only with «تحديث الموجود»', () {
      final existing = {
        'CS9_4-morning': Course(
          code: 'CS9',
          name: 'قديمة',
          stage: const StageRef(4, Shift.morning),
          semester: 2,
          units: 2,
          hasPractical: true,
        ),
      };
      final rows = table(['رمز المادة', 'اسم المادة', 'المرحلة', 'الدراسة', 'الوحدات'], [
        ['CS9', 'جديدة', '4', 'صباحي', '3'],
      ]);
      expect(parseCourses(rows, existing: existing).rows.single.action, RowAction.skip);
      final update = parseCourses(rows, existing: existing, options: const ImportOptions(updateExisting: true));
      final course = update.rows.single.entity!.single;
      expect(update.rows.single.action, RowAction.update);
      expect(course.name, 'جديدة');
      expect(course.semester, 2); // absent column → kept
      expect(course.hasPractical, isTrue);
    });
  });

  test('a file with headers only has no data rows', () {
    final preview = parseCourses(
      table(['رمز المادة', 'اسم المادة', 'المرحلة', 'الوحدات'], const []),
      existing: const {},
    );
    expect(preview.fileIssues.single.code, IssueCode.noDataRows);
  });
}
