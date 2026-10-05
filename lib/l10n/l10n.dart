import 'package:flutter/widgets.dart';

import '../core/domain/stage_ref.dart';
import '../core/firebase/doc_ids.dart';
import '../features/assignments/domain/assignment.dart';
import '../features/attendance/domain/attendance_session.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/auth/domain/app_user.dart';
import '../features/import/domain/import_models.dart';
import '../features/students/domain/student.dart';
import 'app_localizations.dart';

export 'app_localizations.dart';

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// Wraps Latin/number fragments (course codes, e-mails, IDs) in Unicode
/// first-strong isolates so they keep their order inside Arabic sentences
/// (otherwise «CS101 · 3 وحدات» is displayed as «3 · CS101 وحدات»).
String bidiIsolate(String text) => '\u2068$text\u2069';

/// Localized labels for domain values (the domain layer stays language-free).
extension DomainLabels on AppLocalizations {
  String role(UserRole r) => switch (r) {
        UserRole.superAdmin => roleSuperAdmin,
        UserRole.deputyAdmin => roleDeputyAdmin,
        UserRole.stageManager => roleStageManager,
        UserRole.teacher => roleTeacher,
      };

  String level(int level) => switch (level) {
        1 => level1,
        2 => level2,
        3 => level3,
        4 => level4,
        _ => '$level',
      };

  String shift(Shift s) => switch (s) {
        Shift.morning => shiftMorning,
        Shift.evening => shiftEvening,
      };

  String stage(StageRef s) => stageLabel(level(s.level), shift(s.shift));

  /// Stage label from an ID such as `3-morning` (falls back to the ID).
  String stageId(String id) {
    final ref = StageRef.tryParse(id);
    return ref == null ? id : stage(ref);
  }

  String studentStatus(StudentStatus s) => switch (s) {
        StudentStatus.continuing => statusContinuing,
        StudentStatus.postponed => statusPostponed,
        StudentStatus.failedByAbsence => statusFailedByAbsence,
        StudentStatus.withdrawn => statusWithdrawn,
        StudentStatus.transferredIn => statusTransferredIn,
      };

  String attendance(AttendanceStatus s) => switch (s) {
        AttendanceStatus.present => attPresent,
        AttendanceStatus.absent => attAbsent,
        AttendanceStatus.late => attLate,
        AttendanceStatus.excused => attExcused,
      };

  /// «المرحلة الثالثة صباحي · نظري · الشعبة أ» for a teaching assignment.
  String classLabel(Assignment a) => [
        stageId(a.stageId),
        if (a.type == AssignmentType.theory) ...[
          theoryLabel,
          a.target == DocIds.allSections ? allSections : sectionLabel(a.target),
        ] else ...[
          practicalLabel,
          groupLabel(a.target),
        ],
      ].join(' · ');

  String authFailure(AuthException e) => switch (e.failure) {
        AuthFailure.invalidCredentials => authInvalidCredentials,
        AuthFailure.invalidEmail => authInvalidEmail,
        AuthFailure.emailAlreadyInUse => authEmailInUse,
        AuthFailure.weakPassword => authWeakPassword,
        AuthFailure.userDisabled => authUserDisabled,
        AuthFailure.tooManyRequests => authTooManyRequests,
        AuthFailure.network => authNetwork,
        AuthFailure.unknown => authUnknown(e.code ?? '?'),
      };

  String importKind(ImportKind k) => switch (k) {
        ImportKind.students => importStudents,
        ImportKind.teachers => importTeachers,
        ImportKind.courses => importCourses,
      };

  String rowAction(RowAction a) => switch (a) {
        RowAction.create => actionCreate,
        RowAction.update => actionUpdate,
        RowAction.skip => actionSkip,
        RowAction.invalid => actionInvalid,
      };

  String fileProblem(FileProblem p) => switch (p) {
        FileProblem.unsupportedFormat => fileUnsupported,
        FileProblem.legacyXls => fileLegacyXls,
        FileProblem.notUtf8Csv => fileNotUtf8,
        FileProblem.corrupt => fileCorrupt,
        FileProblem.empty => fileEmpty,
      };

  String field(String key) => switch (key) {
        'fullName' => fieldFullName,
        'universityId' => fieldUniversityId,
        'level' => fieldLevel,
        'shift' => fieldShift,
        'section' => fieldSection,
        'status' => fieldStatus,
        'carryOver' => fieldCarryOver,
        'name' => fieldName,
        'title' => fieldTitle,
        'email' => fieldEmail,
        'phone' => fieldPhone,
        'code' => fieldCode,
        'courseName' => fieldCourseName,
        'semester' => fieldSemester,
        'units' => fieldUnits,
        'hasPractical' => fieldHasPractical,
        _ => key,
      };

  String issue(ImportIssue i) {
    String p(String k) => i.params[k] ?? '';
    return switch (i.code) {
      IssueCode.missingColumn => issueMissingColumn(p('column')),
      IssueCode.noDataRows => issueNoDataRows,
      IssueCode.emptyField => issueEmptyField(field(i.field ?? '')),
      IssueCode.invalidLevel => issueInvalidLevel(p('value')),
      IssueCode.invalidShift => issueInvalidShift(p('value')),
      IssueCode.invalidStatus => issueInvalidStatus(p('value')),
      IssueCode.invalidYesNo => issueInvalidYesNo(p('value')),
      IssueCode.invalidSemester => issueInvalidSemester(p('value')),
      IssueCode.invalidUnits => issueInvalidUnits(p('value')),
      IssueCode.invalidEmail => issueInvalidEmail(bidiIsolate(p('value'))),
      IssueCode.stageNotAllowed => issueStageNotAllowed(stageId(p('stage'))),
      IssueCode.duplicateIdInFile => issueDuplicateIdInFile(p('row')),
      IssueCode.duplicateEmailInFile => issueDuplicateEmailInFile(p('row')),
      IssueCode.duplicateCodeInFile => issueDuplicateCodeInFile(bidiIsolate(p('value')), p('row')),
      IssueCode.protectedAdminAccount => issueProtectedAdmin,
      IssueCode.duplicateNameInFile => issueDuplicateNameInFile(p('row')),
      IssueCode.nameMatchesOtherRecord => issueNameMatchesOther(bidiIsolate(p('value'))),
      IssueCode.nameNotFourPart => issueNameNotFourPart,
      IssueCode.existsWillSkip => issueExistsWillSkip,
      IssueCode.existsWillUpdate => issueExistsWillUpdate,
      IssueCode.movesStage => issueMovesStage(stageId(p('from')), stageId(p('to'))),
    };
  }
}
