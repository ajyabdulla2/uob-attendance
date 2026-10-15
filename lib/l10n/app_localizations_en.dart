// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get activityClasses =>
      'Classes — tap one to view and download its register';

  @override
  String get activityClassesEmpty => 'No classes assigned.';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get deleteAccountBody =>
      'Your sign-in account (e-mail and password), your private messages and this phone\'s notification link are deleted, then you are signed out.\n\nThe attendance you recorded and your name in the department\'s staff list stay, as official department records; to be removed from the list, contact the department.\n\nYou can activate the account again with the same e-mail while the department lists you.';

  @override
  String get deleteAccountPassword => 'Enter your password to confirm';

  @override
  String get deleteAccountConfirm => 'Delete permanently';

  @override
  String get deleteAccountDone => 'Account deleted.';

  @override
  String deleteAccountPending(int count) {
    return 'You cannot delete the account: $count records are not uploaded yet. Connect and wait for the upload first.';
  }

  @override
  String get menuDaily => 'Daily follow-up';

  @override
  String get menuStudents => 'Students and absence';

  @override
  String get menuData => 'Data and accounts';

  @override
  String get menuCommunication => 'Communication';

  @override
  String get menuSystem => 'Settings and system';

  @override
  String get menuWarnings => 'Rates and warnings';

  @override
  String get menuDataFix => 'Fix data';

  @override
  String get menuYear => 'Year settings';

  @override
  String get navCourses => 'My courses';

  @override
  String get backAgainToExit => 'Press back again to exit';

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
      'Enter your e-mail and we will send you a link to set a new password. The link reaches only an e-mail that was activated before; if your account is new or the department changed your e-mail, press «Cancel», then «First time? Activate».';

  @override
  String get sendLink => 'Send link';

  @override
  String get passwordResetSent =>
      'If the e-mail is activated, a message arrives within minutes (check Spam too). Nothing came? Activate it with «First time? Activate».';

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
  String get authInvalidCredentials =>
      'Wrong e-mail or password, or this e-mail is not activated yet (use «First time? Activate»).';

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

  @override
  String get attPresent => 'Present';

  @override
  String get attAbsent => 'Absent';

  @override
  String get attLate => 'Late';

  @override
  String get attExcused => 'Excused';

  @override
  String get recordAction => 'Take attendance';

  @override
  String get homeOpenRegister => 'View register';

  @override
  String get registerAction => 'Register';

  @override
  String get homeRecordOnPhone =>
      'Attendance is recorded in the phone app (works offline).';

  @override
  String get homeDownloading => 'Downloading your courses and students…';

  @override
  String get recordDate => 'Date';

  @override
  String recordLectureN(int n) {
    return 'Lecture $n';
  }

  @override
  String get recordNewLecture => 'New lecture';

  @override
  String get recordSearch => 'Search by name or ID';

  @override
  String get recordTapHint =>
      'Tap a student to switch present/absent; long-press for late, excused or a note.';

  @override
  String get recordNote => 'Note';

  @override
  String get recordSave => 'Save attendance';

  @override
  String get recordSaved =>
      'Saved on this phone; it uploads automatically when online.';

  @override
  String get recordNothingChanged => 'No changes since the last save.';

  @override
  String get recordLocked =>
      'Editing time for this lecture is over; changes now go through the stage manager.';

  @override
  String get recordLockedOverride =>
      'Locked for teachers; you can still edit it as a manager.';

  @override
  String recordLocksAt(String date, String time) {
    return 'Editing locks $date $time';
  }

  @override
  String get recordFuture => 'You cannot record a day that has not come yet.';

  @override
  String get recordNoStudents =>
      'No students for this class on this phone. Press \"Sync now\" once the department adds them.';

  @override
  String get recordNeedSync =>
      'The academic year has not been downloaded yet. Connect and press \"Sync now\".';

  @override
  String get recordClassMissing =>
      'This class is not among your courses on this phone.';

  @override
  String get recordDiscardTitle => 'Discard changes?';

  @override
  String get recordDiscardBody => 'Your changes to this lecture are not saved.';

  @override
  String get recordDiscard => 'Discard';

  @override
  String get registerTitle => 'Attendance register';

  @override
  String get registerEmpty => 'No lectures recorded yet.';

  @override
  String get registerStudent => 'Student';

  @override
  String get registerAbsences => 'Absences';

  @override
  String get registerRefresh => 'Refresh from server';

  @override
  String registerPulled(int count) {
    return 'Register updated ($count new or changed lectures).';
  }

  @override
  String get registerOffline =>
      'Could not reach the server; showing what is on this phone.';

  @override
  String get registerOpenLecture => 'Open lecture';

  @override
  String get syncNow => 'Sync now';

  @override
  String get syncAllUploaded => 'Everything is uploaded';

  @override
  String get syncRunning => 'Syncing…';

  @override
  String get syncOffline =>
      'Offline; records are kept on the phone and upload later.';

  @override
  String syncLast(String time) {
    return 'Last upload $time';
  }

  @override
  String get syncNever => 'Not synced yet';

  @override
  String get syncStale =>
      'Some records have not been uploaded for over 24 hours. Connect to upload them.';

  @override
  String syncRejected(int count) {
    return 'The server refused $count save(s)';
  }

  @override
  String get syncRejectedBody =>
      'Usually the lecture locked before the upload or your assignment changed. Retry, or remove it from the phone and ask the stage manager.';

  @override
  String get syncDiscard => 'Remove from phone';

  @override
  String get syncDiscardBody =>
      'These changes are removed from the phone; the server copy is downloaded when the register is refreshed.';

  @override
  String syncProblem(String code) {
    return 'Sync failed ($code)';
  }

  @override
  String get homeDataFixAction => 'Fix IDs and undo wrong imports';

  @override
  String get fixTitle => 'Data fixes';

  @override
  String get fixRenameTab => 'Change an ID';

  @override
  String get fixDeleteTab => 'Undo a wrong import';

  @override
  String get fixKindStudent => 'University ID';

  @override
  String get fixKindCourse => 'Course code';

  @override
  String get fixKindTeacher => 'Teacher e-mail';

  @override
  String get fixStage => 'Stage';

  @override
  String get fixOldId => 'Current ID';

  @override
  String get fixNewId => 'New ID';

  @override
  String get fixRenameHelp =>
      'Everything linked to the ID (attendance, stats, groups, assignments, leaves) moves to the new ID, then the old one is removed. If the new ID already exists with the same name (a duplicate import), they are merged.';

  @override
  String get fixTeacherHelp =>
      'The account and its classes move to the new e-mail; the teacher then activates it with that e-mail. Past attendance keeps the old e-mail as who recorded it.';

  @override
  String get fixDeleteStudents => 'Students';

  @override
  String get fixDeleteCourses => 'Courses';

  @override
  String get fixOnlyOne => 'One ID only (optional)';

  @override
  String get fixOnlyOneHint => 'Leave empty for the whole stage';

  @override
  String get fixDeleteHelp =>
      'Only items without history are deleted: students with no attendance or leave, and courses never taught (with their groups and links). Everything with history stays.';

  @override
  String get fixPhonesNote =>
      'Teachers\' phones update on their next sync. Best done before recording starts, or when phones have nothing waiting to upload.';

  @override
  String get fixPreview => 'Preview';

  @override
  String get fixApply => 'Apply';

  @override
  String get fixWillMove => 'Will move';

  @override
  String get fixWillDelete => 'Will delete';

  @override
  String get fixConfirmTitle => 'Apply this fix?';

  @override
  String get fixConfirmBody =>
      'This cannot be undone automatically and is recorded in the audit log.';

  @override
  String fixDone(int count) {
    return 'Done ($count writes).';
  }

  @override
  String fixInterrupted(String code) {
    return 'Stopped ($code). Preview and apply again to finish from where it stopped.';
  }

  @override
  String fixMerge(String name) {
    return 'The new ID exists as \"$name\" and will be merged into it.';
  }

  @override
  String get fixProblemInvalidId => 'Invalid ID.';

  @override
  String get fixProblemSameId => 'Both IDs are the same.';

  @override
  String get fixProblemNotFound =>
      'The current ID does not exist (or is not in this stage).';

  @override
  String fixProblemTargetExists(String name) {
    return 'The new ID belongs to another record: \"$name\". If it is a duplicate, delete it first under \"Undo a wrong import\".';
  }

  @override
  String get fixProblemOwnAccount =>
      'You cannot change your own account\'s e-mail.';

  @override
  String get fixProblemNothing =>
      'Nothing to delete: everything selected has attendance history.';

  @override
  String fixCountStudents(int n) {
    return 'Students: $n';
  }

  @override
  String fixCountCourses(int n) {
    return 'Courses: $n';
  }

  @override
  String fixCountUsers(int n) {
    return 'Accounts: $n';
  }

  @override
  String fixCountGroups(int n) {
    return 'Practical groups: $n';
  }

  @override
  String fixCountAssignments(int n) {
    return 'Assignments: $n';
  }

  @override
  String fixCountSessions(int n) {
    return 'Lectures: $n';
  }

  @override
  String fixCountRecords(int n) {
    return 'Attendance records: $n';
  }

  @override
  String fixCountStats(int n) {
    return 'Absence stats: $n';
  }

  @override
  String fixCountLeaves(int n) {
    return 'Leaves: $n';
  }

  @override
  String fixCountKept(int n) {
    return 'Kept (has history): $n';
  }

  @override
  String get accountDelete => 'Delete account';

  @override
  String accountDeleteBody(String email, int count) {
    return 'The account $email and its class links ($count) will be deleted. This cannot be undone. Its owner can then activate with their correct e-mail and send a join request.';
  }

  @override
  String get accountDeleted => 'Account deleted.';

  @override
  String get fixDeleteTeachers => 'Teachers';

  @override
  String get fixDeleteTeachersHelp =>
      'Deletes plain teacher accounts that never recorded a lecture, with their class links (e.g. imported with wrong e-mails). Accounts with lectures stay: suspend them or change their e-mail.';

  @override
  String get fixOnlyTeacherHint =>
      'Leave empty for every teacher who never recorded a lecture';

  @override
  String get fixOnlyEmail => 'One e-mail only (optional)';

  @override
  String get fixProblemHasHistory =>
      'This account recorded lectures, so it is kept to protect the register. Suspend it instead, or change its e-mail under Data fixes.';

  @override
  String get accountChangeEmail => 'Change e-mail';

  @override
  String get accountNewEmail => 'Correct e-mail';

  @override
  String accountChangeEmailBody(String from, int count, String to) {
    return 'The account $from and its class links ($count) move to $to. Its owner then activates with the new e-mail («First time? Activate») and sets their own password.';
  }

  @override
  String get accountEmailChanged =>
      'E-mail changed. Tell its owner to activate with the new e-mail («First time? Activate») — «Forgot password» does not work for an e-mail never activated.';

  @override
  String get groupsEditAction => 'Edit group members';

  @override
  String get groupsEditTitle => 'Group members';

  @override
  String get groupsHelp =>
      'Select one or more students, then «Move to…». Groups may differ in size. Attendance already recorded stays with the old group\'s lectures.';

  @override
  String groupsUnassigned(int count) {
    return 'No group · students: $count';
  }

  @override
  String groupsSelected(int count) {
    return 'Selected: $count';
  }

  @override
  String get groupsMoveTo => 'Move to…';

  @override
  String groupsMoveTitle(int count) {
    return 'Move $count student(s) to';
  }

  @override
  String groupsMoved(int count, String group) {
    return 'Moved $count to $group.';
  }

  @override
  String get groupsAdd => 'Add a group';

  @override
  String groupsAdded(String group) {
    return '$group added; move students into it.';
  }

  @override
  String get groupsNone =>
      'No groups yet. Create them first with «Create / redistribute groups».';

  @override
  String get assignmentsRedistributeWarning =>
      'Note: redistributing undoes any manual moves between groups.';

  @override
  String get yearTitle => 'Academic year settings';

  @override
  String get yearAction => 'Year & percentage settings';

  @override
  String get yearNone =>
      'No active academic year. Create it from «Set up» on the home screen.';

  @override
  String yearHeader(String year) {
    return 'Year $year';
  }

  @override
  String get yearHelp =>
      'These are the department\'s decisions behind absence percentages. Change them any time; every percentage follows.';

  @override
  String yearSemesterN(int n) {
    return 'Semester $n';
  }

  @override
  String get yearThresholds =>
      'Absence thresholds (share of the course\'s lectures)';

  @override
  String get levelAlert => 'Alert';

  @override
  String get levelWarning => 'Warning';

  @override
  String get levelDismissal => 'Dismissal';

  @override
  String get yearPlanned => 'Lectures per course per semester';

  @override
  String get yearWeeks => 'Weeks per semester';

  @override
  String get yearPerUnit => 'Lectures per credit unit per week';

  @override
  String get yearPerUnitHelp =>
      'E.g. 1: a 3-unit course = 3 lectures a week. Use 0.5 when two units make one lecture.';

  @override
  String yearExample(int count, String percent) {
    return 'Example: a 3-unit course = $count lectures a semester; one absence = $percent%.';
  }

  @override
  String get yearCombined => 'One percentage for theory and practical together';

  @override
  String get yearCombinedOn =>
      'Theory and practical absences add up in the course\'s percentage.';

  @override
  String get yearCombinedOff =>
      'Separate theory and practical percentages, each over the course\'s lectures.';

  @override
  String get yearLock => 'Locking the register';

  @override
  String get yearLockHours =>
      'The register locks after the lecture day ends by';

  @override
  String get yearHoursSuffix => 'hours';

  @override
  String get yearLockHelp =>
      'After that a teacher needs an edit request; stage managers and admins edit directly.';

  @override
  String get yearLeaves => 'Leaves';

  @override
  String get yearLeavesCount => 'Leaves count as absences';

  @override
  String get yearLeavesCountOn =>
      'Excused absences (and those covered by a leave) count in the percentage.';

  @override
  String get yearLeavesCountOff =>
      'Excused absences and those covered by an approved leave do not count.';

  @override
  String get yearMaxLeave => 'Maximum accepted leave days (optional)';

  @override
  String get yearMaxLeaveHelp =>
      'Empty = no limit. Leave days beyond it count as absences.';

  @override
  String get yearBadNumber => 'Invalid number';

  @override
  String get yearInvalid =>
      'Check the values: thresholds increase (alert < warning < dismissal ≤ 100), weeks 1–30, lock 1–720 hours.';

  @override
  String get yearSaved => 'Year settings saved.';

  @override
  String get leavesTitle => 'Leaves';

  @override
  String get leavesAction => 'Leaves';

  @override
  String get leavesHelp =>
      'A leave entered here is approved: the student\'s absences on its days count as «excused» in every course (per the year settings).';

  @override
  String get leavesEmpty => 'No leaves in this stage.';

  @override
  String get leaveAdd => 'Add a leave';

  @override
  String get leaveStudent => 'Student (name or university ID)';

  @override
  String get leaveTypeLabel => 'Leave type';

  @override
  String get leaveTypeSick => 'Sick';

  @override
  String get leaveTypeOfficial => 'Official';

  @override
  String get leaveTypeEmergency => 'Emergency';

  @override
  String get leaveTypeParticipation =>
      'Official participation (activity or delegation)';

  @override
  String get leaveTypeOther => 'Other';

  @override
  String get leavePickRange => 'Pick the period (from – to)';

  @override
  String leaveRange(String from, String to) {
    return 'From $from to $to';
  }

  @override
  String leaveDays(int count) {
    return '$count day(s)';
  }

  @override
  String get leaveRef => 'Letter or medical report number';

  @override
  String leaveRefShown(String ref) {
    return 'Ref: $ref';
  }

  @override
  String get leaveSaved => 'Leave saved.';

  @override
  String get leaveDeleteTitle => 'Delete the leave?';

  @override
  String leaveDeleteBody(String name) {
    return '$name\'s leave is deleted; their absences on its days count again.';
  }

  @override
  String get warnTitle => 'Percentages & lists';

  @override
  String get warnAction => 'Percentages, alert & warning lists';

  @override
  String get warnTabLists => 'Lists';

  @override
  String get warnTabDecisions => 'Decisions';

  @override
  String get warnCourse => 'Course';

  @override
  String get warnAllCourses => 'All courses';

  @override
  String get warnAll => 'All';

  @override
  String get warnEdge => 'On the edge';

  @override
  String get warnHelp =>
      'Percentage = counted absences ÷ the course\'s planned lectures this semester (year settings). Updates with every save and leave.';

  @override
  String get warnEdgeHelp =>
      'Students who reach the next level after one more absence.';

  @override
  String get warnEmpty => 'Nobody in this list.';

  @override
  String warnSaveAction(String level) {
    return 'Save a department decision: $level list';
  }

  @override
  String get warnSaveTitle => 'Save the department decision?';

  @override
  String warnSaveBody(int count, String level) {
    return 'The $level list of $count student(s) is saved as it stands today. It stays editable and can be regenerated until an admin turns it into a deanery decision.';
  }

  @override
  String get warnSaved =>
      'Department decision saved. Find it under «Decisions».';

  @override
  String warnAbsences(int absences, int planned, String percent) {
    return '$absences absence(s) of $planned lectures = $percent%';
  }

  @override
  String warnExcused(int count) {
    return 'Excused (not counted): $count';
  }

  @override
  String warnOneMore(String level) {
    return '⚠ Reaches $level after one more absence';
  }

  @override
  String get warnNoDecisions => 'No saved decisions for this stage.';

  @override
  String warnDecisionTitle(String level, String course, int count) {
    return '$level · $course · $count student(s)';
  }

  @override
  String warnDeanery(String number, String date) {
    return 'Deanery decision no. $number of $date';
  }

  @override
  String warnDepartment(String date) {
    return 'Department decision (provisional) · $date';
  }

  @override
  String get warnDeaneryLabel => 'Deanery decision (final, locked)';

  @override
  String get warnDepartmentLabel => 'Department decision (provisional)';

  @override
  String get warnDepartmentHelp =>
      'Can be regenerated from today\'s percentages (after a transfer, postponement or leave); an admin then turns it into a deanery decision with the order number and date.';

  @override
  String get warnRegenerate => 'Regenerate';

  @override
  String warnRegenerateBody(int before, int after) {
    return 'The decision\'s list ($before) is replaced by today\'s ($after).';
  }

  @override
  String get warnRegenerated => 'Decision regenerated.';

  @override
  String get warnFinalize => 'Make it a deanery decision';

  @override
  String get warnFinalizeBody =>
      'Once converted the decision is locked for good — no edits, no deletion; any change needs a new decision.';

  @override
  String get warnOrderNumber => 'Administrative order number';

  @override
  String get warnOrderDate => 'Order date';

  @override
  String get warnFinalized => 'The decision is now a locked deanery decision.';

  @override
  String get warnDeleteTitle => 'Delete the department decision?';

  @override
  String get warnDeleteBody =>
      'The saved decision is deleted (the percentages themselves are unaffected).';

  @override
  String get warnDeleted => 'Decision deleted.';

  @override
  String get registerPercent => '%';

  @override
  String get registerPercentHelp =>
      'The student\'s absence percentage in the whole course (theory and practical per the year settings), after leaves. Refresh online to update.';

  @override
  String get recordRequestHint =>
      'The lecture is locked: tap a student to ask the stage manager to change their status.';

  @override
  String get editRequestTitle => 'Edit request';

  @override
  String editRequestNow(String status) {
    return 'Now: $status';
  }

  @override
  String get editRequestReason => 'Reason (required)';

  @override
  String get editRequestSend => 'Send the request';

  @override
  String get editRequestSent => 'Request sent to the stage manager.';

  @override
  String get editRequestPending => '⏳ Edit request awaiting approval';

  @override
  String get editRequestsTitle => 'Edit requests';

  @override
  String get editRequestsAction => 'Edit requests';

  @override
  String get editRequestsEmpty => 'No pending requests.';

  @override
  String editRequestLecture(String course, String date, int n) {
    return '$course · $date · lecture $n';
  }

  @override
  String editRequestWhy(String reason) {
    return 'Reason: $reason';
  }

  @override
  String get editRequestApprove => 'Approve and apply';

  @override
  String get editRequestReject => 'Reject';

  @override
  String get editRequestNote => 'Note (optional)';

  @override
  String get editRequestApproved =>
      'Record changed; teachers\' phones get it on refresh.';

  @override
  String get editRequestRejected => 'Request rejected.';

  @override
  String get dashTitle => 'Stage dashboard';

  @override
  String get dashAction => 'Stage dashboard';

  @override
  String dashToday(int count) {
    return 'Lectures recorded today: $count';
  }

  @override
  String dashWeek(int count) {
    return 'Last 7 days: $count lecture(s)';
  }

  @override
  String dashIdle(int count) {
    return 'Classes with nothing recorded for 7 days: $count';
  }

  @override
  String get dashIdleHelp =>
      'May be a holiday or cancelled lectures; check with their teachers.';

  @override
  String dashRequests(int count) {
    return 'Pending edit requests: $count';
  }

  @override
  String reportPrinted(String date) {
    return 'Printed $date';
  }

  @override
  String reportPage(int page, int pages) {
    return 'Page $page of $pages';
  }

  @override
  String get reportSignatureHint => 'Name and signature';

  @override
  String get reportPdf => 'PDF for printing and signing';

  @override
  String get reportPdfHelp => 'With the department header and signature boxes';

  @override
  String get reportExcel => 'Excel';

  @override
  String get reportExcelHelp => 'An editable, sortable sheet';

  @override
  String get reportSaved => 'File saved.';

  @override
  String get reportExport => 'Export';

  @override
  String get reportLetterPresent => 'P';

  @override
  String get reportLetterAbsent => 'A';

  @override
  String get reportLetterLate => 'L';

  @override
  String get reportLetterExcused => 'E';

  @override
  String get reportRegisterSheet => 'Register';

  @override
  String reportLecturesRange(int from, int to) {
    return 'Lectures $from to $to';
  }

  @override
  String reportRegisterTitle(String course) {
    return 'Attendance register: $course';
  }

  @override
  String reportLectureCount(int count) {
    return 'Lectures recorded: $count';
  }

  @override
  String get reportLegend =>
      'P = present, A = absent, L = late, E = excused, – = not recorded.';

  @override
  String get reportPercentNote =>
      'Percentage = counted absences ÷ the course\'s planned lectures × 100 per the year settings, over all of the course\'s lectures and approved leaves.';

  @override
  String get reportSignTeacher => 'Teacher';

  @override
  String get reportSignStageManager => 'Stage manager';

  @override
  String get reportSignHead => 'Head of department';

  @override
  String get reportSignDean => 'Dean';

  @override
  String get reportPlanned => 'Planned';

  @override
  String reportListTitle(String list, String stage) {
    return '$list list — $stage';
  }

  @override
  String reportStudentCount(int count) {
    return 'Students: $count';
  }

  @override
  String reportDecisionTitle(String level, String stage) {
    return '$level decision — $stage';
  }

  @override
  String reportStudentTitle(String name) {
    return 'Absence summary: $name';
  }

  @override
  String get reportStudentSheet => 'Summary';

  @override
  String get reportExcused => 'Excused';

  @override
  String get reportLevel => 'Level';

  @override
  String get reportStudentNote =>
      'Courses where the student has an absence, late or excused mark are listed.';

  @override
  String reportStatsTitle(String stage) {
    return 'Absence statistics — $stage';
  }

  @override
  String get reportStatsSheet => 'Statistics';

  @override
  String reportStatsLevels(int alert, int warning, int dismissal) {
    return 'Alert: $alert · Warning: $warning · Dismissal: $dismissal';
  }

  @override
  String get reportStatsByCourse => 'Courses by total absences';

  @override
  String get reportAbsentStudents => 'Absent students';

  @override
  String get reportTotalAbsences => 'Total absences';

  @override
  String get reportTopSheet => 'Most absent';

  @override
  String reportTopStudents(int count) {
    return 'Most absent students ($count)';
  }

  @override
  String get reportStudentAction => 'Student summary (PDF)';

  @override
  String get reportStatsAction => 'Stage statistics';

  @override
  String get reportListAction => 'Export the list';

  @override
  String get reportRegisterAction => 'Export the register';

  @override
  String get letterWarningTitle => 'Absence warning';

  @override
  String get letterDismissalTitle => 'Notice of failing by absence';

  @override
  String get letterNumberDate =>
      'No.: ................     Date: ....../....../..........';

  @override
  String letterTo(String name, String id, String stage) {
    return 'To the student: $name — university ID $id — $stage';
  }

  @override
  String letterWarningBody(
    String course,
    String percent,
    int absences,
    int planned,
    String warning,
    String dismissal,
  ) {
    return 'Your absences in ($course) have reached $percent% of the course\'s planned lectures ($absences of $planned), beyond the department\'s warning threshold ($warning%). This is a formal warning: reaching $dismissal% means failing the course by absence under the regulations in force.';
  }

  @override
  String get letterWarningClosing =>
      'Please attend regularly and see the stage manager if you have a valid excuse.';

  @override
  String letterDismissalBody(
    String course,
    String percent,
    int absences,
    int planned,
    String dismissal,
  ) {
    return 'Your absences in ($course) have reached $percent% of the course\'s planned lectures ($absences of $planned), the department\'s threshold for failing by absence ($dismissal%). You are therefore considered to have failed the course by absence under the regulations in force.';
  }

  @override
  String get letterDismissalClosing =>
      'This notice is provisional until the deanery\'s decision.';

  @override
  String get letterAction => 'Warning letter (PDF)';

  @override
  String get letterBatchAction => 'Letters for the whole list (PDF)';

  @override
  String get backupAction => 'Backup';

  @override
  String get backupTitle => 'Backup';

  @override
  String get backupAdminsOnly => 'Backups are for admins only.';

  @override
  String get backupNever => 'No backup saved yet.';

  @override
  String backupLast(String date, String time) {
    return 'Last backup: $date at $time';
  }

  @override
  String backupLastDetail(int count, String by) {
    return '$count documents · $by';
  }

  @override
  String backupAgo(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Last backup $days days ago',
      one: 'Last backup a day ago',
      zero: 'Last backup today',
    );
    return '$_temp0';
  }

  @override
  String get backupDue => 'More than a week ago; save a new one.';

  @override
  String get backupCreateTitle => 'Create a backup';

  @override
  String get backupCreateHelp =>
      'One password-encrypted file with all department data. Keep it off the phone (computer, Google Drive, e-mail). It opens only with the password.';

  @override
  String get backupCount => 'Calculate size';

  @override
  String backupEstimate(int count) {
    return '$count documents (accounts, courses, students, lectures, statistics…)';
  }

  @override
  String backupWithRecords(int count) {
    return 'Include detailed attendance records ($count)';
  }

  @override
  String get backupRecordsHelp =>
      'Each record is one read of the free plan quota (50,000 a day). Percentages do not need them (they are in the statistics).';

  @override
  String get backupPassword => 'Backup password';

  @override
  String get backupPasswordConfirm => 'Confirm password';

  @override
  String get backupPasswordWarning =>
      'If the password is lost the backup can never be opened.';

  @override
  String get backupPasswordShort => 'The password needs at least 8 characters.';

  @override
  String get backupPasswordMismatch => 'The passwords do not match.';

  @override
  String get backupCreate => 'Create and save';

  @override
  String backupReading(String name) {
    return 'Reading $name…';
  }

  @override
  String get backupEncrypting => 'Encrypting…';

  @override
  String backupSaved(int count) {
    return 'Backup saved ($count documents).';
  }

  @override
  String backupCollection(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'academicYears': 'Years',
      'stages': 'Stages',
      'users': 'Accounts',
      'courses': 'Courses',
      'students': 'Students',
      'groups': 'Groups',
      'assignments': 'Assignments',
      'sessions': 'Lectures',
      'leaves': 'Leaves',
      'stats': 'Statistics',
      'warningLists': 'Decisions',
      'config': 'Settings',
      'editRequests': 'Edit requests',
      'accessRequests': 'Join requests',
      'auditLog': 'Audit log',
      'records': 'Attendance records',
      'other': '$name',
    });
    return '$_temp0';
  }

  @override
  String get backupRestoreTitle => 'Restore from a backup';

  @override
  String get backupRestoreHelp =>
      'Super admin only. Writes every document of the backup back over the current one; documents added later stay. Edit/join requests and the audit log are not restored. Can be run again if interrupted.';

  @override
  String get backupPickFile => 'Choose a backup file (.uobk)';

  @override
  String get backupOpen => 'Open file';

  @override
  String get backupWrongPassword => 'Wrong password or damaged file.';

  @override
  String get backupNotABackup => 'This is not a backup file of this app.';

  @override
  String backupFileInfo(String date, String by) {
    return 'Backup of $date — $by';
  }

  @override
  String get backupRestore => 'Restore';

  @override
  String get backupRestoreConfirmTitle => 'Restore this backup?';

  @override
  String get backupRestoreConfirmBody =>
      'Current data is replaced by the backup for every document it contains. This cannot be undone. Save a backup of the current state first.';

  @override
  String get backupRestoreTypeTitle => 'Final confirmation';

  @override
  String backupRestoreType(String word) {
    return 'Type “$word” to continue';
  }

  @override
  String get backupRestoreWord => 'restore';

  @override
  String backupRestoreProgress(int done, int total) {
    return 'Batch $done of $total';
  }

  @override
  String backupRestored(int count) {
    return 'Restore finished ($count writes).';
  }

  @override
  String backupRestoreFailed(String error) {
    return 'Restore stopped: $error. Run it again to finish (the daily write quota may be used up).';
  }

  @override
  String get auditOpen => 'Audit log';

  @override
  String get auditTitle => 'Audit log';

  @override
  String get auditAllStages => 'Whole department';

  @override
  String get auditEmpty => 'Nothing logged.';

  @override
  String get auditMore => 'Show more';

  @override
  String get auditEnd => 'End of the log';

  @override
  String get auditBefore => 'Before';

  @override
  String get auditAfter => 'After';

  @override
  String auditActionLabel(String action) {
    String _temp0 = intl.Intl.selectLogic(action, {
      'session_missed': 'Missed lecture recorded',
      'record_update': 'Attendance changed',
      'editRequest_reject': 'Edit request rejected',
      'leave_create': 'Leave added',
      'leave_delete': 'Leave deleted',
      'warnings_create': 'Decision created',
      'warnings_regenerate': 'Decision regenerated',
      'warnings_delete': 'Decision deleted',
      'warnings_finalize': 'Decision sent to the deanery',
      'user_create': 'Account added',
      'user_update': 'Account edited',
      'user_approve': 'Join request approved',
      'user_reject': 'Join request rejected',
      'user_rename': 'Account e-mail changed',
      'users_delete': 'Accounts deleted',
      'student_rename': 'University ID changed',
      'students_delete': 'Students deleted',
      'course_rename': 'Course code changed',
      'courses_delete': 'Courses deleted',
      'import_students': 'Students imported',
      'import_teachers': 'Teachers imported',
      'import_courses': 'Courses imported',
      'year_update': 'Year settings changed',
      'backup_export': 'Backup saved',
      'backup_restore': 'Backup restored',
      'config_update': 'App release changed',
      'other': '$action',
    });
    return '$_temp0';
  }

  @override
  String get deptAction => 'Department dashboard';

  @override
  String get deptTitle => 'Department dashboard';

  @override
  String deptActiveAccounts(int count) {
    return '$count active accounts';
  }

  @override
  String deptAccessRequests(int count) {
    return 'Pending join requests: $count';
  }

  @override
  String get deptStageEmpty => 'No data yet.';

  @override
  String deptStudents(int count) {
    return '$count students';
  }

  @override
  String deptCourses(int count) {
    return '$count courses';
  }

  @override
  String deptLecturesToday(int count) {
    return 'Lectures today: $count';
  }

  @override
  String deptPendingRequests(int count) {
    return 'Edit requests: $count';
  }

  @override
  String get syncRejectedTap => 'Tap for the reason and to retry';

  @override
  String get syncReasonLocked =>
      'The lecture locked before it was uploaded. Only the stage manager can save it now: send them the names, then remove it from the phone.';

  @override
  String get syncReasonDenied =>
      'The server refused the save. Press Retry (the lock time is recomputed from the year settings); if it repeats, check your assignment with the stage manager.';

  @override
  String deptPartial(String collections, String code) {
    return 'Some counts could not be read ($collections) — $code. If it says “permission-denied”, the deployed rules are older than the app: deploy firestore.rules.';
  }

  @override
  String get errorDetails => 'Details';

  @override
  String get errorReportTitle => 'Problem report';

  @override
  String get errorReportHelp =>
      'Press Copy and paste it in a message to the developer (or take a screenshot). It contains no passwords.';

  @override
  String get errorCopy => 'Copy';

  @override
  String get errorLogAction => 'Error log (to send to the developer)';

  @override
  String get errorLogEmpty => 'No errors since the app was opened.';

  @override
  String errorLogCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count errors since the app was opened',
      one: 'One error since the app was opened',
      zero: 'No errors since the app was opened',
    );
    return '$_temp0';
  }

  @override
  String get syncDiagnose => 'Diagnose';

  @override
  String get syncDiagnoseTitle => 'Save diagnosis';

  @override
  String get syncDiagnoseRunning => 'Checking on the server…';

  @override
  String get studentNoData =>
      'This course has not been downloaded yet; refresh the register.';

  @override
  String studentHistory(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lectures not fully attended',
      one: 'One lecture not fully attended',
      zero: 'No absences or lateness',
    );
    return '$_temp0';
  }

  @override
  String get studentNoAbsences => 'Attended every recorded lecture.';

  @override
  String get studentSourceNote =>
      'Includes the course\'s lectures by all its teachers as last downloaded (refresh in the register) and this phone\'s records.';

  @override
  String studentCounts(int lates, int excused, int byLeave) {
    return 'Late: $lates · Excused: $excused · of which on approved leave: $byLeave';
  }

  @override
  String studentUntilNext(int count, String level) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Reaches $level after $count more absences',
      one: 'Reaches $level after one more absence',
    );
    return '$_temp0';
  }

  @override
  String get studentOnLeave => 'on approved leave';

  @override
  String get reportPeriodAll => 'The whole semester';

  @override
  String get reportPeriodPick => 'A period…';

  @override
  String reportPeriod(String from, String to) {
    return 'Period: $from to $to';
  }

  @override
  String get reportPeriodNote =>
      'The absences column counts lectures in the period only; the percentage is for the whole semester.';

  @override
  String get auditSearch => 'Search';

  @override
  String get auditSearchActive => 'Search (active)';

  @override
  String get auditActor => 'E-mail of the user who acted';

  @override
  String get auditText => 'University ID or text';

  @override
  String get auditTextHelp =>
      'Searched in the target and its before/after values';

  @override
  String get auditAnyDate => 'Any date';

  @override
  String get auditClear => 'Clear';

  @override
  String get auditApply => 'Search';

  @override
  String get auditNoMatch => 'No matching entries.';

  @override
  String get notifTitle => 'Notifications';

  @override
  String get notifCompose => 'New message';

  @override
  String get notifMessages => 'Department messages';

  @override
  String get notifNoMessages => 'No messages.';

  @override
  String get notifRequests => 'Edit requests';

  @override
  String get notifDecisions => 'Decisions on your requests';

  @override
  String get notifAlerts => 'Students at alert level';

  @override
  String get notifAlertsOnPhone =>
      'Students of your classes appear on the phone.';

  @override
  String get notifNoAlerts => 'No students at alert level or above.';

  @override
  String get notifNew => 'New';

  @override
  String get notifApproved => 'The stage manager approved your request';

  @override
  String get notifRejected => 'Your request was rejected';

  @override
  String notifStageAlerts(String stage) {
    return '$stage: open to list the students';
  }

  @override
  String notifOpenWarnings(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count students — open percentages and lists',
      one: 'One student — open percentages and lists',
    );
    return '$_temp0';
  }

  @override
  String get notifAudience => 'To';

  @override
  String get notifToAll => 'Everyone';

  @override
  String get notifToTeachers => 'Teachers';

  @override
  String get notifToStageManagers => 'Stage managers';

  @override
  String get notifToStage => 'A stage';

  @override
  String get notifMessageTitle => 'Title';

  @override
  String get notifMessageBody => 'Message';

  @override
  String get notifSend => 'Send';

  @override
  String get notifSent => 'Message sent.';

  @override
  String get chartTitle => 'Absence rates';

  @override
  String get chartHelp =>
      'Mean absence percentage of the students (no absence counts as zero) this semester. It reads every stage’s statistics, so show it when needed.';

  @override
  String get chartShow => 'Show chart';

  @override
  String get chartByStage => 'By stage';

  @override
  String chartByCourse(String stage) {
    return 'By course — $stage';
  }

  @override
  String get chartTapStage => 'Tap a stage to see its courses.';

  @override
  String get chartNoData => 'No data yet.';

  @override
  String chartBarTip(String mean, int alert, int students) {
    return 'Mean absence $mean% · at alert or above: $alert of $students students';
  }

  @override
  String get missedTitle => 'Record a missed lecture';

  @override
  String get missedHelp =>
      'For a lecture that was not recorded in time, for any class of your stage. It is saved straight to the server (needs a connection), reaches the teachers\' phones and counts in the percentages.';

  @override
  String get missedClass => 'Class';

  @override
  String get missedPickClass => 'Choose the class';

  @override
  String get missedDate => 'Lecture date';

  @override
  String missedLectureNo(int no) {
    return 'This will be lecture $no of this class on that day.';
  }

  @override
  String get missedHint =>
      'Tap a name to change the status in turn: present, absent, late, excused.';

  @override
  String get missedAllPresent => 'All present';

  @override
  String get missedSave => 'Save the lecture';

  @override
  String missedConfirm(
    int no,
    String date,
    String cls,
    int absent,
    int late,
    int excused,
    int present,
  ) {
    return 'Lecture $no of $date for $cls will be saved:\nabsent $absent, late $late, excused $excused, present $present.\nOnly a stage manager or an admin can delete it afterwards.';
  }

  @override
  String get missedSaved => 'The lecture was saved.';

  @override
  String get missedNoClasses => 'This stage has no assigned classes.';

  @override
  String get missedNoStudents => 'This class has no students.';

  @override
  String get dashMissedHelp =>
      'For a class whose lecture was not recorded in time, on any past day.';

  @override
  String get yearMissed => 'Allow recording a missed lecture';

  @override
  String get yearMissedOn =>
      'On: stage managers and admins see «Record a missed lecture» on the stage dashboard, for any class of their stage on any past day.';

  @override
  String get yearMissedOff =>
      'Off: a lecture past its lock time can only be corrected through edit requests.';

  @override
  String get missedDisabled =>
      'Recording missed lectures is off. An admin can switch it on in Year settings.';

  @override
  String get yearSystems => 'Stage systems';

  @override
  String get yearSystemsHelp =>
      'Semester stage: each semester\'s courses are counted over the semester\'s weeks. Annual stage: its courses run all year and are counted over the year\'s weeks. The thresholds are the same for both.';

  @override
  String get yearSystemSemester => 'Semester';

  @override
  String get yearSystemAnnual => 'Annual';

  @override
  String get yearWeeksYear => 'Weeks per year (annual stages)';

  @override
  String get yearWeeksYearHelp =>
      'For example 30: a 3-unit annual course = 90 lectures a year.';

  @override
  String assignmentsCourseInfoAnnual(String code, String units) {
    return '$code · $units units · annual';
  }

  @override
  String get activityAction => 'Teacher activity';

  @override
  String get activityTitle => 'Teacher activity';

  @override
  String get activityHelp =>
      'When each teacher last opened the app and when their phone last uploaded attendance (a lecture recorded or edited). Tracking starts with this update, so anyone who has not opened it yet shows as «Not yet». Tap a name for details, their lectures and class registers, and to send a message.';

  @override
  String get activityAll => 'All';

  @override
  String get activityToday => 'Today';

  @override
  String get activityRecent => 'Last 7 days';

  @override
  String get activityIdle => 'Inactive';

  @override
  String get activityNever => 'Not yet';

  @override
  String get activityEmpty => 'No teachers in this group.';

  @override
  String get activityNeverSeen => 'Not opened yet';

  @override
  String activityLastSeen(String when) {
    return 'Last seen: $when';
  }

  @override
  String get activityNoUpload => 'No attendance uploaded yet';

  @override
  String activityLastUpload(String when) {
    return 'Last upload: $when';
  }

  @override
  String activityDevice(String device) {
    return 'Device and version: $device';
  }

  @override
  String activityLectures(int count) {
    return 'Lectures opened: $count';
  }

  @override
  String activityLectureNo(int no) {
    return 'Lecture $no';
  }

  @override
  String get activityLecturesError => 'Could not read the lectures.';

  @override
  String get activitySendMessage => 'Send a message';

  @override
  String activityMessageShown(int count) {
    return 'Message those shown ($count)';
  }

  @override
  String activityRecipients(int count) {
    return '$count teachers';
  }

  @override
  String activityTo(String names) {
    return 'To: $names';
  }

  @override
  String get activityInAppOnly =>
      'It appears under «Notifications» in the app, with a badge on the home screen when opened; it is not a phone notification while the app is closed.';

  @override
  String activitySent(int count) {
    return 'Message sent to $count.';
  }

  @override
  String get agoJustNow => 'just now';

  @override
  String agoMinutes(int n) {
    return '$n min ago';
  }

  @override
  String agoHours(int n) {
    return '$n h ago';
  }

  @override
  String agoDays(int n) {
    return '$n days ago';
  }

  @override
  String get notifToMe => 'Personal message';

  @override
  String activitySentPush(int count, int phones) {
    return 'Message sent to $count; it reached $phones phones.';
  }

  @override
  String activitySentNoPush(int count) {
    return 'Message sent to $count in the app; phones could not be reached now.';
  }

  @override
  String get activityPushOn => 'notifications on';

  @override
  String get activityPushOnLong =>
      'Phone notifications on: messages arrive even with the app closed.';

  @override
  String get activityPushOff =>
      'Phone notifications off (version 1.4 not installed, or not allowed).';

  @override
  String get activityPushNote =>
      'Arrives as a phone notification for those on version 1.4 who allowed notifications, and in «Notifications» in the app for everyone.';

  @override
  String get reportVerifyHint =>
      'Scan to verify this document, or enter the verification code:';

  @override
  String get annAction => 'Department announcements';

  @override
  String get annTitle => 'Department announcements';

  @override
  String get annHelp =>
      'These are public, without signing in, on the announcements page that the department\'s QR code opens.';

  @override
  String get annEmpty => 'No announcements yet.';

  @override
  String get annAdd => 'New announcement';

  @override
  String get annEdit => 'Edit announcement';

  @override
  String get annFieldTitle => 'Title';

  @override
  String get annFieldBody => 'Text';

  @override
  String get annSaved => 'Announcement saved.';

  @override
  String get annDeleteTitle => 'Delete the announcement?';

  @override
  String get annDeleteBody =>
      'It disappears from the public announcements page at once.';

  @override
  String get annDeleted => 'Announcement deleted.';

  @override
  String get annQr => 'Announcements page QR';

  @override
  String get annQrHelp =>
      'Post this code in the department: scanning it with a phone camera opens the announcements page.';

  @override
  String get annCopyLink => 'Copy link';

  @override
  String get annLinkCopied => 'Link copied.';

  @override
  String get annPoster => 'Printable PDF poster';

  @override
  String get annPosterTitle => 'Department announcements';

  @override
  String get annPosterLine =>
      'Scan with your phone camera for the latest announcements';

  @override
  String annEdited(String date) {
    return 'edited $date';
  }

  @override
  String get releaseAction => 'App release';

  @override
  String get releaseTitle => 'App release';

  @override
  String get releaseHelp =>
      'After publishing a new APK, enter its version and download link here: anyone on an older version sees a «new update» banner with a download button. Small Shorebird patches arrive by themselves and do not need this.';

  @override
  String releaseInstalled(String version) {
    return 'Version on this device: $version';
  }

  @override
  String get releaseLatest => 'Latest version (e.g. 1.4.0)';

  @override
  String get releaseMinimum => 'Oldest version allowed (optional)';

  @override
  String get releaseMinimumHelp =>
      'Anyone older than this cannot use the app until they update. Leave it empty unless a rules change breaks older versions.';

  @override
  String get releaseAndroidUrl => 'Android download link';

  @override
  String get releaseIosUrl => 'iOS link (optional)';

  @override
  String get releaseUrlHelp =>
      'A public link that works without signing in, e.g. a Google Drive link shared with «anyone with the link».';

  @override
  String get releaseNotes => 'What\'s new (shown in the banner)';

  @override
  String releasePreview(String latest) {
    return 'After saving: anyone older than $latest sees the update banner.';
  }

  @override
  String releasePreviewRequired(String minimum) {
    return 'And anyone older than $minimum cannot use the app until they update.';
  }

  @override
  String get releaseSaved =>
      'Saved. The banner appears when the app is opened.';

  @override
  String get releaseConfirmTitle => 'Stop older versions?';

  @override
  String releaseConfirmBody(String minimum) {
    return 'Anyone older than $minimum will not be able to use the app until they install the update, and may keep unsent records until then. Check that the link works before saving.';
  }

  @override
  String get releaseLatestMissing => 'Enter the latest version.';

  @override
  String get releaseVersionInvalid => 'Format: numbers with dots, e.g. 1.4.0';

  @override
  String get releaseMinimumAboveLatest =>
      'The oldest allowed version cannot be newer than the latest.';

  @override
  String get releaseUrlInvalid => 'The link must start with https://';

  @override
  String get releaseOpenLink => 'Test the link';

  @override
  String get activitySearch => 'Search by teacher name or email';

  @override
  String get coursePanelAction => 'Course panel';

  @override
  String get coursePanelExport => 'Download the course panel as PDF or Excel';

  @override
  String get coursePanelInfo => 'Information';

  @override
  String coursePanelLectures(int count) {
    return 'Lectures ($count)';
  }

  @override
  String coursePanelStudents(int count) {
    return 'Students ($count)';
  }

  @override
  String get coursePanelMissing => 'This course no longer exists.';

  @override
  String coursePanelWithPractical(int count) {
    return 'Theory and practical ($count groups)';
  }

  @override
  String get coursePanelTheoryOnly => 'Theory only';

  @override
  String coursePanelLastLecture(String date) {
    return 'Last lecture: $date';
  }

  @override
  String get coursePanelClasses => 'Classes and teachers';

  @override
  String get coursePanelClassesHelp =>
      'Tap a class to view and download its register.';

  @override
  String get coursePanelNoClasses => 'No teacher is linked to this course yet.';

  @override
  String get coursePanelNoTeacher => 'No teacher';

  @override
  String coursePanelLectureCount(int count) {
    return '$count lectures';
  }

  @override
  String get coursePanelAllPresent => 'Nobody was absent in this lecture.';

  @override
  String get coursePanelSearch => 'Search by student name or ID';

  @override
  String coursePanelReportTitle(String name) {
    return 'Course panel: $name';
  }

  @override
  String get coursePanelStudentsSheet => 'Students';

  @override
  String get coursePanelLecturesSheet => 'Lectures';

  @override
  String get coursePanelGroup => 'Group';

  @override
  String get coursePanelDate => 'Date';

  @override
  String get coursePanelLectureNo => 'No.';

  @override
  String get coursePanelClass => 'Class';

  @override
  String get coursePanelTeacher => 'Teacher';

  @override
  String homeGroupsList(String groups) {
    return 'Groups: $groups';
  }

  @override
  String get homePickGroup =>
      'Pick a group to record its attendance or view its register.';
}
