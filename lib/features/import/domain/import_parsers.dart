import '../../../core/domain/stage_ref.dart';
import '../../../core/firebase/doc_ids.dart';
import '../../../core/utils/arabic_text.dart';
import '../../auth/domain/app_user.dart';
import '../../courses/domain/course.dart';
import '../../students/domain/student.dart';
import 'import_columns.dart';
import 'import_models.dart';
import 'value_parsers.dart';

/// Options shared by all imports.
final class ImportOptions {
  const ImportOptions({
    this.updateExisting = false,
    this.defaultStage,
    this.defaultSemester = 1,
    this.allowedStageIds,
    this.canEditAdmins = false,
  });

  /// «تحديث الموجود»: rows whose key already exists update the record instead
  /// of being skipped.
  final bool updateExisting;

  /// Students: stage used when the file has no level/shift columns or cells.
  final StageRef? defaultStage;

  /// Courses: semester used when the cell is empty.
  final int defaultSemester;

  /// Students: stages the importer may write (null = any — admins).
  final Set<String>? allowedStageIds;

  /// Teachers: only the super admin may update accounts holding admin roles.
  final bool canEditAdmins;
}

/// Accessor for one row with matched columns.
final class _Row {
  _Row(this.cells, this.columns);
  final List<String> cells;
  final Map<String, int> columns;

  bool has(String key) => columns.containsKey(key);
  String operator [](String key) {
    final i = columns[key];
    return i == null ? '' : ArabicText.collapseSpaces(cells[i]);
  }
}

typedef _Parsed<T> = ({T? entity, List<ImportIssue> issues});

/// Shared skeleton: header matching, empty-row skipping, and key-based
/// duplicate detection (in the file and against existing records).
ImportPreview<T> _parse<T>({
  required ImportKind kind,
  required SheetTable table,
  required _Parsed<T> Function(_Row row) parseRow,
  required List<String> Function(T entity) keysOf,
  required IssueCode duplicateKeyCode,
  required bool Function(String key) exists,
  required ImportOptions options,
  List<ImportIssue> Function(T entity, int rowNumber)? extraChecks,
}) {
  final columns = ImportColumns.of(kind);
  final matched = ImportColumns.match(table.headers, columns);
  final fileIssues = <ImportIssue>[
    for (final c in columns)
      if (c.required && !matched.containsKey(c.key))
        ImportIssue.error(IssueCode.missingColumn, field: c.key, params: {'column': c.templateHeader}),
  ];

  final rows = <ImportRow<T>>[];
  final seenKeys = <String, int>{};

  if (fileIssues.isEmpty) {
    for (var i = 0; i < table.rows.length; i++) {
      final cells = table.rows[i];
      if (cells.every((c) => c.trim().isEmpty)) continue;
      final rowNumber = SheetTable.rowNumberOf(i);
      final parsed = parseRow(_Row(cells, matched));
      final issues = [...parsed.issues];
      final entity = parsed.entity;

      if (entity != null) {
        final keys = keysOf(entity);
        for (final key in keys) {
          final firstRow = seenKeys[key];
          if (firstRow != null) {
            issues.add(ImportIssue.error(duplicateKeyCode, params: {'row': '$firstRow', 'value': key}));
          }
        }
        if (!issues.any((x) => x.isError)) {
          for (final key in keys) {
            seenKeys[key] = rowNumber;
          }
          issues.addAll(extraChecks?.call(entity, rowNumber) ?? const []);
        }
      }

      final RowAction action;
      if (entity == null || issues.any((x) => x.isError)) {
        action = RowAction.invalid;
      } else if (keysOf(entity).any(exists)) {
        if (options.updateExisting) {
          action = RowAction.update;
          issues.add(const ImportIssue.info(IssueCode.existsWillUpdate));
        } else {
          action = RowAction.skip;
          issues.add(const ImportIssue.warning(IssueCode.existsWillSkip));
        }
      } else {
        action = RowAction.create;
      }

      rows.add(ImportRow(
        rowNumber: rowNumber,
        cells: cells,
        action: action,
        entity: action == RowAction.invalid ? null : entity,
        issues: issues,
      ));
    }
    if (rows.isEmpty) fileIssues.add(const ImportIssue.error(IssueCode.noDataRows));
  }

  return ImportPreview(kind: kind, headers: table.headers, rows: rows, fileIssues: fileIssues);
}

