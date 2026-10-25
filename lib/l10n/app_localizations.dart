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

  /// No description provided for @activityClasses.
  ///
  /// In ar, this message translates to:
  /// **'صفوفه — اضغط صفاً لعرض سجل الحضور وتنزيله'**
  String get activityClasses;

  /// No description provided for @activityClassesEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا صفوف مُسندة إليه.'**
  String get activityClassesEmpty;

  /// No description provided for @deleteAccount.
  ///
  /// In ar, this message translates to:
  /// **'حذف الحساب'**
  String get deleteAccount;

  /// No description provided for @deleteAccountBody.
  ///
  /// In ar, this message translates to:
  /// **'يُحذف حساب الدخول (البريد وكلمة المرور) ورسائلك الخاصة وربط هذا الهاتف بالإشعارات، ثم تخرج من التطبيق.\n\nتبقى سجلات الحضور التي سجّلتها واسمك في قائمة تدريسيي القسم لأنها سجلات رسمية للقسم؛ لحذف اسمك منها راسل إدارة القسم.\n\nيمكنك تفعيل الحساب من جديد بالبريد نفسه ما دام القسم يضيفك.'**
  String get deleteAccountBody;

  /// No description provided for @deleteAccountPassword.
  ///
  /// In ar, this message translates to:
  /// **'اكتب كلمة المرور للتأكيد'**
  String get deleteAccountPassword;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In ar, this message translates to:
  /// **'حذف نهائياً'**
  String get deleteAccountConfirm;

  /// No description provided for @deleteAccountDone.
  ///
  /// In ar, this message translates to:
  /// **'حُذف الحساب.'**
  String get deleteAccountDone;

  /// No description provided for @deleteAccountPending.
  ///
  /// In ar, this message translates to:
  /// **'لا يمكن حذف الحساب: توجد {count} سجلات غير مرفوعة. اتصل بالإنترنت وانتظر الرفع أولاً.'**
  String deleteAccountPending(int count);

  /// No description provided for @menuDaily.
  ///
  /// In ar, this message translates to:
  /// **'المتابعة اليومية'**
  String get menuDaily;

  /// No description provided for @menuStudents.
  ///
  /// In ar, this message translates to:
  /// **'الطلبة والغياب'**
  String get menuStudents;

  /// No description provided for @menuData.
  ///
  /// In ar, this message translates to:
  /// **'البيانات والحسابات'**
  String get menuData;

  /// No description provided for @menuCommunication.
  ///
  /// In ar, this message translates to:
  /// **'التواصل'**
  String get menuCommunication;

  /// No description provided for @menuSystem.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات والنظام'**
  String get menuSystem;

  /// No description provided for @menuWarnings.
  ///
  /// In ar, this message translates to:
  /// **'النسب والإنذارات'**
  String get menuWarnings;

  /// No description provided for @menuDataFix.
  ///
  /// In ar, this message translates to:
  /// **'تصحيح البيانات'**
  String get menuDataFix;

  /// No description provided for @menuYear.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات السنة'**
  String get menuYear;

  /// No description provided for @navCourses.
  ///
  /// In ar, this message translates to:
  /// **'موادي'**
  String get navCourses;

  /// No description provided for @backAgainToExit.
  ///
  /// In ar, this message translates to:
  /// **'اضغط رجوع مرة أخرى للخروج'**
  String get backAgainToExit;

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
  /// **'أدخل بريدك وسنرسل إليك رابطاً لتعيين كلمة مرور جديدة. الرابط يصل فقط لبريد فُعِّل من قبل؛ إن كان حسابك جديداً أو غيّرت الإدارة بريدك فاضغط «إلغاء» ثم «أول مرة؟ فعّل حسابك».'**
  String get resetPasswordBody;

  /// No description provided for @sendLink.
  ///
  /// In ar, this message translates to:
  /// **'إرسال الرابط'**
  String get sendLink;

  /// No description provided for @passwordResetSent.
  ///
  /// In ar, this message translates to:
  /// **'إن كان البريد مفعَّلاً فستصلك رسالة خلال دقائق (تفقّد مجلد Spam أيضاً). لم تصل؟ فعّل حسابك من «أول مرة؟ فعّل حسابك».'**
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
  /// **'البريد أو كلمة المرور غير صحيحة، أو لم يُفعَّل هذا البريد بعد (فعّله من «أول مرة؟ فعّل حسابك»).'**
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

  /// No description provided for @homeOpenRegister.
  ///
  /// In ar, this message translates to:
  /// **'عرض السجل'**
  String get homeOpenRegister;

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

  /// No description provided for @recordConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'مراجعة قبل الحفظ'**
  String get recordConfirmTitle;

  /// No description provided for @recordConfirmAbsent.
  ///
  /// In ar, this message translates to:
  /// **'الغائبون ({count})'**
  String recordConfirmAbsent(int count);

  /// No description provided for @recordConfirmNoAbsent.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد غائب في هذه المحاضرة.'**
  String get recordConfirmNoAbsent;

  /// No description provided for @recordConfirmSave.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الحفظ'**
  String get recordConfirmSave;

  /// No description provided for @recordConfirmBack.
  ///
  /// In ar, this message translates to:
  /// **'رجوع للتعديل'**
  String get recordConfirmBack;

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
  /// **'حذف بيانات خاطئة'**
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
  /// **'المعرّف الجديد مستعمل لسجل آخر: «{name}». إن كان مكرراً فاحذفه أولاً من «حذف بيانات خاطئة».'**
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
  /// **'تغيّر البريد. أخبر صاحبه أن يفعّل حسابه بالبريد الجديد من «أول مرة؟ فعّل حسابك» — «نسيت كلمة المرور» لا يعمل لبريد لم يُفعَّل.'**
  String get accountEmailChanged;

  /// No description provided for @groupsEditAction.
  ///
  /// In ar, this message translates to:
  /// **'تعديل أعضاء المجاميع'**
  String get groupsEditAction;

  /// No description provided for @groupsEditTitle.
  ///
  /// In ar, this message translates to:
  /// **'أعضاء المجاميع'**
  String get groupsEditTitle;

  /// No description provided for @groupsHelp.
  ///
  /// In ar, this message translates to:
  /// **'حدّد طالباً أو أكثر ثم «نقل إلى…». لا يُشترط تساوي أعداد المجاميع. الحضور المسجَّل سابقاً يبقى في محاضرات مجموعته القديمة.'**
  String get groupsHelp;

  /// No description provided for @groupsUnassigned.
  ///
  /// In ar, this message translates to:
  /// **'بلا مجموعة · عدد الطلبة: {count}'**
  String groupsUnassigned(int count);

  /// No description provided for @groupsSelected.
  ///
  /// In ar, this message translates to:
  /// **'المحدَّدون: {count}'**
  String groupsSelected(int count);

  /// No description provided for @groupsMoveTo.
  ///
  /// In ar, this message translates to:
  /// **'نقل إلى…'**
  String get groupsMoveTo;

  /// No description provided for @groupsMoveTitle.
  ///
  /// In ar, this message translates to:
  /// **'نقل {count} طالب إلى'**
  String groupsMoveTitle(int count);

  /// No description provided for @groupsMoved.
  ///
  /// In ar, this message translates to:
  /// **'نُقل {count} إلى {group}.'**
  String groupsMoved(int count, String group);

  /// No description provided for @groupsMovedCourses.
  ///
  /// In ar, this message translates to:
  /// **'نُقل {count} إلى {group} في {courses} مواد.'**
  String groupsMovedCourses(int count, String group, int courses);

  /// No description provided for @groupsApplyTitle.
  ///
  /// In ar, this message translates to:
  /// **'تطبيق النقل على مواد أخرى؟'**
  String get groupsApplyTitle;

  /// No description provided for @groupsApplyBody.
  ///
  /// In ar, this message translates to:
  /// **'نقل {count} طالب إلى {group} في «{course}». اختر المواد الأخرى التي يُطبَّق عليها النقل نفسه:'**
  String groupsApplyBody(int count, String group, String course);

  /// No description provided for @groupsApplyMissing.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد فيها {group}'**
  String groupsApplyMissing(String group);

  /// No description provided for @groupsApplyOnlyThis.
  ///
  /// In ar, this message translates to:
  /// **'هذه المادة فقط'**
  String get groupsApplyOnlyThis;

  /// No description provided for @groupsApply.
  ///
  /// In ar, this message translates to:
  /// **'تطبيق على {count} أخرى'**
  String groupsApply(int count);

  /// No description provided for @groupsAdd.
  ///
  /// In ar, this message translates to:
  /// **'إضافة مجموعة'**
  String get groupsAdd;

  /// No description provided for @groupsAdded.
  ///
  /// In ar, this message translates to:
  /// **'أُضيفت {group}؛ انقل إليها الطلبة.'**
  String groupsAdded(String group);

  /// No description provided for @groupsNone.
  ///
  /// In ar, this message translates to:
  /// **'لا مجاميع بعد. أنشئها أولاً من «إنشاء / إعادة توزيع المجاميع».'**
  String get groupsNone;

  /// No description provided for @assignmentsRedistributeWarning.
  ///
  /// In ar, this message translates to:
  /// **'تنبيه: إعادة التوزيع تلغي أي نقل يدوي سابق بين المجاميع.'**
  String get assignmentsRedistributeWarning;

  /// No description provided for @yearTitle.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات السنة الدراسية'**
  String get yearTitle;

  /// No description provided for @yearAction.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات السنة والنسب'**
  String get yearAction;

  /// No description provided for @yearNone.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد سنة دراسية نشطة. أنشئها من «تهيئة النظام» في الرئيسية.'**
  String get yearNone;

  /// No description provided for @yearHeader.
  ///
  /// In ar, this message translates to:
  /// **'السنة {year}'**
  String yearHeader(String year);

  /// No description provided for @yearHelp.
  ///
  /// In ar, this message translates to:
  /// **'هذه قرارات القسم التي تُحسب بها نسب الغياب. يمكن تعديلها في أي وقت، فتُعاد النسب كلها تلقائياً.'**
  String get yearHelp;

  /// No description provided for @yearSemesterN.
  ///
  /// In ar, this message translates to:
  /// **'الفصل {n}'**
  String yearSemesterN(int n);

  /// No description provided for @yearThresholds.
  ///
  /// In ar, this message translates to:
  /// **'عتبات الغياب (نسبة من محاضرات المادة)'**
  String get yearThresholds;

  /// No description provided for @levelAlert.
  ///
  /// In ar, this message translates to:
  /// **'تنبيه'**
  String get levelAlert;

  /// No description provided for @levelWarning.
  ///
  /// In ar, this message translates to:
  /// **'إنذار'**
  String get levelWarning;

  /// No description provided for @levelDismissal.
  ///
  /// In ar, this message translates to:
  /// **'فصل'**
  String get levelDismissal;

  /// No description provided for @yearPlanned.
  ///
  /// In ar, this message translates to:
  /// **'عدد محاضرات المادة في الفصل'**
  String get yearPlanned;

  /// No description provided for @yearWeeks.
  ///
  /// In ar, this message translates to:
  /// **'عدد أسابيع الفصل'**
  String get yearWeeks;

  /// No description provided for @yearPerUnit.
  ///
  /// In ar, this message translates to:
  /// **'محاضرات أسبوعياً لكل وحدة'**
  String get yearPerUnit;

  /// No description provided for @yearPerUnitHelp.
  ///
  /// In ar, this message translates to:
  /// **'مثلاً 1: مادة بثلاث وحدات = 3 محاضرات أسبوعياً. اكتب 0.5 إن كانت الوحدتان محاضرة واحدة.'**
  String get yearPerUnitHelp;

  /// No description provided for @yearExample.
  ///
  /// In ar, this message translates to:
  /// **'مثال: مادة بثلاث وحدات = {count} محاضرة في الفصل، والغياب الواحد = {percent}٪.'**
  String yearExample(int count, String percent);

  /// No description provided for @yearCombined.
  ///
  /// In ar, this message translates to:
  /// **'نسبة واحدة للنظري والعملي معاً'**
  String get yearCombined;

  /// No description provided for @yearCombinedOn.
  ///
  /// In ar, this message translates to:
  /// **'غيابات النظري والعملي تُجمع في نسبة المادة.'**
  String get yearCombinedOn;

  /// No description provided for @yearCombinedOff.
  ///
  /// In ar, this message translates to:
  /// **'نسبة للنظري وأخرى للعملي، وكل منهما من محاضرات المادة نفسها.'**
  String get yearCombinedOff;

  /// No description provided for @yearLock.
  ///
  /// In ar, this message translates to:
  /// **'إقفال السجل'**
  String get yearLock;

  /// No description provided for @yearLockHours.
  ///
  /// In ar, this message translates to:
  /// **'يُقفل السجل بعد نهاية يوم المحاضرة بـ'**
  String get yearLockHours;

  /// No description provided for @yearHoursSuffix.
  ///
  /// In ar, this message translates to:
  /// **'ساعة'**
  String get yearHoursSuffix;

  /// No description provided for @yearLockHelp.
  ///
  /// In ar, this message translates to:
  /// **'بعدها لا يعدّل التدريسي المحاضرة إلا بطلب، ويعدّلها مسؤول المرحلة والمدير مباشرة.'**
  String get yearLockHelp;

  /// No description provided for @yearLeaves.
  ///
  /// In ar, this message translates to:
  /// **'الإجازات'**
  String get yearLeaves;

  /// No description provided for @yearLeavesCount.
  ///
  /// In ar, this message translates to:
  /// **'الإجازات تُحتسب ضمن الغياب'**
  String get yearLeavesCount;

  /// No description provided for @yearLeavesCountOn.
  ///
  /// In ar, this message translates to:
  /// **'الغياب المُجاز (والمغطّى بإجازة) يدخل في النسبة.'**
  String get yearLeavesCountOn;

  /// No description provided for @yearLeavesCountOff.
  ///
  /// In ar, this message translates to:
  /// **'الغياب المُجاز والمغطّى بإجازة معتمدة لا يدخل في النسبة.'**
  String get yearLeavesCountOff;

  /// No description provided for @yearMaxLeave.
  ///
  /// In ar, this message translates to:
  /// **'الحد الأعلى لأيام الإجازة المقبولة (اختياري)'**
  String get yearMaxLeave;

  /// No description provided for @yearMaxLeaveHelp.
  ///
  /// In ar, this message translates to:
  /// **'فارغ = بلا حد. ما زاد عليه من أيام الإجازة يُحسب غياباً.'**
  String get yearMaxLeaveHelp;

  /// No description provided for @yearBadNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم غير صالح'**
  String get yearBadNumber;

  /// No description provided for @yearInvalid.
  ///
  /// In ar, this message translates to:
  /// **'تحقّق من القيم: العتبات تصاعدية (تنبيه < إنذار < فصل ≤ 100)، والأسابيع 1–30، والإقفال 1–720 ساعة.'**
  String get yearInvalid;

  /// No description provided for @yearSaved.
  ///
  /// In ar, this message translates to:
  /// **'حُفظت إعدادات السنة.'**
  String get yearSaved;

  /// No description provided for @leavesTitle.
  ///
  /// In ar, this message translates to:
  /// **'الإجازات'**
  String get leavesTitle;

  /// No description provided for @leavesAction.
  ///
  /// In ar, this message translates to:
  /// **'الإجازات'**
  String get leavesAction;

  /// No description provided for @leavesHelp.
  ///
  /// In ar, this message translates to:
  /// **'الإجازة المُدخلة هنا معتمدة: غياب الطالب في أيامها يُحسب «مُجاز» في كل مواده (حسب إعدادات السنة).'**
  String get leavesHelp;

  /// No description provided for @leavesEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا إجازات في هذه المرحلة.'**
  String get leavesEmpty;

  /// No description provided for @leaveAdd.
  ///
  /// In ar, this message translates to:
  /// **'إضافة إجازة'**
  String get leaveAdd;

  /// No description provided for @leaveStudent.
  ///
  /// In ar, this message translates to:
  /// **'الطالب (اسم أو رقم جامعي)'**
  String get leaveStudent;

  /// No description provided for @leaveTypeLabel.
  ///
  /// In ar, this message translates to:
  /// **'نوع الإجازة'**
  String get leaveTypeLabel;

  /// No description provided for @leaveTypeSick.
  ///
  /// In ar, this message translates to:
  /// **'مرضية'**
  String get leaveTypeSick;

  /// No description provided for @leaveTypeOfficial.
  ///
  /// In ar, this message translates to:
  /// **'رسمية'**
  String get leaveTypeOfficial;

  /// No description provided for @leaveTypeEmergency.
  ///
  /// In ar, this message translates to:
  /// **'ظرف طارئ'**
  String get leaveTypeEmergency;

  /// No description provided for @leaveTypeParticipation.
  ///
  /// In ar, this message translates to:
  /// **'مشاركة رسمية (نشاط أو وفد)'**
  String get leaveTypeParticipation;

  /// No description provided for @leaveTypeOther.
  ///
  /// In ar, this message translates to:
  /// **'أخرى'**
  String get leaveTypeOther;

  /// No description provided for @leavePickRange.
  ///
  /// In ar, this message translates to:
  /// **'اختر الفترة (من – إلى)'**
  String get leavePickRange;

  /// No description provided for @leaveRange.
  ///
  /// In ar, this message translates to:
  /// **'من {from} إلى {to}'**
  String leaveRange(String from, String to);

  /// No description provided for @leaveDays.
  ///
  /// In ar, this message translates to:
  /// **'{count} يوم'**
  String leaveDays(int count);

  /// No description provided for @leaveRef.
  ///
  /// In ar, this message translates to:
  /// **'رقم الكتاب أو التقرير الطبي'**
  String get leaveRef;

  /// No description provided for @leaveRefShown.
  ///
  /// In ar, this message translates to:
  /// **'الكتاب: {ref}'**
  String leaveRefShown(String ref);

  /// No description provided for @leaveSaved.
  ///
  /// In ar, this message translates to:
  /// **'حُفظت الإجازة.'**
  String get leaveSaved;

  /// No description provided for @leaveDeleteTitle.
  ///
  /// In ar, this message translates to:
  /// **'حذف الإجازة؟'**
  String get leaveDeleteTitle;

  /// No description provided for @leaveDeleteBody.
  ///
  /// In ar, this message translates to:
  /// **'تُحذف إجازة {name}، فيعود غيابه في أيامها غياباً.'**
  String leaveDeleteBody(String name);

  /// No description provided for @warnTitle.
  ///
  /// In ar, this message translates to:
  /// **'النسب والقوائم'**
  String get warnTitle;

  /// No description provided for @warnAction.
  ///
  /// In ar, this message translates to:
  /// **'النسب وقوائم التنبيه والإنذار'**
  String get warnAction;

  /// No description provided for @warnTabLists.
  ///
  /// In ar, this message translates to:
  /// **'القوائم'**
  String get warnTabLists;

  /// No description provided for @warnTabDecisions.
  ///
  /// In ar, this message translates to:
  /// **'القرارات'**
  String get warnTabDecisions;

  /// No description provided for @warnCourse.
  ///
  /// In ar, this message translates to:
  /// **'المادة'**
  String get warnCourse;

  /// No description provided for @warnAllCourses.
  ///
  /// In ar, this message translates to:
  /// **'كل المواد'**
  String get warnAllCourses;

  /// No description provided for @warnAll.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get warnAll;

  /// No description provided for @warnEdge.
  ///
  /// In ar, this message translates to:
  /// **'على الحافة'**
  String get warnEdge;

  /// No description provided for @warnHelp.
  ///
  /// In ar, this message translates to:
  /// **'النسبة = الغيابات المحتسبة ÷ محاضرات المادة المقررة في الفصل (من إعدادات السنة). تُحدَّث مع كل حفظ وإجازة.'**
  String get warnHelp;

  /// No description provided for @warnEdgeHelp.
  ///
  /// In ar, this message translates to:
  /// **'طلبة يصلون إلى المستوى التالي بعد غياب واحد.'**
  String get warnEdgeHelp;

  /// No description provided for @warnEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا أحد في هذه القائمة.'**
  String get warnEmpty;

  /// No description provided for @warnSaveAction.
  ///
  /// In ar, this message translates to:
  /// **'حفظ قرار قسم بقائمة {level}'**
  String warnSaveAction(String level);

  /// No description provided for @warnSaveTitle.
  ///
  /// In ar, this message translates to:
  /// **'حفظ قرار القسم؟'**
  String get warnSaveTitle;

  /// No description provided for @warnSaveBody.
  ///
  /// In ar, this message translates to:
  /// **'تُحفظ قائمة {level} بـ {count} طالب كما هي اليوم. يبقى القرار قابلاً للتعديل وإعادة التوليد حتى يحوّله المدير إلى قرار عمادة.'**
  String warnSaveBody(int count, String level);

  /// No description provided for @warnSaved.
  ///
  /// In ar, this message translates to:
  /// **'حُفظ قرار القسم. تجده في «القرارات».'**
  String get warnSaved;

  /// No description provided for @warnAbsences.
  ///
  /// In ar, this message translates to:
  /// **'الغياب {absences} من {planned} محاضرة = {percent}٪'**
  String warnAbsences(int absences, int planned, String percent);

  /// No description provided for @warnExcused.
  ///
  /// In ar, this message translates to:
  /// **'مُجاز (لا يُحتسب): {count}'**
  String warnExcused(int count);

  /// No description provided for @warnOneMore.
  ///
  /// In ar, this message translates to:
  /// **'⚠ يصل إلى {level} بعد غياب واحد'**
  String warnOneMore(String level);

  /// No description provided for @warnNoDecisions.
  ///
  /// In ar, this message translates to:
  /// **'لا قرارات محفوظة لهذه المرحلة.'**
  String get warnNoDecisions;

  /// No description provided for @warnDecisionTitle.
  ///
  /// In ar, this message translates to:
  /// **'{level} · {course} · {count} طالب'**
  String warnDecisionTitle(String level, String course, int count);

  /// No description provided for @warnDeanery.
  ///
  /// In ar, this message translates to:
  /// **'قرار عمادة رقم {number} في {date}'**
  String warnDeanery(String number, String date);

  /// No description provided for @warnDepartment.
  ///
  /// In ar, this message translates to:
  /// **'قرار قسم (أولي) · {date}'**
  String warnDepartment(String date);

  /// No description provided for @warnDeaneryLabel.
  ///
  /// In ar, this message translates to:
  /// **'قرار عمادة (نهائي ومقفل)'**
  String get warnDeaneryLabel;

  /// No description provided for @warnDepartmentLabel.
  ///
  /// In ar, this message translates to:
  /// **'قرار قسم (أولي)'**
  String get warnDepartmentLabel;

  /// No description provided for @warnDepartmentHelp.
  ///
  /// In ar, this message translates to:
  /// **'يمكن إعادة توليده من نسب اليوم (بعد نقل أو تأجيل أو إجازة)، ثم يحوّله المدير إلى قرار عمادة برقم الأمر وتاريخه.'**
  String get warnDepartmentHelp;

  /// No description provided for @warnRegenerate.
  ///
  /// In ar, this message translates to:
  /// **'إعادة التوليد'**
  String get warnRegenerate;

  /// No description provided for @warnRegenerateBody.
  ///
  /// In ar, this message translates to:
  /// **'تُستبدل قائمة القرار ({before} طالب) بقائمة اليوم ({after} طالب).'**
  String warnRegenerateBody(int before, int after);

  /// No description provided for @warnRegenerated.
  ///
  /// In ar, this message translates to:
  /// **'أُعيد توليد القرار.'**
  String get warnRegenerated;

  /// No description provided for @warnFinalize.
  ///
  /// In ar, this message translates to:
  /// **'تحويل إلى قرار عمادة'**
  String get warnFinalize;

  /// No description provided for @warnFinalizeBody.
  ///
  /// In ar, this message translates to:
  /// **'بعد التحويل يُقفل القرار نهائياً ولا يُعدَّل ولا يُحذف؛ أي تغيير بعده يحتاج قراراً جديداً.'**
  String get warnFinalizeBody;

  /// No description provided for @warnOrderNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم الأمر الإداري'**
  String get warnOrderNumber;

  /// No description provided for @warnOrderDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الأمر'**
  String get warnOrderDate;

  /// No description provided for @warnFinalized.
  ///
  /// In ar, this message translates to:
  /// **'صار القرار قرار عمادة مقفلاً.'**
  String get warnFinalized;

  /// No description provided for @warnDeleteTitle.
  ///
  /// In ar, this message translates to:
  /// **'حذف قرار القسم؟'**
  String get warnDeleteTitle;

  /// No description provided for @warnDeleteBody.
  ///
  /// In ar, this message translates to:
  /// **'يُحذف القرار المحفوظ (النسب نفسها لا تتأثر).'**
  String get warnDeleteBody;

  /// No description provided for @warnDeleted.
  ///
  /// In ar, this message translates to:
  /// **'حُذف القرار.'**
  String get warnDeleted;

  /// No description provided for @registerPercent.
  ///
  /// In ar, this message translates to:
  /// **'النسبة'**
  String get registerPercent;

  /// No description provided for @registerPercentHelp.
  ///
  /// In ar, this message translates to:
  /// **'نسبة غياب الطالب في المادة كلها (النظري والعملي حسب إعدادات السنة)، بعد احتساب الإجازات. تُحدَّث بزر التحديث عند الاتصال.'**
  String get registerPercentHelp;

  /// No description provided for @recordRequestHint.
  ///
  /// In ar, this message translates to:
  /// **'المحاضرة مقفلة: المس طالباً لطلب تعديل حالته من مسؤول المرحلة.'**
  String get recordRequestHint;

  /// No description provided for @editRequestTitle.
  ///
  /// In ar, this message translates to:
  /// **'طلب تعديل'**
  String get editRequestTitle;

  /// No description provided for @editRequestNow.
  ///
  /// In ar, this message translates to:
  /// **'الحالة الآن: {status}'**
  String editRequestNow(String status);

  /// No description provided for @editRequestReason.
  ///
  /// In ar, this message translates to:
  /// **'سبب التعديل (إلزامي)'**
  String get editRequestReason;

  /// No description provided for @editRequestSend.
  ///
  /// In ar, this message translates to:
  /// **'إرسال الطلب'**
  String get editRequestSend;

  /// No description provided for @editRequestSent.
  ///
  /// In ar, this message translates to:
  /// **'أُرسل الطلب إلى مسؤول المرحلة.'**
  String get editRequestSent;

  /// No description provided for @editRequestPending.
  ///
  /// In ar, this message translates to:
  /// **'⏳ طلب تعديل بانتظار الموافقة'**
  String get editRequestPending;

  /// No description provided for @editRequestsTitle.
  ///
  /// In ar, this message translates to:
  /// **'طلبات التعديل'**
  String get editRequestsTitle;

  /// No description provided for @editRequestsAction.
  ///
  /// In ar, this message translates to:
  /// **'طلبات التعديل'**
  String get editRequestsAction;

  /// No description provided for @editRequestsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا طلبات معلّقة.'**
  String get editRequestsEmpty;

  /// No description provided for @editRequestLecture.
  ///
  /// In ar, this message translates to:
  /// **'{course} · {date} · المحاضرة {n}'**
  String editRequestLecture(String course, String date, int n);

  /// No description provided for @editRequestWhy.
  ///
  /// In ar, this message translates to:
  /// **'السبب: {reason}'**
  String editRequestWhy(String reason);

  /// No description provided for @editRequestApprove.
  ///
  /// In ar, this message translates to:
  /// **'موافقة وتعديل'**
  String get editRequestApprove;

  /// No description provided for @editRequestReject.
  ///
  /// In ar, this message translates to:
  /// **'رفض'**
  String get editRequestReject;

  /// No description provided for @editRequestNote.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظة (اختياري)'**
  String get editRequestNote;

  /// No description provided for @editRequestApproved.
  ///
  /// In ar, this message translates to:
  /// **'عُدّل السجل ووصل التعديل إلى هواتف التدريسيين عند التحديث.'**
  String get editRequestApproved;

  /// No description provided for @editRequestRejected.
  ///
  /// In ar, this message translates to:
  /// **'رُفض الطلب.'**
  String get editRequestRejected;

  /// No description provided for @dashTitle.
  ///
  /// In ar, this message translates to:
  /// **'لوحة المرحلة'**
  String get dashTitle;

  /// No description provided for @dashAction.
  ///
  /// In ar, this message translates to:
  /// **'لوحة المرحلة'**
  String get dashAction;

  /// No description provided for @dashToday.
  ///
  /// In ar, this message translates to:
  /// **'محاضرات مسجّلة اليوم: {count}'**
  String dashToday(int count);

  /// No description provided for @dashWeek.
  ///
  /// In ar, this message translates to:
  /// **'آخر 7 أيام: {count} محاضرة'**
  String dashWeek(int count);

  /// No description provided for @dashIdle.
  ///
  /// In ar, this message translates to:
  /// **'صفوف بلا تسجيل منذ 7 أيام: {count}'**
  String dashIdle(int count);

  /// No description provided for @dashIdleHelp.
  ///
  /// In ar, this message translates to:
  /// **'قد تكون عطلة أو محاضرات ملغاة؛ تابع مع تدريسييها.'**
  String get dashIdleHelp;

  /// No description provided for @dashRequests.
  ///
  /// In ar, this message translates to:
  /// **'طلبات تعديل معلّقة: {count}'**
  String dashRequests(int count);

  /// No description provided for @reportPrinted.
  ///
  /// In ar, this message translates to:
  /// **'طُبع في {date}'**
  String reportPrinted(String date);

  /// No description provided for @reportPage.
  ///
  /// In ar, this message translates to:
  /// **'صفحة {page} من {pages}'**
  String reportPage(int page, int pages);

  /// No description provided for @reportSignatureHint.
  ///
  /// In ar, this message translates to:
  /// **'الاسم والتوقيع'**
  String get reportSignatureHint;

  /// No description provided for @reportPdf.
  ///
  /// In ar, this message translates to:
  /// **'PDF للطباعة والتوقيع'**
  String get reportPdf;

  /// No description provided for @reportPdfHelp.
  ///
  /// In ar, this message translates to:
  /// **'بترويسة القسم وأماكن التوقيع'**
  String get reportPdfHelp;

  /// No description provided for @reportExcel.
  ///
  /// In ar, this message translates to:
  /// **'Excel'**
  String get reportExcel;

  /// No description provided for @reportExcelHelp.
  ///
  /// In ar, this message translates to:
  /// **'جدول قابل للتعديل والفرز'**
  String get reportExcelHelp;

  /// No description provided for @reportSaved.
  ///
  /// In ar, this message translates to:
  /// **'حُفظ الملف.'**
  String get reportSaved;

  /// No description provided for @reportExport.
  ///
  /// In ar, this message translates to:
  /// **'تصدير'**
  String get reportExport;

  /// No description provided for @reportLetterPresent.
  ///
  /// In ar, this message translates to:
  /// **'ح'**
  String get reportLetterPresent;

  /// No description provided for @reportLetterAbsent.
  ///
  /// In ar, this message translates to:
  /// **'غ'**
  String get reportLetterAbsent;

  /// No description provided for @reportLetterLate.
  ///
  /// In ar, this message translates to:
  /// **'ت'**
  String get reportLetterLate;

  /// No description provided for @reportLetterExcused.
  ///
  /// In ar, this message translates to:
  /// **'م'**
  String get reportLetterExcused;

  /// No description provided for @reportRegisterSheet.
  ///
  /// In ar, this message translates to:
  /// **'السجل'**
  String get reportRegisterSheet;

  /// No description provided for @reportLecturesRange.
  ///
  /// In ar, this message translates to:
  /// **'المحاضرات من {from} إلى {to}'**
  String reportLecturesRange(int from, int to);

  /// No description provided for @reportRegisterTitle.
  ///
  /// In ar, this message translates to:
  /// **'سجل حضور مادة {course}'**
  String reportRegisterTitle(String course);

  /// No description provided for @reportLectureCount.
  ///
  /// In ar, this message translates to:
  /// **'عدد المحاضرات المسجلة: {count}'**
  String reportLectureCount(int count);

  /// No description provided for @reportLegend.
  ///
  /// In ar, this message translates to:
  /// **'ح = حاضر، غ = غائب، ت = متأخر، م = مُجاز، – = لم يُسجَّل.'**
  String get reportLegend;

  /// No description provided for @reportPercentNote.
  ///
  /// In ar, this message translates to:
  /// **'النسبة = الغيابات المحتسبة ÷ محاضرات المادة المقررة في الفصل × 100 حسب إعدادات السنة، وتشمل كل محاضرات المادة والإجازات المعتمدة.'**
  String get reportPercentNote;

  /// No description provided for @reportSignTeacher.
  ///
  /// In ar, this message translates to:
  /// **'التدريسي'**
  String get reportSignTeacher;

  /// No description provided for @reportSignStageManager.
  ///
  /// In ar, this message translates to:
  /// **'مسؤول المرحلة'**
  String get reportSignStageManager;

  /// No description provided for @reportSignHead.
  ///
  /// In ar, this message translates to:
  /// **'رئيس القسم'**
  String get reportSignHead;

  /// No description provided for @reportSignDean.
  ///
  /// In ar, this message translates to:
  /// **'عميد الكلية'**
  String get reportSignDean;

  /// No description provided for @reportPlanned.
  ///
  /// In ar, this message translates to:
  /// **'المقررة'**
  String get reportPlanned;

  /// No description provided for @reportListTitle.
  ///
  /// In ar, this message translates to:
  /// **'قائمة {list} — {stage}'**
  String reportListTitle(String list, String stage);

  /// No description provided for @reportStudentCount.
  ///
  /// In ar, this message translates to:
  /// **'عدد الطلبة: {count}'**
  String reportStudentCount(int count);

  /// No description provided for @reportDecisionTitle.
  ///
  /// In ar, this message translates to:
  /// **'قرار {level} — {stage}'**
  String reportDecisionTitle(String level, String stage);

  /// No description provided for @reportStudentTitle.
  ///
  /// In ar, this message translates to:
  /// **'ملخص غياب الطالب {name}'**
  String reportStudentTitle(String name);

  /// No description provided for @reportStudentSheet.
  ///
  /// In ar, this message translates to:
  /// **'الملخص'**
  String get reportStudentSheet;

  /// No description provided for @reportExcused.
  ///
  /// In ar, this message translates to:
  /// **'مُجاز'**
  String get reportExcused;

  /// No description provided for @reportLevel.
  ///
  /// In ar, this message translates to:
  /// **'المستوى'**
  String get reportLevel;

  /// No description provided for @reportStudentNote.
  ///
  /// In ar, this message translates to:
  /// **'تظهر المواد التي سُجّل للطالب فيها غياب أو تأخر أو إجازة.'**
  String get reportStudentNote;

  /// No description provided for @reportStatsTitle.
  ///
  /// In ar, this message translates to:
  /// **'إحصائية الغياب — {stage}'**
  String reportStatsTitle(String stage);

  /// No description provided for @reportStatsSheet.
  ///
  /// In ar, this message translates to:
  /// **'الإحصائية'**
  String get reportStatsSheet;

  /// No description provided for @reportStatsLevels.
  ///
  /// In ar, this message translates to:
  /// **'تنبيه: {alert} · إنذار: {warning} · فصل: {dismissal}'**
  String reportStatsLevels(int alert, int warning, int dismissal);

  /// No description provided for @reportStatsByCourse.
  ///
  /// In ar, this message translates to:
  /// **'المواد حسب مجموع الغيابات'**
  String get reportStatsByCourse;

  /// No description provided for @reportAbsentStudents.
  ///
  /// In ar, this message translates to:
  /// **'طلبة متغيبون'**
  String get reportAbsentStudents;

  /// No description provided for @reportTotalAbsences.
  ///
  /// In ar, this message translates to:
  /// **'مجموع الغيابات'**
  String get reportTotalAbsences;

  /// No description provided for @reportTopSheet.
  ///
  /// In ar, this message translates to:
  /// **'الأعلى غياباً'**
  String get reportTopSheet;

  /// No description provided for @reportTopStudents.
  ///
  /// In ar, this message translates to:
  /// **'الطلبة الأعلى غياباً ({count})'**
  String reportTopStudents(int count);

  /// No description provided for @reportStudentAction.
  ///
  /// In ar, this message translates to:
  /// **'ملخص الطالب (PDF)'**
  String get reportStudentAction;

  /// No description provided for @reportStatsAction.
  ///
  /// In ar, this message translates to:
  /// **'إحصائية المرحلة'**
  String get reportStatsAction;

  /// No description provided for @reportListAction.
  ///
  /// In ar, this message translates to:
  /// **'تصدير القائمة'**
  String get reportListAction;

  /// No description provided for @reportRegisterAction.
  ///
  /// In ar, this message translates to:
  /// **'تصدير السجل'**
  String get reportRegisterAction;

  /// No description provided for @letterWarningTitle.
  ///
  /// In ar, this message translates to:
  /// **'إنذار بالغياب'**
  String get letterWarningTitle;

  /// No description provided for @letterDismissalTitle.
  ///
  /// In ar, this message translates to:
  /// **'إشعار رسوب بسبب الغياب'**
  String get letterDismissalTitle;

  /// No description provided for @letterNumberDate.
  ///
  /// In ar, this message translates to:
  /// **'العدد: ................     التاريخ: ....../....../..........'**
  String get letterNumberDate;

  /// No description provided for @letterTo.
  ///
  /// In ar, this message translates to:
  /// **'إلى الطالب/ة: {name} — الرقم الجامعي {id} — {stage}'**
  String letterTo(String name, String id, String stage);

  /// No description provided for @letterWarningBody.
  ///
  /// In ar, this message translates to:
  /// **'نظراً لبلوغ غيابك في مادة ({course}) نسبة {percent}٪ من محاضرات المادة المقررة في الفصل ({absences} غياب من {planned} محاضرة)، وهي نسبة تتجاوز حد الإنذار المعتمد في القسم ({warning}٪)، نوجّه إليك هذا الإنذار، ونلفت انتباهك إلى أن بلوغ نسبة {dismissal}٪ يعرّضك للرسوب في المادة بسبب الغياب وفق التعليمات النافذة.'**
  String letterWarningBody(
    String course,
    String percent,
    int absences,
    int planned,
    String warning,
    String dismissal,
  );

  /// No description provided for @letterWarningClosing.
  ///
  /// In ar, this message translates to:
  /// **'يرجى الالتزام بالحضور ومراجعة مسؤول المرحلة عند وجود عذر مشروع.'**
  String get letterWarningClosing;

  /// No description provided for @letterDismissalBody.
  ///
  /// In ar, this message translates to:
  /// **'نظراً لبلوغ غيابك في مادة ({course}) نسبة {percent}٪ من محاضرات المادة المقررة في الفصل ({absences} غياب من {planned} محاضرة)، وهي نسبة تبلغ حد الرسوب بسبب الغياب المعتمد في القسم ({dismissal}٪)، نشعرك بأنك تُعدّ راسباً في المادة بسبب الغياب وفق التعليمات النافذة.'**
  String letterDismissalBody(
    String course,
    String percent,
    int absences,
    int planned,
    String dismissal,
  );

  /// No description provided for @letterDismissalClosing.
  ///
  /// In ar, this message translates to:
  /// **'يُعدّ هذا الإشعار أولياً حتى صدور قرار العمادة.'**
  String get letterDismissalClosing;

  /// No description provided for @letterAction.
  ///
  /// In ar, this message translates to:
  /// **'كتاب إنذار (PDF)'**
  String get letterAction;

  /// No description provided for @letterBatchAction.
  ///
  /// In ar, this message translates to:
  /// **'كتب الإنذار لكل القائمة (PDF)'**
  String get letterBatchAction;

  /// No description provided for @backupAction.
  ///
  /// In ar, this message translates to:
  /// **'النسخ الاحتياطي'**
  String get backupAction;

  /// No description provided for @backupTitle.
  ///
  /// In ar, this message translates to:
  /// **'النسخ الاحتياطي'**
  String get backupTitle;

  /// No description provided for @backupAdminsOnly.
  ///
  /// In ar, this message translates to:
  /// **'النسخ الاحتياطي للمدراء فقط.'**
  String get backupAdminsOnly;

  /// No description provided for @backupNever.
  ///
  /// In ar, this message translates to:
  /// **'لم تُحفظ نسخة احتياطية بعد.'**
  String get backupNever;

  /// No description provided for @backupLast.
  ///
  /// In ar, this message translates to:
  /// **'آخر نسخة: {date} الساعة {time}'**
  String backupLast(String date, String time);

  /// No description provided for @backupLastDetail.
  ///
  /// In ar, this message translates to:
  /// **'{count} وثيقة · {by}'**
  String backupLastDetail(int count, String by);

  /// No description provided for @backupAgo.
  ///
  /// In ar, this message translates to:
  /// **'{days, plural, =0{آخر نسخة احتياطية اليوم} =1{آخر نسخة احتياطية قبل يوم} =2{آخر نسخة احتياطية قبل يومين} few{آخر نسخة احتياطية قبل {days} أيام} other{آخر نسخة احتياطية قبل {days} يوماً}}'**
  String backupAgo(int days);

  /// No description provided for @backupDue.
  ///
  /// In ar, this message translates to:
  /// **'مرّ أكثر من أسبوع؛ احفظ نسخة جديدة.'**
  String get backupDue;

  /// No description provided for @backupCreateTitle.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء نسخة احتياطية'**
  String get backupCreateTitle;

  /// No description provided for @backupCreateHelp.
  ///
  /// In ar, this message translates to:
  /// **'ملف واحد مشفّر بكلمة مرور فيه كل بيانات القسم. احفظه خارج الهاتف (الحاسوب، Google Drive، البريد). لا يُفتح إلا بكلمة المرور.'**
  String get backupCreateHelp;

  /// No description provided for @backupCount.
  ///
  /// In ar, this message translates to:
  /// **'حساب حجم النسخة'**
  String get backupCount;

  /// No description provided for @backupEstimate.
  ///
  /// In ar, this message translates to:
  /// **'{count} وثيقة (الحسابات، المواد، الطلبة، المحاضرات، الإحصائيات…)'**
  String backupEstimate(int count);

  /// No description provided for @backupWithRecords.
  ///
  /// In ar, this message translates to:
  /// **'تضمين سجلات الحضور التفصيلية ({count})'**
  String backupWithRecords(int count);

  /// No description provided for @backupRecordsHelp.
  ///
  /// In ar, this message translates to:
  /// **'كل سجل قراءة من حصة الخطة المجانية (50,000 قراءة يومياً). النسب لا تحتاجها فهي في الإحصائيات؛ إن كانت كثيرة فاحفظها في يوم هادئ.'**
  String get backupRecordsHelp;

  /// No description provided for @backupPassword.
  ///
  /// In ar, this message translates to:
  /// **'كلمة مرور النسخة'**
  String get backupPassword;

  /// No description provided for @backupPasswordConfirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد كلمة المرور'**
  String get backupPasswordConfirm;

  /// No description provided for @backupPasswordWarning.
  ///
  /// In ar, this message translates to:
  /// **'إن نُسيت كلمة المرور فلا يمكن فتح النسخة أبداً.'**
  String get backupPasswordWarning;

  /// No description provided for @backupPasswordShort.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور 8 أحرف على الأقل.'**
  String get backupPasswordShort;

  /// No description provided for @backupPasswordMismatch.
  ///
  /// In ar, this message translates to:
  /// **'كلمتا المرور غير متطابقتين.'**
  String get backupPasswordMismatch;

  /// No description provided for @backupCreate.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء النسخة وحفظها'**
  String get backupCreate;

  /// No description provided for @backupReading.
  ///
  /// In ar, this message translates to:
  /// **'قراءة {name}…'**
  String backupReading(String name);

  /// No description provided for @backupEncrypting.
  ///
  /// In ar, this message translates to:
  /// **'تشفير الملف…'**
  String get backupEncrypting;

  /// No description provided for @backupSaved.
  ///
  /// In ar, this message translates to:
  /// **'حُفظت النسخة ({count} وثيقة).'**
  String backupSaved(int count);

  /// No description provided for @backupCollection.
  ///
  /// In ar, this message translates to:
  /// **'{name, select, academicYears{السنوات} stages{المراحل} users{الحسابات} courses{المواد} students{الطلبة} groups{المجاميع} assignments{الإسنادات} sessions{المحاضرات} leaves{الإجازات} stats{الإحصائيات} warningLists{القرارات} config{الإعدادات} editRequests{طلبات التعديل} accessRequests{طلبات الانضمام} auditLog{سجل التدقيق} records{سجلات الحضور} other{{name}}}'**
  String backupCollection(String name);

  /// No description provided for @backupRestoreTitle.
  ///
  /// In ar, this message translates to:
  /// **'الاستعادة من نسخة'**
  String get backupRestoreTitle;

  /// No description provided for @backupRestoreHelp.
  ///
  /// In ar, this message translates to:
  /// **'للمدير العام فقط. تعيد كل وثائق النسخة كما كانت وتكتب فوق الحالية، ولا تحذف ما أُضيف بعدها. طلبات التعديل والانضمام وسجل التدقيق لا تُستعاد. يمكن إعادة تشغيلها إن انقطعت.'**
  String get backupRestoreHelp;

  /// No description provided for @backupPickFile.
  ///
  /// In ar, this message translates to:
  /// **'اختيار ملف النسخة (.uobk)'**
  String get backupPickFile;

  /// No description provided for @backupOpen.
  ///
  /// In ar, this message translates to:
  /// **'فتح الملف'**
  String get backupOpen;

  /// No description provided for @backupWrongPassword.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور خاطئة أو الملف تالف.'**
  String get backupWrongPassword;

  /// No description provided for @backupNotABackup.
  ///
  /// In ar, this message translates to:
  /// **'هذا ليس ملف نسخة احتياطية لهذا البرنامج.'**
  String get backupNotABackup;

  /// No description provided for @backupFileInfo.
  ///
  /// In ar, this message translates to:
  /// **'نسخة {date} — {by}'**
  String backupFileInfo(String date, String by);

  /// No description provided for @backupRestore.
  ///
  /// In ar, this message translates to:
  /// **'استعادة'**
  String get backupRestore;

  /// No description provided for @backupRestoreConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'استعادة النسخة؟'**
  String get backupRestoreConfirmTitle;

  /// No description provided for @backupRestoreConfirmBody.
  ///
  /// In ar, this message translates to:
  /// **'ستُستبدل البيانات الحالية بما في النسخة لكل وثيقة موجودة فيها، ولا يمكن التراجع. احفظ نسخة من الحالة الحالية أولاً إن لم تفعل.'**
  String get backupRestoreConfirmBody;

  /// No description provided for @backupRestoreTypeTitle.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد أخير'**
  String get backupRestoreTypeTitle;

  /// No description provided for @backupRestoreType.
  ///
  /// In ar, this message translates to:
  /// **'اكتب «{word}» للمتابعة'**
  String backupRestoreType(String word);

  /// No description provided for @backupRestoreWord.
  ///
  /// In ar, this message translates to:
  /// **'استعادة'**
  String get backupRestoreWord;

  /// No description provided for @backupRestoreProgress.
  ///
  /// In ar, this message translates to:
  /// **'الدفعة {done} من {total}'**
  String backupRestoreProgress(int done, int total);

  /// No description provided for @backupRestored.
  ///
  /// In ar, this message translates to:
  /// **'اكتملت الاستعادة ({count} كتابة).'**
  String backupRestored(int count);

  /// No description provided for @backupRestoreFailed.
  ///
  /// In ar, this message translates to:
  /// **'توقفت الاستعادة: {error}. أعد تشغيلها لتكمل (قد تكون حصة الكتابة اليومية انتهت).'**
  String backupRestoreFailed(String error);

  /// No description provided for @auditOpen.
  ///
  /// In ar, this message translates to:
  /// **'سجل التدقيق'**
  String get auditOpen;

  /// No description provided for @auditTitle.
  ///
  /// In ar, this message translates to:
  /// **'سجل التدقيق'**
  String get auditTitle;

  /// No description provided for @auditAllStages.
  ///
  /// In ar, this message translates to:
  /// **'كل القسم'**
  String get auditAllStages;

  /// No description provided for @auditEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد عمليات مسجلة.'**
  String get auditEmpty;

  /// No description provided for @auditMore.
  ///
  /// In ar, this message translates to:
  /// **'عرض المزيد'**
  String get auditMore;

  /// No description provided for @auditEnd.
  ///
  /// In ar, this message translates to:
  /// **'نهاية السجل'**
  String get auditEnd;

  /// No description provided for @auditBefore.
  ///
  /// In ar, this message translates to:
  /// **'قبل'**
  String get auditBefore;

  /// No description provided for @auditAfter.
  ///
  /// In ar, this message translates to:
  /// **'بعد'**
  String get auditAfter;

  /// No description provided for @auditActionLabel.
  ///
  /// In ar, this message translates to:
  /// **'{action, select, session_missed{تسجيل محاضرة فائتة} record_update{تعديل حضور طالب} editRequest_reject{رفض طلب تعديل} leave_create{إضافة إجازة} leave_delete{حذف إجازة} warnings_create{إنشاء قرار} warnings_regenerate{إعادة توليد قرار} warnings_delete{حذف قرار} warnings_finalize{تحويل قرار إلى العمادة} user_create{إضافة حساب} user_update{تعديل حساب} user_approve{قبول طلب انضمام} user_reject{رفض طلب انضمام} user_rename{تغيير بريد حساب} users_delete{حذف حسابات} student_create{إضافة طالب} student_update{تعديل طالب} student_rename{تغيير رقم جامعي} students_delete{حذف طلبة} course_rename{تغيير رمز مادة} sessions_delete{حذف محاضرات} courses_delete{حذف مواد} import_students{استيراد طلبة} import_teachers{استيراد تدريسيين} import_courses{استيراد مواد} year_update{تعديل إعدادات السنة} backup_export{نسخة احتياطية} backup_restore{استعادة نسخة احتياطية} config_update{تعديل إصدار التطبيق} other{{action}}}'**
  String auditActionLabel(String action);

  /// No description provided for @deptAction.
  ///
  /// In ar, this message translates to:
  /// **'لوحة القسم'**
  String get deptAction;

  /// No description provided for @deptTitle.
  ///
  /// In ar, this message translates to:
  /// **'لوحة القسم'**
  String get deptTitle;

  /// No description provided for @deptActiveAccounts.
  ///
  /// In ar, this message translates to:
  /// **'{count} حساب فعّال'**
  String deptActiveAccounts(int count);

  /// No description provided for @deptAccessRequests.
  ///
  /// In ar, this message translates to:
  /// **'طلبات الانضمام المعلّقة: {count}'**
  String deptAccessRequests(int count);

  /// No description provided for @deptStageEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا بيانات بعد.'**
  String get deptStageEmpty;

  /// No description provided for @deptStudents.
  ///
  /// In ar, this message translates to:
  /// **'{count} طالب'**
  String deptStudents(int count);

  /// No description provided for @deptCourses.
  ///
  /// In ar, this message translates to:
  /// **'{count} مادة'**
  String deptCourses(int count);

  /// No description provided for @deptLecturesToday.
  ///
  /// In ar, this message translates to:
  /// **'محاضرات اليوم: {count}'**
  String deptLecturesToday(int count);

  /// No description provided for @deptPendingRequests.
  ///
  /// In ar, this message translates to:
  /// **'طلبات تعديل: {count}'**
  String deptPendingRequests(int count);

  /// No description provided for @syncRejectedTap.
  ///
  /// In ar, this message translates to:
  /// **'المس لمعرفة السبب وإعادة المحاولة'**
  String get syncRejectedTap;

  /// No description provided for @syncReasonLocked.
  ///
  /// In ar, this message translates to:
  /// **'انتهت مهلة التسجيل لهذه المحاضرة قبل رفعها. لا يحفظها الآن إلا مسؤول المرحلة: أرسل له الأسماء، ثم احذفها من الهاتف.'**
  String get syncReasonLocked;

  /// No description provided for @syncReasonDenied.
  ///
  /// In ar, this message translates to:
  /// **'رفض الخادم الحفظ. اضغط «إعادة المحاولة» (التطبيق يعيد حساب موعد الإقفال من إعدادات السنة)، وإن تكرر فتأكد من إسنادك لهذه المادة لدى مسؤول المرحلة.'**
  String get syncReasonDenied;

  /// No description provided for @deptPartial.
  ///
  /// In ar, this message translates to:
  /// **'تعذّرت قراءة بعض الأعداد ({collections}) — {code}. إن كان «permission-denied» فالقواعد المنشورة أقدم من التطبيق: انشر firestore.rules.'**
  String deptPartial(String collections, String code);

  /// No description provided for @errorDetails.
  ///
  /// In ar, this message translates to:
  /// **'التفاصيل'**
  String get errorDetails;

  /// No description provided for @errorReportTitle.
  ///
  /// In ar, this message translates to:
  /// **'تقرير المشكلة'**
  String get errorReportTitle;

  /// No description provided for @errorReportHelp.
  ///
  /// In ar, this message translates to:
  /// **'اضغط «نسخ» ثم الصقه في رسالة للمطوّر (أو صوّر الشاشة). لا يحتوي كلمات مرور.'**
  String get errorReportHelp;

  /// No description provided for @errorCopy.
  ///
  /// In ar, this message translates to:
  /// **'نسخ'**
  String get errorCopy;

  /// No description provided for @errorLogAction.
  ///
  /// In ar, this message translates to:
  /// **'سجل الأخطاء (للإرسال إلى المطوّر)'**
  String get errorLogAction;

  /// No description provided for @errorLogEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لم يُسجَّل أي خطأ منذ فتح التطبيق.'**
  String get errorLogEmpty;

  /// No description provided for @errorLogCount.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =0{لا أخطاء منذ فتح التطبيق} =1{خطأ واحد منذ فتح التطبيق} =2{خطآن منذ فتح التطبيق} few{{count} أخطاء منذ فتح التطبيق} other{{count} خطأ منذ فتح التطبيق}}'**
  String errorLogCount(int count);

  /// No description provided for @syncDiagnose.
  ///
  /// In ar, this message translates to:
  /// **'تشخيص'**
  String get syncDiagnose;

  /// No description provided for @syncDiagnoseTitle.
  ///
  /// In ar, this message translates to:
  /// **'تشخيص عملية الحفظ'**
  String get syncDiagnoseTitle;

  /// No description provided for @syncDiagnoseRunning.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ الفحص على الخادم…'**
  String get syncDiagnoseRunning;

  /// No description provided for @studentNoData.
  ///
  /// In ar, this message translates to:
  /// **'لم تُنزَّل بيانات هذه المادة بعد؛ اضغط تحديث السجل.'**
  String get studentNoData;

  /// No description provided for @studentHistory.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =0{لا غياب ولا تأخير} =1{محاضرة واحدة لم يحضرها كاملة} =2{محاضرتان لم يحضرهما كاملتين} few{{count} محاضرات لم يحضرها كاملة} other{{count} محاضرة لم يحضرها كاملة}}'**
  String studentHistory(int count);

  /// No description provided for @studentNoAbsences.
  ///
  /// In ar, this message translates to:
  /// **'حضر كل المحاضرات المسجّلة.'**
  String get studentNoAbsences;

  /// No description provided for @studentSourceNote.
  ///
  /// In ar, this message translates to:
  /// **'يشمل محاضرات المادة لكل تدريسييها كما نُزّلت آخر مرة (زر التحديث في السجل)، وتسجيلات هذا الهاتف.'**
  String get studentSourceNote;

  /// No description provided for @studentCounts.
  ///
  /// In ar, this message translates to:
  /// **'تأخير: {lates} · مُجاز: {excused} · منها بإجازة معتمدة: {byLeave}'**
  String studentCounts(int lates, int excused, int byLeave);

  /// No description provided for @studentUntilNext.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =1{يصل إلى {level} بعد غياب واحد} =2{يصل إلى {level} بعد غيابين} few{يصل إلى {level} بعد {count} غيابات} other{يصل إلى {level} بعد {count} غياباً}}'**
  String studentUntilNext(int count, String level);

  /// No description provided for @studentOnLeave.
  ///
  /// In ar, this message translates to:
  /// **'بإجازة معتمدة'**
  String get studentOnLeave;

  /// No description provided for @reportPeriodAll.
  ///
  /// In ar, this message translates to:
  /// **'الفصل كله'**
  String get reportPeriodAll;

  /// No description provided for @reportPeriodPick.
  ///
  /// In ar, this message translates to:
  /// **'فترة محددة…'**
  String get reportPeriodPick;

  /// No description provided for @reportPeriod.
  ///
  /// In ar, this message translates to:
  /// **'الفترة: من {from} إلى {to}'**
  String reportPeriod(String from, String to);

  /// No description provided for @reportPeriodNote.
  ///
  /// In ar, this message translates to:
  /// **'عمود الغياب للمحاضرات ضمن الفترة فقط، والنسبة للفصل كله.'**
  String get reportPeriodNote;

  /// No description provided for @auditSearch.
  ///
  /// In ar, this message translates to:
  /// **'بحث'**
  String get auditSearch;

  /// No description provided for @auditSearchActive.
  ///
  /// In ar, this message translates to:
  /// **'بحث (مفعّل)'**
  String get auditSearchActive;

  /// No description provided for @auditActor.
  ///
  /// In ar, this message translates to:
  /// **'بريد المستخدم الذي نفّذ العملية'**
  String get auditActor;

  /// No description provided for @auditText.
  ///
  /// In ar, this message translates to:
  /// **'رقم جامعي أو نص'**
  String get auditText;

  /// No description provided for @auditTextHelp.
  ///
  /// In ar, this message translates to:
  /// **'يُبحث في هدف العملية وقيمها قبل وبعد'**
  String get auditTextHelp;

  /// No description provided for @auditAnyDate.
  ///
  /// In ar, this message translates to:
  /// **'كل التواريخ'**
  String get auditAnyDate;

  /// No description provided for @auditClear.
  ///
  /// In ar, this message translates to:
  /// **'مسح'**
  String get auditClear;

  /// No description provided for @auditApply.
  ///
  /// In ar, this message translates to:
  /// **'بحث'**
  String get auditApply;

  /// No description provided for @auditNoMatch.
  ///
  /// In ar, this message translates to:
  /// **'لا نتائج مطابقة.'**
  String get auditNoMatch;

  /// No description provided for @notifTitle.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get notifTitle;

  /// No description provided for @notifCompose.
  ///
  /// In ar, this message translates to:
  /// **'رسالة جديدة'**
  String get notifCompose;

  /// No description provided for @notifMessages.
  ///
  /// In ar, this message translates to:
  /// **'رسائل القسم'**
  String get notifMessages;

  /// No description provided for @notifNoMessages.
  ///
  /// In ar, this message translates to:
  /// **'لا رسائل.'**
  String get notifNoMessages;

  /// No description provided for @notifRequests.
  ///
  /// In ar, this message translates to:
  /// **'طلبات التعديل'**
  String get notifRequests;

  /// No description provided for @notifDecisions.
  ///
  /// In ar, this message translates to:
  /// **'قرارات طلباتك'**
  String get notifDecisions;

  /// No description provided for @notifAlerts.
  ///
  /// In ar, this message translates to:
  /// **'طلبة وصلوا حدّ التنبيه'**
  String get notifAlerts;

  /// No description provided for @notifAlertsOnPhone.
  ///
  /// In ar, this message translates to:
  /// **'تظهر طلبة صفوفك على الهاتف.'**
  String get notifAlertsOnPhone;

  /// No description provided for @notifNoAlerts.
  ///
  /// In ar, this message translates to:
  /// **'لا طلبة في مستوى التنبيه أو أعلى.'**
  String get notifNoAlerts;

  /// No description provided for @notifNew.
  ///
  /// In ar, this message translates to:
  /// **'جديد'**
  String get notifNew;

  /// No description provided for @notifApproved.
  ///
  /// In ar, this message translates to:
  /// **'وافق مسؤول المرحلة على طلبك'**
  String get notifApproved;

  /// No description provided for @notifRejected.
  ///
  /// In ar, this message translates to:
  /// **'رُفض طلبك'**
  String get notifRejected;

  /// No description provided for @notifStageAlerts.
  ///
  /// In ar, this message translates to:
  /// **'{stage}: افتح لعرض الطلبة'**
  String notifStageAlerts(String stage);

  /// No description provided for @notifOpenWarnings.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =1{طالب واحد — فتح النسب والقوائم} =2{طالبان — فتح النسب والقوائم} few{{count} طلبة — فتح النسب والقوائم} other{{count} طالباً — فتح النسب والقوائم}}'**
  String notifOpenWarnings(int count);

  /// No description provided for @notifAudience.
  ///
  /// In ar, this message translates to:
  /// **'إلى'**
  String get notifAudience;

  /// No description provided for @notifToAll.
  ///
  /// In ar, this message translates to:
  /// **'الجميع'**
  String get notifToAll;

  /// No description provided for @notifToTeachers.
  ///
  /// In ar, this message translates to:
  /// **'التدريسيون'**
  String get notifToTeachers;

  /// No description provided for @notifToStageManagers.
  ///
  /// In ar, this message translates to:
  /// **'مسؤولو المراحل'**
  String get notifToStageManagers;

  /// No description provided for @notifToStage.
  ///
  /// In ar, this message translates to:
  /// **'مرحلة محددة'**
  String get notifToStage;

  /// No description provided for @notifMessageTitle.
  ///
  /// In ar, this message translates to:
  /// **'العنوان'**
  String get notifMessageTitle;

  /// No description provided for @notifMessageBody.
  ///
  /// In ar, this message translates to:
  /// **'نص الرسالة'**
  String get notifMessageBody;

  /// No description provided for @notifSend.
  ///
  /// In ar, this message translates to:
  /// **'إرسال'**
  String get notifSend;

  /// No description provided for @notifSent.
  ///
  /// In ar, this message translates to:
  /// **'أُرسلت الرسالة.'**
  String get notifSent;

  /// No description provided for @chartTitle.
  ///
  /// In ar, this message translates to:
  /// **'نسب الغياب'**
  String get chartTitle;

  /// No description provided for @chartHelp.
  ///
  /// In ar, this message translates to:
  /// **'متوسط نسبة غياب الطلبة (من لم يغب يُحسب صفراً) للفصل الحالي. يقرأ إحصائيات كل المراحل، فاعرضه عند الحاجة.'**
  String get chartHelp;

  /// No description provided for @chartShow.
  ///
  /// In ar, this message translates to:
  /// **'عرض الرسم'**
  String get chartShow;

  /// No description provided for @chartByStage.
  ///
  /// In ar, this message translates to:
  /// **'حسب المرحلة'**
  String get chartByStage;

  /// No description provided for @chartByCourse.
  ///
  /// In ar, this message translates to:
  /// **'حسب المادة — {stage}'**
  String chartByCourse(String stage);

  /// No description provided for @chartTapStage.
  ///
  /// In ar, this message translates to:
  /// **'المس مرحلة لعرض موادها.'**
  String get chartTapStage;

  /// No description provided for @chartNoData.
  ///
  /// In ar, this message translates to:
  /// **'لا بيانات بعد.'**
  String get chartNoData;

  /// No description provided for @chartBarTip.
  ///
  /// In ar, this message translates to:
  /// **'متوسط الغياب {mean}٪ · في التنبيه فأعلى: {alert} من {students} طالب'**
  String chartBarTip(String mean, int alert, int students);

  /// No description provided for @missedTitle.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل محاضرة فائتة'**
  String get missedTitle;

  /// No description provided for @missedHelp.
  ///
  /// In ar, this message translates to:
  /// **'لمحاضرة لم تُسجَّل في وقتها، لأي صف في مرحلتك. تُحفظ مباشرة على الخادم (يلزم الاتصال)، وتصل إلى هواتف التدريسيين، وتُحسب في النسب.'**
  String get missedHelp;

  /// No description provided for @missedClass.
  ///
  /// In ar, this message translates to:
  /// **'الصف'**
  String get missedClass;

  /// No description provided for @missedPickClass.
  ///
  /// In ar, this message translates to:
  /// **'اختر الصف'**
  String get missedPickClass;

  /// No description provided for @missedDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ المحاضرة'**
  String get missedDate;

  /// No description provided for @missedLectureNo.
  ///
  /// In ar, this message translates to:
  /// **'ستُحفظ المحاضرة رقم {no} لهذا الصف في هذا اليوم.'**
  String missedLectureNo(int no);

  /// No description provided for @missedHint.
  ///
  /// In ar, this message translates to:
  /// **'اضغط على اسم الطالب لتغيير حالته بالترتيب: حاضر، غائب، متأخر، مُجاز.'**
  String get missedHint;

  /// No description provided for @missedAllPresent.
  ///
  /// In ar, this message translates to:
  /// **'الكل حاضر'**
  String get missedAllPresent;

  /// No description provided for @missedSave.
  ///
  /// In ar, this message translates to:
  /// **'حفظ المحاضرة'**
  String get missedSave;

  /// No description provided for @missedConfirm.
  ///
  /// In ar, this message translates to:
  /// **'ستُحفظ المحاضرة رقم {no} بتاريخ {date} لـ {cls}:\nغائب {absent}، متأخر {late}، مُجاز {excused}، حاضر {present}.\nلا يحذفها بعد ذلك إلا مسؤول المرحلة أو المدير.'**
  String missedConfirm(
    int no,
    String date,
    String cls,
    int absent,
    int late,
    int excused,
    int present,
  );

  /// No description provided for @missedSaved.
  ///
  /// In ar, this message translates to:
  /// **'حُفظت المحاضرة.'**
  String get missedSaved;

  /// No description provided for @missedNoClasses.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد صفوف مُسندة في هذه المرحلة.'**
  String get missedNoClasses;

  /// No description provided for @missedNoStudents.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد طلبة في هذا الصف.'**
  String get missedNoStudents;

  /// No description provided for @dashMissedHelp.
  ///
  /// In ar, this message translates to:
  /// **'لصف لم تُسجَّل محاضرته في وقتها، بأي تاريخ سابق.'**
  String get dashMissedHelp;

  /// No description provided for @yearMissed.
  ///
  /// In ar, this message translates to:
  /// **'السماح بتسجيل محاضرة فائتة'**
  String get yearMissed;

  /// No description provided for @yearMissedOn.
  ///
  /// In ar, this message translates to:
  /// **'مفعّل: يرى مسؤول المرحلة والمدير «تسجيل محاضرة فائتة» في لوحة المرحلة، لأي صف في مرحلته وبأي تاريخ سابق.'**
  String get yearMissedOn;

  /// No description provided for @yearMissedOff.
  ///
  /// In ar, this message translates to:
  /// **'معطّل: المحاضرة التي فات موعد إقفالها تُصحَّح بطلبات التعديل فقط.'**
  String get yearMissedOff;

  /// No description provided for @missedDisabled.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل المحاضرات الفائتة معطّل. يفعّله المدير من «إعدادات السنة».'**
  String get missedDisabled;

  /// No description provided for @yearSystems.
  ///
  /// In ar, this message translates to:
  /// **'نظام المراحل'**
  String get yearSystems;

  /// No description provided for @yearSystemsHelp.
  ///
  /// In ar, this message translates to:
  /// **'المرحلة الفصلية: مواد كل فصل تُحسب نسبتها على أسابيع الفصل. المرحلة السنوية: موادها تستمر طوال السنة وتُحسب نسبتها على أسابيع السنة. العتبات نفسها للنظامين.'**
  String get yearSystemsHelp;

  /// No description provided for @yearSystemSemester.
  ///
  /// In ar, this message translates to:
  /// **'فصلي'**
  String get yearSystemSemester;

  /// No description provided for @yearSystemAnnual.
  ///
  /// In ar, this message translates to:
  /// **'سنوي'**
  String get yearSystemAnnual;

  /// No description provided for @yearWeeksYear.
  ///
  /// In ar, this message translates to:
  /// **'عدد أسابيع السنة (للمراحل السنوية)'**
  String get yearWeeksYear;

  /// No description provided for @yearWeeksYearHelp.
  ///
  /// In ar, this message translates to:
  /// **'مثلاً 30: مادة سنوية بثلاث وحدات = 90 محاضرة في السنة.'**
  String get yearWeeksYearHelp;

  /// No description provided for @assignmentsCourseInfoAnnual.
  ///
  /// In ar, this message translates to:
  /// **'{code} · {units} وحدات · سنوية'**
  String assignmentsCourseInfoAnnual(String code, String units);

  /// No description provided for @activityAction.
  ///
  /// In ar, this message translates to:
  /// **'متابعة التدريسيين'**
  String get activityAction;

  /// No description provided for @activityTitle.
  ///
  /// In ar, this message translates to:
  /// **'متابعة التدريسيين'**
  String get activityTitle;

  /// No description provided for @activityHelp.
  ///
  /// In ar, this message translates to:
  /// **'آخر مرة فتح فيها كل تدريسي البرنامج، وآخر مرة رفع هاتفه حضوراً (تسجيل محاضرة أو تعديلها). تبدأ المتابعة من تحديث البرنامج هذا، فمن لم يفتحه بعد يظهر «لم يدخل بعد». المسّ اسماً لتفاصيله ومحاضراته وسجلات صفوفه ولإرسال إشعار.'**
  String get activityHelp;

  /// No description provided for @activityAll.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get activityAll;

  /// No description provided for @activityToday.
  ///
  /// In ar, this message translates to:
  /// **'اليوم'**
  String get activityToday;

  /// No description provided for @activityRecent.
  ///
  /// In ar, this message translates to:
  /// **'خلال 7 أيام'**
  String get activityRecent;

  /// No description provided for @activityIdle.
  ///
  /// In ar, this message translates to:
  /// **'غير نشط'**
  String get activityIdle;

  /// No description provided for @activityNever.
  ///
  /// In ar, this message translates to:
  /// **'لم يدخل بعد'**
  String get activityNever;

  /// No description provided for @activityEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد تدريسيون في هذا التصنيف.'**
  String get activityEmpty;

  /// No description provided for @activityNeverSeen.
  ///
  /// In ar, this message translates to:
  /// **'لم يدخل بعد'**
  String get activityNeverSeen;

  /// No description provided for @activityLastSeen.
  ///
  /// In ar, this message translates to:
  /// **'آخر دخول: {when}'**
  String activityLastSeen(String when);

  /// No description provided for @activityNoUpload.
  ///
  /// In ar, this message translates to:
  /// **'لم يرفع حضوراً بعد'**
  String get activityNoUpload;

  /// No description provided for @activityLastUpload.
  ///
  /// In ar, this message translates to:
  /// **'آخر رفع للحضور: {when}'**
  String activityLastUpload(String when);

  /// No description provided for @activityDevice.
  ///
  /// In ar, this message translates to:
  /// **'الجهاز والإصدار: {device}'**
  String activityDevice(String device);

  /// No description provided for @activityLectures.
  ///
  /// In ar, this message translates to:
  /// **'المحاضرات التي فتحها: {count}'**
  String activityLectures(int count);

  /// No description provided for @activityLectureNo.
  ///
  /// In ar, this message translates to:
  /// **'المحاضرة {no}'**
  String activityLectureNo(int no);

  /// No description provided for @activityLecturesError.
  ///
  /// In ar, this message translates to:
  /// **'تعذّرت قراءة المحاضرات.'**
  String get activityLecturesError;

  /// No description provided for @activitySendMessage.
  ///
  /// In ar, this message translates to:
  /// **'إرسال إشعار'**
  String get activitySendMessage;

  /// No description provided for @activityMessageShown.
  ///
  /// In ar, this message translates to:
  /// **'إرسال إشعار للمعروضين ({count})'**
  String activityMessageShown(int count);

  /// No description provided for @activityRecipients.
  ///
  /// In ar, this message translates to:
  /// **'{count} تدريسياً'**
  String activityRecipients(int count);

  /// No description provided for @activityTo.
  ///
  /// In ar, this message translates to:
  /// **'إلى: {names}'**
  String activityTo(String names);

  /// No description provided for @activityInAppOnly.
  ///
  /// In ar, this message translates to:
  /// **'يظهر في «الإشعارات» داخل البرنامج مع شارة في الرئيسية عند فتحه، ولا يصل كإشعار هاتف والبرنامج مغلق.'**
  String get activityInAppOnly;

  /// No description provided for @activitySent.
  ///
  /// In ar, this message translates to:
  /// **'أُرسل الإشعار إلى {count}.'**
  String activitySent(int count);

  /// No description provided for @agoJustNow.
  ///
  /// In ar, this message translates to:
  /// **'الآن'**
  String get agoJustNow;

  /// No description provided for @agoMinutes.
  ///
  /// In ar, this message translates to:
  /// **'منذ {n} دقيقة'**
  String agoMinutes(int n);

  /// No description provided for @agoHours.
  ///
  /// In ar, this message translates to:
  /// **'منذ {n} ساعة'**
  String agoHours(int n);

  /// No description provided for @agoDays.
  ///
  /// In ar, this message translates to:
  /// **'منذ {n} يوم'**
  String agoDays(int n);

  /// No description provided for @notifToMe.
  ///
  /// In ar, this message translates to:
  /// **'رسالة خاصة'**
  String get notifToMe;

  /// No description provided for @activitySentPush.
  ///
  /// In ar, this message translates to:
  /// **'أُرسل الإشعار إلى {count}، ووصل إلى {phones} هاتف.'**
  String activitySentPush(int count, int phones);

  /// No description provided for @activitySentNoPush.
  ///
  /// In ar, this message translates to:
  /// **'أُرسل الإشعار إلى {count} داخل البرنامج، وتعذّر إرساله إلى الهواتف الآن.'**
  String activitySentNoPush(int count);

  /// No description provided for @activityPushOn.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات مفعّلة'**
  String get activityPushOn;

  /// No description provided for @activityPushOnLong.
  ///
  /// In ar, this message translates to:
  /// **'إشعارات الهاتف مفعّلة: تصله الرسائل والبرنامج مغلق.'**
  String get activityPushOnLong;

  /// No description provided for @activityPushOff.
  ///
  /// In ar, this message translates to:
  /// **'إشعارات الهاتف غير مفعّلة (لم يثبّت الإصدار 1.4 أو لم يسمح بالإشعارات).'**
  String get activityPushOff;

  /// No description provided for @activityPushNote.
  ///
  /// In ar, this message translates to:
  /// **'يصل إشعاراً على هاتف من ثبّت الإصدار 1.4 وسمح بالإشعارات، ويظهر للجميع في «الإشعارات» داخل البرنامج.'**
  String get activityPushNote;

  /// No description provided for @reportVerifyHint.
  ///
  /// In ar, this message translates to:
  /// **'امسح الرمز للتحقق من صحة الوثيقة، أو أدخل رمز التحقق:'**
  String get reportVerifyHint;

  /// No description provided for @annAction.
  ///
  /// In ar, this message translates to:
  /// **'إعلانات القسم'**
  String get annAction;

  /// No description provided for @annTitle.
  ///
  /// In ar, this message translates to:
  /// **'إعلانات القسم'**
  String get annTitle;

  /// No description provided for @annHelp.
  ///
  /// In ar, this message translates to:
  /// **'تظهر هذه الإعلانات للجميع بلا تسجيل دخول في صفحة الإعلانات العامة، وهي التي يفتحها رمز QR المعلّق في القسم.'**
  String get annHelp;

  /// No description provided for @annEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا إعلانات بعد.'**
  String get annEmpty;

  /// No description provided for @annAdd.
  ///
  /// In ar, this message translates to:
  /// **'إعلان جديد'**
  String get annAdd;

  /// No description provided for @annEdit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الإعلان'**
  String get annEdit;

  /// No description provided for @annFieldTitle.
  ///
  /// In ar, this message translates to:
  /// **'العنوان'**
  String get annFieldTitle;

  /// No description provided for @annFieldBody.
  ///
  /// In ar, this message translates to:
  /// **'نص الإعلان'**
  String get annFieldBody;

  /// No description provided for @annSaved.
  ///
  /// In ar, this message translates to:
  /// **'حُفظ الإعلان.'**
  String get annSaved;

  /// No description provided for @annDeleteTitle.
  ///
  /// In ar, this message translates to:
  /// **'حذف الإعلان؟'**
  String get annDeleteTitle;

  /// No description provided for @annDeleteBody.
  ///
  /// In ar, this message translates to:
  /// **'يختفي من صفحة الإعلانات العامة فوراً.'**
  String get annDeleteBody;

  /// No description provided for @annDeleted.
  ///
  /// In ar, this message translates to:
  /// **'حُذف الإعلان.'**
  String get annDeleted;

  /// No description provided for @annQr.
  ///
  /// In ar, this message translates to:
  /// **'رمز صفحة الإعلانات'**
  String get annQr;

  /// No description provided for @annQrHelp.
  ///
  /// In ar, this message translates to:
  /// **'علّق هذا الرمز في القسم: من يمسحه بكاميرا الهاتف يفتح صفحة الإعلانات.'**
  String get annQrHelp;

  /// No description provided for @annCopyLink.
  ///
  /// In ar, this message translates to:
  /// **'نسخ الرابط'**
  String get annCopyLink;

  /// No description provided for @annLinkCopied.
  ///
  /// In ar, this message translates to:
  /// **'نُسخ الرابط.'**
  String get annLinkCopied;

  /// No description provided for @annPoster.
  ///
  /// In ar, this message translates to:
  /// **'ملصق PDF للطباعة'**
  String get annPoster;

  /// No description provided for @annPosterTitle.
  ///
  /// In ar, this message translates to:
  /// **'إعلانات القسم'**
  String get annPosterTitle;

  /// No description provided for @annPosterLine.
  ///
  /// In ar, this message translates to:
  /// **'امسح الرمز بكاميرا الهاتف لعرض آخر الإعلانات'**
  String get annPosterLine;

  /// No description provided for @annEdited.
  ///
  /// In ar, this message translates to:
  /// **'عُدِّل {date}'**
  String annEdited(String date);

  /// No description provided for @releaseAction.
  ///
  /// In ar, this message translates to:
  /// **'إصدار التطبيق'**
  String get releaseAction;

  /// No description provided for @releaseTitle.
  ///
  /// In ar, this message translates to:
  /// **'إصدار التطبيق'**
  String get releaseTitle;

  /// No description provided for @releaseHelp.
  ///
  /// In ar, this message translates to:
  /// **'بعد نشر APK جديد، اكتب رقمه ورابط تنزيله هنا: كل من نسخته أقدم يرى لافتة «تحديث جديد» مع زر التنزيل. الرقع الصغيرة (Shorebird) تصل وحدها ولا تحتاج هذا.'**
  String get releaseHelp;

  /// No description provided for @releaseInstalled.
  ///
  /// In ar, this message translates to:
  /// **'نسختك على هذا الجهاز: {version}'**
  String releaseInstalled(String version);

  /// No description provided for @releaseLatest.
  ///
  /// In ar, this message translates to:
  /// **'أحدث إصدار (مثل 1.4.0)'**
  String get releaseLatest;

  /// No description provided for @releaseMinimum.
  ///
  /// In ar, this message translates to:
  /// **'أقدم إصدار مسموح (اختياري)'**
  String get releaseMinimum;

  /// No description provided for @releaseMinimumHelp.
  ///
  /// In ar, this message translates to:
  /// **'من نسخته أقدم من هذا لا يستطيع استعمال التطبيق حتى يحدّث. اتركه فارغاً ما لم تتغير القواعد بشكل يكسر النسخ القديمة.'**
  String get releaseMinimumHelp;

  /// No description provided for @releaseAndroidUrl.
  ///
  /// In ar, this message translates to:
  /// **'رابط تنزيل Android'**
  String get releaseAndroidUrl;

  /// No description provided for @releaseIosUrl.
  ///
  /// In ar, this message translates to:
  /// **'رابط iOS (اختياري)'**
  String get releaseIosUrl;

  /// No description provided for @releaseUrlHelp.
  ///
  /// In ar, this message translates to:
  /// **'رابط عام يعمل بلا تسجيل دخول، مثل رابط Google Drive بمشاركة «أي شخص لديه الرابط».'**
  String get releaseUrlHelp;

  /// No description provided for @releaseNotes.
  ///
  /// In ar, this message translates to:
  /// **'ما الجديد (يظهر في اللافتة)'**
  String get releaseNotes;

  /// No description provided for @releasePreview.
  ///
  /// In ar, this message translates to:
  /// **'بعد الحفظ: من نسخته أقدم من {latest} يرى لافتة التحديث.'**
  String releasePreview(String latest);

  /// No description provided for @releasePreviewRequired.
  ///
  /// In ar, this message translates to:
  /// **'ومن نسخته أقدم من {minimum} يُمنع من استعمال التطبيق حتى يحدّث.'**
  String releasePreviewRequired(String minimum);

  /// No description provided for @releaseSaved.
  ///
  /// In ar, this message translates to:
  /// **'حُفظ. تظهر اللافتة عند فتح التطبيق.'**
  String get releaseSaved;

  /// No description provided for @releaseConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'إيقاف النسخ القديمة؟'**
  String get releaseConfirmTitle;

  /// No description provided for @releaseConfirmBody.
  ///
  /// In ar, this message translates to:
  /// **'كل من نسخته أقدم من {minimum} لن يستطيع استعمال التطبيق حتى يثبّت التحديث، وقد تبقى عنده سجلات غير مرفوعة حتى يحدّث. تأكد أن الرابط يعمل قبل الحفظ.'**
  String releaseConfirmBody(String minimum);

  /// No description provided for @releaseLatestMissing.
  ///
  /// In ar, this message translates to:
  /// **'اكتب رقم أحدث إصدار.'**
  String get releaseLatestMissing;

  /// No description provided for @releaseVersionInvalid.
  ///
  /// In ar, this message translates to:
  /// **'الصيغة: أرقام بنقاط، مثل 1.4.0'**
  String get releaseVersionInvalid;

  /// No description provided for @releaseMinimumAboveLatest.
  ///
  /// In ar, this message translates to:
  /// **'أقدم إصدار مسموح لا يكون أحدث من أحدث إصدار.'**
  String get releaseMinimumAboveLatest;

  /// No description provided for @releaseUrlInvalid.
  ///
  /// In ar, this message translates to:
  /// **'الرابط يجب أن يبدأ بـ https://'**
  String get releaseUrlInvalid;

  /// No description provided for @releaseOpenLink.
  ///
  /// In ar, this message translates to:
  /// **'تجربة الرابط'**
  String get releaseOpenLink;

  /// No description provided for @activitySearch.
  ///
  /// In ar, this message translates to:
  /// **'ابحث باسم التدريسي أو بريده'**
  String get activitySearch;

  /// No description provided for @coursePanelAction.
  ///
  /// In ar, this message translates to:
  /// **'لوحة المادة'**
  String get coursePanelAction;

  /// No description provided for @coursePanelExport.
  ///
  /// In ar, this message translates to:
  /// **'تنزيل لوحة المادة PDF أو Excel'**
  String get coursePanelExport;

  /// No description provided for @coursePanelInfo.
  ///
  /// In ar, this message translates to:
  /// **'المعلومات'**
  String get coursePanelInfo;

  /// No description provided for @coursePanelLectures.
  ///
  /// In ar, this message translates to:
  /// **'المحاضرات ({count})'**
  String coursePanelLectures(int count);

  /// No description provided for @coursePanelStudents.
  ///
  /// In ar, this message translates to:
  /// **'الطلبة ({count})'**
  String coursePanelStudents(int count);

  /// No description provided for @coursePanelMissing.
  ///
  /// In ar, this message translates to:
  /// **'لم تعد هذه المادة موجودة.'**
  String get coursePanelMissing;

  /// No description provided for @coursePanelWithPractical.
  ///
  /// In ar, this message translates to:
  /// **'نظري وعملي ({count} مجاميع)'**
  String coursePanelWithPractical(int count);

  /// No description provided for @coursePanelTheoryOnly.
  ///
  /// In ar, this message translates to:
  /// **'نظري فقط'**
  String get coursePanelTheoryOnly;

  /// No description provided for @coursePanelLastLecture.
  ///
  /// In ar, this message translates to:
  /// **'آخر محاضرة: {date}'**
  String coursePanelLastLecture(String date);

  /// No description provided for @coursePanelClasses.
  ///
  /// In ar, this message translates to:
  /// **'الصفوف والتدريسيون'**
  String get coursePanelClasses;

  /// No description provided for @coursePanelClassesHelp.
  ///
  /// In ar, this message translates to:
  /// **'المس صفاً لعرض سجله وتنزيله.'**
  String get coursePanelClassesHelp;

  /// No description provided for @coursePanelNoClasses.
  ///
  /// In ar, this message translates to:
  /// **'لا تدريسي مُسنَد لهذه المادة بعد.'**
  String get coursePanelNoClasses;

  /// No description provided for @coursePanelNoTeacher.
  ///
  /// In ar, this message translates to:
  /// **'بلا تدريسي'**
  String get coursePanelNoTeacher;

  /// No description provided for @coursePanelLectureCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} محاضرة'**
  String coursePanelLectureCount(int count);

  /// No description provided for @coursePanelAllPresent.
  ///
  /// In ar, this message translates to:
  /// **'لا غائب في هذه المحاضرة.'**
  String get coursePanelAllPresent;

  /// No description provided for @coursePanelSearch.
  ///
  /// In ar, this message translates to:
  /// **'ابحث باسم الطالب أو رقمه'**
  String get coursePanelSearch;

  /// No description provided for @coursePanelReportTitle.
  ///
  /// In ar, this message translates to:
  /// **'لوحة مادة {name}'**
  String coursePanelReportTitle(String name);

  /// No description provided for @coursePanelStudentsSheet.
  ///
  /// In ar, this message translates to:
  /// **'الطلبة'**
  String get coursePanelStudentsSheet;

  /// No description provided for @coursePanelLecturesSheet.
  ///
  /// In ar, this message translates to:
  /// **'المحاضرات'**
  String get coursePanelLecturesSheet;

  /// No description provided for @coursePanelGroup.
  ///
  /// In ar, this message translates to:
  /// **'المجموعة'**
  String get coursePanelGroup;

  /// No description provided for @coursePanelDate.
  ///
  /// In ar, this message translates to:
  /// **'التاريخ'**
  String get coursePanelDate;

  /// No description provided for @coursePanelLectureNo.
  ///
  /// In ar, this message translates to:
  /// **'رقمها'**
  String get coursePanelLectureNo;

  /// No description provided for @coursePanelClass.
  ///
  /// In ar, this message translates to:
  /// **'الصف'**
  String get coursePanelClass;

  /// No description provided for @coursePanelTeacher.
  ///
  /// In ar, this message translates to:
  /// **'التدريسي'**
  String get coursePanelTeacher;

  /// No description provided for @homeGroupsList.
  ///
  /// In ar, this message translates to:
  /// **'المجاميع: {groups}'**
  String homeGroupsList(String groups);

  /// No description provided for @homePickGroup.
  ///
  /// In ar, this message translates to:
  /// **'اختر المجموعة لتسجيل حضورها أو عرض سجلها.'**
  String get homePickGroup;

  /// No description provided for @fixDeleteLectures.
  ///
  /// In ar, this message translates to:
  /// **'محاضرات'**
  String get fixDeleteLectures;

  /// No description provided for @fixAllStages.
  ///
  /// In ar, this message translates to:
  /// **'كل المراحل'**
  String get fixAllStages;

  /// No description provided for @fixLecturesPickDays.
  ///
  /// In ar, this message translates to:
  /// **'اختر اليوم أو الأيام'**
  String get fixLecturesPickDays;

  /// No description provided for @fixLecturesDays.
  ///
  /// In ar, this message translates to:
  /// **'من {from} إلى {to}'**
  String fixLecturesDays(String from, String to);

  /// No description provided for @fixLecturesTooLong.
  ///
  /// In ar, this message translates to:
  /// **'اختر {days} يوماً على الأكثر.'**
  String fixLecturesTooLong(int days);

  /// No description provided for @fixDeleteLecturesHelp.
  ///
  /// In ar, this message translates to:
  /// **'تُحذف كل المحاضرات المسجلة في هذه الأيام للمرحلة والمادة المختارتين (أو للكل) مع حضورها، وتُزال من نسب الطلبة، وتُرفض طلبات التعديل المعلّقة عليها. لأيام أُدخلت للتجربة أو بالخطأ. لا يمكن التراجع، فخذ نسخة احتياطية قبلها إن شئت.'**
  String get fixDeleteLecturesHelp;

  /// No description provided for @fixLecturesPhonesNote.
  ///
  /// In ar, this message translates to:
  /// **'تختفي من هاتف التدريسي حين يفتح الصف (التسجيل أو السجل)، إلا محاضرة لها حفظ غير مرفوع على هاتفه.'**
  String get fixLecturesPhonesNote;

  /// No description provided for @fixLecturesList.
  ///
  /// In ar, this message translates to:
  /// **'المحاضرات التي ستُحذف ({count})'**
  String fixLecturesList(int count);

  /// No description provided for @fixLecturesRejectNote.
  ///
  /// In ar, this message translates to:
  /// **'حُذفت المحاضرة من الإدارة.'**
  String get fixLecturesRejectNote;

  /// No description provided for @fixLecturesCourse.
  ///
  /// In ar, this message translates to:
  /// **'المادة'**
  String get fixLecturesCourse;

  /// No description provided for @fixAllCourses.
  ///
  /// In ar, this message translates to:
  /// **'كل المواد'**
  String get fixAllCourses;

  /// No description provided for @studentsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الطلبة'**
  String get studentsTitle;

  /// No description provided for @studentsAdd.
  ///
  /// In ar, this message translates to:
  /// **'إضافة طالب'**
  String get studentsAdd;

  /// No description provided for @studentsEdit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل طالب'**
  String get studentsEdit;

  /// No description provided for @studentsRequired.
  ///
  /// In ar, this message translates to:
  /// **'اكتب الرقم الجامعي والاسم.'**
  String get studentsRequired;

  /// No description provided for @studentsNameHint.
  ///
  /// In ar, this message translates to:
  /// **'يُفضَّل الاسم الرباعي.'**
  String get studentsNameHint;

  /// No description provided for @studentsNoSection.
  ///
  /// In ar, this message translates to:
  /// **'بلا شعبة'**
  String get studentsNoSection;

  /// No description provided for @studentsCarryOverHelp.
  ///
  /// In ar, this message translates to:
  /// **'المحمَّل يحضر الامتحانات فقط، فلا يظهر في قوائم الحضور ولا النسب.'**
  String get studentsCarryOverHelp;

  /// No description provided for @studentsGroupOf.
  ///
  /// In ar, this message translates to:
  /// **'مجموعة العملي: {course}'**
  String studentsGroupOf(String course);

  /// No description provided for @studentsNoGroup.
  ///
  /// In ar, this message translates to:
  /// **'بلا مجموعة (تُحدَّد لاحقاً)'**
  String get studentsNoGroup;

  /// No description provided for @studentsPhonesNote.
  ///
  /// In ar, this message translates to:
  /// **'يظهر الطالب في هواتف التدريسيين بعد مزامنتها (مرة يومياً، أو فوراً بـ«مزامنة الآن»).'**
  String get studentsPhonesNote;

  /// No description provided for @studentsAdded.
  ///
  /// In ar, this message translates to:
  /// **'أُضيف {name}.'**
  String studentsAdded(String name);

  /// No description provided for @studentsSaved.
  ///
  /// In ar, this message translates to:
  /// **'حُفظت التعديلات.'**
  String get studentsSaved;

  /// No description provided for @studentsExists.
  ///
  /// In ar, this message translates to:
  /// **'هذا الرقم الجامعي مسجّل باسم {name} في {stage}.'**
  String studentsExists(String name, String stage);

  /// No description provided for @studentsElsewhere.
  ///
  /// In ar, this message translates to:
  /// **'تعذّرت الإضافة: الرقم الجامعي غالباً مسجّل في مرحلة أخرى. راجع المدير.'**
  String get studentsElsewhere;

  /// No description provided for @coursePanelDeleteLecture.
  ///
  /// In ar, this message translates to:
  /// **'حذف هذه المحاضرة'**
  String get coursePanelDeleteLecture;

  /// No description provided for @coursePanelDeleteLectureBody.
  ///
  /// In ar, this message translates to:
  /// **'تُحذف المحاضرة «{lecture}» مع حضورها، وتخرج من نسب الطلبة، وتختفي من هاتف التدريسي عند فتحه الصف. لا يمكن التراجع.'**
  String coursePanelDeleteLectureBody(String lecture);

  /// No description provided for @coursePanelLectureDeleted.
  ///
  /// In ar, this message translates to:
  /// **'حُذفت المحاضرة.'**
  String get coursePanelLectureDeleted;

  /// No description provided for @coursePanelLectureNotFound.
  ///
  /// In ar, this message translates to:
  /// **'لم تُعثر على هذه المحاضرة على الخادم (ربما حُذفت من قبل). أُعيد تحميل اللوحة.'**
  String get coursePanelLectureNotFound;
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
