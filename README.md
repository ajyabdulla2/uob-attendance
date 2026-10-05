# نظام الحضور والغياب — قسم علوم الحاسوب، جامعة البصرة

تطبيق Flutter (Android و iOS و Web) لتسجيل حضور الطلبة، يعمل على خطة Firebase المجانية (Spark): Authentication + Cloud Firestore فقط.

- المواصفات: [`docs/SPEC.md`](docs/SPEC.md)
- القرارات التقنية ودليل المطوّر: [`CLAUDE.md`](CLAUDE.md)

## الإعداد لأول مرة

1. **مشروع Firebase** بحساب Google خاص بالقسم (خطة Spark).
2. **Authentication** → Sign-in method → فعّل **Email/Password**. (اترك «إنشاء الحسابات» مفعّلاً: التدريسي يفعّل حسابه بنفسه بعد أن تضيفه الإدارة.)
3. **Firestore Database** → أنشئ قاعدة بيانات في وضع الإنتاج.
4. **ربط التطبيق** (يولّد ملفات المفاتيح، وكلها مستثناة من git):
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure --platforms=android,ios,web
   ```
5. **نشر قواعد الأمان**:
   ```bash
   firebase use --add            # اختر المشروع
   firebase deploy --only firestore:rules,firestore:indexes
   ```
6. **أول مدير عام**: في Firestore Console أنشئ المجموعة `users` ووثيقة معرّفها بريدك **بأحرف صغيرة** وحقولها:
   | الحقل | النوع | القيمة |
   | --- | --- | --- |
   | `email` | string | البريد نفسه (أحرف صغيرة) |
   | `name` | string | اسمك |
   | `roles` | array | `superAdmin`, `teacher` |
   | `stageScopes` | array | فارغة |
   | `teachingStages` | array | فارغة |
   | `active` | boolean | `true` |
   | `departmentId` | string | `cs` |

   ثم في التطبيق: «أول مرة؟ فعّل حسابك» بالبريد نفسه → افتح رسالة التأكيد → «أكّدت بريدي».
7. من الرئيسية اضغط **«تهيئة الآن»** لإنشاء المراحل الثمان والسنة الدراسية، ثم استورد التدريسيين والمواد والطلبة من **الاستيراد**، واربط التدريسيين من **الربط**.
8. بعدها لا حاجة إلى Firebase Console للحسابات: من **الحسابات** أضف حساباً أو امنح صلاحية (مسؤول مرحلة، مدير ثانٍ) أو أوقف حساباً. ومن فعّل حسابه قبل أن تضيفه الإدارة يرسل **طلب انضمام** من التطبيق، فتقبله من **الحسابات** ويدخل تلقائياً.

## الإصدار والتوزيع (Android)

يُبنى ملف APK على خوادم GitHub، فلا حاجة لـ Android Studio. التفاصيل وقاعدة رقم الإصدار في [`CLAUDE.md`](CLAUDE.md#البناء-والنشر-والتحديثات).

1. **مفتاح التوقيع، مرة واحدة فقط** (احفظه مع كلمات المرور في مكان آمن؛ ضياعه يعني أن المستخدمين سيحذفون التطبيق ليحدّثوه، فتضيع بياناتهم غير المرفوعة):
   ```bash
   keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   base64 -w0 upload-keystore.jks          # macOS: base64 -i upload-keystore.jks
   ```
2. أضف الأسرار في GitHub ← Settings ← Secrets and variables ← Actions:
   `ANDROID_KEYSTORE_B64` و`ANDROID_KEYSTORE_PASSWORD` و`ANDROID_KEY_ALIAS` و`ANDROID_KEY_PASSWORD` (في ملفات PKCS12 يساوي كلمة مرور الملف) و`FIREBASE_OPTIONS_DART_B64` (ناتج `base64 -w0 lib/firebase_options.dart`)، و`GOOGLE_SERVICES_JSON_B64` إن أنشأ flutterfire الملف.
   على Windows (PowerShell) يُنسخ ناتج base64 لأي ملف مباشرة:
   ```powershell
   [Convert]::ToBase64String([IO.File]::ReadAllBytes("lib\firebase_options.dart")) | Set-Clipboard
   ```
3. لكل إصدار: ارفع `version` في `pubspec.yaml`، ثم:
   ```bash
   git tag v1.1.0 && git push origin v1.1.0
   ```
   فيبني GitHub ملف APK موقّعاً ويضعه في صفحة **Releases**.
4. وزّع الرابط، ثم في Firestore أنشئ أو حدّث الوثيقة `config/app` بالحقول: `latestVersion: "1.1.0"` و`androidUrl: "<الرابط>"` و`notes`. ستظهر للمستخدمين رسالة «إصدار جديد متاح». ولإيقاف نسخة قديمة غير متوافقة اضبط `minVersion`.
   إن كان المستودع **خاصاً** فملفات Releases تتطلب حساب GitHub؛ نزّل الـ APK منها وارفعه إلى Google Drive (رابط عام) وضع ذلك الرابط في `androidUrl`.

**فحص الإعداد**: من Actions شغّل **Setup check** بعد إضافة الأسرار أو تغييرها؛ يتحقق من الأسرار (دون إظهارها) ومن مشروع Firebase، ويكتب تقريراً بما ينقص.

**النشر على Firebase** (القواعد ونسخة الويب): من Actions شغّل **Deploy Firebase**. لا تُنشَر القواعد إلا بعد نجاح اختباراتها. يحتاج المتغير `FIREBASE_PROJECT_ID` والسر `FIREBASE_SERVICE_ACCOUNT_JSON`.

**صفحة الخصوصية**: `web/privacy.html` تظهر على `https://<المشروع>.web.app/privacy.html`، وتطلبها متاجر Google Play وApp Store. النص الحالي مسودة تحتاج اعتماد القسم وبريد التواصل.

## التشغيل والتطوير

```bash
flutter pub get
flutter run                                   # جهاز Android/iOS أو Chrome
flutter run --dart-define=USE_FIREBASE_EMULATOR=true   # مع محاكيات Firebase المحلية
./tool/check_all.sh                           # التحليل + الاختبارات + اختبارات القواعد
flutter build web --release && firebase deploy --only hosting   # لوحة الويب (اختياري)
```

لاستعمال قاعدة البيانات المحلية على الويب نفّذ `./tool/build_drift_web.sh` مرة واحدة.

## الخط

خط [Cairo](https://github.com/Gue3bara/Cairo) مضمَّن تحت رخصة SIL Open Font License 1.1 (`assets/fonts/cairo/OFL.txt`).