// =============================================================== students ==

/// Parses a students file. [existing] are the students the importer can see,
/// keyed by ID; when updating, columns missing from the file keep their
/// current values (so a file without «الحالة» never resets statuses).
ImportPreview<Student> parseStudents(
  SheetTable table, {
  required Map<String, Student> existing,
  ImportOptions options = const ImportOptions(),
}) {
  final namesInFile = <String, int>{};
  final existingByName = <String, String>{
    for (final s in existing.values) ArabicText.normalizeForCompare(s.fullName): s.universityId,
  };

  _Parsed<Student> parseRow(_Row r) {
    final issues = <ImportIssue>[];
    final name = r[ImportColumns.fullName.key];
    final rawId = r[ImportColumns.universityId.key];
    final id = DocIds.normalizeUniversityId(rawId);
    final current = existing[id];

    if (name.isEmpty) issues.add(const ImportIssue.error(IssueCode.emptyField, field: 'fullName'));
    if (id.isEmpty) issues.add(const ImportIssue.error(IssueCode.emptyField, field: 'universityId'));

    // Stage: explicit cells, else the existing record, else the default.
    final levelCell = r[ImportColumns.level.key];
    final shiftCell = r[ImportColumns.shift.key];
    var level = levelCell.isEmpty ? null : ValueParsers.level(levelCell);
    var shift = shiftCell.isEmpty ? null : ValueParsers.shift(shiftCell);
    if (levelCell.isNotEmpty && level == null) {
      issues.add(ImportIssue.error(IssueCode.invalidLevel, field: 'level', params: {'value': levelCell}));
    }
    if (shiftCell.isNotEmpty && shift == null) {
      issues.add(ImportIssue.error(IssueCode.invalidShift, field: 'shift', params: {'value': shiftCell}));
    }
    final fallback = current?.stage ?? options.defaultStage;
    if (levelCell.isEmpty) level = fallback?.level;
    if (shiftCell.isEmpty) shift = fallback?.shift;
    if (levelCell.isEmpty && level == null) {
      issues.add(const ImportIssue.error(IssueCode.emptyField, field: 'level'));
    }
    if (shiftCell.isEmpty && shift == null) {
      issues.add(const ImportIssue.error(IssueCode.emptyField, field: 'shift'));
    }

    final statusCell = r[ImportColumns.status.key];
    final status = statusCell.isEmpty
        ? (current?.status ?? StudentStatus.continuing)
        : ValueParsers.status(statusCell);
    if (status == null) {
      issues.add(ImportIssue.error(IssueCode.invalidStatus, field: 'status', params: {'value': statusCell}));
    }

    final carryCell = r[ImportColumns.carryOver.key];
    final carryOver = ValueParsers.yesNo(carryCell, fallback: current?.carryOver ?? false);
    if (carryOver == null) {
      issues.add(ImportIssue.error(IssueCode.invalidYesNo, field: 'carryOver', params: {'value': carryCell}));
    }

    if (issues.any((i) => i.isError)) return (entity: null, issues: issues);

    final stage = StageRef(level!, shift!);
    final allowed = options.allowedStageIds;
    if (allowed != null && !allowed.contains(stage.id)) {
      issues.add(ImportIssue.error(IssueCode.stageNotAllowed, field: 'level', params: {'stage': stage.id}));
      return (entity: null, issues: issues);
    }
    if (current != null && options.updateExisting && current.stageId != stage.id) {
      issues.add(ImportIssue.warning(IssueCode.movesStage, params: {'from': current.stageId, 'to': stage.id}));
    }
    if (ArabicText.wordCount(name) < 4) {
      issues.add(const ImportIssue.warning(IssueCode.nameNotFourPart, field: 'fullName'));
    }

    return (
      entity: Student(
        universityId: id,
        fullName: name,
        stage: stage,
        section: r.has(ImportColumns.section.key)
            ? r[ImportColumns.section.key]
            : (current?.section ?? ''),
        status: status!,
        carryOver: carryOver!,
      ),
      issues: issues,
    );
  }

  return _parse<Student>(
    kind: ImportKind.students,
    table: table,
    parseRow: parseRow,
    keysOf: (s) => [s.id],
    duplicateKeyCode: IssueCode.duplicateIdInFile,
    exists: existing.containsKey,
    options: options,
    extraChecks: (s, rowNumber) {
      final key = ArabicText.normalizeForCompare(s.fullName);
      final issues = <ImportIssue>[];
      final firstRow = namesInFile[key];
      if (firstRow != null) {
        issues.add(ImportIssue.warning(IssueCode.duplicateNameInFile, field: 'fullName', params: {'row': '$firstRow'}));
      } else {
        namesInFile[key] = rowNumber;
      }
      final otherId = existingByName[key];
      if (otherId != null && otherId != s.universityId) {
        issues.add(ImportIssue.warning(IssueCode.nameMatchesOtherRecord, field: 'fullName', params: {'value': otherId}));
      }
      return issues;
    },
  );
}

