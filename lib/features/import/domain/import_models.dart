/// What is being imported.
enum ImportKind { students, teachers, courses }

/// A spreadsheet already reduced to strings: one header row + data rows.
/// Every data row is padded/truncated to [headers] length.
final class SheetTable {
  SheetTable({required this.headers, required List<List<String>> rows})
      : rows = [
          for (final r in rows)
            [for (var i = 0; i < headers.length; i++) i < r.length ? r[i] : ''],
        ];

  final List<String> headers;
  final List<List<String>> rows;

  /// Spreadsheet row number of data row [index] (header is row 1).
  static int rowNumberOf(int index) => index + 2;
}

enum IssueSeverity { info, warning, error }

/// Language-independent issue codes; the UI renders localized messages.
enum IssueCode {
  // file-level
  missingColumn,
  noDataRows,
  // field-level errors
  emptyField,
  invalidLevel,
  invalidShift,
  invalidStatus,
  invalidYesNo,
  invalidSemester,
  invalidUnits,
  invalidEmail,
  stageNotAllowed,
  duplicateIdInFile,
  duplicateEmailInFile,
  duplicateCodeInFile,
  protectedAdminAccount,
  // warnings / info
  duplicateNameInFile,
  nameMatchesOtherRecord,
  nameNotFourPart,
  existsWillSkip,
  existsWillUpdate,
  movesStage,
}

final class ImportIssue {
  const ImportIssue(this.code, this.severity, {this.field, this.params = const {}});

  const ImportIssue.error(this.code, {this.field, this.params = const {}})
      : severity = IssueSeverity.error;
  const ImportIssue.warning(this.code, {this.field, this.params = const {}})
      : severity = IssueSeverity.warning;
  const ImportIssue.info(this.code, {this.field, this.params = const {}})
      : severity = IssueSeverity.info;

  final IssueCode code;
  final IssueSeverity severity;

  /// Column key the issue refers to (e.g. `universityId`).
  final String? field;

  /// e.g. {'row': '7'} for duplicates, {'value': 'خامسة'} for bad values.
  final Map<String, String> params;

  bool get isError => severity == IssueSeverity.error;

  @override
  String toString() => 'ImportIssue($code, $severity, $field, $params)';
}

/// What saving will do with a row.
enum RowAction { create, update, skip, invalid }

final class ImportRow<T> {
  const ImportRow({
    required this.rowNumber,
    required this.cells,
    required this.action,
    this.entity,
    this.issues = const [],
  });

  /// 1-based spreadsheet row number (header = 1).
  final int rowNumber;
  final List<String> cells;
  final RowAction action;

  /// Parsed value; null when the row is invalid.
  final T? entity;
  final List<ImportIssue> issues;

  bool get hasWarnings => issues.any((i) => i.severity == IssueSeverity.warning);
  bool get willWrite => action == RowAction.create || action == RowAction.update;
}

/// Result of parsing a file, shown to the user before anything is saved.
final class ImportPreview<T> {
  const ImportPreview({
    required this.kind,
    required this.headers,
    required this.rows,
    this.fileIssues = const [],
  });

  final ImportKind kind;
  final List<String> headers;
  final List<ImportRow<T>> rows;
  final List<ImportIssue> fileIssues;

  int count(RowAction action) => rows.where((r) => r.action == action).length;
  int get warningCount => rows.where((r) => r.hasWarnings).length;

  bool get hasFileErrors => fileIssues.any((i) => i.isError);

  /// Saving is possible when the file is structurally valid and at least one
  /// row will be written. Invalid rows are simply left out.
  bool get canCommit => !hasFileErrors && rows.any((r) => r.willWrite);

  Iterable<ImportRow<T>> get rowsToWrite => rows.where((r) => r.willWrite);
}

/// Thrown by readers for unreadable files.
enum FileProblem { unsupportedFormat, legacyXls, notUtf8Csv, corrupt, empty }

class SpreadsheetException implements Exception {
  const SpreadsheetException(this.problem, [this.detail]);
  final FileProblem problem;
  final String? detail;

  @override
  String toString() => 'SpreadsheetException($problem, $detail)';
}
