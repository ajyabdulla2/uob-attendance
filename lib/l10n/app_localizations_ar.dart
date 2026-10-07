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

  @override
  String get leavesTitle => 'الإجازات';

  @override
  String get leavesAction => 'الإجازات';

  @override
  String get leavesHelp =>
      'الإجازة المُدخلة هنا معتمدة: غياب الطالب في أيامها يُحسب «مُجاز» في كل مواده (حسب إعدادات السنة).';

  @override
  String get leavesEmpty => 'لا إجازات في هذه المرحلة.';

  @override
  String get leaveAdd => 'إضافة إجازة';

  @override
  String get leaveStudent => 'الطالب (اسم أو رقم جامعي)';

  @override
  String get leaveTypeLabel => 'نوع الإجازة';

  @override
  String get leaveTypeSick => 'مرضية';

  @override
  String get leaveTypeOfficial => 'رسمية';

  @override
  String get leaveTypeEmergency => 'ظرف طارئ';

  @override
  String get leaveTypeParticipation => 'مشاركة رسمية (نشاط أو وفد)';

  @override
  String get leaveTypeOther => 'أخرى';

  @override
  String get leavePickRange => 'اختر الفترة (من – إلى)';

  @override
  String leaveRange(String from, String to) {
    return 'من $from إلى $to';
  }

  @override
  String leaveDays(int count) {
    return '$count يوم';
  }

  @override
  String get leaveRef => 'رقم الكتاب أو التقرير الطبي';

  @override
  String leaveRefShown(String ref) {
    return 'الكتاب: $ref';
  }

  @override
  String get leaveSaved => 'حُفظت الإجازة.';

  @override
  String get leaveDeleteTitle => 'حذف الإجازة؟';

  @override
  String leaveDeleteBody(String name) {
    return 'تُحذف إجازة $name، فيعود غيابه في أيامها غياباً.';
  }

  @override
  String get warnTitle => 'النسب والقوائم';

  @override
  String get warnAction => 'النسب وقوائم التنبيه والإنذار';

  @override
  String get warnTabLists => 'القوائم';

  @override
  String get warnTabDecisions => 'القرارات';

  @override
  String get warnCourse => 'المادة';

  @override
  String get warnAllCourses => 'كل المواد';

  @override
  String get warnAll => 'الكل';

  @override
  String get warnEdge => 'على الحافة';

  @override
  String get warnHelp =>
      'النسبة = الغيابات المحتسبة ÷ محاضرات المادة المقررة في الفصل (من إعدادات السنة). تُحدَّث مع كل حفظ وإجازة.';

  @override
  String get warnEdgeHelp => 'طلبة يصلون إلى المستوى التالي بعد غياب واحد.';

  @override
  String get warnEmpty => 'لا أحد في هذه القائمة.';

  @override
  String warnSaveAction(String level) {
    return 'حفظ قرار قسم بقائمة $level';
  }

  @override
  String get warnSaveTitle => 'حفظ قرار القسم؟';

  @override
  String warnSaveBody(int count, String level) {
    return 'تُحفظ قائمة $level بـ $count طالب كما هي اليوم. يبقى القرار قابلاً للتعديل وإعادة التوليد حتى يحوّله المدير إلى قرار عمادة.';
  }

  @override
  String get warnSaved => 'حُفظ قرار القسم. تجده في «القرارات».';

  @override
  String warnAbsences(int absences, int planned, String percent) {
    return 'الغياب $absences من $planned محاضرة = $percent٪';
  }

  @override
  String warnExcused(int count) {
    return 'مُجاز (لا يُحتسب): $count';
  }

  @override
  String warnOneMore(String level) {
    return '⚠ يصل إلى $level بعد غياب واحد';
  }

  @override
  String get warnNoDecisions => 'لا قرارات محفوظة لهذه المرحلة.';

  @override
  String warnDecisionTitle(String level, String course, int count) {
    return '$level · $course · $count طالب';
  }

  @override
  String warnDeanery(String number, String date) {
    return 'قرار عمادة رقم $number في $date';
  }

  @override
  String warnDepartment(String date) {
    return 'قرار قسم (أولي) · $date';
  }

  @override
  String get warnDeaneryLabel => 'قرار عمادة (نهائي ومقفل)';

  @override
  String get warnDepartmentLabel => 'قرار قسم (أولي)';

  @override
  String get warnDepartmentHelp =>
      'يمكن إعادة توليده من نسب اليوم (بعد نقل أو تأجيل أو إجازة)، ثم يحوّله المدير إلى قرار عمادة برقم الأمر وتاريخه.';

  @override
  String get warnRegenerate => 'إعادة التوليد';

  @override
  String warnRegenerateBody(int before, int after) {
    return 'تُستبدل قائمة القرار ($before طالب) بقائمة اليوم ($after طالب).';
  }

  @override
  String get warnRegenerated => 'أُعيد توليد القرار.';

  @override
  String get warnFinalize => 'تحويل إلى قرار عمادة';

  @override
  String get warnFinalizeBody =>
      'بعد التحويل يُقفل القرار نهائياً ولا يُعدَّل ولا يُحذف؛ أي تغيير بعده يحتاج قراراً جديداً.';

  @override
  String get warnOrderNumber => 'رقم الأمر الإداري';

  @override
  String get warnOrderDate => 'تاريخ الأمر';

  @override
  String get warnFinalized => 'صار القرار قرار عمادة مقفلاً.';

  @override
  String get warnDeleteTitle => 'حذف قرار القسم؟';

  @override
  String get warnDeleteBody => 'يُحذف القرار المحفوظ (النسب نفسها لا تتأثر).';

  @override
  String get warnDeleted => 'حُذف القرار.';

  @override
  String get registerPercent => 'النسبة';

  @override
  String get registerPercentHelp =>
      'نسبة غياب الطالب في المادة كلها (النظري والعملي حسب إعدادات السنة)، بعد احتساب الإجازات. تُحدَّث بزر التحديث عند الاتصال.';

  @override
  String get recordRequestHint =>
      'المحاضرة مقفلة: المس طالباً لطلب تعديل حالته من مسؤول المرحلة.';

  @override
  String get editRequestTitle => 'طلب تعديل';

  @override
  String editRequestNow(String status) {
    return 'الحالة الآن: $status';
  }

  @override
  String get editRequestReason => 'سبب التعديل (إلزامي)';

  @override
  String get editRequestSend => 'إرسال الطلب';

  @override
  String get editRequestSent => 'أُرسل الطلب إلى مسؤول المرحلة.';

  @override
  String get editRequestPending => '⏳ طلب تعديل بانتظار الموافقة';

  @override
  String get editRequestsTitle => 'طلبات التعديل';

  @override
  String get editRequestsAction => 'طلبات التعديل';

  @override
  String get editRequestsEmpty => 'لا طلبات معلّقة.';

  @override
  String editRequestLecture(String course, String date, int n) {
    return '$course · $date · المحاضرة $n';
  }

  @override
  String editRequestWhy(String reason) {
    return 'السبب: $reason';
  }

  @override
  String get editRequestApprove => 'موافقة وتعديل';

  @override
  String get editRequestReject => 'رفض';

  @override
  String get editRequestNote => 'ملاحظة (اختياري)';

  @override
  String get editRequestApproved =>
      'عُدّل السجل ووصل التعديل إلى هواتف التدريسيين عند التحديث.';

  @override
  String get editRequestRejected => 'رُفض الطلب.';

  @override
  String get dashTitle => 'لوحة المرحلة';

  @override
  String get dashAction => 'لوحة المرحلة';

  @override
  String dashToday(int count) {
    return 'محاضرات مسجّلة اليوم: $count';
  }

  @override
  String dashWeek(int count) {
    return 'آخر 7 أيام: $count محاضرة';
  }

  @override
  String dashIdle(int count) {
    return 'صفوف بلا تسجيل منذ 7 أيام: $count';
  }

  @override
  String get dashIdleHelp =>
      'قد تكون عطلة أو محاضرات ملغاة؛ تابع مع تدريسييها.';

  @override
  String dashRequests(int count) {
    return 'طلبات تعديل معلّقة: $count';
  }

  @override
  String reportPrinted(String date) {
    return 'طُبع في $date';
  }

  @override
  String reportPage(int page, int pages) {
    return 'صفحة $page من $pages';
  }

  @override
  String get reportSignatureHint => 'الاسم والتوقيع';

  @override
  String get reportPdf => 'PDF للطباعة والتوقيع';

  @override
  String get reportPdfHelp => 'بترويسة القسم وأماكن التوقيع';

  @override
  String get reportExcel => 'Excel';

  @override
  String get reportExcelHelp => 'جدول قابل للتعديل والفرز';

  @override
  String get reportSaved => 'حُفظ الملف.';

  @override
  String get reportExport => 'تصدير';

  @override
  String get reportLetterPresent => 'ح';

  @override
  String get reportLetterAbsent => 'غ';

  @override
  String get reportLetterLate => 'ت';

  @override
  String get reportLetterExcused => 'م';

  @override
  String get reportRegisterSheet => 'السجل';

  @override
  String reportLecturesRange(int from, int to) {
    return 'المحاضرات من $from إلى $to';
  }

  @override
  String reportRegisterTitle(String course) {
    return 'سجل حضور مادة $course';
  }

  @override
  String reportLectureCount(int count) {
    return 'عدد المحاضرات المسجلة: $count';
  }

  @override
  String get reportLegend =>
      'ح = حاضر، غ = غائب، ت = متأخر، م = مُجاز، – = لم يُسجَّل.';

  @override
  String get reportPercentNote =>
      'النسبة = الغيابات المحتسبة ÷ محاضرات المادة المقررة في الفصل × 100 حسب إعدادات السنة، وتشمل كل محاضرات المادة والإجازات المعتمدة.';

  @override
  String get reportSignTeacher => 'التدريسي';

  @override
  String get reportSignStageManager => 'مسؤول المرحلة';

  @override
  String get reportSignHead => 'رئيس القسم';

  @override
  String get reportSignDean => 'عميد الكلية';

  @override
  String get reportPlanned => 'المقررة';

  @override
  String reportListTitle(String list, String stage) {
    return 'قائمة $list — $stage';
  }

  @override
  String reportStudentCount(int count) {
    return 'عدد الطلبة: $count';
  }

  @override
  String reportDecisionTitle(String level, String stage) {
    return 'قرار $level — $stage';
  }

  @override
  String reportStudentTitle(String name) {
    return 'ملخص غياب الطالب $name';
  }

  @override
  String get reportStudentSheet => 'الملخص';

  @override
  String get reportExcused => 'مُجاز';

  @override
  String get reportLevel => 'المستوى';

  @override
  String get reportStudentNote =>
      'تظهر المواد التي سُجّل للطالب فيها غياب أو تأخر أو إجازة.';

  @override
  String reportStatsTitle(String stage) {
    return 'إحصائية الغياب — $stage';
  }

  @override
  String get reportStatsSheet => 'الإحصائية';

  @override
  String reportStatsLevels(int alert, int warning, int dismissal) {
    return 'تنبيه: $alert · إنذار: $warning · فصل: $dismissal';
  }

  @override
  String get reportStatsByCourse => 'المواد حسب مجموع الغيابات';

  @override
  String get reportAbsentStudents => 'طلبة متغيبون';

  @override
  String get reportTotalAbsences => 'مجموع الغيابات';

  @override
  String get reportTopSheet => 'الأعلى غياباً';

  @override
  String reportTopStudents(int count) {
    return 'الطلبة الأعلى غياباً ($count)';
  }

  @override
  String get reportStudentAction => 'ملخص الطالب (PDF)';

  @override
  String get reportStatsAction => 'إحصائية المرحلة';

  @override
  String get reportListAction => 'تصدير القائمة';

  @override
  String get reportRegisterAction => 'تصدير السجل';

  @override
  String get letterWarningTitle => 'إنذار بالغياب';

  @override
  String get letterDismissalTitle => 'إشعار رسوب بسبب الغياب';

  @override
  String get letterNumberDate =>
      'العدد: ................     التاريخ: ....../....../..........';

  @override
  String letterTo(String name, String id, String stage) {
    return 'إلى الطالب/ة: $name — الرقم الجامعي $id — $stage';
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
    return 'نظراً لبلوغ غيابك في مادة ($course) نسبة $percent٪ من محاضرات المادة المقررة في الفصل ($absences غياب من $planned محاضرة)، وهي نسبة تتجاوز حد الإنذار المعتمد في القسم ($warning٪)، نوجّه إليك هذا الإنذار، ونلفت انتباهك إلى أن بلوغ نسبة $dismissal٪ يعرّضك للرسوب في المادة بسبب الغياب وفق التعليمات النافذة.';
  }

  @override
  String get letterWarningClosing =>
      'يرجى الالتزام بالحضور ومراجعة مسؤول المرحلة عند وجود عذر مشروع.';

  @override
  String letterDismissalBody(
    String course,
    String percent,
    int absences,
    int planned,
    String dismissal,
  ) {
    return 'نظراً لبلوغ غيابك في مادة ($course) نسبة $percent٪ من محاضرات المادة المقررة في الفصل ($absences غياب من $planned محاضرة)، وهي نسبة تبلغ حد الرسوب بسبب الغياب المعتمد في القسم ($dismissal٪)، نشعرك بأنك تُعدّ راسباً في المادة بسبب الغياب وفق التعليمات النافذة.';
  }

  @override
  String get letterDismissalClosing =>
      'يُعدّ هذا الإشعار أولياً حتى صدور قرار العمادة.';

  @override
  String get letterAction => 'كتاب إنذار (PDF)';

  @override
  String get letterBatchAction => 'كتب الإنذار لكل القائمة (PDF)';

  @override
  String get backupAction => 'النسخ الاحتياطي';

  @override
  String get backupTitle => 'النسخ الاحتياطي';

  @override
  String get backupAdminsOnly => 'النسخ الاحتياطي للمدراء فقط.';

  @override
  String get backupNever => 'لم تُحفظ نسخة احتياطية بعد.';

  @override
  String backupLast(String date, String time) {
    return 'آخر نسخة: $date الساعة $time';
  }

  @override
  String backupLastDetail(int count, String by) {
    return '$count وثيقة · $by';
  }

  @override
  String backupAgo(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'آخر نسخة احتياطية قبل $days يوماً',
      few: 'آخر نسخة احتياطية قبل $days أيام',
      two: 'آخر نسخة احتياطية قبل يومين',
      one: 'آخر نسخة احتياطية قبل يوم',
      zero: 'آخر نسخة احتياطية اليوم',
    );
    return '$_temp0';
  }

  @override
  String get backupDue => 'مرّ أكثر من أسبوع؛ احفظ نسخة جديدة.';

  @override
  String get backupCreateTitle => 'إنشاء نسخة احتياطية';

  @override
  String get backupCreateHelp =>
      'ملف واحد مشفّر بكلمة مرور فيه كل بيانات القسم. احفظه خارج الهاتف (الحاسوب، Google Drive، البريد). لا يُفتح إلا بكلمة المرور.';

  @override
  String get backupCount => 'حساب حجم النسخة';

  @override
  String backupEstimate(int count) {
    return '$count وثيقة (الحسابات، المواد، الطلبة، المحاضرات، الإحصائيات…)';
  }

  @override
  String backupWithRecords(int count) {
    return 'تضمين سجلات الحضور التفصيلية ($count)';
  }

  @override
  String get backupRecordsHelp =>
      'كل سجل قراءة من حصة الخطة المجانية (50,000 قراءة يومياً). النسب لا تحتاجها فهي في الإحصائيات؛ إن كانت كثيرة فاحفظها في يوم هادئ.';

  @override
  String get backupPassword => 'كلمة مرور النسخة';

  @override
  String get backupPasswordConfirm => 'تأكيد كلمة المرور';

  @override
  String get backupPasswordWarning =>
      'إن نُسيت كلمة المرور فلا يمكن فتح النسخة أبداً.';

  @override
  String get backupPasswordShort => 'كلمة المرور 8 أحرف على الأقل.';

  @override
  String get backupPasswordMismatch => 'كلمتا المرور غير متطابقتين.';

  @override
  String get backupCreate => 'إنشاء النسخة وحفظها';

  @override
  String backupReading(String name) {
    return 'قراءة $name…';
  }

  @override
  String get backupEncrypting => 'تشفير الملف…';

  @override
  String backupSaved(int count) {
    return 'حُفظت النسخة ($count وثيقة).';
  }

  @override
  String backupCollection(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'academicYears': 'السنوات',
      'stages': 'المراحل',
      'users': 'الحسابات',
      'courses': 'المواد',
      'students': 'الطلبة',
      'groups': 'المجاميع',
      'assignments': 'الإسنادات',
      'sessions': 'المحاضرات',
      'leaves': 'الإجازات',
      'stats': 'الإحصائيات',
      'warningLists': 'القرارات',
      'config': 'الإعدادات',
      'editRequests': 'طلبات التعديل',
      'accessRequests': 'طلبات الانضمام',
      'auditLog': 'سجل التدقيق',
      'records': 'سجلات الحضور',
      'other': '$name',
    });
    return '$_temp0';
  }

  @override
  String get backupRestoreTitle => 'الاستعادة من نسخة';

  @override
  String get backupRestoreHelp =>
      'للمدير العام فقط. تعيد كل وثائق النسخة كما كانت وتكتب فوق الحالية، ولا تحذف ما أُضيف بعدها. طلبات التعديل والانضمام وسجل التدقيق لا تُستعاد. يمكن إعادة تشغيلها إن انقطعت.';

  @override
  String get backupPickFile => 'اختيار ملف النسخة (.uobk)';

  @override
  String get backupOpen => 'فتح الملف';

  @override
  String get backupWrongPassword => 'كلمة المرور خاطئة أو الملف تالف.';

  @override
  String get backupNotABackup => 'هذا ليس ملف نسخة احتياطية لهذا البرنامج.';

  @override
  String backupFileInfo(String date, String by) {
    return 'نسخة $date — $by';
  }

  @override
  String get backupRestore => 'استعادة';

  @override
  String get backupRestoreConfirmTitle => 'استعادة النسخة؟';

  @override
  String get backupRestoreConfirmBody =>
      'ستُستبدل البيانات الحالية بما في النسخة لكل وثيقة موجودة فيها، ولا يمكن التراجع. احفظ نسخة من الحالة الحالية أولاً إن لم تفعل.';

  @override
  String get backupRestoreTypeTitle => 'تأكيد أخير';

  @override
  String backupRestoreType(String word) {
    return 'اكتب «$word» للمتابعة';
  }

  @override
  String get backupRestoreWord => 'استعادة';

  @override
  String backupRestoreProgress(int done, int total) {
    return 'الدفعة $done من $total';
  }

  @override
  String backupRestored(int count) {
    return 'اكتملت الاستعادة ($count كتابة).';
  }

  @override
  String backupRestoreFailed(String error) {
    return 'توقفت الاستعادة: $error. أعد تشغيلها لتكمل (قد تكون حصة الكتابة اليومية انتهت).';
  }

  @override
  String get auditOpen => 'سجل التدقيق';

  @override
  String get auditTitle => 'سجل التدقيق';

  @override
  String get auditAllStages => 'كل القسم';

  @override
  String get auditEmpty => 'لا توجد عمليات مسجلة.';

  @override
  String get auditMore => 'عرض المزيد';

  @override
  String get auditEnd => 'نهاية السجل';

  @override
  String get auditBefore => 'قبل';

  @override
  String get auditAfter => 'بعد';

  @override
  String auditActionLabel(String action) {
    String _temp0 = intl.Intl.selectLogic(action, {
      'record_update': 'تعديل حضور طالب',
      'editRequest_reject': 'رفض طلب تعديل',
      'leave_create': 'إضافة إجازة',
      'leave_delete': 'حذف إجازة',
      'warnings_create': 'إنشاء قرار',
      'warnings_regenerate': 'إعادة توليد قرار',
      'warnings_delete': 'حذف قرار',
      'warnings_finalize': 'تحويل قرار إلى العمادة',
      'user_create': 'إضافة حساب',
      'user_update': 'تعديل حساب',
      'user_approve': 'قبول طلب انضمام',
      'user_reject': 'رفض طلب انضمام',
      'user_rename': 'تغيير بريد حساب',
      'users_delete': 'حذف حسابات',
      'student_rename': 'تغيير رقم جامعي',
      'students_delete': 'حذف طلبة',
      'course_rename': 'تغيير رمز مادة',
      'courses_delete': 'حذف مواد',
      'import_students': 'استيراد طلبة',
      'import_teachers': 'استيراد تدريسيين',
      'import_courses': 'استيراد مواد',
      'year_update': 'تعديل إعدادات السنة',
      'backup_export': 'نسخة احتياطية',
      'backup_restore': 'استعادة نسخة احتياطية',
      'other': '$action',
    });
    return '$_temp0';
  }

  @override
  String get deptAction => 'لوحة القسم';

  @override
  String get deptTitle => 'لوحة القسم';

  @override
  String deptActiveAccounts(int count) {
    return '$count حساب فعّال';
  }

  @override
  String deptAccessRequests(int count) {
    return 'طلبات الانضمام المعلّقة: $count';
  }

  @override
  String get deptStageEmpty => 'لا بيانات بعد.';

  @override
  String deptStudents(int count) {
    return '$count طالب';
  }

  @override
  String deptCourses(int count) {
    return '$count مادة';
  }

  @override
  String deptLecturesToday(int count) {
    return 'محاضرات اليوم: $count';
  }

  @override
  String deptPendingRequests(int count) {
    return 'طلبات تعديل: $count';
  }

  @override
  String get syncRejectedTap => 'المس لمعرفة السبب وإعادة المحاولة';

  @override
  String get syncReasonLocked =>
      'انتهت مهلة التسجيل لهذه المحاضرة قبل رفعها. لا يحفظها الآن إلا مسؤول المرحلة: أرسل له الأسماء، ثم احذفها من الهاتف.';

  @override
  String get syncReasonDenied =>
      'رفض الخادم الحفظ. اضغط «إعادة المحاولة» (التطبيق يعيد حساب موعد الإقفال من إعدادات السنة)، وإن تكرر فتأكد من إسنادك لهذه المادة لدى مسؤول المرحلة.';

  @override
  String deptPartial(String collections, String code) {
    return 'تعذّرت قراءة بعض الأعداد ($collections) — $code. إن كان «permission-denied» فالقواعد المنشورة أقدم من التطبيق: انشر firestore.rules.';
  }
}