// =============================================================== teachers ==

/// Parses a teachers file into `users` docs with the teacher role. Updating
/// keeps roles, scopes and status, and only refreshes the profile fields.
ImportPreview<AppUser> parseTeachers(
  SheetTable table, {
  required Map<String, AppUser> existing,
  ImportOptions options = const ImportOptions(),
}) {
  final namesInFile = <String, int>{};

  _Parsed<AppUser> parseRow(_Row r) {
    final issues = <ImportIssue>[];
    final name = r[ImportColumns.teacherName.key];
    final rawEmail = r[ImportColumns.email.key];
    final email = ValueParsers.email(rawEmail);

    if (name.isEmpty) issues.add(const ImportIssue.error(IssueCode.emptyField, field: 'name'));
    if (rawEmail.isEmpty) {
      issues.add(const ImportIssue.error(IssueCode.emptyField, field: 'email'));
    } else if (email == null) {
      issues.add(ImportIssue.error(IssueCode.invalidEmail, field: 'email', params: {'value': rawEmail}));
    }
    if (issues.any((i) => i.isError)) return (entity: null, issues: issues);

    final current = existing[email!];
    if (current != null &&
        options.updateExisting &&
        !options.canEditAdmins &&
        (current.hasRole(UserRole.superAdmin) || current.hasRole(UserRole.deputyAdmin))) {
      issues.add(const ImportIssue.error(IssueCode.protectedAdminAccount, field: 'email'));
      return (entity: null, issues: issues);
    }

    final title = r.has(ImportColumns.title.key) ? r[ImportColumns.title.key] : (current?.title ?? '');
    final phone = r.has(ImportColumns.phone.key)
        ? ValueParsers.phone(r[ImportColumns.phone.key])
        : (current?.phone ?? '');

    final user = current != null
        ? current.copyWith(name: name, title: title, phone: phone)
        : AppUser(email: email, name: name, title: title, phone: phone);
    return (entity: user, issues: issues);
  }

  return _parse<AppUser>(
    kind: ImportKind.teachers,
    table: table,
    parseRow: parseRow,
    keysOf: (u) => [u.id],
    duplicateKeyCode: IssueCode.duplicateEmailInFile,
    exists: existing.containsKey,
    options: options,
    extraChecks: (u, rowNumber) {
      final key = ArabicText.normalizeForCompare(u.name);
      final firstRow = namesInFile[key];
      if (firstRow != null) {
        return [ImportIssue.warning(IssueCode.duplicateNameInFile, field: 'name', params: {'row': '$firstRow'})];
      }
      namesInFile[key] = rowNumber;
      return const [];
    },
  );
}

