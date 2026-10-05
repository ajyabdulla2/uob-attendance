import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In ar, this message translates to:
  /// **'نظام الحضور والغياب'**
  String get appTitle;

  /// No description provided for @universityName.
  ///
  /// In ar, this message translates to:
  /// **'جامعة البصرة'**
  String get universityName;

  /// No description provided for @collegeName.
  ///
  /// In ar, this message translates to:
  /// **'كلية التربية للعلوم الصرفة'**
  String get collegeName;

  /// No description provided for @departmentName.
  ///
  /// In ar, this message translates to:
  /// **'قسم علوم الحاسوب'**
  String get departmentName;

  /// No description provided for @ok.
  ///
  /// In ar, this message translates to:
  /// **'حسناً'**
  String get ok;

  /// No description provided for @cancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get save;

  /// No description provided for @retry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get retry;

  /// No description provided for @close.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق'**
  String get close;

  /// No description provided for @confirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get confirm;

  /// No description provided for @delete.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get delete;

  /// No description provided for @loading.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ التحميل…'**
  String get loading;

  /// No description provided for @errorGeneric.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ غير متوقع: {error}'**
  String errorGeneric(String error);

  /// No description provided for @permissionDenied.
  ///
  /// In ar, this message translates to:
  /// **'لا تملك صلاحية هذا الإجراء.'**
  String get permissionDenied;

  /// No description provided for @signOut.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get signOut;

  /// No description provided for @languageSwitch.
  ///
  /// In ar, this message translates to:
  /// **'English'**
  String get languageSwitch;

  /// No description provided for @toggleTheme.
  ///
  /// In ar, this message translates to:
  /// **'تبديل الوضع الليلي'**
  String get toggleTheme;

  /// No description provided for @loginTitle.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get loginTitle;

  /// No description provided for @activateTitle.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل حساب جديد'**
  String get activateTitle;

  /// No description provided for @emailLabel.
  ///
  /// In ar, this message translates to:
  /// **'البريد الجامعي'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get passwordLabel;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد كلمة المرور'**
  String get confirmPasswordLabel;

  /// No description provided for @showPassword.
  ///
  /// In ar, this message translates to:
  /// **'إظهار كلمة المرور'**
  String get showPassword;

  /// No description provided for @signIn.
  ///
  /// In ar, this message translates to:
  /// **'دخول'**
  String get signIn;

  /// No description provided for @activate.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل الحساب'**
  String get activate;

  /// No description provided for @forgotPassword.
  ///
  /// In ar, this message translates to:
  /// **'نسيت كلمة المرور؟'**
  String get forgotPassword;

  /// No description provided for @haveNoAccount.
  ///
  /// In ar, this message translates to:
  /// **'أول مرة؟ فعّل حسابك'**
  String get haveNoAccount;

  /// No description provided for @haveAccount.
  ///
  /// In ar, this message translates to:
  /// **'لديك حساب مفعَّل؟ سجّل الدخول'**
  String get haveAccount;

  /// No description provided for @activateHint.
  ///
  /// In ar, this message translates to:
  /// **'يفعّل التدريسي حسابه بالبريد الذي أضافته إدارة القسم، ثم يؤكّده من الرسالة المرسلة إلى بريده.'**
  String get activateHint;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In ar, this message translates to:
  /// **'استعادة كلمة المرور'**
  String get resetPasswordTitle;

  /// No description provided for @resetPasswordBody.
  ///
  /// In ar, this message translates to:
  /// **'أدخل بريدك وسنرسل إليك رابطاً لتعيين كلمة مرور جديدة.'**
  String get resetPasswordBody;

  /// No description provided for @sendLink.
  ///
  /// In ar, this message translates to:
  /// **'إرسال الرابط'**
  String get sendLink;

  /// No description provided for @passwordResetSent.
  ///
  /// In ar, this message translates to:
  /// **'إن كان البريد مسجلاً فستصلك رسالة لاستعادة كلمة المرور.'**
  String get passwordResetSent;

  /// No description provided for @validationRequired.
  ///
  /// In ar, this message translates to:
  /// **'هذا الحقل مطلوب'**
  String get validationRequired;

  /// No description provided for @validationEmail.
  ///
  /// In ar, this message translates to:
  /// **'صيغة البريد غير صحيحة'**
  String get validationEmail;

  /// No description provided for @validationPasswordLength.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور 8 أحرف على الأقل'**
  String get validationPasswordLength;

  /// No description provided for @validationPasswordMatch.
  ///
  /// In ar, this message translates to:
  /// **'كلمتا المرور غير متطابقتين'**
  String get validationPasswordMatch;

  /// No description provided for @authInvalidCredentials.
  ///
  /// In ar, this message translates to:
  /// **'البريد أو كلمة المرور غير صحيحة.'**
  String get authInvalidCredentials;

  /// No description provided for @authInvalidEmail.
  ///
  /// In ar, this message translates to:
  /// **'صيغة البريد غير صحيحة.'**
  String get authInvalidEmail;

  /// No description provided for @authEmailInUse.
  ///
  /// In ar, this message translates to:
  /// **'هذا البريد مفعَّل مسبقاً. سجّل الدخول أو استعد كلمة المرور.'**
  String get authEmailInUse;

  /// No description provided for @authWeakPassword.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور ضعيفة؛ اختر كلمة أطول.'**
  String get authWeakPassword;

  /// No description provided for @authUserDisabled.
  ///
  /// In ar, this message translates to:
  /// **'هذا الحساب معطَّل. راجع إدارة القسم.'**
  String get authUserDisabled;

  /// No description provided for @authTooManyRequests.
  ///
  /// In ar, this message translates to:
  /// **'محاولات كثيرة. حاول بعد قليل.'**
  String get authTooManyRequests;

  /// No description provided for @authNetwork.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد اتصال بالإنترنت. تسجيل الدخول أول مرة يتطلب اتصالاً.'**
  String get authNetwork;

  /// No description provided for @authUnknown.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر إكمال العملية ({code}).'**
  String authUnknown(String code);

  /// No description provided for @verifyTitle.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد البريد'**
  String get verifyTitle;

  /// No description provided for @verifyBody.
  ///
  /// In ar, this message translates to:
  /// **'أرسلنا رابط تأكيد إلى {email}. افتح الرسالة واضغط الرابط، ثم عد إلى هنا.\nلم تصل خلال دقيقتين؟ ابحث في مجلد الرسائل غير المرغوب فيها (Spam) عن رسالة من noreply.'**
  String verifyBody(String email);

  /// No description provided for @verifyDone.
  ///
  /// In ar, this message translates to:
  /// **'أكّدت بريدي'**
  String get verifyDone;

  /// No description provided for @verifyResend.
  ///
  /// In ar, this message translates to:
  /// **'إعادة إرسال الرابط'**
  String get verifyResend;

  /// No description provided for @verifySent.
  ///
  /// In ar, this message translates to:
  /// **'أُرسل رابط جديد.'**
  String get verifySent;

  /// No description provided for @verifyNotYet.
  ///
  /// In ar, this message translates to:
  /// **'لم يُؤكَّد البريد بعد. تحقق من مجلد الرسائل غير المرغوب فيها.'**
  String get verifyNotYet;

  /// No description provided for @notProvisionedTitle.
  ///
  /// In ar, this message translates to:
  /// **'الحساب غير مضاف'**
  String get notProvisionedTitle;

  /// No description provided for @notProvisionedBody.
  ///
  /// In ar, this message translates to:
  /// **'البريد {email} غير مسجَّل في النظام بعد. أرسل طلب انضمام أدناه، أو اطلب من إدارة القسم إضافتك.'**
  String notProvisionedBody(String email);

  /// No description provided for @suspendedTitle.
  ///
  /// In ar, this message translates to:
  /// **'الحساب موقوف'**
  String get suspendedTitle;

  /// No description provided for @suspendedBody.
  ///
  /// In ar, this message translates to:
  /// **'أُوقف هذا الحساب من إدارة القسم.'**
  String get suspendedBody;

  /// No description provided for @profileErrorTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تحميل الحساب'**
  String get profileErrorTitle;

  /// No description provided for @profileErrorBody.
  ///
  /// In ar, this message translates to:
  /// **'تحقق من الاتصال ثم أعد المحاولة.'**
  String get profileErrorBody;

  /// No description provided for @configErrorTitle.
  ///
  /// In ar, this message translates to:
  /// **'إعداد Firebase غير مكتمل'**
  String get configErrorTitle;

  /// No description provided for @configErrorBody.
  ///
  /// In ar, this message translates to:
  /// **'شغّل الأمر flutterfire configure لتوليد lib/firebase_options.dart ثم أعد بناء التطبيق.'**
  String get configErrorBody;

  /// No description provided for @navHome.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get navHome;

  /// No description provided for @navImport.
  ///
  /// In ar, this message translates to:
  /// **'الاستيراد'**
  String get navImport;

  /// No description provided for @navAssignments.
  ///
  /// In ar, this message translates to:
  /// **'الربط'**
  String get navAssignments;

  /// No description provided for @navProfile.
  ///
  /// In ar, this message translates to:
  /// **'الملف الشخصي'**
  String get navProfile;

  /// No description provided for @roleSuperAdmin.
  ///
  /// In ar, this message translates to:
  /// **'مدير عام'**
  String get roleSuperAdmin;

  /// No description provided for @roleDeputyAdmin.
  ///
  /// In ar, this message translates to:
  /// **'مدير ثانٍ'**
  String get roleDeputyAdmin;

  /// No description provided for @roleStageManager.
  ///
  /// In ar, this message translates to:
  /// **'مسؤول مرحلة'**
  String get roleStageManager;

  /// No description provided for @roleTeacher.
  ///
  /// In ar, this message translates to:
  /// **'تدريسي'**
  String get roleTeacher;

  /// No description provided for @level1.
  ///
  /// In ar, this message translates to:
  /// **'المرحلة الأولى'**
  String get level1;

  /// No description provided for @level2.
  ///
  /// In ar, this message translates to:
  /// **'المرحلة الثانية'**
  String get level2;

  /// No description provided for @level3.
  ///
  /// In ar, this message translates to:
  /// **'المرحلة الثالثة'**
  String get level3;

  /// No description provided for @level4.
  ///
  /// In ar, this message translates to:
  /// **'المرحلة الرابعة'**
  String get level4;

  /// No description provided for @shiftMorning.
  ///
  /// In ar, this message translates to:
  /// **'صباحي'**
  String get shiftMorning;

  /// No description provided for @shiftEvening.
  ///
  /// In ar, this message translates to:
  /// **'مسائي'**
  String get shiftEvening;

  /// No description provided for @stageLabel.
  ///
  /// In ar, this message translates to:
  /// **'{level} — {shift}'**
  String stageLabel(String level, String shift);

  /// No description provided for @statusContinuing.
  ///
  /// In ar, this message translates to:
  /// **'مستمر'**
  String get statusContinuing;

  /// No description provided for @statusPostponed.
  ///
  /// In ar, this message translates to:
  /// **'مؤجل'**
  String get statusPostponed;

  /// No description provided for @statusFailedByAbsence.
  ///
  /// In ar, this message translates to:
  /// **'راسب بالغياب'**
  String get statusFailedByAbsence;

  /// No description provided for @statusWithdrawn.
  ///
  /// In ar, this message translates to:
  /// **'منسحب'**
  String get statusWithdrawn;

  /// No description provided for @statusTransferredIn.
  ///
  /// In ar, this message translates to:
  /// **'منقول إلى القسم'**
  String get statusTransferredIn;

  /// No description provided for @theoryLabel.
  ///
  /// In ar, this message translates to:
  /// **'نظري'**
  String get theoryLabel;

  /// No description provided for @practicalLabel.
  ///
  /// In ar, this message translates to:
  /// **'عملي'**
  String get practicalLabel;

  /// No description provided for @groupLabel.
  ///
  /// In ar, this message translates to:
  /// **'مجموعة {name}'**
  String groupLabel(String name);

  /// No description provided for @sectionLabel.
  ///
  /// In ar, this message translates to:
  /// **'شعبة {name}'**
  String sectionLabel(String name);

  /// No description provided for @allSections.
  ///
  /// In ar, this message translates to:
  /// **'كل الشعب'**
  String get allSections;

  /// No description provided for @homeWelcome.
  ///
  /// In ar, this message translates to:
  /// **'أهلاً، {name}'**
  String homeWelcome(String name);

  /// No description provided for @homeRoles.
  ///
  /// In ar, this message translates to:
  /// **'صلاحياتك'**
  String get homeRoles;

  /// No description provided for @homeStageScopes.
  ///
  /// In ar, this message translates to:
  /// **'المراحل المسندة إليك'**
  String get homeStageScopes;

  /// No description provided for @homeMyCourses.
  ///
  /// In ar, this message translates to:
  /// **'موادي'**
  String get homeMyCourses;

  /// No description provided for @homeNoCourses.
  ///
  /// In ar, this message translates to:
  /// **'لم تُسند إليك مواد بعد.'**
  String get homeNoCourses;

  /// No description provided for @homeSetupTitle.
  ///
  /// In ar, this message translates to:
  /// **'تهيئة البيانات الأساسية'**
  String get homeSetupTitle;

  /// No description provided for @homeSetupBody.
  ///
  /// In ar, this message translates to:
  /// **'لم تُنشأ المراحل الثمان أو السنة الدراسية النشطة بعد.'**
  String get homeSetupBody;

  /// No description provided for @homeSetupAction.
  ///
  /// In ar, this message translates to:
  /// **'تهيئة الآن'**
  String get homeSetupAction;

  /// No description provided for @homeSetupDone.
  ///
  /// In ar, this message translates to:
  /// **'تمت التهيئة.'**
  String get homeSetupDone;

  /// No description provided for @homeActiveYear.
  ///
  /// In ar, this message translates to:
  /// **'السنة الدراسية {year} — الفصل {semester}'**
  String homeActiveYear(String year, String semester);

  /// No description provided for @homeQuickActions.
  ///
  /// In ar, this message translates to:
  /// **'إجراءات سريعة'**
  String get homeQuickActions;

  /// No description provided for @homeImportAction.
  ///
  /// In ar, this message translates to:
  /// **'استيراد الطلبة والتدريسيين والمواد'**
  String get homeImportAction;

  /// No description provided for @homeAssignAction.
  ///
  /// In ar, this message translates to:
  /// **'ربط التدريسيين بالمواد والمجاميع'**
  String get homeAssignAction;

  /// No description provided for @pendingUploads.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =0{لا توجد سجلات بانتظار الرفع} =1{سجل واحد بانتظار الرفع} =2{سجلّان بانتظار الرفع} few{{count} سجلات بانتظار الرفع} many{{count} سجلاً بانتظار الرفع} other{{count} سجل بانتظار الرفع}}'**
  String pendingUploads(int count);

  /// No description provided for @profileTitle.
  ///
  /// In ar, this message translates to:
  /// **'الملف الشخصي'**
  String get profileTitle;

  /// No description provided for @profileTheme.
  ///
  /// In ar, this message translates to:
  /// **'المظهر'**
  String get profileTheme;

  /// No description provided for @themeSystem.
  ///
  /// In ar, this message translates to:
  /// **'حسب النظام'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In ar, this message translates to:
  /// **'فاتح'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In ar, this message translates to:
  /// **'ليلي'**
  String get themeDark;

  /// No description provided for @profileLanguage.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get profileLanguage;

  /// No description provided for @languageArabic.
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @languageEnglish.
  ///
  /// In ar, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @profilePhone.
  ///
  /// In ar, this message translates to:
  /// **'الهاتف'**
  String get profilePhone;

  /// No description provided for @profilePhoneSaved.
  ///
  /// In ar, this message translates to:
  /// **'حُفظ رقم الهاتف.'**
  String get profilePhoneSaved;

  /// No description provided for @profileChangePassword.
  ///
  /// In ar, this message translates to:
  /// **'تغيير كلمة المرور'**
  String get profileChangePassword;

  /// No description provided for @profileResetLinkSent.
  ///
  /// In ar, this message translates to:
  /// **'أُرسل رابط تغيير كلمة المرور إلى بريدك.'**
  String get profileResetLinkSent;

  /// No description provided for @signOutConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد تسجيل الخروج؟'**
  String get signOutConfirm;

  /// No description provided for @signOutPending.
  ///
  /// In ar, this message translates to:
  /// **'لا يمكن تسجيل الخروج: توجد {count} سجلات غير مرفوعة. اتصل بالإنترنت وانتظر الرفع أولاً.'**
  String signOutPending(int count);

  /// No description provided for @importTitle.
  ///
  /// In ar, this message translates to:
  /// **'استيراد البيانات'**
  String get importTitle;

  /// No description provided for @importStudents.
  ///
  /// In ar, this message translates to:
  /// **'الطلبة'**
  String get importStudents;

  /// No description provided for @importTeachers.
  ///
  /// In ar, this message translates to:
  /// **'التدريسيون'**
  String get importTeachers;

  /// No description provided for @importCourses.
  ///
  /// In ar, this message translates to:
  /// **'المواد'**
  String get importCourses;

  /// No description provided for @importStep1.
  ///
  /// In ar, this message translates to:
  /// **'١. نزّل القالب واملأه'**
  String get importStep1;

  /// No description provided for @importStep2.
  ///
  /// In ar, this message translates to:
  /// **'٢. اختر الملف (xlsx أو csv)'**
  String get importStep2;

  /// No description provided for @importDownloadTemplate.
  ///
  /// In ar, this message translates to:
  /// **'تنزيل القالب'**
  String get importDownloadTemplate;

  /// No description provided for @importTemplateSaved.
  ///
  /// In ar, this message translates to:
  /// **'حُفظ القالب.'**
  String get importTemplateSaved;

  /// No description provided for @importPickFile.
  ///
  /// In ar, this message translates to:
  /// **'اختيار ملف'**
  String get importPickFile;

  /// No description provided for @importFileName.
  ///
  /// In ar, this message translates to:
  /// **'الملف: {name}'**
  String importFileName(String name);

  /// No description provided for @importUpdateExistingStudents.
  ///
  /// In ar, this message translates to:
  /// **'تحديث الموجود حسب الرقم الجامعي بدل تجاوزه'**
  String get importUpdateExistingStudents;

  /// No description provided for @importUpdateExistingTeachers.
  ///
  /// In ar, this message translates to:
  /// **'تحديث الموجود حسب البريد بدل تجاوزه'**
  String get importUpdateExistingTeachers;

  /// No description provided for @importUpdateExistingCourses.
  ///
  /// In ar, this message translates to:
  /// **'تحديث الموجود حسب رمز المادة والمرحلة بدل تجاوزه'**
  String get importUpdateExistingCourses;

  /// No description provided for @importDefaultStage.
  ///
  /// In ar, this message translates to:
  /// **'المرحلة الافتراضية (إن لم يحددها الملف)'**
  String get importDefaultStage;

  /// No description provided for @importDefaultStageNone.
  ///
  /// In ar, this message translates to:
  /// **'من الملف'**
  String get importDefaultStageNone;

  /// No description provided for @importDefaultSemester.
  ///
  /// In ar, this message translates to:
  /// **'الفصل الافتراضي (إن لم يحدده الملف)'**
  String get importDefaultSemester;

  /// No description provided for @importPreviewTitle.
  ///
  /// In ar, this message translates to:
  /// **'معاينة قبل الحفظ'**
  String get importPreviewTitle;

  /// No description provided for @importSummaryCreate.
  ///
  /// In ar, this message translates to:
  /// **'جديد: {count}'**
  String importSummaryCreate(int count);

  /// No description provided for @importSummaryUpdate.
  ///
  /// In ar, this message translates to:
  /// **'تحديث: {count}'**
  String importSummaryUpdate(int count);

  /// No description provided for @importSummarySkip.
  ///
  /// In ar, this message translates to:
  /// **'متجاوَز: {count}'**
  String importSummarySkip(int count);

  /// No description provided for @importSummaryInvalid.
  ///
  /// In ar, this message translates to:
  /// **'أخطاء: {count}'**
  String importSummaryInvalid(int count);

  /// No description provided for @importSummaryWarnings.
  ///
  /// In ar, this message translates to:
  /// **'تحذيرات: {count}'**
  String importSummaryWarnings(int count);

  /// No description provided for @importFilterAll.
  ///
  /// In ar, this message translates to:
  /// **'كل الصفوف'**
  String get importFilterAll;

  /// No description provided for @importFilterProblems.
  ///
  /// In ar, this message translates to:
  /// **'المشكلات فقط'**
  String get importFilterProblems;

  /// No description provided for @importRow.
  ///
  /// In ar, this message translates to:
  /// **'الصف {row}'**
  String importRow(String row);

  /// No description provided for @importSave.
  ///
  /// In ar, this message translates to:
  /// **'حفظ ({count})'**
  String importSave(int count);

  /// No description provided for @importSaving.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ الحفظ…'**
  String get importSaving;

  /// No description provided for @importConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الحفظ'**
  String get importConfirmTitle;

  /// No description provided for @importConfirmBody.
  ///
  /// In ar, this message translates to:
  /// **'سيُضاف {created} ويُحدَّث {updated}. الصفوف التي فيها أخطاء أو المتجاوَزة لن تُحفظ.'**
  String importConfirmBody(String created, String updated);

  /// No description provided for @importDone.
  ///
  /// In ar, this message translates to:
  /// **'تم الحفظ: أُضيف {created} وحُدِّث {updated}.'**
  String importDone(String created, String updated);

  /// No description provided for @importFailures.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر حفظ {count} صفوف: {rows}'**
  String importFailures(int count, String rows);

  /// No description provided for @importNoRowsMatch.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد صفوف تطابق التصفية.'**
  String get importNoRowsMatch;

  /// No description provided for @importNotAllowed.
  ///
  /// In ar, this message translates to:
  /// **'لا تملك صلاحية الاستيراد.'**
  String get importNotAllowed;

  /// No description provided for @importReading.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ قراءة الملف…'**
  String get importReading;

  /// No description provided for @actionCreate.
  ///
  /// In ar, this message translates to:
  /// **'جديد'**
  String get actionCreate;

  /// No description provided for @actionUpdate.
  ///
  /// In ar, this message translates to:
  /// **'تحديث'**
  String get actionUpdate;

  /// No description provided for @actionSkip.
  ///
  /// In ar, this message translates to:
  /// **'تجاوز'**
  String get actionSkip;

  /// No description provided for @actionInvalid.
  ///
  /// In ar, this message translates to:
  /// **'خطأ'**
  String get actionInvalid;

  /// No description provided for @issueMissingColumn.
  ///
  /// In ar, this message translates to:
  /// **'العمود «{column}» غير موجود في الملف.'**
  String issueMissingColumn(String column);

  /// No description provided for @issueNoDataRows.
  ///
  /// In ar, this message translates to:
  /// **'الملف لا يحتوي صفوف بيانات.'**
  String get issueNoDataRows;

  /// No description provided for @issueEmptyField.
  ///
  /// In ar, this message translates to:
  /// **'الحقل «{field}» فارغ.'**
  String issueEmptyField(String field);

  /// No description provided for @issueInvalidLevel.
  ///
  /// In ar, this message translates to:
  /// **'المرحلة «{value}» غير معروفة (الأولى–الرابعة).'**
  String issueInvalidLevel(String value);

  /// No description provided for @issueInvalidShift.
  ///
  /// In ar, this message translates to:
  /// **'الدراسة «{value}» غير معروفة (صباحي/مسائي).'**
  String issueInvalidShift(String value);

  /// No description provided for @issueInvalidStatus.
  ///
  /// In ar, this message translates to:
  /// **'الحالة «{value}» غير معروفة.'**
  String issueInvalidStatus(String value);

  /// No description provided for @issueInvalidYesNo.
  ///
  /// In ar, this message translates to:
  /// **'القيمة «{value}» يجب أن تكون نعم أو لا.'**
  String issueInvalidYesNo(String value);

  /// No description provided for @issueInvalidSemester.
  ///
  /// In ar, this message translates to:
  /// **'الفصل «{value}» يجب أن يكون 1 أو 2.'**
  String issueInvalidSemester(String value);

  /// No description provided for @issueInvalidUnits.
  ///
  /// In ar, this message translates to:
  /// **'الوحدات «{value}» يجب أن تكون عدداً صحيحاً موجباً.'**
  String issueInvalidUnits(String value);

  /// No description provided for @issueInvalidEmail.
  ///
  /// In ar, this message translates to:
  /// **'البريد «{value}» غير صالح.'**
  String issueInvalidEmail(String value);

  /// No description provided for @issueStageNotAllowed.
  ///
  /// In ar, this message translates to:
  /// **'لا تملك صلاحية على {stage}.'**
  String issueStageNotAllowed(String stage);

  /// No description provided for @issueDuplicateIdInFile.
  ///
  /// In ar, this message translates to:
  /// **'الرقم الجامعي مكرر (ورد في الصف {row}).'**
  String issueDuplicateIdInFile(String row);

  /// No description provided for @issueDuplicateEmailInFile.
  ///
  /// In ar, this message translates to:
  /// **'البريد مكرر (ورد في الصف {row}).'**
  String issueDuplicateEmailInFile(String row);

  /// No description provided for @issueDuplicateCodeInFile.
  ///
  /// In ar, this message translates to:
  /// **'المادة {value} مكررة (وردت في الصف {row}).'**
  String issueDuplicateCodeInFile(String value, String row);

  /// No description provided for @issueProtectedAdmin.
  ///
  /// In ar, this message translates to:
  /// **'الحساب لمدير؛ لا يعدّله إلا المدير العام.'**
  String get issueProtectedAdmin;

  /// No description provided for @issueDuplicateNameInFile.
  ///
  /// In ar, this message translates to:
  /// **'الاسم مكرر (ورد في الصف {row}) — تأكد أنهما شخصان مختلفان.'**
  String issueDuplicateNameInFile(String row);

  /// No description provided for @issueNameMatchesOther.
  ///
  /// In ar, this message translates to:
  /// **'يوجد طالب بالاسم نفسه برقم جامعي آخر ({value}).'**
  String issueNameMatchesOther(String value);

  /// No description provided for @issueNameNotFourPart.
  ///
  /// In ar, this message translates to:
  /// **'الاسم ليس رباعياً.'**
  String get issueNameNotFourPart;

  /// No description provided for @issueExistsWillSkip.
  ///
  /// In ar, this message translates to:
  /// **'موجود مسبقاً — سيُتجاوز (فعّل «تحديث الموجود» لتحديثه).'**
  String get issueExistsWillSkip;

  /// No description provided for @issueExistsWillUpdate.
  ///
  /// In ar, this message translates to:
  /// **'موجود مسبقاً — سيُحدَّث.'**
  String get issueExistsWillUpdate;

  /// No description provided for @issueMovesStage.
  ///
  /// In ar, this message translates to:
  /// **'سينتقل الطالب من {from} إلى {to}.'**
  String issueMovesStage(String from, String to);

  /// No description provided for @fieldFullName.
  ///
  /// In ar, this message translates to:
  /// **'الاسم الرباعي'**
  String get fieldFullName;

  /// No description provided for @fieldUniversityId.
  ///
  /// In ar, this message translates to:
  /// **'الرقم الجامعي'**
  String get fieldUniversityId;

  /// No description provided for @fieldLevel.
  ///
  /// In ar, this message translates to:
  /// **'المرحلة'**
  String get fieldLevel;

  /// No description provided for @fieldShift.
  ///
  /// In ar, this message translates to:
  /// **'الدراسة'**
  String get fieldShift;

  /// No description provided for @fieldSection.
  ///
  /// In ar, this message translates to:
  /// **'الشعبة'**
  String get fieldSection;

  /// No description provided for @fieldStatus.
  ///
  /// In ar, this message translates to:
  /// **'الحالة'**
  String get fieldStatus;

  /// No description provided for @fieldCarryOver.
  ///
  /// In ar, this message translates to:
  /// **'محمّل'**
  String get fieldCarryOver;

  /// No description provided for @fieldName.
  ///
  /// In ar, this message translates to:
  /// **'الاسم'**
  String get fieldName;

  /// No description provided for @fieldTitle.
  ///
  /// In ar, this message translates to:
  /// **'اللقب العلمي'**
  String get fieldTitle;

  /// No description provided for @fieldEmail.
  ///
  /// In ar, this message translates to:
  /// **'البريد'**
  String get fieldEmail;

  /// No description provided for @fieldPhone.
  ///
  /// In ar, this message translates to:
  /// **'الهاتف'**
  String get fieldPhone;

  /// No description provided for @fieldCode.
  ///
  /// In ar, this message translates to:
  /// **'رمز المادة'**
  String get fieldCode;

  /// No description provided for @fieldCourseName.
  ///
  /// In ar, this message translates to:
  /// **'اسم المادة'**
  String get fieldCourseName;

  /// No description provided for @fieldSemester.
  ///
  /// In ar, this message translates to:
  /// **'الفصل'**
  String get fieldSemester;

  /// No description provided for @fieldUnits.
  ///
  /// In ar, this message translates to:
  /// **'الوحدات'**
  String get fieldUnits;

  /// No description provided for @fieldHasPractical.
  ///
  /// In ar, this message translates to:
  /// **'فيها عملي'**
  String get fieldHasPractical;

  /// No description provided for @fileUnsupported.
  ///
  /// In ar, this message translates to:
  /// **'صيغة الملف غير مدعومة. استعمل xlsx أو csv.'**
  String get fileUnsupported;

  /// No description provided for @fileLegacyXls.
  ///
  /// In ar, this message translates to:
  /// **'صيغة xls القديمة غير مدعومة. احفظ الملف من Excel بصيغة «مصنف Excel (.xlsx)».'**
  String get fileLegacyXls;

  /// No description provided for @fileNotUtf8.
  ///
  /// In ar, this message translates to:
  /// **'ترميز ملف CSV غير مدعوم. احفظه من Excel بصيغة «CSV UTF-8».'**
  String get fileNotUtf8;

  /// No description provided for @fileCorrupt.
  ///
  /// In ar, this message translates to:
  /// **'تعذّرت قراءة الملف؛ قد يكون تالفاً.'**
  String get fileCorrupt;

  /// No description provided for @fileEmpty.
  ///
  /// In ar, this message translates to:
  /// **'الملف فارغ.'**
  String get fileEmpty;

  /// No description provided for @assignmentsTitle.
  ///
  /// In ar, this message translates to:
  /// **'ربط التدريسيين بالمواد'**
  String get assignmentsTitle;

  /// No description provided for @assignmentsPickStage.
  ///
  /// In ar, this message translates to:
  /// **'المرحلة'**
  String get assignmentsPickStage;

  /// No description provided for @assignmentsNoStages.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مراحل ضمن صلاحيتك.'**
  String get assignmentsNoStages;

  /// No description provided for @assignmentsNoCourses.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مواد لهذه المرحلة. استورد المواد أولاً.'**
  String get assignmentsNoCourses;

  /// No description provided for @assignmentsCourseInfo.
  ///
  /// In ar, this message translates to:
  /// **'{code} · {units} وحدات · الفصل {semester}'**
  String assignmentsCourseInfo(String code, String units, String semester);

  /// No description provided for @assignmentsTheory.
  ///
  /// In ar, this message translates to:
  /// **'النظري'**
  String get assignmentsTheory;

  /// No description provided for @assignmentsPractical.
  ///
  /// In ar, this message translates to:
  /// **'العملي'**
  String get assignmentsPractical;

  /// No description provided for @assignmentsNoTheoryTeacher.
  ///
  /// In ar, this message translates to:
  /// **'لم يُسند النظري بعد.'**
  String get assignmentsNoTheoryTeacher;

  /// No description provided for @assignmentsNoGroups.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مجاميع عملي بعد.'**
  String get assignmentsNoGroups;

  /// No description provided for @assignmentsGroupStudents.
  ///
  /// In ar, this message translates to:
  /// **'{name} · عدد الطلبة: {count}'**
  String assignmentsGroupStudents(String name, int count);

  /// No description provided for @assignmentsAssignTheory.
  ///
  /// In ar, this message translates to:
  /// **'إسناد النظري'**
  String get assignmentsAssignTheory;

  /// No description provided for @assignmentsAssignGroup.
  ///
  /// In ar, this message translates to:
  /// **'إسناد {name}'**
  String assignmentsAssignGroup(String name);

  /// No description provided for @assignmentsTeacher.
  ///
  /// In ar, this message translates to:
  /// **'التدريسي'**
  String get assignmentsTeacher;

  /// No description provided for @assignmentsSection.
  ///
  /// In ar, this message translates to:
  /// **'الشعبة'**
  String get assignmentsSection;

  /// No description provided for @assignmentsSaved.
  ///
  /// In ar, this message translates to:
  /// **'تم الإسناد.'**
  String get assignmentsSaved;

  /// No description provided for @assignmentsRemoveTitle.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء الإسناد'**
  String get assignmentsRemoveTitle;

  /// No description provided for @assignmentsRemoveBody.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء إسناد {teacher} من {target}؟'**
  String assignmentsRemoveBody(String teacher, String target);

  /// No description provided for @assignmentsRemoved.
  ///
  /// In ar, this message translates to:
  /// **'أُلغي الإسناد.'**
  String get assignmentsRemoved;

  /// No description provided for @assignmentsCreateGroups.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء / إعادة توزيع المجاميع'**
  String get assignmentsCreateGroups;

  /// No description provided for @assignmentsGroupCount.
  ///
  /// In ar, this message translates to:
  /// **'عدد المجاميع'**
  String get assignmentsGroupCount;

  /// No description provided for @assignmentsDistributeBody.
  ///
  /// In ar, this message translates to:
  /// **'سيوزَّع {count} طالباً مستمراً من {stage} على المجاميع بالتساوي أبجدياً. المجاميع الزائدة تُحذف مع إسناداتها.'**
  String assignmentsDistributeBody(int count, String stage);

  /// No description provided for @assignmentsDistribute.
  ///
  /// In ar, this message translates to:
  /// **'توزيع'**
  String get assignmentsDistribute;

  /// No description provided for @assignmentsDistributed.
  ///
  /// In ar, this message translates to:
  /// **'وُزِّع الطلبة على {count} مجاميع.'**
  String assignmentsDistributed(int count);

  /// No description provided for @assignmentsNoTeachers.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد تدريسيون. استورد التدريسيين أولاً.'**
  String get assignmentsNoTeachers;

  /// No description provided for @assignmentsNoStudents.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد طلبة مستمرون في هذه المرحلة لتوزيعهم.'**
  String get assignmentsNoStudents;

  /// No description provided for @assignmentsAlreadyAssigned.
  ///
  /// In ar, this message translates to:
  /// **'هذا الإسناد موجود مسبقاً.'**
  String get assignmentsAlreadyAssigned;

  /// No description provided for @assignmentsSearchTeacher.
  ///
  /// In ar, this message translates to:
  /// **'ابحث باسم التدريسي أو بريده'**
  String get assignmentsSearchTeacher;

  /// No description provided for @updateAvailable.
  ///
  /// In ar, this message translates to:
  /// **'إصدار جديد ({version}) متاح'**
  String updateAvailable(String version);

  /// No description provided for @updateDownload.
  ///
  /// In ar, this message translates to:
  /// **'تنزيل'**
  String get updateDownload;

  /// No description provided for @updateLater.
  ///
  /// In ar, this message translates to:
  /// **'لاحقاً'**
  String get updateLater;

  /// No description provided for @updateRequiredTitle.
  ///
  /// In ar, this message translates to:
  /// **'يجب تحديث التطبيق'**
  String get updateRequiredTitle;

  /// No description provided for @updateRequiredBody.
  ///
  /// In ar, this message translates to:
  /// **'الإصدار المثبّت ({installed}) لم يعد مدعوماً. ثبّت الإصدار الجديد فوقه مباشرة، وستبقى بياناتك المحلية كما هي.'**
  String updateRequiredBody(String installed);

  /// No description provided for @updateNoLink.
  ///
  /// In ar, this message translates to:
  /// **'رابط التنزيل غير مضبوط بعد؛ راجع إدارة القسم.'**
  String get updateNoLink;

  /// No description provided for @updateOpenFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر فتح الرابط: {url}'**
  String updateOpenFailed(String url);

  /// No description provided for @navAccounts.
  ///
  /// In ar, this message translates to:
  /// **'الحسابات'**
  String get navAccounts;

  /// No description provided for @accountsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الحسابات والصلاحيات'**
  String get accountsTitle;

  /// No description provided for @accountsAdd.
  ///
  /// In ar, this message translates to:
  /// **'إضافة حساب'**
  String get accountsAdd;

  /// No description provided for @accountsAddHint.
  ///
  /// In ar, this message translates to:
  /// **'بعد الإضافة يفعّل صاحب البريد حسابه من «أول مرة؟ فعّل حسابك».'**
  String get accountsAddHint;

  /// No description provided for @accountsSearch.
  ///
  /// In ar, this message translates to:
  /// **'بحث بالاسم أو البريد'**
  String get accountsSearch;

  /// No description provided for @accountsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد حسابات مطابقة.'**
  String get accountsEmpty;

  /// No description provided for @accountsSuspended.
  ///
  /// In ar, this message translates to:
  /// **'موقوف'**
  String get accountsSuspended;

  /// No description provided for @accountsLocked.
  ///
  /// In ar, this message translates to:
  /// **'حساب مدير؛ يعدّله المدير العام فقط.'**
  String get accountsLocked;

  /// No description provided for @accountsRequestsTitle.
  ///
  /// In ar, this message translates to:
  /// **'طلبات الانضمام ({count})'**
  String accountsRequestsTitle(int count);

  /// No description provided for @accountsRequestedOn.
  ///
  /// In ar, this message translates to:
  /// **'طُلب في {date}'**
  String accountsRequestedOn(String date);

  /// No description provided for @accountsApprove.
  ///
  /// In ar, this message translates to:
  /// **'قبول'**
  String get accountsApprove;

  /// No description provided for @accountsReject.
  ///
  /// In ar, this message translates to:
  /// **'رفض'**
  String get accountsReject;

  /// No description provided for @accountsRejectTitle.
  ///
  /// In ar, this message translates to:
  /// **'رفض الطلب'**
  String get accountsRejectTitle;

  /// No description provided for @accountsRejectBody.
  ///
  /// In ar, this message translates to:
  /// **'رفض طلب {email}؟ يستطيع صاحبه إرسال طلب جديد.'**
  String accountsRejectBody(String email);

  /// No description provided for @accountsApproved.
  ///
  /// In ar, this message translates to:
  /// **'أُضيف {name}، ويدخل الآن تلقائياً.'**
  String accountsApproved(String name);

  /// No description provided for @accountsRejected.
  ///
  /// In ar, this message translates to:
  /// **'رُفض الطلب.'**
  String get accountsRejected;

  /// No description provided for @accountsCreated.
  ///
  /// In ar, this message translates to:
  /// **'أُضيف {email}. أخبر صاحبه أن يفعّل حسابه من التطبيق.'**
  String accountsCreated(String email);

  /// No description provided for @accountsSaved.
  ///
  /// In ar, this message translates to:
  /// **'حُفظ الحساب.'**
  String get accountsSaved;

  /// No description provided for @accountsExists.
  ///
  /// In ar, this message translates to:
  /// **'يوجد حساب بهذا البريد؛ عدّله من القائمة.'**
  String get accountsExists;

  /// No description provided for @accountEditNew.
  ///
  /// In ar, this message translates to:
  /// **'حساب جديد'**
  String get accountEditNew;

  /// No description provided for @accountEditApprove.
  ///
  /// In ar, this message translates to:
  /// **'قبول طلب الانضمام'**
  String get accountEditApprove;

  /// No description provided for @accountEditTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الحساب'**
  String get accountEditTitle;

  /// No description provided for @accountRoles.
  ///
  /// In ar, this message translates to:
  /// **'الصلاحيات'**
  String get accountRoles;

  /// No description provided for @accountStageScopes.
  ///
  /// In ar, this message translates to:
  /// **'المراحل التي يديرها'**
  String get accountStageScopes;

  /// No description provided for @accountActive.
  ///
  /// In ar, this message translates to:
  /// **'الحساب فعّال'**
  String get accountActive;

  /// No description provided for @accountActiveHint.
  ///
  /// In ar, this message translates to:
  /// **'الحساب الموقوف لا يصل إلى أي بيانات.'**
  String get accountActiveHint;

  /// No description provided for @accountSelfLocked.
  ///
  /// In ar, this message translates to:
  /// **'لا يمكنك تغيير صلاحياتك أو إيقاف حسابك بنفسك.'**
  String get accountSelfLocked;

  /// No description provided for @accountIssueRole.
  ///
  /// In ar, this message translates to:
  /// **'اختر صلاحية واحدة على الأقل.'**
  String get accountIssueRole;

  /// No description provided for @accountIssueStage.
  ///
  /// In ar, this message translates to:
  /// **'اختر مرحلة واحدة على الأقل لمسؤول المرحلة.'**
  String get accountIssueStage;

  /// No description provided for @homeAccessRequests.
  ///
  /// In ar, this message translates to:
  /// **'طلبات انضمام بانتظار موافقتك: {count}'**
  String homeAccessRequests(int count);

  /// No description provided for @joinTitle.
  ///
  /// In ar, this message translates to:
  /// **'طلب الانضمام'**
  String get joinTitle;

  /// No description provided for @joinBody.
  ///
  /// In ar, this message translates to:
  /// **'أرسل طلباً إلى إدارة القسم، وستدخل تلقائياً بعد الموافقة.'**
  String get joinBody;

  /// No description provided for @joinName.
  ///
  /// In ar, this message translates to:
  /// **'اسمك الكامل'**
  String get joinName;

  /// No description provided for @joinNote.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظة للإدارة (اختياري)'**
  String get joinNote;

  /// No description provided for @joinNoteHint.
  ///
  /// In ar, this message translates to:
  /// **'مثل اللقب العلمي أو المرحلة التي تدرّسها'**
  String get joinNoteHint;

  /// No description provided for @joinSubmit.
  ///
  /// In ar, this message translates to:
  /// **'إرسال طلب الانضمام'**
  String get joinSubmit;

  /// No description provided for @joinSent.
  ///
  /// In ar, this message translates to:
  /// **'أُرسل طلبك.'**
  String get joinSent;

  /// No description provided for @joinPending.
  ///
  /// In ar, this message translates to:
  /// **'طلبك مُرسَل منذ {date} وبانتظار موافقة الإدارة. ستدخل تلقائياً بعد الموافقة.'**
  String joinPending(String date);

  /// No description provided for @joinCancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء الطلب'**
  String get joinCancel;

  /// No description provided for @joinCancelled.
  ///
  /// In ar, this message translates to:
  /// **'أُلغي الطلب.'**
  String get joinCancelled;

  /// No description provided for @attPresent.
  ///
  /// In ar, this message translates to:
  /// **'حاضر'**
  String get attPresent;

  /// No description provided for @attAbsent.
  ///
  /// In ar, this message translates to:
  /// **'غائب'**
  String get attAbsent;

  /// No description provided for @attLate.
  ///
  /// In ar, this message translates to:
  /// **'متأخر'**
  String get attLate;

  /// No description provided for @attExcused.
  ///
  /// In ar, this message translates to:
  /// **'مُجاز'**
  String get attExcused;

  /// No description provided for @recordAction.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الحضور'**
  String get recordAction;

  /// No description provided for @registerAction.
  ///
  /// In ar, this message translates to:
  /// **'سجل الحضور'**
  String get registerAction;

  /// No description provided for @homeRecordOnPhone.
  ///
  /// In ar, this message translates to:
  /// **'يُسجَّل الحضور من تطبيق الهاتف (يعمل دون اتصال).'**
  String get homeRecordOnPhone;

  /// No description provided for @homeDownloading.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ تنزيل موادك وطلبتك…'**
  String get homeDownloading;

  /// No description provided for @recordDate.
  ///
  /// In ar, this message translates to:
  /// **'التاريخ'**
  String get recordDate;

  /// No description provided for @recordLectureN.
  ///
  /// In ar, this message translates to:
  /// **'المحاضرة {n}'**
  String recordLectureN(int n);

  /// No description provided for @recordNewLecture.
  ///
  /// In ar, this message translates to:
  /// **'محاضرة جديدة'**
  String get recordNewLecture;

  /// No description provided for @recordSearch.
  ///
  /// In ar, this message translates to:
  /// **'بحث بالاسم أو الرقم الجامعي'**
  String get recordSearch;

  /// No description provided for @recordTapHint.
  ///
  /// In ar, this message translates to:
  /// **'اضغط على الطالب للتبديل بين حاضر وغائب، واضغط مطوّلاً لاختيار «متأخر» أو «مُجاز» أو كتابة ملاحظة.'**
  String get recordTapHint;

  /// No description provided for @recordNote.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظة'**
  String get recordNote;

  /// No description provided for @recordSave.
  ///
  /// In ar, this message translates to:
  /// **'حفظ الحضور'**
  String get recordSave;

  /// No description provided for @recordSaved.
  ///
  /// In ar, this message translates to:
  /// **'حُفظ على الهاتف، ويُرفع تلقائياً عند توفّر الاتصال.'**
  String get recordSaved;

  /// No description provided for @recordNothingChanged.
  ///
  /// In ar, this message translates to:
  /// **'لا تغييرات منذ آخر حفظ.'**
  String get recordNothingChanged;

  /// No description provided for @recordLocked.
  ///
  /// In ar, this message translates to:
  /// **'انتهت مهلة التعديل لهذه المحاضرة؛ أي تعديل الآن يكون عبر مسؤول المرحلة.'**
  String get recordLocked;

  /// No description provided for @recordLockedOverride.
  ///
  /// In ar, this message translates to:
  /// **'المحاضرة مقفلة للتدريسي، ويمكنك تعديلها بصفتك مسؤولاً.'**
  String get recordLockedOverride;

  /// No description provided for @recordLocksAt.
  ///
  /// In ar, this message translates to:
  /// **'يُقفل التعديل {date} {time}'**
  String recordLocksAt(String date, String time);

  /// No description provided for @recordFuture.
  ///
  /// In ar, this message translates to:
  /// **'لا يمكن تسجيل حضور يوم لم يأتِ بعد.'**
  String get recordFuture;

  /// No description provided for @recordNoStudents.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد طلبة لهذه المادة على الهاتف. اضغط «مزامنة الآن» بعد أن تضيفهم الإدارة.'**
  String get recordNoStudents;

  /// No description provided for @recordNeedSync.
  ///
  /// In ar, this message translates to:
  /// **'لم تُنزَّل بيانات السنة الدراسية بعد. اتصل بالإنترنت واضغط «مزامنة الآن».'**
  String get recordNeedSync;

  /// No description provided for @recordClassMissing.
  ///
  /// In ar, this message translates to:
  /// **'هذه المادة ليست ضمن موادك على هذا الهاتف.'**
  String get recordClassMissing;

  /// No description provided for @recordDiscardTitle.
  ///
  /// In ar, this message translates to:
  /// **'تجاهل التغييرات؟'**
  String get recordDiscardTitle;

  /// No description provided for @recordDiscardBody.
  ///
  /// In ar, this message translates to:
  /// **'لم تُحفَظ تغييراتك على هذه المحاضرة.'**
  String get recordDiscardBody;

  /// No description provided for @recordDiscard.
  ///
  /// In ar, this message translates to:
  /// **'تجاهل'**
  String get recordDiscard;

  /// No description provided for @registerTitle.
  ///
  /// In ar, this message translates to:
  /// **'سجل الحضور'**
  String get registerTitle;

  /// No description provided for @registerEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد محاضرات مسجّلة بعد.'**
  String get registerEmpty;

  /// No description provided for @registerStudent.
  ///
  /// In ar, this message translates to:
  /// **'الطالب'**
  String get registerStudent;

  /// No description provided for @registerAbsences.
  ///
  /// In ar, this message translates to:
  /// **'الغياب'**
  String get registerAbsences;

  /// No description provided for @registerRefresh.
  ///
  /// In ar, this message translates to:
  /// **'تحديث من الخادم'**
  String get registerRefresh;

  /// No description provided for @registerPulled.
  ///
  /// In ar, this message translates to:
  /// **'حُدِّث السجل ({count} محاضرة جديدة أو معدّلة).'**
  String registerPulled(int count);

  /// No description provided for @registerOffline.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر الاتصال بالخادم؛ يُعرض ما على الهاتف.'**
  String get registerOffline;

  /// No description provided for @registerOpenLecture.
  ///
  /// In ar, this message translates to:
  /// **'فتح المحاضرة'**
  String get registerOpenLecture;

  /// No description provided for @syncNow.
  ///
  /// In ar, this message translates to:
  /// **'مزامنة الآن'**
  String get syncNow;

  /// No description provided for @syncAllUploaded.
  ///
  /// In ar, this message translates to:
  /// **'كل السجلات مرفوعة'**
  String get syncAllUploaded;

  /// No description provided for @syncRunning.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ المزامنة…'**
  String get syncRunning;

  /// No description provided for @syncOffline.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد اتصال؛ السجلات محفوظة على الهاتف وتُرفع لاحقاً.'**
  String get syncOffline;

  /// No description provided for @syncLast.
  ///
  /// In ar, this message translates to:
  /// **'آخر رفع {time}'**
  String syncLast(String time);

  /// No description provided for @syncNever.
  ///
  /// In ar, this message translates to:
  /// **'لم تتم المزامنة بعد'**
  String get syncNever;

  /// No description provided for @syncStale.
  ///
  /// In ar, this message translates to:
  /// **'توجد سجلات لم تُرفع منذ أكثر من 24 ساعة. اتصل بالإنترنت لرفعها.'**
  String get syncStale;

  /// No description provided for @syncRejected.
  ///
  /// In ar, this message translates to:
  /// **'رفض الخادم {count} عملية حفظ'**
  String syncRejected(int count);

  /// No description provided for @syncRejectedBody.
  ///
  /// In ar, this message translates to:
  /// **'غالباً لأن مهلة التعديل انتهت قبل الرفع أو تغيّر إسنادك. أعد المحاولة، أو احذفها من الهاتف واطلب التعديل من مسؤول المرحلة.'**
  String get syncRejectedBody;

  /// No description provided for @syncDiscard.
  ///
  /// In ar, this message translates to:
  /// **'حذف من الهاتف'**
  String get syncDiscard;

  /// No description provided for @syncDiscardBody.
  ///
  /// In ar, this message translates to:
  /// **'ستُحذف هذه التعديلات من الهاتف، وتُنزَّل نسخة الخادم عند تحديث السجل.'**
  String get syncDiscardBody;

  /// No description provided for @syncProblem.
  ///
  /// In ar, this message translates to:
  /// **'تعذّرت المزامنة ({code})'**
  String syncProblem(String code);

  /// No description provided for @homeDataFixAction.
  ///
  /// In ar, this message translates to:
  /// **'تصحيح المعرّفات وحذف الاستيراد الخاطئ'**
  String get homeDataFixAction;

  /// No description provided for @fixTitle.
  ///
  /// In ar, this message translates to:
  /// **'تصحيح البيانات'**
  String get fixTitle;

  /// No description provided for @fixRenameTab.
  ///
  /// In ar, this message translates to:
  /// **'تغيير معرّف'**
  String get fixRenameTab;

  /// No description provided for @fixDeleteTab.
  ///
  /// In ar, this message translates to:
  /// **'حذف استيراد خاطئ'**
  String get fixDeleteTab;

  /// No description provided for @fixKindStudent.
  ///
  /// In ar, this message translates to:
  /// **'رقم جامعي'**
  String get fixKindStudent;

  /// No description provided for @fixKindCourse.
  ///
  /// In ar, this message translates to:
  /// **'رمز مادة'**
  String get fixKindCourse;

  /// No description provided for @fixKindTeacher.
  ///
  /// In ar, this message translates to:
  /// **'بريد تدريسي'**
  String get fixKindTeacher;

  /// No description provided for @fixStage.
  ///
  /// In ar, this message translates to:
  /// **'المرحلة'**
  String get fixStage;

  /// No description provided for @fixOldId.
  ///
  /// In ar, this message translates to:
  /// **'المعرّف الحالي'**
  String get fixOldId;

  /// No description provided for @fixNewId.
  ///
  /// In ar, this message translates to:
  /// **'المعرّف الجديد'**
  String get fixNewId;

  /// No description provided for @fixRenameHelp.
  ///
  /// In ar, this message translates to:
  /// **'يُنقل كل ما يرتبط بالمعرّف إلى المعرّف الجديد (الحضور والإحصائيات والمجموعات والإسنادات والإجازات) ثم يُحذف القديم. إن كان المعرّف الجديد موجوداً بالاسم نفسه (استيراد مكرر) يُدمج فيه.'**
  String get fixRenameHelp;

  /// No description provided for @fixTeacherHelp.
  ///
  /// In ar, this message translates to:
  /// **'يُنقل الحساب وإسناداته إلى البريد الجديد، ثم يفعّل التدريسي حسابه بالبريد الجديد. يبقى البريد القديم في سجل الحضور السابق لأنه من سجّل حينها.'**
  String get fixTeacherHelp;

  /// No description provided for @fixDeleteStudents.
  ///
  /// In ar, this message translates to:
  /// **'طلبة'**
  String get fixDeleteStudents;

  /// No description provided for @fixDeleteCourses.
  ///
  /// In ar, this message translates to:
  /// **'مواد'**
  String get fixDeleteCourses;

  /// No description provided for @fixOnlyOne.
  ///
  /// In ar, this message translates to:
  /// **'معرّف واحد فقط (اختياري)'**
  String get fixOnlyOne;

  /// No description provided for @fixOnlyOneHint.
  ///
  /// In ar, this message translates to:
  /// **'اتركه فارغاً لكل ما في المرحلة'**
  String get fixOnlyOneHint;

  /// No description provided for @fixDeleteHelp.
  ///
  /// In ar, this message translates to:
  /// **'يُحذف فقط ما ليس له تاريخ: الطالب الذي لم يُسجَّل له حضور ولا إجازة، والمادة التي لم تُفتح لها محاضرة (مع مجموعاتها وإسناداتها). ما له تاريخ يبقى.'**
  String get fixDeleteHelp;

  /// No description provided for @fixPhonesNote.
  ///
  /// In ar, this message translates to:
  /// **'تتحدّث هواتف التدريسيين في المزامنة التالية. الأفضل التنفيذ قبل بدء التسجيل أو حين لا تكون على الهواتف سجلات غير مرفوعة.'**
  String get fixPhonesNote;

  /// No description provided for @fixPreview.
  ///
  /// In ar, this message translates to:
  /// **'معاينة'**
  String get fixPreview;

  /// No description provided for @fixApply.
  ///
  /// In ar, this message translates to:
  /// **'تنفيذ'**
  String get fixApply;

  /// No description provided for @fixWillMove.
  ///
  /// In ar, this message translates to:
  /// **'سيُنقل'**
  String get fixWillMove;

  /// No description provided for @fixWillDelete.
  ///
  /// In ar, this message translates to:
  /// **'سيُحذف'**
  String get fixWillDelete;

  /// No description provided for @fixConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'تنفيذ التصحيح؟'**
  String get fixConfirmTitle;

  /// No description provided for @fixConfirmBody.
  ///
  /// In ar, this message translates to:
  /// **'لا يمكن التراجع تلقائياً عن هذا التصحيح، ويُسجَّل في سجل التدقيق.'**
  String get fixConfirmBody;

  /// No description provided for @fixDone.
  ///
  /// In ar, this message translates to:
  /// **'اكتمل التصحيح ({count} عملية كتابة).'**
  String fixDone(int count);

  /// No description provided for @fixInterrupted.
  ///
  /// In ar, this message translates to:
  /// **'توقّف التنفيذ ({code}). أعد المعاينة ثم التنفيذ لإكماله من حيث توقّف.'**
  String fixInterrupted(String code);

  /// No description provided for @fixMerge.
  ///
  /// In ar, this message translates to:
  /// **'المعرّف الجديد موجود باسم «{name}» وسيُدمج فيه.'**
  String fixMerge(String name);

  /// No description provided for @fixProblemInvalidId.
  ///
  /// In ar, this message translates to:
  /// **'المعرّف غير صالح.'**
  String get fixProblemInvalidId;

  /// No description provided for @fixProblemSameId.
  ///
  /// In ar, this message translates to:
  /// **'المعرّفان متطابقان.'**
  String get fixProblemSameId;

  /// No description provided for @fixProblemNotFound.
  ///
  /// In ar, this message translates to:
  /// **'المعرّف الحالي غير موجود (أو ليس في هذه المرحلة).'**
  String get fixProblemNotFound;

  /// No description provided for @fixProblemTargetExists.
  ///
  /// In ar, this message translates to:
  /// **'المعرّف الجديد مستعمل لسجل آخر: «{name}». إن كان مكرراً فاحذفه أولاً من «حذف استيراد خاطئ».'**
  String fixProblemTargetExists(String name);

  /// No description provided for @fixProblemOwnAccount.
  ///
  /// In ar, this message translates to:
  /// **'لا يمكنك تغيير بريد حسابك أنت.'**
  String get fixProblemOwnAccount;

  /// No description provided for @fixProblemNothing.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد ما يُحذف: كل ما اخترته له تاريخ حضور.'**
  String get fixProblemNothing;

  /// No description provided for @fixCountStudents.
  ///
  /// In ar, this message translates to:
  /// **'الطلبة: {n}'**
  String fixCountStudents(int n);

  /// No description provided for @fixCountCourses.
  ///
  /// In ar, this message translates to:
  /// **'المواد: {n}'**
  String fixCountCourses(int n);

  /// No description provided for @fixCountUsers.
  ///
  /// In ar, this message translates to:
  /// **'الحسابات: {n}'**
  String fixCountUsers(int n);

  /// No description provided for @fixCountGroups.
  ///
  /// In ar, this message translates to:
  /// **'مجموعات العملي: {n}'**
  String fixCountGroups(int n);

  /// No description provided for @fixCountAssignments.
  ///
  /// In ar, this message translates to:
  /// **'الإسنادات: {n}'**
  String fixCountAssignments(int n);

  /// No description provided for @fixCountSessions.
  ///
  /// In ar, this message translates to:
  /// **'المحاضرات: {n}'**
  String fixCountSessions(int n);

  /// No description provided for @fixCountRecords.
  ///
  /// In ar, this message translates to:
  /// **'سجلات الحضور: {n}'**
  String fixCountRecords(int n);

  /// No description provided for @fixCountStats.
  ///
  /// In ar, this message translates to:
  /// **'إحصائيات الغياب: {n}'**
  String fixCountStats(int n);

  /// No description provided for @fixCountLeaves.
  ///
  /// In ar, this message translates to:
  /// **'الإجازات: {n}'**
  String fixCountLeaves(int n);

  /// No description provided for @fixCountKept.
  ///
  /// In ar, this message translates to:
  /// **'يبقى لأن له تاريخاً: {n}'**
  String fixCountKept(int n);

  /// No description provided for @accountDelete.
  ///
  /// In ar, this message translates to:
  /// **'حذف الحساب'**
  String get accountDelete;

  /// No description provided for @accountDeleteBody.
  ///
  /// In ar, this message translates to:
  /// **'سيُحذف الحساب {email} مع إسناداته ({count}). لا يمكن التراجع. يستطيع صاحبه بعدها تفعيل حسابه ببريده الصحيح وإرسال طلب انضمام.'**
  String accountDeleteBody(String email, int count);

  /// No description provided for @accountDeleted.
  ///
  /// In ar, this message translates to:
  /// **'حُذف الحساب.'**
  String get accountDeleted;

  /// No description provided for @fixDeleteTeachers.
  ///
  /// In ar, this message translates to:
  /// **'تدريسيون'**
  String get fixDeleteTeachers;

  /// No description provided for @fixDeleteTeachersHelp.
  ///
  /// In ar, this message translates to:
  /// **'يُحذف حساب التدريسي (بلا صلاحية إدارية) الذي لم يسجّل أي محاضرة، مع إسناداته، كحسابات استُوردت ببريد خاطئ. من سجّل محاضرات يبقى: أوقف حسابه أو غيّر بريده.'**
  String get fixDeleteTeachersHelp;

  /// No description provided for @fixOnlyTeacherHint.
  ///
  /// In ar, this message translates to:
  /// **'اتركه فارغاً لكل التدريسيين الذين لم يسجّلوا أي محاضرة'**
  String get fixOnlyTeacherHint;

  /// No description provided for @fixOnlyEmail.
  ///
  /// In ar, this message translates to:
  /// **'بريد واحد فقط (اختياري)'**
  String get fixOnlyEmail;

  /// No description provided for @fixProblemHasHistory.
  ///
  /// In ar, this message translates to:
  /// **'سجّل هذا الحساب محاضرات، فلا يُحذف حفاظاً على السجل. أوقف الحساب بدلاً من ذلك، أو غيّر بريده من «تصحيح البيانات».'**
  String get fixProblemHasHistory;

  /// No description provided for @accountChangeEmail.
  ///
  /// In ar, this message translates to:
  /// **'تغيير البريد'**
  String get accountChangeEmail;

  /// No description provided for @accountNewEmail.
  ///
  /// In ar, this message translates to:
  /// **'البريد الصحيح'**
  String get accountNewEmail;

  /// No description provided for @accountChangeEmailBody.
  ///
  /// In ar, this message translates to:
  /// **'سينتقل الحساب {from} مع إسناداته ({count}) إلى {to}. بعدها يفعّل صاحبه حسابه بالبريد الجديد من «أول مرة؟ فعّل حسابك» ويضع كلمة مروره.'**
  String accountChangeEmailBody(String from, int count, String to);

  /// No description provided for @accountEmailChanged.
  ///
  /// In ar, this message translates to:
  /// **'تغيّر البريد.'**
  String get accountEmailChanged;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
