// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Attendance System';

  @override
  String get universityName => 'University of Basrah';

  @override
  String get collegeName => 'College of Education for Pure Sciences';

  @override
  String get departmentName => 'Department of Computer Science';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get retry => 'Retry';

  @override
  String get close => 'Close';

  @override
  String get confirm => 'Confirm';

  @override
  String get delete => 'Delete';

  @override
  String get loading => 'Loading…';

  @override
  String errorGeneric(String error) {
    return 'Unexpected error: $error';
  }

  @override
  String get permissionDenied => 'You do not have permission for this action.';

  @override
  String get signOut => 'Sign out';

  @override
  String get languageSwitch => 'العربية';

  @override
  String get toggleTheme => 'Toggle dark mode';

  @override
  String get loginTitle => 'Sign in';

  @override
  String get activateTitle => 'Activate a new account';

  @override
  String get emailLabel => 'University e-mail';

  @override
  String get passwordLabel => 'Password';

  @override
  String get confirmPasswordLabel => 'Confirm password';

  @override
  String get showPassword => 'Show password';

  @override
  String get signIn => 'Sign in';

  @override
  String get activate => 'Activate account';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get haveNoAccount => 'First time? Activate your account';

  @override
  String get haveAccount => 'Already activated? Sign in';

  @override
  String get activateHint =>
      'Use the e-mail the department registered for you, then confirm it from the message sent to your inbox.';

  @override
  String get resetPasswordTitle => 'Reset password';

  @override
  String get resetPasswordBody =>
      'Enter your e-mail and we will send you a link to set a new password.';

  @override
  String get sendLink => 'Send link';

  @override
  String get passwordResetSent =>
      'If the e-mail is registered, you will receive a reset message.';

  @override
  String get validationRequired => 'This field is required';

  @override
  String get validationEmail => 'Invalid e-mail address';

  @override
  String get validationPasswordLength =>
      'Password must be at least 8 characters';

  @override
  String get validationPasswordMatch => 'Passwords do not match';

  @override
  String get authInvalidCredentials => 'Wrong e-mail or password.';

  @override
  String get authInvalidEmail => 'Invalid e-mail address.';

  @override
  String get authEmailInUse =>
      'This e-mail is already activated. Sign in or reset your password.';

  @override
  String get authWeakPassword => 'Password is too weak; choose a longer one.';

  @override
  String get authUserDisabled =>
      'This account is disabled. Contact the department.';

  @override
  String get authTooManyRequests => 'Too many attempts. Try again later.';

  @override
  String get authNetwork =>
      'No internet connection. The first sign-in needs a connection.';

  @override
  String authUnknown(String code) {
    return 'Could not complete the operation ($code).';
  }

  @override
  String get verifyTitle => 'Verify your e-mail';

  @override
  String verifyBody(String email) {
    return 'We sent a verification link to $email. Open it, then come back here.\nNot there after two minutes? Look in your spam folder for a message from noreply.';
  }

  @override
  String get verifyDone => 'I have verified';

  @override
  String get verifyResend => 'Resend link';

  @override
  String get verifySent => 'A new link was sent.';

  @override
  String get verifyNotYet => 'Not verified yet. Check your spam folder.';

  @override
  String get notProvisionedTitle => 'Account not registered';

  @override
  String notProvisionedBody(String email) {
    return '$email is not registered yet. Send a join request below, or ask the department to add you.';
  }

  @override
  String get suspendedTitle => 'Account suspended';

  @override
  String get suspendedBody => 'This account was suspended by the department.';

  @override
  String get profileErrorTitle => 'Could not load your account';

  @override
  String get profileErrorBody => 'Check your connection and retry.';

  @override
  String get configErrorTitle => 'Firebase is not configured';

  @override
  String get configErrorBody =>
      'Run flutterfire configure to generate lib/firebase_options.dart, then rebuild.';

  @override
  String get navHome => 'Home';

  @override
  String get navImport => 'Import';

  @override
  String get navAssignments => 'Assignments';

  @override
  String get navProfile => 'Profile';

  @override
  String get roleSuperAdmin => 'Super admin';

  @override
  String get roleDeputyAdmin => 'Deputy admin';

  @override
  String get roleStageManager => 'Stage manager';

  @override
  String get roleTeacher => 'Teacher';

  @override
  String get level1 => 'First year';

  @override
  String get level2 => 'Second year';

  @override
  String get level3 => 'Third year';

  @override
  String get level4 => 'Fourth year';

  @override
  String get shiftMorning => 'Morning';

  @override
  String get shiftEvening => 'Evening';

  @override
  String stageLabel(String level, String shift) {
    return '$level — $shift';
  }

  @override
  String get statusContinuing => 'Continuing';

  @override
  String get statusPostponed => 'Postponed';

  @override
  String get statusFailedByAbsence => 'Failed by absence';

  @override
  String get statusWithdrawn => 'Withdrawn';

  @override
  String get statusTransferredIn => 'Transferred in';

  @override
  String get theoryLabel => 'Theory';

  @override
  String get practicalLabel => 'Practical';

  @override
  String groupLabel(String name) {
    return 'Group $name';
  }

  @override
  String sectionLabel(String name) {
    return 'Section $name';
  }

  @override
  String get allSections => 'All sections';

  @override
  String homeWelcome(String name) {
    return 'Welcome, $name';
  }

  @override
  String get homeRoles => 'Your roles';

  @override
  String get homeStageScopes => 'Your stages';

  @override
  String get homeMyCourses => 'My courses';

  @override
  String get homeNoCourses => 'No courses assigned to you yet.';

  @override
  String get homeAttendanceSoon => 'Attendance recording arrives in phase 2.';

  @override
  String get homeSetupTitle => 'Initial setup';

  @override
  String get homeSetupBody =>
      'The eight stages or the active academic year are missing.';

  @override
  String get homeSetupAction => 'Set up now';

  @override
  String get homeSetupDone => 'Setup complete.';

  @override
  String homeActiveYear(String year, String semester) {
    return 'Academic year $year — semester $semester';
  }

  @override
  String get homeQuickActions => 'Quick actions';

  @override
  String get homeImportAction => 'Import students, teachers and courses';

  @override
  String get homeAssignAction => 'Link teachers to courses and groups';

  @override
  String pendingUploads(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count records waiting to upload',
      one: '1 record waiting to upload',
      zero: 'No records waiting to upload',
    );
    return '$_temp0';
  }

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileTheme => 'Appearance';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get profileLanguage => 'Language';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageEnglish => 'English';

  @override
  String get profilePhone => 'Phone';

  @override
  String get profilePhoneSaved => 'Phone number saved.';

  @override
  String get profileChangePassword => 'Change password';

  @override
  String get profileResetLinkSent =>
      'A password change link was sent to your e-mail.';

  @override
  String get signOutConfirm => 'Sign out?';

  @override
  String signOutPending(int count) {
    return 'You cannot sign out: $count records are not uploaded yet. Connect and wait for the upload first.';
  }

  @override
  String get importTitle => 'Import data';

  @override
  String get importStudents => 'Students';

  @override
  String get importTeachers => 'Teachers';

  @override
  String get importCourses => 'Courses';

  @override
  String get importStep1 => '1. Download and fill the template';

  @override
  String get importStep2 => '2. Choose the file (xlsx or csv)';

  @override
  String get importDownloadTemplate => 'Download template';

  @override
  String get importTemplateSaved => 'Template saved.';

  @override
  String get importPickFile => 'Choose file';

  @override
  String importFileName(String name) {
    return 'File: $name';
  }

  @override
  String get importUpdateExistingStudents =>
      'Update existing records by university ID instead of skipping them';

  @override
  String get importUpdateExistingTeachers =>
      'Update existing records by e-mail instead of skipping them';

  @override
  String get importUpdateExistingCourses =>
      'Update existing records by course code and stage instead of skipping them';

  @override
  String get importDefaultStage => 'Default stage (when the file has none)';

  @override
  String get importDefaultStageNone => 'From the file';

  @override
  String get importDefaultSemester =>
      'Default semester (when the file has none)';

  @override
  String get importPreviewTitle => 'Preview before saving';

  @override
  String importSummaryCreate(int count) {
    return 'New: $count';
  }

  @override
  String importSummaryUpdate(int count) {
    return 'Update: $count';
  }

  @override
  String importSummarySkip(int count) {
    return 'Skipped: $count';
  }

  @override
  String importSummaryInvalid(int count) {
    return 'Errors: $count';
  }

  @override
  String importSummaryWarnings(int count) {
    return 'Warnings: $count';
  }

  @override
  String get importFilterAll => 'All rows';

  @override
  String get importFilterProblems => 'Problems only';

  @override
  String importRow(String row) {
    return 'Row $row';
  }

  @override
  String importSave(int count) {
    return 'Save ($count)';
  }

  @override
  String get importSaving => 'Saving…';

  @override
  String get importConfirmTitle => 'Confirm save';

  @override
  String importConfirmBody(String created, String updated) {
    return '$created will be added and $updated updated. Rows with errors or skipped rows are not saved.';
  }

  @override
  String importDone(String created, String updated) {
    return 'Saved: $created added, $updated updated.';
  }

  @override
  String importFailures(int count, String rows) {
    return '$count rows could not be saved: $rows';
  }

  @override
  String get importNoRowsMatch => 'No rows match the filter.';

  @override
  String get importNotAllowed => 'You are not allowed to import.';

  @override
  String get importReading => 'Reading the file…';

  @override
  String get actionCreate => 'New';

  @override
  String get actionUpdate => 'Update';

  @override
  String get actionSkip => 'Skip';

  @override
  String get actionInvalid => 'Error';

  @override
  String issueMissingColumn(String column) {
    return 'Column “$column” is missing from the file.';
  }

  @override
  String get issueNoDataRows => 'The file has no data rows.';

  @override
  String issueEmptyField(String field) {
    return '“$field” is empty.';
  }

  @override
  String issueInvalidLevel(String value) {
    return 'Unknown stage “$value” (1–4).';
  }

  @override
  String issueInvalidShift(String value) {
    return 'Unknown study “$value” (morning/evening).';
  }

  @override
  String issueInvalidStatus(String value) {
    return 'Unknown status “$value”.';
  }

  @override
  String issueInvalidYesNo(String value) {
    return '“$value” must be yes or no.';
  }

  @override
  String issueInvalidSemester(String value) {
    return 'Semester “$value” must be 1 or 2.';
  }

  @override
  String issueInvalidUnits(String value) {
    return 'Units “$value” must be a positive whole number.';
  }

  @override
  String issueInvalidEmail(String value) {
    return 'Invalid e-mail “$value”.';
  }

  @override
  String issueStageNotAllowed(String stage) {
    return 'You do not manage $stage.';
  }

  @override
  String issueDuplicateIdInFile(String row) {
    return 'Duplicate university ID (also in row $row).';
  }

  @override
  String issueDuplicateEmailInFile(String row) {
    return 'Duplicate e-mail (also in row $row).';
  }

  @override
  String issueDuplicateCodeInFile(String value, String row) {
    return 'Duplicate course $value (also in row $row).';
  }

  @override
  String get issueProtectedAdmin =>
      'Admin account: only the super admin can edit it.';

  @override
  String issueDuplicateNameInFile(String row) {
    return 'Duplicate name (also in row $row) — make sure they are different people.';
  }

  @override
  String issueNameMatchesOther(String value) {
    return 'A student with the same name exists under another ID ($value).';
  }

  @override
  String get issueNameNotFourPart => 'The name is not a four-part name.';

  @override
  String get issueExistsWillSkip =>
      'Already exists — will be skipped (enable “update existing”).';

  @override
  String get issueExistsWillUpdate => 'Already exists — will be updated.';

  @override
  String issueMovesStage(String from, String to) {
    return 'The student moves from $from to $to.';
  }

  @override
  String get fieldFullName => 'Full name';

  @override
  String get fieldUniversityId => 'University ID';

  @override
  String get fieldLevel => 'Stage';

  @override
  String get fieldShift => 'Study';

  @override
  String get fieldSection => 'Section';

  @override
  String get fieldStatus => 'Status';

  @override
  String get fieldCarryOver => 'Carry-over';

  @override
  String get fieldName => 'Name';

  @override
  String get fieldTitle => 'Academic title';

  @override
  String get fieldEmail => 'E-mail';

  @override
  String get fieldPhone => 'Phone';

  @override
  String get fieldCode => 'Course code';

  @override
  String get fieldCourseName => 'Course name';

  @override
  String get fieldSemester => 'Semester';

  @override
  String get fieldUnits => 'Units';

  @override
  String get fieldHasPractical => 'Has practical';

  @override
  String get fileUnsupported => 'Unsupported file type. Use xlsx or csv.';

  @override
  String get fileLegacyXls =>
      'The old .xls format is not supported. Save it from Excel as “Excel Workbook (.xlsx)”.';

  @override
  String get fileNotUtf8 =>
      'Unsupported CSV encoding. Save it from Excel as “CSV UTF-8”.';

  @override
  String get fileCorrupt => 'Could not read the file; it may be corrupt.';

  @override
  String get fileEmpty => 'The file is empty.';

  @override
  String get assignmentsTitle => 'Link teachers to courses';

  @override
  String get assignmentsPickStage => 'Stage';

  @override
  String get assignmentsNoStages => 'No stages in your scope.';

  @override
  String get assignmentsNoCourses =>
      'No courses for this stage. Import courses first.';

  @override
  String assignmentsCourseInfo(String code, String units, String semester) {
    return '$code · $units units · semester $semester';
  }

  @override
  String get assignmentsTheory => 'Theory';

  @override
  String get assignmentsPractical => 'Practical';

  @override
  String get assignmentsNoTheoryTeacher => 'Theory not assigned yet.';

  @override
  String get assignmentsNoGroups => 'No practical groups yet.';

  @override
  String assignmentsGroupStudents(String name, int count) {
    return '$name · students: $count';
  }

  @override
  String get assignmentsAssignTheory => 'Assign theory';

  @override
  String assignmentsAssignGroup(String name) {
    return 'Assign $name';
  }

  @override
  String get assignmentsTeacher => 'Teacher';

  @override
  String get assignmentsSection => 'Section';

  @override
  String get assignmentsSaved => 'Assigned.';

  @override
  String get assignmentsRemoveTitle => 'Remove assignment';

  @override
  String assignmentsRemoveBody(String teacher, String target) {
    return 'Remove $teacher from $target?';
  }

  @override
  String get assignmentsRemoved => 'Assignment removed.';

  @override
  String get assignmentsCreateGroups => 'Create / redistribute groups';

  @override
  String get assignmentsGroupCount => 'Number of groups';

  @override
  String assignmentsDistributeBody(int count, String stage) {
    return '$count attending students of $stage will be split evenly and alphabetically. Extra groups are deleted with their assignments.';
  }

  @override
  String get assignmentsDistribute => 'Distribute';

  @override
  String assignmentsDistributed(int count) {
    return 'Students distributed over $count groups.';
  }

  @override
  String get assignmentsNoTeachers => 'No teachers. Import teachers first.';

  @override
  String get assignmentsNoStudents =>
      'No attending students in this stage to distribute.';

  @override
  String get assignmentsAlreadyAssigned => 'This assignment already exists.';

  @override
  String get assignmentsSearchTeacher => 'Search by teacher name or e-mail';

  @override
  String updateAvailable(String version) {
    return 'A new version ($version) is available';
  }

  @override
  String get updateDownload => 'Download';

  @override
  String get updateLater => 'Later';

  @override
  String get updateRequiredTitle => 'Update required';

  @override
  String updateRequiredBody(String installed) {
    return 'The installed version ($installed) is no longer supported. Install the new version over it; your local data is kept.';
  }

  @override
  String get updateNoLink =>
      'No download link is set yet; contact the department.';

  @override
  String updateOpenFailed(String url) {
    return 'Could not open the link: $url';
  }

  @override
  String get navAccounts => 'Accounts';

  @override
  String get accountsTitle => 'Accounts and permissions';

  @override
  String get accountsAdd => 'Add account';

  @override
  String get accountsAddHint =>
      'After adding, the owner of the e-mail activates it from “First time? Activate your account”.';

  @override
  String get accountsSearch => 'Search by name or e-mail';

  @override
  String get accountsEmpty => 'No matching accounts.';

  @override
  String get accountsSuspended => 'Suspended';

  @override
  String get accountsLocked => 'Admin account; only the super admin edits it.';

  @override
  String accountsRequestsTitle(int count) {
    return 'Join requests ($count)';
  }

  @override
  String accountsRequestedOn(String date) {
    return 'Requested $date';
  }

  @override
  String get accountsApprove => 'Approve';

  @override
  String get accountsReject => 'Reject';

  @override
  String get accountsRejectTitle => 'Reject request';

  @override
  String accountsRejectBody(String email) {
    return 'Reject the request from $email? They can send a new one.';
  }

  @override
  String accountsApproved(String name) {
    return '$name was added and is signed in automatically.';
  }

  @override
  String get accountsRejected => 'Request rejected.';

  @override
  String accountsCreated(String email) {
    return '$email was added. Ask them to activate the account in the app.';
  }

  @override
  String get accountsSaved => 'Account saved.';

  @override
  String get accountsExists =>
      'An account with this e-mail exists; edit it from the list.';

  @override
  String get accountEditNew => 'New account';

  @override
  String get accountEditApprove => 'Approve join request';

  @override
  String get accountEditTitle => 'Edit account';

  @override
  String get accountRoles => 'Permissions';

  @override
  String get accountStageScopes => 'Stages they manage';

  @override
  String get accountActive => 'Account active';

  @override
  String get accountActiveHint => 'A suspended account cannot reach any data.';

  @override
  String get accountSelfLocked =>
      'You cannot change your own permissions or suspend yourself.';

  @override
  String get accountIssueRole => 'Choose at least one permission.';

  @override
  String get accountIssueStage =>
      'Choose at least one stage for a stage manager.';

  @override
  String homeAccessRequests(int count) {
    return 'Join requests awaiting your approval: $count';
  }

  @override
  String get joinTitle => 'Join request';

  @override
  String get joinBody =>
      'Send a request to the department; you get in automatically once it is approved.';

  @override
  String get joinName => 'Your full name';

  @override
  String get joinNote => 'Note for the admins (optional)';

  @override
  String get joinNoteHint => 'e.g. academic title or the stage you teach';

  @override
  String get joinSubmit => 'Send join request';

  @override
  String get joinSent => 'Your request was sent.';

  @override
  String joinPending(String date) {
    return 'Your request was sent $date and awaits approval. You get in automatically once approved.';
  }

  @override
  String get joinCancel => 'Cancel request';

  @override
  String get joinCancelled => 'Request cancelled.';
}
