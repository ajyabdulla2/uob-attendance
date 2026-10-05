// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'نظام الحضور والغياب';

  @override
  String get universityName => 'جامعة البصرة';

  @override
  String get collegeName => 'كلية التربية للعلوم الصرفة';

  @override
  String get departmentName => 'قسم علوم الحاسوب';

  @override
  String get ok => 'حسناً';

  @override
  String get cancel => 'إلغاء';

  @override
  String get save => 'حفظ';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get close => 'إغلاق';

  @override
  String get confirm => 'تأكيد';

  @override
  String get delete => 'حذف';

  @override
  String get loading => 'جارٍ التحميل…';

  @override
  String errorGeneric(String error) {
    return 'حدث خطأ غير متوقع: $error';
  }

  @override
  String get permissionDenied => 'لا تملك صلاحية هذا الإجراء.';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get languageSwitch => 'English';

  @override
  String get toggleTheme => 'تبديل الوضع الليلي';

  @override
  String get loginTitle => 'تسجيل الدخول';

  @override
  String get activateTitle => 'تفعيل حساب جديد';

  @override
  String get emailLabel => 'البريد الجامعي';

  @override
  String get passwordLabel => 'كلمة المرور';

  @override
  String get confirmPasswordLabel => 'تأكيد كلمة المرور';

  @override
  String get showPassword => 'إظهار كلمة المرور';

  @override
  String get signIn => 'دخول';

  @override
  String get activate => 'تفعيل الحساب';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get haveNoAccount => 'أول مرة؟ فعّل حسابك';

  @override
  String get haveAccount => 'لديك حساب مفعَّل؟ سجّل الدخول';

  @override
  String get activateHint =>
      'يفعّل التدريسي حسابه بالبريد الذي أضافته إدارة القسم، ثم يؤكّده من الرسالة المرسلة إلى بريده.';

  @override
  String get resetPasswordTitle => 'استعادة كلمة المرور';

  @override
  String get resetPasswordBody =>
      'أدخل بريدك وسنرسل إليك رابطاً لتعيين كلمة مرور جديدة. الرابط يصل فقط لبريد فُعِّل من قبل؛ إن كان حسابك جديداً أو غيّرت الإدارة بريدك فاضغط «إلغاء» ثم «أول مرة؟ فعّل حسابك».';

  @override
  String get sendLink => 'إرسال الرابط';

  @override
  String get passwordResetSent =>
      'إن كان البريد مفعَّلاً فستصلك رسالة خلال دقائق (تفقّد مجلد Spam أيضاً). لم تصل؟ فعّل حسابك من «أول مرة؟ فعّل حسابك».';

  @override
  String get validationRequired => 'هذا الحقل مطلوب';

  @override
  String get validationEmail => 'صيغة البريد غير صحيحة';

  @override
  String get validationPasswordLength => 'كلمة المرور 8 أحرف على الأقل';

  @override
  String get validationPasswordMatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get authInvalidCredentials =>
      'البريد أو كلمة المرور غير صحيحة، أو لم يُفعَّل هذا البريد بعد (فعّله من «أول مرة؟ فعّل حسابك»).';

  @override
  String get authInvalidEmail => 'صيغة البريد غير صحيحة.';

  @override
  String get authEmailInUse =>
      'هذا البريد مفعَّل مسبقاً. سجّل الدخول أو استعد كلمة المرور.';

  @override
  String get authWeakPassword => 'كلمة المرور ضعيفة؛ اختر كلمة أطول.';

  @override
  String get authUserDisabled => 'هذا الحساب معطَّل. راجع إدارة القسم.';

  @override
  String get authTooManyRequests => 'محاولات كثيرة. حاول بعد قليل.';

  @override
  String get authNetwork =>
      'لا يوجد اتصال بالإنترنت. تسجيل الدخول أول مرة يتطلب اتصالاً.';

  @override
  String authUnknown(String code) {
    return 'تعذّر إكمال العملية ($code).';
  }

  @override
  String get verifyTitle => 'تأكيد البريد';

  @override
  String verifyBody(String email) {
    return 'أرسلنا رابط تأكيد إلى $email. افتح الرسالة واضغط الرابط، ثم عد إلى هنا.\nلم تصل خلال دقيقتين؟ ابحث في مجلد الرسائل غير المرغوب فيها (Spam) عن رسالة من noreply.';
  }

  @override
  String get verifyDone => 'أكّدت بريدي';

  @override
  String get verifyResend => 'إعادة إرسال الرابط';

  @override
  String get verifySent => 'أُرسل رابط جديد.';

  @override
  String get verifyNotYet =>
      'لم يُؤكَّد البريد بعد. تحقق من مجلد الرسائل غير المرغوب فيها.';

  @override
  String get notProvisionedTitle => 'الحساب غير مضاف';

  @override
  String notProvisionedBody(String email) {
    return 'البريد $email غير مسجَّل في النظام بعد. أرسل طلب انضمام أدناه، أو اطلب من إدارة القسم إضافتك.';
  }

  @override
  String get suspendedTitle => 'الحساب موقوف';

  @override
  String get suspendedBody => 'أُوقف هذا الحساب من إدارة القسم.';

  @override
  String get profileErrorTitle => 'تعذّر تحميل الحساب';

  @override
  String get profileErrorBody => 'تحقق من الاتصال ثم أعد المحاولة.';

  @override
  String get configErrorTitle => 'إعداد Firebase غير مكتمل';

  @override
  String get configErrorBody =>
      'شغّل الأمر flutterfire configure لتوليد lib/firebase_options.dart ثم أعد بناء التطبيق.';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navImport => 'الاستيراد';

  @override
  String get navAssignments => 'الربط';

  @override
  String get navProfile => 'الملف الشخصي';

  @override
  String get roleSuperAdmin => 'مدير عام';

  @override
  String get roleDeputyAdmin => 'مدير ثانٍ';

  @override
  String get roleStageManager => 'مسؤول مرحلة';

  @override
  String get roleTeacher => 'تدريسي';

  @override
  String get level1 => 'المرحلة الأولى';

  @override
  String get level2 => 'المرحلة الثانية';

  @override
  String get level3 => 'المرحلة الثالثة';

  @override
  String get level4 => 'المرحلة الرابعة';

  @override
  String get shiftMorning => 'صباحي';

  @override
  String get shiftEvening => 'مسائي';

  @override
  String stageLabel(String level, String shift) {
    return '$level — $shift';
  }

  @override
  String get statusContinuing => 'مستمر';

  @override
  String get statusPostponed => 'مؤجل';

  @override
  String get statusFailedByAbsence => 'راسب بالغياب';

  @override
  String get statusWithdrawn => 'منسحب';

  @override
  String get statusTransferredIn => 'منقول إلى القسم';

  @override
  String get theoryLabel => 'نظري';

  @override
  String get practicalLabel => 'عملي';

  @override
  String groupLabel(String name) {
    return 'مجموعة $name';
  }

  @override
  String sectionLabel(String name) {
    return 'شعبة $name';
  }

  @override
  String get allSections => 'كل الشعب';

  @override
  String homeWelcome(String name) {
    return 'أهلاً، $name';
  }

  @override
  String get homeRoles => 'صلاحياتك';

  @override
  String get homeStageScopes => 'المراحل المسندة إليك';

  @override
  String get homeMyCourses => 'موادي';

  @override
  String get homeNoCourses => 'لم تُسند إليك مواد بعد.';

  @override
  String get homeSetupTitle => 'تهيئة البيانات الأساسية';

  @override
  String get homeSetupBody =>
      'لم تُنشأ المراحل الثمان أو السنة الدراسية النشطة بعد.';

  @override
  String get homeSetupAction => 'تهيئة الآن';

  @override
  String get homeSetupDone => 'تمت التهيئة.';

  @override
  String homeActiveYear(String year, String semester) {
    return 'السنة الدراسية $year — الفصل $semester';
  }

  @override
  String get homeQuickActions => 'إجراءات سريعة';

  @override
  String get homeImportAction => 'استيراد الطلبة والتدريسيين والمواد';

  @override
  String get homeAssignAction => 'ربط التدريسيين بالمواد والمجاميع';

  @override
  String pendingUploads(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count سجل بانتظار الرفع',
      many: '$count سجلاً بانتظار الرفع',
      few: '$count سجلات بانتظار الرفع',
      two: 'سجلّان بانتظار الرفع',
      one: 'سجل واحد بانتظار الرفع',
      zero: 'لا توجد سجلات بانتظار الرفع',
    );
    return '$_temp0';
  }

  @override
  String get profileTitle => 'الملف الشخصي';

  @override
  String get profileTheme => 'المظهر';

  @override
  String get themeSystem => 'حسب النظام';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'ليلي';

  @override
  String get profileLanguage => 'اللغة';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageEnglish => 'English';

  @override
  String get profilePhone => 'الهاتف';

  @override
  String get profilePhoneSaved => 'حُفظ رقم الهاتف.';

  @override
  String get profileChangePassword => 'تغيير كلمة المرور';

  @override
  String get profileResetLinkSent => 'أُرسل رابط تغيير كلمة المرور إلى بريدك.';

  @override
  String get signOutConfirm => 'هل تريد تسجيل الخروج؟';

  @override
  String signOutPending(int count) {
    return 'لا يمكن تسجيل الخروج: توجد $count سجلات غير مرفوعة. اتصل بالإنترنت وانتظر الرفع أولاً.';
  }

  @override
  String get importTitle => 'استيراد البيانات';

  @override
  String get importStudents => 'الطلبة';

  @override
  String get importTeachers => 'التدريسيون';

  @override
  String get importCourses => 'المواد';

  @override
  String get importStep1 => '١. نزّل القالب واملأه';

  @override
  String get importStep2 => '٢. اختر الملف (xlsx أو csv)';

  @override
  String get importDownloadTemplate => 'تنزيل القالب';

  @override
  String get importTemplateSaved => 'حُفظ القالب.';

  @override
  String get importPickFile => 'اختيار ملف';

  @override
  String importFileName(String name) {
    return 'الملف: $name';
  }

  @override
  String get importUpdateExistingStudents =>
      'تحديث الموجود حسب الرقم الجامعي بدل تجاوزه';

  @override
  String get importUpdateExistingTeachers =>
      'تحديث الموجود حسب البريد بدل تجاوزه';

  @override
  String get importUpdateExistingCourses =>
      'تحديث الموجود حسب رمز المادة والمرحلة بدل تجاوزه';

  @override
  String get importDefaultStage => 'المرحلة الافتراضية (إن لم يحددها الملف)';

  @override
  String get importDefaultStageNone => 'من الملف';

  @override
  String get importDefaultSemester => 'الفصل الافتراضي (إن لم يحدده الملف)';

  @override
  String get importPreviewTitle => 'معاينة قبل الحفظ';

  @override
  String importSummaryCreate(int count) {
    return 'جديد: $count';
  }

  @override
  String importSummaryUpdate(int count) {
    return 'تحديث: $count';
  }

  @override
  String importSummarySkip(int count) {
    return 'متجاوَز: $count';
  }

  @override
  String importSummaryInvalid(int count) {
    return 'أخطاء: $count';
  }

  @override
  String importSummaryWarnings(int count) {
    return 'تحذيرات: $count';
  }

  @override
  String get importFilterAll => 'كل الصفوف';

  @override
  String get importFilterProblems => 'المشكلات فقط';

  @override
  String importRow(String row) {
    return 'الصف $row';
  }

  @override
  String importSave(int count) {
    return 'حفظ ($count)';
  }

  @override
  String get importSaving => 'جارٍ الحفظ…';

  @override
  String get importConfirmTitle => 'تأكيد الحفظ';

  @override
  String importConfirmBody(String created, String updated) {
    return 'سيُضاف $created ويُحدَّث $updated. الصفوف التي فيها أخطاء أو المتجاوَزة لن تُحفظ.';
  }

  @override
  String importDone(String created, String updated) {
    return 'تم الحفظ: أُضيف $created وحُدِّث $updated.';
  }

  @override
  String importFailures(int count, String rows) {
    return 'تعذّر حفظ $count صفوف: $rows';
  }

  @override
  String get importNoRowsMatch => 'لا توجد صفوف تطابق التصفية.';

  @override
  String get importNotAllowed => 'لا تملك صلاحية الاستيراد.';

  @override
  String get importReading => 'جارٍ قراءة الملف…';

  @override
  String get actionCreate => 'جديد';

  @override
  String get actionUpdate => 'تحديث';

  @override
  String get actionSkip => 'تجاوز';

  @override
  String get actionInvalid => 'خطأ';

  @override
  String issueMissingColumn(String column) {
    return 'العمود «$column» غير موجود في الملف.';
  }

  @override
  String get issueNoDataRows => 'الملف لا يحتوي صفوف بيانات.';

  @override
  String issueEmptyField(String field) {
    return 'الحقل «$field» فارغ.';
  }

  @override
  String issueInvalidLevel(String value) {
    return 'المرحلة «$value» غير معروفة (الأولى–الرابعة).';
  }

  @override
  String issueInvalidShift(String value) {
    return 'الدراسة «$value» غير معروفة (صباحي/مسائي).';
  }

  @override
  String issueInvalidStatus(String value) {
    return 'الحالة «$value» غير معروفة.';
  }

  @override
  String issueInvalidYesNo(String value) {
    return 'القيمة «$value» يجب أن تكون نعم أو لا.';
  }

  @override
  String issueInvalidSemester(String value) {
    return 'الفصل «$value» يجب أن يكون 1 أو 2.';
  }

  @override
  String issueInvalidUnits(String value) {
    return 'الوحدات «$value» يجب أن تكون عدداً صحيحاً موجباً.';
  }

  @override
  String issueInvalidEmail(String value) {
    return 'البريد «$value» غير صالح.';
  }

  @override
  String issueStageNotAllowed(String stage) {
    return 'لا تملك صلاحية على $stage.';
  }

  @override
  String issueDuplicateIdInFile(String row) {
    return 'الرقم الجامعي مكرر (ورد في الصف $row).';
  }

  @override
  String issueDuplicateEmailInFile(String row) {
    return 'البريد مكرر (ورد في الصف $row).';
  }

  @override
  String issueDuplicateCodeInFile(String value, String row) {
    return 'المادة $value مكررة (وردت في الصف $row).';
  }

  @override
  String get issueProtectedAdmin => 'الحساب لمدير؛ لا يعدّله إلا المدير العام.';

  @override
  String issueDuplicateNameInFile(String row) {
    return 'الاسم مكرر (ورد في الصف $row) — تأكد أنهما شخصان مختلفان.';
  }

  @override
  String issueNameMatchesOther(String value) {
    return 'يوجد طالب بالاسم نفسه برقم جامعي آخر ($value).';
  }

  @override
  String get issueNameNotFourPart => 'الاسم ليس رباعياً.';

  @override
  String get issueExistsWillSkip =>
      'موجود مسبقاً — سيُتجاوز (فعّل «تحديث الموجود» لتحديثه).';

  @override
  String get issueExistsWillUpdate => 'موجود مسبقاً — سيُحدَّث.';

  @override
  String issueMovesStage(String from, String to) {
    return 'سينتقل الطالب من $from إلى $to.';
  }

  @override
  String get fieldFullName => 'الاسم الرباعي';

  @override
  String get fieldUniversityId => 'الرقم الجامعي';

  @override
  String get fieldLevel => 'المرحلة';

  @override
  String get fieldShift => 'الدراسة';

  @override
  String get fieldSection => 'الشعبة';

  @override
  String get fieldStatus => 'الحالة';

  @override
  String get fieldCarryOver => 'محمّل';

  @override
  String get fieldName => 'الاسم';

  @override
  String get fieldTitle => 'اللقب العلمي';

  @override
  String get fieldEmail => 'البريد';

  @override
  String get fieldPhone => 'الهاتف';

  @override
  String get fieldCode => 'رمز المادة';

  @override
  String get fieldCourseName => 'اسم المادة';

  @override
  String get fieldSemester => 'الفصل';

  @override
  String get fieldUnits => 'الوحدات';

  @override
  String get fieldHasPractical => 'فيها عملي';

  @override
  String get fileUnsupported => 'صيغة الملف غير مدعومة. استعمل xlsx أو csv.';

  @override
  String get fileLegacyXls =>
      'صيغة xls القديمة غير مدعومة. احفظ الملف من Excel بصيغة «مصنف Excel (.xlsx)».';

  @override
  String get fileNotUtf8 =>
      'ترميز ملف CSV غير مدعوم. احفظه من Excel بصيغة «CSV UTF-8».';

  @override
  String get fileCorrupt => 'تعذّرت قراءة الملف؛ قد يكون تالفاً.';

  @override
  String get fileEmpty => 'الملف فارغ.';

  @override
  String get assignmentsTitle => 'ربط التدريسيين بالمواد';

  @override
  String get assignmentsPickStage => 'المرحلة';

  @override
  String get assignmentsNoStages => 'لا توجد مراحل ضمن صلاحيتك.';

  @override
  String get assignmentsNoCourses =>
      'لا توجد مواد لهذه المرحلة. استورد المواد أولاً.';

  @override
  String assignmentsCourseInfo(String code, String units, String semester) {
    return '$code · $units وحدات · الفصل $semester';
  }

  @override
  String get assignmentsTheory => 'النظري';

  @override
  String get assignmentsPractical => 'العملي';

  @override
  String get assignmentsNoTheoryTeacher => 'لم يُسند النظري بعد.';

  @override
  String get assignmentsNoGroups => 'لا توجد مجاميع عملي بعد.';

  @override
  String assignmentsGroupStudents(String name, int count) {
    return '$name · عدد الطلبة: $count';
  }

  @override
  String get assignmentsAssignTheory => 'إسناد النظري';

  @override
  String assignmentsAssignGroup(String name) {
    return 'إسناد $name';
  }

  @override
  String get assignmentsTeacher => 'التدريسي';

  @override
  String get assignmentsSection => 'الشعبة';

  @override
  String get assignmentsSaved => 'تم الإسناد.';

  @override
  String get assignmentsRemoveTitle => 'إلغاء الإسناد';

  @override
  String assignmentsRemoveBody(String teacher, String target) {
    return 'إلغاء إسناد $teacher من $target؟';
  }

  @override
  String get assignmentsRemoved => 'أُلغي الإسناد.';

  @override
  String get assignmentsCreateGroups => 'إنشاء / إعادة توزيع المجاميع';

  @override
  String get assignmentsGroupCount => 'عدد المجاميع';

  @override
  String assignmentsDistributeBody(int count, String stage) {
    return 'سيوزَّع $count طالباً مستمراً من $stage على المجاميع بالتساوي أبجدياً. المجاميع الزائدة تُحذف مع إسناداتها.';
  }

  @override
  String get assignmentsDistribute => 'توزيع';

  @override
  String assignmentsDistributed(int count) {
    return 'وُزِّع الطلبة على $count مجاميع.';
  }

  @override
  String get assignmentsNoTeachers =>
      'لا يوجد تدريسيون. استورد التدريسيين أولاً.';

  @override
  String get assignmentsNoStudents =>
      'لا يوجد طلبة مستمرون في هذه المرحلة لتوزيعهم.';

  @override
  String get assignmentsAlreadyAssigned => 'هذا الإسناد موجود مسبقاً.';

  @override
  String get assignmentsSearchTeacher => 'ابحث باسم التدريسي أو بريده';

  @override
  String updateAvailable(String version) {
    return 'إصدار جديد ($version) متاح';
  }

  @override
  String get updateDownload => 'تنزيل';

  @override
  String get updateLater => 'لاحقاً';

  @override
  String get updateRequiredTitle => 'يجب تحديث التطبيق';

  @override
  String updateRequiredBody(String installed) {
    return 'الإصدار المثبّت ($installed) لم يعد مدعوماً. ثبّت الإصدار الجديد فوقه مباشرة، وستبقى بياناتك المحلية كما هي.';
  }

  @override
  String get updateNoLink => 'رابط التنزيل غير مضبوط بعد؛ راجع إدارة القسم.';

  @override
  String updateOpenFailed(String url) {
    return 'تعذّر فتح الرابط: $url';
  }

  @override
  String get navAccounts => 'الحسابات';

  @override
  String get accountsTitle => 'الحسابات والصلاحيات';

  @override
  String get accountsAdd => 'إضافة حساب';

  @override
  String get accountsAddHint =>
      'بعد الإضافة يفعّل صاحب البريد حسابه من «أول مرة؟ فعّل حسابك».';

  @override
  String get accountsSearch => 'بحث بالاسم أو البريد';

  @override
  String get accountsEmpty => 'لا توجد حسابات مطابقة.';

  @override
  String get accountsSuspended => 'موقوف';

  @override
  String get accountsLocked => 'حساب مدير؛ يعدّله المدير العام فقط.';

  @override
  String accountsRequestsTitle(int count) {
    return 'طلبات الانضمام ($count)';
  }

  @override
  String accountsRequestedOn(String date) {
    return 'طُلب في $date';
  }

  @override
  String get accountsApprove => 'قبول';

  @override
  String get accountsReject => 'رفض';

  @override
  String get accountsRejectTitle => 'رفض الطلب';

  @override
  String accountsRejectBody(String email) {
    return 'رفض طلب $email؟ يستطيع صاحبه إرسال طلب جديد.';
  }

  @override
  String accountsApproved(String name) {
    return 'أُضيف $name، ويدخل الآن تلقائياً.';
  }

  @override
  String get accountsRejected => 'رُفض الطلب.';

  @override
  String accountsCreated(String email) {
    return 'أُضيف $email. أخبر صاحبه أن يفعّل حسابه من التطبيق.';
  }

  @override
  String get accountsSaved => 'حُفظ الحساب.';

  @override
  String get accountsExists => 'يوجد حساب بهذا البريد؛ عدّله من القائمة.';

  @override
  String get accountEditNew => 'حساب جديد';

  @override
  String get accountEditApprove => 'قبول طلب الانضمام';

  @override
  String get accountEditTitle => 'تعديل الحساب';

  @override
  String get accountRoles => 'الصلاحيات';

  @override
  String get accountStageScopes => 'المراحل التي يديرها';

  @override
  String get accountActive => 'الحساب فعّال';

  @override
  String get accountActiveHint => 'الحساب الموقوف لا يصل إلى أي بيانات.';

  @override
  String get accountSelfLocked =>
      'لا يمكنك تغيير صلاحياتك أو إيقاف حسابك بنفسك.';

  @override
  String get accountIssueRole => 'اختر صلاحية واحدة على الأقل.';

  @override
  String get accountIssueStage => 'اختر مرحلة واحدة على الأقل لمسؤول المرحلة.';

  @override
  String homeAccessRequests(int count) {
    return 'طلبات انضمام بانتظار موافقتك: $count';
  }

  @override
  String get joinTitle => 'طلب الانضمام';

  @override
  String get joinBody =>
      'أرسل طلباً إلى إدارة القسم، وستدخل تلقائياً بعد الموافقة.';

  @override
  String get joinName => 'اسمك الكامل';

  @override
  String get joinNote => 'ملاحظة للإدارة (اختياري)';

  @override
  String get joinNoteHint => 'مثل اللقب العلمي أو المرحلة التي تدرّسها';

  @override
  String get joinSubmit => 'إرسال طلب الانضمام';

  @override
  String get joinSent => 'أُرسل طلبك.';

  @override
  String joinPending(String date) {
    return 'طلبك مُرسَل منذ $date وبانتظار موافقة الإدارة. ستدخل تلقائياً بعد الموافقة.';
  }

  @override
  String get joinCancel => 'إلغاء الطلب';

  @override
  String get joinCancelled => 'أُلغي الطلب.';

  @override
  String get attPresent => 'حاضر';

  @override
  String get attAbsent => 'غائب';

  @override
  String get attLate => 'متأخر';

  @override
  String get attExcused => 'مُجاز';

  @override
  String get recordAction => 'تسجيل الحضور';

  @override
  String get registerAction => 'سجل الحضور';

  @override
  String get homeRecordOnPhone =>
      'يُسجَّل الحضور من تطبيق الهاتف (يعمل دون اتصال).';

  @override
  String get homeDownloading => 'جارٍ تنزيل موادك وطلبتك…';

  @override
  String get recordDate => 'التاريخ';

  @override
  String recordLectureN(int n) {
    return 'المحاضرة $n';
  }

  @override
  String get recordNewLecture => 'محاضرة جديدة';

  @override
  String get recordSearch => 'بحث بالاسم أو الرقم الجامعي';

  @override
  String get recordTapHint =>
      'اضغط على الطالب للتبديل بين حاضر وغائب، واضغط مطوّلاً لاختيار «متأخر» أو «مُجاز» أو كتابة ملاحظة.';

  @override
  String get recordNote => 'ملاحظة';

  @override
  String get recordSave => 'حفظ الحضور';

  @override
  String get recordSaved =>
      'حُفظ على الهاتف، ويُرفع تلقائياً عند توفّر الاتصال.';

  @override
  String get recordNothingChanged => 'لا تغييرات منذ آخر حفظ.';

  @override
  String get recordLocked =>
      'انتهت مهلة التعديل لهذه المحاضرة؛ أي تعديل الآن يكون عبر مسؤول المرحلة.';

  @override
  String get recordLockedOverride =>
      'المحاضرة مقفلة للتدريسي، ويمكنك تعديلها بصفتك مسؤولاً.';

  @override
  String recordLocksAt(String date, String time) {
    return 'يُقفل التعديل $date $time';
  }

  @override
  String get recordFuture => 'لا يمكن تسجيل حضور يوم لم يأتِ بعد.';

  @override
  String get recordNoStudents =>
      'لا يوجد طلبة لهذه المادة على الهاتف. اضغط «مزامنة الآن» بعد أن تضيفهم الإدارة.';

  @override
  String get recordNeedSync =>
      'لم تُنزَّل بيانات السنة الدراسية بعد. اتصل بالإنترنت واضغط «مزامنة الآن».';

  @override
  String get recordClassMissing => 'هذه المادة ليست ضمن موادك على هذا الهاتف.';

  @override
  String get recordDiscardTitle => 'تجاهل التغييرات؟';

  @override
  String get recordDiscardBody => 'لم تُحفَظ تغييراتك على هذه المحاضرة.';

  @override
  String get recordDiscard => 'تجاهل';

  @override
  String get registerTitle => 'سجل الحضور';

  @override
  String get registerEmpty => 'لا توجد محاضرات مسجّلة بعد.';

  @override
  String get registerStudent => 'الطالب';

  @override
  String get registerAbsences => 'الغياب';

  @override
  String get registerRefresh => 'تحديث من الخادم';

  @override
  String registerPulled(int count) {
    return 'حُدِّث السجل ($count محاضرة جديدة أو معدّلة).';
  }

  @override
  String get registerOffline => 'تعذّر الاتصال بالخادم؛ يُعرض ما على الهاتف.';

  @override
  String get registerOpenLecture => 'فتح المحاضرة';

  @override
  String get syncNow => 'مزامنة الآن';

  @override
  String get syncAllUploaded => 'كل السجلات مرفوعة';

  @override
  String get syncRunning => 'جارٍ المزامنة…';

  @override
  String get syncOffline =>
      'لا يوجد اتصال؛ السجلات محفوظة على الهاتف وتُرفع لاحقاً.';

  @override
  String syncLast(String time) {
    return 'آخر رفع $time';
  }

  @override
  String get syncNever => 'لم تتم المزامنة بعد';

  @override
  String get syncStale =>
      'توجد سجلات لم تُرفع منذ أكثر من 24 ساعة. اتصل بالإنترنت لرفعها.';

  @override
  String syncRejected(int count) {
    return 'رفض الخادم $count عملية حفظ';
  }

  @override
  String get syncRejectedBody =>
      'غالباً لأن مهلة التعديل انتهت قبل الرفع أو تغيّر إسنادك. أعد المحاولة، أو احذفها من الهاتف واطلب التعديل من مسؤول المرحلة.';

  @override
  String get syncDiscard => 'حذف من الهاتف';

  @override
  String get syncDiscardBody =>
      'ستُحذف هذه التعديلات من الهاتف، وتُنزَّل نسخة الخادم عند تحديث السجل.';

  @override
  String syncProblem(String code) {
    return 'تعذّرت المزامنة ($code)';
  }

  @override
  String get homeDataFixAction => 'تصحيح المعرّفات وحذف الاستيراد الخاطئ';

  @override
  String get fixTitle => 'تصحيح البيانات';

  @override
  String get fixRenameTab => 'تغيير معرّف';

  @override
  String get fixDeleteTab => 'حذف استيراد خاطئ';

  @override
  String get fixKindStudent => 'رقم جامعي';

  @override
  String get fixKindCourse => 'رمز مادة';

  @override
  String get fixKindTeacher => 'بريد تدريسي';

  @override
  String get fixStage => 'المرحلة';

  @override
  String get fixOldId => 'المعرّف الحالي';

  @override
  String get fixNewId => 'المعرّف الجديد';

  @override
  String get fixRenameHelp =>
      'يُنقل كل ما يرتبط بالمعرّف إلى المعرّف الجديد (الحضور والإحصائيات والمجموعات والإسنادات والإجازات) ثم يُحذف القديم. إن كان المعرّف الجديد موجوداً بالاسم نفسه (استيراد مكرر) يُدمج فيه.';

  @override
  String get fixTeacherHelp =>
      'يُنقل الحساب وإسناداته إلى البريد الجديد، ثم يفعّل التدريسي حسابه بالبريد الجديد. يبقى البريد القديم في سجل الحضور السابق لأنه من سجّل حينها.';

  @override
  String get fixDeleteStudents => 'طلبة';

  @override
  String get fixDeleteCourses => 'مواد';

  @override
  String get fixOnlyOne => 'معرّف واحد فقط (اختياري)';

  @override
  String get fixOnlyOneHint => 'اتركه فارغاً لكل ما في المرحلة';

  @override
  String get fixDeleteHelp =>
      'يُحذف فقط ما ليس له تاريخ: الطالب الذي لم يُسجَّل له حضور ولا إجازة، والمادة التي لم تُفتح لها محاضرة (مع مجموعاتها وإسناداتها). ما له تاريخ يبقى.';

  @override
  String get fixPhonesNote =>
      'تتحدّث هواتف التدريسيين في المزامنة التالية. الأفضل التنفيذ قبل بدء التسجيل أو حين لا تكون على الهواتف سجلات غير مرفوعة.';

  @override
  String get fixPreview => 'معاينة';

  @override
  String get fixApply => 'تنفيذ';

  @override
  String get fixWillMove => 'سيُنقل';

  @override
  String get fixWillDelete => 'سيُحذف';

  @override
  String get fixConfirmTitle => 'تنفيذ التصحيح؟';

  @override
  String get fixConfirmBody =>
      'لا يمكن التراجع تلقائياً عن هذا التصحيح، ويُسجَّل في سجل التدقيق.';

  @override
  String fixDone(int count) {
    return 'اكتمل التصحيح ($count عملية كتابة).';
  }

  @override
  String fixInterrupted(String code) {
    return 'توقّف التنفيذ ($code). أعد المعاينة ثم التنفيذ لإكماله من حيث توقّف.';
  }

  @override
  String fixMerge(String name) {
    return 'المعرّف الجديد موجود باسم «$name» وسيُدمج فيه.';
  }

  @override
  String get fixProblemInvalidId => 'المعرّف غير صالح.';

  @override
  String get fixProblemSameId => 'المعرّفان متطابقان.';

  @override
  String get fixProblemNotFound =>
      'المعرّف الحالي غير موجود (أو ليس في هذه المرحلة).';

  @override
  String fixProblemTargetExists(String name) {
    return 'المعرّف الجديد مستعمل لسجل آخر: «$name». إن كان مكرراً فاحذفه أولاً من «حذف استيراد خاطئ».';
  }

  @override
  String get fixProblemOwnAccount => 'لا يمكنك تغيير بريد حسابك أنت.';

  @override
  String get fixProblemNothing =>
      'لا يوجد ما يُحذف: كل ما اخترته له تاريخ حضور.';

  @override
  String fixCountStudents(int n) {
    return 'الطلبة: $n';
  }

  @override
  String fixCountCourses(int n) {
    return 'المواد: $n';
  }

  @override
  String fixCountUsers(int n) {
    return 'الحسابات: $n';
  }

  @override
  String fixCountGroups(int n) {
    return 'مجموعات العملي: $n';
  }

  @override
  String fixCountAssignments(int n) {
    return 'الإسنادات: $n';
  }

  @override
  String fixCountSessions(int n) {
    return 'المحاضرات: $n';
  }

  @override
  String fixCountRecords(int n) {
    return 'سجلات الحضور: $n';
  }

  @override
  String fixCountStats(int n) {
    return 'إحصائيات الغياب: $n';
  }

  @override
  String fixCountLeaves(int n) {
    return 'الإجازات: $n';
  }

  @override
  String fixCountKept(int n) {
    return 'يبقى لأن له تاريخاً: $n';
  }

  @override
  String get accountDelete => 'حذف الحساب';

  @override
  String accountDeleteBody(String email, int count) {
    return 'سيُحذف الحساب $email مع إسناداته ($count). لا يمكن التراجع. يستطيع صاحبه بعدها تفعيل حسابه ببريده الصحيح وإرسال طلب انضمام.';
  }

  @override
  String get accountDeleted => 'حُذف الحساب.';

  @override
  String get fixDeleteTeachers => 'تدريسيون';

  @override
  String get fixDeleteTeachersHelp =>
      'يُحذف حساب التدريسي (بلا صلاحية إدارية) الذي لم يسجّل أي محاضرة، مع إسناداته، كحسابات استُوردت ببريد خاطئ. من سجّل محاضرات يبقى: أوقف حسابه أو غيّر بريده.';

  @override
  String get fixOnlyTeacherHint =>
      'اتركه فارغاً لكل التدريسيين الذين لم يسجّلوا أي محاضرة';

  @override
  String get fixOnlyEmail => 'بريد واحد فقط (اختياري)';

  @override
  String get fixProblemHasHistory =>
      'سجّل هذا الحساب محاضرات، فلا يُحذف حفاظاً على السجل. أوقف الحساب بدلاً من ذلك، أو غيّر بريده من «تصحيح البيانات».';

  @override
  String get accountChangeEmail => 'تغيير البريد';

  @override
  String get accountNewEmail => 'البريد الصحيح';

  @override
  String accountChangeEmailBody(String from, int count, String to) {
    return 'سينتقل الحساب $from مع إسناداته ($count) إلى $to. بعدها يفعّل صاحبه حسابه بالبريد الجديد من «أول مرة؟ فعّل حسابك» ويضع كلمة مروره.';
  }

  @override
  String get accountEmailChanged =>
      'تغيّر البريد. أخبر صاحبه أن يفعّل حسابه بالبريد الجديد من «أول مرة؟ فعّل حسابك» — «نسيت كلمة المرور» لا يعمل لبريد لم يُفعَّل.';

  @override
  String get groupsEditAction => 'تعديل أعضاء المجاميع';

  @override
  String get groupsEditTitle => 'أعضاء المجاميع';

  @override
  String get groupsHelp =>
      'حدّد طالباً أو أكثر ثم «نقل إلى…». لا يُشترط تساوي أعداد المجاميع. الحضور المسجَّل سابقاً يبقى في محاضرات مجموعته القديمة.';

  @override
  String groupsUnassigned(int count) {
    return 'بلا مجموعة · عدد الطلبة: $count';
  }

  @override
  String groupsSelected(int count) {
    return 'المحدَّدون: $count';
  }

  @override
  String get groupsMoveTo => 'نقل إلى…';

  @override
  String groupsMoveTitle(int count) {
    return 'نقل $count طالب إلى';
  }

  @override
  String groupsMoved(int count, String group) {
    return 'نُقل $count إلى $group.';
  }

  @override
  String get groupsAdd => 'إضافة مجموعة';

  @override
  String groupsAdded(String group) {
    return 'أُضيفت $group؛ انقل إليها الطلبة.';
  }

  @override
  String get groupsNone =>
      'لا مجاميع بعد. أنشئها أولاً من «إنشاء / إعادة توزيع المجاميع».';

  @override
  String get assignmentsRedistributeWarning =>
      'تنبيه: إعادة التوزيع تلغي أي نقل يدوي سابق بين المجاميع.';

  @override
  String get yearTitle => 'إعدادات السنة الدراسية';

  @override
  String get yearAction => 'إعدادات السنة والنسب';

  @override
  String get yearNone =>
      'لا توجد سنة دراسية نشطة. أنشئها من «تهيئة النظام» في الرئيسية.';

  @override
  String yearHeader(String year) {
    return 'السنة $year';
  }

  @override
  String get yearHelp =>
      'هذه قرارات القسم التي تُحسب بها نسب الغياب. يمكن تعديلها في أي وقت، فتُعاد النسب كلها تلقائياً.';

  @override
  String yearSemesterN(int n) {
    return 'الفصل $n';
  }

  @override
  String get yearThresholds => 'عتبات الغياب (نسبة من محاضرات المادة)';

  @override
  String get levelAlert => 'تنبيه';

  @override
  String get levelWarning => 'إنذار';

  @override
  String get levelDismissal => 'فصل';

  @override
  String get yearPlanned => 'عدد محاضرات المادة في الفصل';

  @override
  String get yearWeeks => 'عدد أسابيع الفصل';

  @override
  String get yearPerUnit => 'محاضرات أسبوعياً لكل وحدة';

  @override
  String get yearPerUnitHelp =>
      'مثلاً 1: مادة بثلاث وحدات = 3 محاضرات أسبوعياً. اكتب 0.5 إن كانت الوحدتان محاضرة واحدة.';

  @override
  String yearExample(int count, String percent) {
    return 'مثال: مادة بثلاث وحدات = $count محاضرة في الفصل، والغياب الواحد = $percent٪.';
  }

  @override
  String get yearCombined => 'نسبة واحدة للنظري والعملي معاً';

  @override
  String get yearCombinedOn => 'غيابات النظري والعملي تُجمع في نسبة المادة.';

  @override
  String get yearCombinedOff =>
      'نسبة للنظري وأخرى للعملي، وكل منهما من محاضرات المادة نفسها.';

  @override
  String get yearLock => 'إقفال السجل';

  @override
  String get yearLockHours => 'يُقفل السجل بعد نهاية يوم المحاضرة بـ';

  @override
  String get yearHoursSuffix => 'ساعة';

  @override
  String get yearLockHelp =>
      'بعدها لا يعدّل التدريسي المحاضرة إلا بطلب، ويعدّلها مسؤول المرحلة والمدير مباشرة.';

  @override
  String get yearLeaves => 'الإجازات';

  @override
  String get yearLeavesCount => 'الإجازات تُحتسب ضمن الغياب';

  @override
  String get yearLeavesCountOn =>
      'الغياب المُجاز (والمغطّى بإجازة) يدخل في النسبة.';

  @override
  String get yearLeavesCountOff =>
      'الغياب المُجاز والمغطّى بإجازة معتمدة لا يدخل في النسبة.';

  @override
  String get yearMaxLeave => 'الحد الأعلى لأيام الإجازة المقبولة (اختياري)';

  @override
  String get yearMaxLeaveHelp =>
      'فارغ = بلا حد. ما زاد عليه من أيام الإجازة يُحسب غياباً.';

  @override
  String get yearBadNumber => 'رقم غير صالح';

  @override
  String get yearInvalid =>
      'تحقّق من القيم: العتبات تصاعدية (تنبيه < إنذار < فصل ≤ 100)، والأسابيع 1–30، والإقفال 1–720 ساعة.';

  @override
  String get yearSaved => 'حُفظت إعدادات السنة.';
}