// ================================================================ courses ==

/// Parses a courses file. One row may yield two courses when «الدراسة» is
/// «كلاهما» (or empty): one per shift.
ImportPreview<List<Course>> parseCourses(
  SheetTable table, {
  required Map<String, Course> existing,
  ImportOptions options = const ImportOptions(),
}) {
  _Parsed<List<Course>> parseRow(_Row r) {
    final issues = <ImportIssue>[];
    final code = DocIds.normalizeCourseCode(r[ImportColumns.code.key]);
    final name = r[ImportColumns.courseName.key];
    final levelCell = r[ImportColumns.courseLevel.key];
    final shiftCell = r[ImportColumns.courseShift.key];
    final semesterCell = r[ImportColumns.semester.key];
    final unitsCell = r[ImportColumns.units.key];
    final practicalCell = r[ImportColumns.hasPractical.key];

    if (code.isEmpty) issues.add(const ImportIssue.error(IssueCode.emptyField, field: 'code'));
    if (name.isEmpty) issues.add(const ImportIssue.error(IssueCode.emptyField, field: 'courseName'));

    final level = ValueParsers.level(levelCell);
    if (levelCell.isEmpty) {
      issues.add(const ImportIssue.error(IssueCode.emptyField, field: 'level'));
    } else if (level == null) {
      issues.add(ImportIssue.error(IssueCode.invalidLevel, field: 'level', params: {'value': levelCell}));
    }

    // Empty «الدراسة» = taught in both morning and evening study.
    final shifts = shiftCell.isEmpty ? Shift.values : ValueParsers.shifts(shiftCell);
    if (shifts == null) {
      issues.add(ImportIssue.error(IssueCode.invalidShift, field: 'shift', params: {'value': shiftCell}));
    }

    final units = ValueParsers.units(unitsCell);
    if (unitsCell.isEmpty) {
      issues.add(const ImportIssue.error(IssueCode.emptyField, field: 'units'));
    } else if (units == null) {
      issues.add(ImportIssue.error(IssueCode.invalidUnits, field: 'units', params: {'value': unitsCell}));
    }

    if (issues.any((i) => i.isError)) return (entity: null, issues: issues);

    Course? currentFor(Shift s) => existing[DocIds.course(code, StageRef(level!, s).id)];
    final anyCurrent = shifts!.map(currentFor).nonNulls.firstOrNull;

    final semester = ValueParsers.semester(semesterCell,
        fallback: anyCurrent?.semester ?? options.defaultSemester);
    if (semester == null) {
      issues.add(ImportIssue.error(IssueCode.invalidSemester, field: 'semester', params: {'value': semesterCell}));
    }
    final hasPractical = ValueParsers.yesNo(practicalCell, fallback: anyCurrent?.hasPractical ?? false);
    if (hasPractical == null) {
      issues.add(ImportIssue.error(IssueCode.invalidYesNo, field: 'hasPractical', params: {'value': practicalCell}));
    }
    if (issues.any((i) => i.isError)) return (entity: null, issues: issues);

    return (
      entity: [
        for (final s in shifts)
          Course(
            code: code,
            name: name,
            stage: StageRef(level!, s),
            semester: semester!,
            units: units!,
            hasPractical: hasPractical!,
          ),
      ],
      issues: issues,
    );
  }

  return _parse<List<Course>>(
    kind: ImportKind.courses,
    table: table,
    parseRow: parseRow,
    keysOf: (courses) => [for (final c in courses) c.id],
    duplicateKeyCode: IssueCode.duplicateCodeInFile,
    exists: existing.containsKey,
    options: options,
  );
}
