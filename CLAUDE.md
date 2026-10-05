# CLAUDE.md — نظام حضور طلبة قسم علوم الحاسوب، جامعة البصرة

المرجع الوظيفي الكامل: [`docs/SPEC.md`](docs/SPEC.md). هذا الملف يلخّص **القرارات التقنية** و**طريقة العمل في بيئة Claude Code السحابية** لتعتمد عليه الجلسات القادمة. حدّثه عند اتخاذ قرار جديد.

## حالة المراحل

| المرحلة | الحالة |
| --- | --- |
| 1 — الأساس (المشروع، RTL/Cairo/الوضع الليلي، الدخول، النماذج، القواعد واختباراتها، الاستيراد، شاشة الربط) | ✅ منجزة |
| 2 — تسجيل الحضور + محرك المزامنة (outbox → Firestore) + تحديث `stats` + أداة تصحيح البيانات | ✅ منجزة |
| 3 — الإجازات، القوائم والإنذارات، طلبات التعديل | ⏳ التالية |
| 4 — التقارير PDF/Excel، النسخ الاحتياطي، سجل التدقيق، لوحة القسم | — |

نماذج كل المجموعات وقواعد أمانها **موجودة مسبقاً** (حتى لمراحل 2–4)؛ المراحل القادمة تبني الواجهات والمنطق فوقها.

---

## تشغيل Flutter في هذه البيئة (Claude Code cloud)

```bash
source tool/cloud_setup.sh   # يثبّت Flutter 3.47.6 في /opt/flutter-sdk إن لم يوجد + pub get + npm + محاكي Firestore
./tool/check_all.sh          # analyze + flutter test + اختبارات القواعد على المحاكي
```

- Flutter **غير مثبَّت مسبقاً** في الحاوية؛ يُنزَّل من `storage.googleapis.com` (مسموح). أضف `export PATH="/opt/flutter-sdk/flutter/bin:$PATH"` في كل أمر Bash (الصدفة لا تحتفظ بالمتغيرات).
- النطاقات **المحجوبة** بسياسة الشبكة (403):
  - `github.com` لغير هذا المستودع → لا تُنزَّل ثنائيات `sqlite3` الجاهزة ولا `sqlite3.wasm`.
  - `dl.google.com` → لا Android SDK، فلا يمكن بناء APK هنا.
  - `www.gstatic.com` → حزمة Firebase JS للويب لا تُحمَّل، فلا يمكن تشغيل تطبيق الويب مع Firebase داخل الحاوية (البناء نفسه ينجح).
  - `firebase-public.firebaseio.com` → تحذير MOTD من firebase CLI فقط، غير مؤثر.
  - `*.shorebird.dev` → لا يمكن تثبيت Shorebird أو اختباره هنا (يعمل على جهازك أو في GitHub Actions).
- البناء الذي لا يمكن هنا (APK) يتم على **GitHub Actions**؛ بعد الدفع راقب النتيجة بأدوات GitHub MCP (`actions_list`, `get_job_logs`).
- المسموح: `pub.dev`، `registry.npmjs.org`، `storage.googleapis.com` (Flutter + jar المحاكي)، `fonts.googleapis.com`/`fonts.gstatic.com`، `raw.githubusercontent.com`، Maven.
- **sqlite3 / Drift في الاختبارات**: `pubspec.yaml` يضبط `hooks.user_defines.sqlite3.source` على `linux: system` (يستعمل `libsqlite3.so` من النظام) و`default: sqlite3` لبقية المنصات. Linux ليس منصة شحن للتطبيق، فهذا لا يمس Android/iOS.
- Java 21 و`firebase` CLI (15.x) مثبّتان. المحاكي: `firebase emulators:exec --only firestore --project demo-uob-attendance "npm --prefix rules-tests test"`.
- لا يوجد `gh`؛ استعمل أدوات GitHub MCP. التطوير على الفرع المحدد في تعليمات الجلسة.

### أوامر شائعة

| الغرض | الأمر |
| --- | --- |
| ملف Firebase المؤقت (مطلوب قبل analyze/test/build) | `./tool/ensure_firebase_options.sh` |
| التحليل | `flutter analyze` (يجب أن يكون نظيفاً) |
| الاختبارات | `flutter test --timeout 120s` |
| اختبارات القواعد | `cd rules-tests && npm run test:emulator` |
| توليد Drift بعد تعديل الجداول | `dart run build_runner build` (الملف `app_database.g.dart` مُلتزَم في المستودع) |
| توليد الترجمة بعد تعديل ARB | `flutter gen-l10n` (الملفات المولَّدة مُلتزَمة) |
| بناء الويب | `flutter build web --release` |
| ملفات Drift للويب | `./tool/build_drift_web.sh` (يحتاج github.com — نفّذه على جهاز المطوّر) |
| أيقونات التطبيق (Android/iOS/الويب) بعد تعديل التصميم | `./tool/build_icons.sh` (Chromium + ImageMagick، متوفران هنا) ثم التزم الملفات المولَّدة؛ المعاينة في `build/icon_preview.png` |
| فحص سير عمل GitHub | `go install github.com/rhysd/actionlint/cmd/actionlint@latest && ~/go/bin/actionlint` |

---

## البنية

```
lib/
  main.dart, app.dart          تهيئة Firebase (+ --dart-define=USE_FIREBASE_EMULATOR=true) و MaterialApp.router
  firebase_options.dart        مُهمَل في git — يولّده المستخدم بـ flutterfire configure
  core/
    config/      AppConfig (departmentId = 'cs'، المحاكي، نطاق البريد)
    database/    Drift: AppDatabase (مرايا محلية + outbox + sync state) و providers
    domain/      StageRef (المراحل الثمان: '{1-4}-{morning|evening}')
    firebase/    أسماء المجموعات Col، DocIds (معرّفات حتمية)، محوّلات Fs، providers
    router/      go_router + redirectFor() نقية ومختبَرة
    theme/       AppTheme (Cairo، فاتح/ليلي)، StatusPalette (لون + رمز)، AppSettings
    utils/       ArabicText (توحيد الأرقام والإملاء، sortKey)
    widgets/     عناصر مشتركة
  features/<feature>/{domain,data,application,presentation}
    auth, users, academic, students, courses, assignments, import,
    attendance, leaves, stats, warnings, edit_requests, audit, home, settings
  l10n/          app_ar.arb (القالب) + app_en.arb + l10n.dart (امتدادات التسميات + bidiIsolate)
firestore.rules, firestore.indexes.json, firebase.json
rules-tests/     اختبارات القواعد (node:test + @firebase/rules-unit-testing)
tool/            سكربتات الإعداد والفحص
```

- **domain** بلا اعتماد على Flutter (يُسمح بـ `cloud_firestore` لأجل `Timestamp` فقط). المنطق القابل للاختبار هنا.
- **Riverpod 3** بلا توليد كود: `Provider`/`StreamProvider`/`NotifierProvider`. العائلات: `NotifierProvider.autoDispose.family<N, S, A>(N.new)` والـ Notifier يستقبل الوسيط في المُنشئ. `AsyncValue.value` يعيد nullable.
- **package:excel** يصدّر أسماء تتعارض مع Flutter (`TextSpan`, `Border`) → استعمله فقط في ملفات `data/` لا تستورد Flutter.

---

## القرارات

### Firebase (خطة Spark فقط)
- خدمتان فقط: **Authentication (بريد/كلمة مرور)** و**Cloud Firestore**. ممنوع Cloud Functions و Cloud Storage.
- **لا مفاتيح في المستودع**: `lib/firebase_options.dart`، `google-services.json`، `GoogleService-Info.plist`، `.firebaserc` كلها في `.gitignore`. `tool/ensure_firebase_options.sh` يكتب ملفاً مؤقتاً يرمي خطأ، فيظهر `ConfigErrorApp` بدل الانهيار.
- مشروع المحاكي والاختبارات: `demo-uob-attendance`.
- مشروع الإنتاج: **`basrah-researches`** — اسم قديم لمشروع لم يُستعمل (بلغ الحساب حدّ عدد المشاريع)، وهو مخصّص لهذا التطبيق وحده. المعرّف لا يتغيّر، فنسخة الويب على `basrah-researches.web.app`.

### الحسابات والصلاحيات
- وثيقة الحساب `users/{email}` — **المعرّف هو البريد بأحرف صغيرة**. القواعد تقرأها بـ `get(/users/$(request.auth.token.email.lower()))`.
- **لا إنشاء حسابات من التطبيق** (يتطلب Admin SDK/Functions): الإدارة تضيف الوثيقة (استيراد أو يدوياً)، ثم يضغط التدريسي «أول مرة؟ فعّل حسابك» فيُنشئ حساب Auth بالبريد نفسه ويؤكّده من رسالة البريد.
- القواعد تشترط `email_verified == true` و`active == true`؛ لذلك التسجيل ببريد شخص آخر لا يمنح شيئاً. بعد التأكيد يستدعي التطبيق `getIdToken(true)` لتحديث المطالبة.
- الأدوار: `superAdmin | deputyAdmin | stageManager | teacher` في `roles[]`. `stageScopes[]` لمسؤول المرحلة. المدير الثاني لا يمنح ولا يعدّل أدوار المدراء.
- `teachingStages[]` (مشتقّ): المراحل التي للتدريسي فيها إسناد؛ يسمح له بقراءة طلبتها ومجاميعها وإجازاتها فقط. يحدّثه `AssignmentsRepository` مع كل إسناد/إلغاء؛ مسؤول المرحلة يعدّله فقط ضمن مراحله. المدراء لا يُحدَّث لهم (يقرؤون كل شيء).
- `Permissions` (عميل) مرآة لمصفوفة SPEC لإظهار الواجهات فقط؛ **التنفيذ الحقيقي في `firestore.rules`** — حافظ على تطابقهما.
- أول مدير عام يُنشأ يدوياً من Firebase Console (انظر README). ومعرّف الوثيقة **البريد** لا الـ UID (خطأ وقع فعلاً).
- **شاشة «الحسابات»** (`features/users/presentation/accounts_screen.dart`، للمدراء): إضافة حساب، تعديل الاسم/اللقب/الهاتف/الأدوار/مراحل مسؤول المرحلة، إيقاف الحساب. `AccountsRepository` يكتب سجل تدقيق (`user.create|update|approve|reject`) في الـ batch/transaction نفسه. الإضافة بـ transaction ترفض البريد الموجود بدل الكتابة فوقه. لا يغيّر المدير أدواره أو حالته بنفسه (`Permissions.canChangeAccessOf`)، والمدير الثاني لا يمنح دور مدير ولا يفتح حسابات المدراء.
- **طلبات الانضمام** `accessRequests/{email}`: من فعّل حسابه ولم تُضفه الإدارة يرى نموذج «طلب الانضمام» في شاشة «الحساب غير مضاف» (اسم + ملاحظة). المدراء يرونها في «الحسابات» وبطاقة في الرئيسية؛ القبول يُنشئ `users/{email}` (ما لم يوجد) ويحذف الطلب في transaction واحدة، فيدخل صاحبها تلقائياً. القواعد: إنشاء طلب واحد للبريد المؤكَّد نفسه إن لم يكن مُضافاً، بحقول محددة و`requestedAt == request.time`، بلا تعديل؛ القراءة لصاحبه وللمدراء.

### المعرّفات الحتمية (مكررة في `firestore.rules` — عدّلهما معاً)
| المجموعة | المعرّف |
| --- | --- |
| `students` | الرقم الجامعي بعد التوحيد (أرقام لاتينية، بلا مسافات، `/`←`-`) |
| `courses` | `{CODE}_{stageId}` — المادة لكل مرحلة ودراسة؛ «كلاهما» = وثيقتان |
| `groups` | `{courseId}__{A}` |
| `assignments` | `{courseId}__{theory|practical}__{target}__{email}` |
| `sessions` | `{courseId}__{type}__{target}__{yyyyMMdd}__{lectureNo}` (مفتاح SPEC) |
| `stats` | `{courseId}__{studentId}` |

`target` = اسم مجموعة العملي، أو للنظري الشعبة أو `all` (كل الشعب).

### الجلسات والإقفال
- `date` = منتصف ليل UTC ليوم المحاضرة، `dateKey` = `yyyyMMdd`.
- `lockAt = date + 24h + lockHours` (من `academicYears/{yearId}.lockHours`، الافتراضي 48). التدريسي لا يفتح جلسة مستقبلية ولا جلسة انتهت مهلتها، ولا يعدّل `locked/lockAt`.
- بعد الإقفال: التدريسي يقدّم `editRequests`، ومسؤول المرحلة/المدير يعدّلان مباشرة.
- السجلات تشترط `updatedBy == البريد` و`updatedAt == request.time` (serverTimestamp) لحل التعارض «الأحدث يفوز». القواعد تستعمل `getAfter()` لأن الجلسة قد تُنشأ في نفس الـ batch.
- `stats/{courseId}__{studentId}` تُكتب في نفس الـ batch، **بلا `increment`**: الحقل `bySession: {sessionId: status}` (قيمة ثابتة لكل محاضرة) فإعادة رفع الدفعة نفسها لا تحسب الغياب مرتين. التدريسي لا يغيّر إلا مفتاح `lastSessionId` (تثبت القواعد به حقه)، وبمفاتيح محددة فقط. يُكتب للطالب غير الحاضر في أول حفظ، ولأي تغيّر حالة بعده. المجاميع تُحسب من `bySession` عند القراءة (المرحلة 3).
- قراءة جلسة **غير موجودة** مسموحة للتدريسي المُسند إلى صفّها (الصف يُستخرج من المعرّف بـ `split('__')`)، لأن الرافع يسأل الخادم أولاً هل أُنشئت. القاعدة العادية تقرأ `resource.data` فترفض الوثيقة الغائبة — خطأ لم يظهر على `fake_cloud_firestore` واكتشفه اختبار المحاكي: **كل مسار كتابة/قراءة جديد يحتاج اختبار قواعد، لا يكفي الـ fake.**
- `warningLists`: قرار القسم قابل للتعديل والحذف؛ التحويل إلى `deanery` للمدراء فقط مع `orderNumber` و`orderDate`، وبعدها مجمّد تماماً. `auditLog` إنشاء فقط.

### تصحيح البيانات (`features/data_fix`، للمدراء)
- المعرّفات مفاتيح وثائق، فتغييرها = نسخ كل وثيقة إلى مفتاحها الجديد وحذف القديمة. `DataFixRepository.plan…` يقرأ الحالة ويعيد معاينة (`FixPlan`: مشكلات، أعداد، كتابات)، و`apply` ينفّذ.
- **رقم جامعي**: الطالب، `stats`، `groups.studentIds`، `leaves.studentId`، سجلات الحضور في جلسات مراحله (مع تحديث `updatedAt` الجلسة لتعيد الهواتف تنزيلها). **رمز مادة**: المادة، المجموعات، الإسنادات، الجلسات وسجلاتها، `stats` مع إعادة مفاتيح `bySession` و`lastSessionId`. **بريد تدريسي** (المدير العام فقط؛ حذف `users` له وحده): الحساب والإسنادات، ويحذف طلب الانضمام للبريد الجديد. السجل السابق يحتفظ بالبريد القديم في `openedBy/updatedBy`.
- **مراحل الكتابة مرتبة** لأن القواعد تفحص الأب بـ `get()`/`exists()` التي لا ترى إلا المحفوظ: المادة ← المجموعات ← الإسنادات ← الجلسات/الإحصائيات ← حذف القديم. الحساب قبل إسناداته. اختبارات القواعد (`data_fix.test.js`) تثبت أن الدمج في دفعة واحدة يُرفض.
- آمن لإعادة التشغيل: القديم يُحذف آخراً، وكل عنصر (نسخ + حذف) في دفعة واحدة. إن وُجد المعرّف الجديد **بالاسم نفسه** يُدمج فيه (استيراد مكرر أو تنفيذ منقطع)، وباسم مختلف يُرفض.
- **حذف استيراد خاطئ**: طلبة بلا سجل حضور ولا إحصائية ولا إجازة، أو مواد لم تُفتح لها محاضرة (مع مجموعاتها وإسناداتها وتقليص `teachingStages`). فحص الطلبة يقرأ سجلات المرحلة كلها؛ يُستعمل قرب الاستيراد.
- سجل تدقيق: `student.rename`، `course.rename`، `user.rename`، `students.delete`، `courses.delete`.

### الاستيراد
- ملفات openpyxl (بايثون/وكلاء الذكاء الاصطناعي) صالحة لكن package:excel يعجز عنها: مسارات أجزاء مطلقة (`Target="/xl/..."`) وخلايا نصية فارغة `<c t="inlineStr"></c>`. `SpreadsheetReader.repairForPackageExcel` يصلحهما قبل القراءة (اختبار بملف `test/fixtures/openpyxl_teachers.xlsx` ببيانات وهمية).
- `.xlsx` (package:excel) و`.csv` (UTF-8 فقط؛ ترميز Windows-1256 يُرفض برسالة «احفظه CSV UTF-8»). `.xls` القديم غير مدعوم.
- العناوين تُطابَق بأسماء بديلة عربية/إنكليزية (`ImportColumns`)؛ الأعمدة الإلزامية المفقودة خطأ على مستوى الملف.
- المعاينة لا تحفظ شيئاً. كشف: المكرر داخل الملف (رقم جامعي/بريد/رمز = خطأ، الاسم = تحذير)، والموجود في القاعدة (تجاوز، أو تحديث مع «تحديث الموجود»)، والاسم المطابق لرقم آخر، والاسم غير الرباعي، ونقل المرحلة.
- عند التحديث: **الأعمدة الغائبة من الملف تحتفظ بقيمها الحالية**؛ تحديث التدريسي يمس `name/title/phone` فقط ولا يلمس الأدوار.
- الحفظ بدفعات 400، وعند رفض دفعة يُعاد كل صف منفرداً لتحديد الصفوف الفاشلة. يُكتب سجل تدقيق `import.<kind>`.
- `docs/AGENT_BRIEF.md`: وصف البرنامج وصيغ ملفات الاستيراد ونص جاهز لوكيل ذكاء اصطناعي يجهّز البيانات. **حدّثه مع أي تعديل على `ImportColumns` أو `ValueParsers` أو قواعد الاستيراد.**
- القوالب `.xlsx` تُبنى في التطبيق (`ImportTemplates`)؛ excel لا يكتب `rightToLeft` لورقة جديدة في الحفظ الأول، لذلك نحفظ ثم نعيد الفتح ونضبط RTL ونحفظ ثانية.

### الواجهة
- العربية افتراضياً (RTL) والإنكليزية اختيارية؛ كل النصوص في ARB، والـ domain يعيد رموزاً (`IssueCode`، `AuthFailure`) تُترجم في `l10n.dart`.
- النصوص اللاتينية داخل جمل عربية (رموز المواد، البريد) تُغلَّف بـ `bidiIsolate()` وإلا انقلب ترتيبها.
- في RTL استعمل `Icons.chevron_right` للتقدّم (ينعكس تلقائياً)، و`EdgeInsetsDirectional`/`AlignmentDirectional`. حقول البريد وكلمة المرور `textDirection: ltr`.
- خط **Cairo** مضمَّن في `assets/fonts/cairo` (رخصة OFL) — لا تحميل وقت التشغيل.
- **الهوية**: شعار القسم `assets/images/dept_logo.png` (دائري، شفاف خارج الدائرة) في رأس شاشتي الدخول والتحميل (`UniversityHeader`)، ويُستعمل لاحقاً في رؤوس التقارير. تصميم الأيقونة `assets/icon/app_icon.svg` (من القسم) يضمّن الشعار؛ `tool/build_icons.sh` يولّد منه: أيقونة Android التكيفية (المحتوى مصغّر إلى 60٪ داخل المنطقة الآمنة + خلفية التدرج)، وأيقونات iOS معتمة، وأيقونات الويب (عادية + maskable) و`favicon`.
- الحالات بلون + رمز معاً (`StatusPalette`).

### محلياً (Drift) والمزامنة
- `AppDatabase` (schemaVersion 2): مرايا `LocalStudents/Courses/Groups/Assignments`، و`LocalSessions/LocalRecords` (سجل الحضور على الهاتف)، و`OutboxEntries` (كل صف كتابة واحدة، والصفوف بنفس `batchId` تُرفع معاً، و`failed` للمرفوض)، و`SyncStates`. لقطات المخطط في `drift_schemas/` والترحيل مختبَر (`test/core/database/migration_test.dart`)؛ بعد تعديل الجداول: ارفع `schemaVersion` وأضف الترحيل ثم `dart run drift_dev schema dump lib/core/database/app_database.dart drift_schemas/` و`schema generate --data-classes --companions drift_schemas/ test/core/database/generated/`.
- **الحفظ** (`AttendanceStore.save`): `SavePlan` (نقي ومختبَر) يحسب الكتابات، ثم معاملة واحدة تكتب الجلسة والسجلات محلياً وتضع الكتابات في الطابور (`batchId = sessionId#micros`). الجلسة عملية `createOrUpdate`: الرافع يسأل الخادم (`Source.server`) فإن وُجدت حدّث `counts/updatedAt/updatedBy` فقط (ما يسمح به للتدريسي) وإلا أنشأها كاملة.
- **الرفع** (`OutboxUploader`): الأقدم أولاً، بقطع 450 كتابة. أخطاء دائمة (`permission-denied`…) تعلّم الدفعة `failed` وتكمل البقية؛ أخطاء الشبكة توقف الجولة. المرفوض يظهر في بطاقة المزامنة مع «إعادة المحاولة» أو «حذف من الهاتف» (يحذف نسخة المحاضرة المحلية لتُنزَّل نسخة الخادم).
- **التنزيل** (`TeacherDataSync`): كل القراءات `Source.server` (ذاكرة Firestore المؤقتة دون اتصال قد تكون فارغة فتمسح المرآة). السنة النشطة، إسنادات التدريسي، مواد وطلبة مراحلها، المجموعات. **مرة يومياً** أو عند تغيّر الإسنادات أو «مزامنة الآن» (حصة القراءات في Spark). `pullClassSessions` ينزّل جلسات صفّ (الجديد/المعدّل فقط) عند فتح شاشتي التسجيل والسجل، ويستبدل سجلات الجلسة المحلية ما لم يكن لها حفظ غير مرفوع.
- `SyncLifecycle` (في `AppShell`): مزامنة عند الفتح، كل دقيقتين، عند العودة للتطبيق، وعند تغيّر إسنادات التدريسي (مستمع حي على `assignments`).
- التسجيل على الهاتف فقط (`localFirstProvider` = `!kIsWeb`)؛ الويب يعرض «سجّل من الهاتف». الشاشتان `/record?a=&d=&n=` و`/register?a=` صفحات تُدفع فوق الـ shell.
- اختبارات الواجهة بقاعدة محلية: `pumpApp(..., localDb: AppDatabase(NativeDatabase.memory()))` وفي آخر الاختبار `unmountApp(tester)` (يلغي المؤقتات ويفرغ مؤقتات Drift).
- يُفتح كسولاً (`appDatabaseProvider`)؛ لوحة الويب لا تحتاجه. على الويب يحتاج `web/sqlite3.wasm` و`web/drift_worker.js` (مُهمَلان في git).
- منع تسجيل الخروج إذا وُجدت سجلات غير مرفوعة (منفّذ في الملف الشخصي).

### المنصات
- Android: `minSdk = 26` (Android 8 حسب SPEC).
- iOS: **15.0** — قالب Flutter 3.47 وحزم Firebase الحالية تتطلبه، بينما SPEC يذكر iOS 14 (انحراف موثّق).

### قرارات القسم المعلّقة (القيم الحالية افتراضية فقط)
العتبات 5/10/15٪، `weeksPerSemester = 15`، `lecturesPerUnitPerWeek = 1`، `lockHours = 48`، الإجازات لا تُحتسب، نسبة واحدة مدمجة للنظري والعملي، عدم حصر البريد بنطاق `uobasrah.edu.iq` (موجود في `AppConfig` للإشارة فقط).

---

## البناء والنشر والتحديثات

دروس مشروع سابق (Expo + EAS) مطبّقة على Flutter:

| في Expo | المقابل هنا | الحالة |
| --- | --- | --- |
| EAS Build (بناء APK على خوادم سحابية) | **GitHub Actions** `.github/workflows/android.yml` على خوادم GitHub (فيها Android SDK) | ✅ جاهز |
| EAS Update (تحديث JS بلا بناء جديد) | **Shorebird** (`shorebird.dev`) code push لكود Dart | 📝 موثّق، يحتاج حساباً (محجوب هنا) |
| رسالة «تحديث جديد جاهز» | `config/app` + `UpdateGate` (لافتة أو شاشة إلزامية مع رابط التنزيل) | ✅ جاهز |
| EAS Submit | iOS: `flutter build ipa` على macOS (GitHub macOS runner أو Codemagic) ثم TestFlight | 📝 يحتاج حساب Apple (99$ سنوياً) |
| Firebase Hosting (نسخة الحاسوب + صفحة الخصوصية) | `firebase.json` + `web/privacy.html` (تُخدَم في `/privacy.html`) | ✅ جاهز (الصفحة مسودة) |
| «اختبر القواعد قبل النشر» | `ci.yml` في كل push، و`deploy.yml` لا ينشر القواعد إلا بعد نجاح اختبارات المحاكي | ✅ جاهز |
| Expo Push | FCM يحتاج خادماً للإرسال (غير متاح في Spark) → إشعارات داخل التطبيق من Firestore، وإشعارات محلية على الجهاز (مثل «سجلات غير مرفوعة منذ 24 ساعة») في المرحلة 2 | 📝 قرار |

### قاعدة رقم الإصدار (مقابل runtimeVersion في Expo)
`pubspec.yaml`: `version: X.Y.Z+N`. الجزء `N` (versionCode) يضعه CI من `github.run_number` ويجب أن يزيد دائماً.
- **تغيير أصلي (native)**: إضافة/ترقية حزمة فيها كود Android/iOS (مثل `package_info_plus`, `url_launcher`, Drift/sqlite)، تعديل `android/` أو `ios/`، ترقية Flutter → ارفع `X.Y.Z`، ثم `git tag vX.Y.Z && git push --tags` → `android.yml` يبني APK موقّعاً ويرفقه بـ GitHub Release → حدّث `config/app.latestVersion` (و`minVersion` إن لزم إيقاف النسخ القديمة).
- **تغيير Dart فقط** (شاشات/منطق): مع Shorebird يكفي `shorebird patch android`؛ بدونه يُعامل كتغيير أصلي (APK جديد).
- **الويب**: لا تحديث على الأجهزة؛ `Deploy Firebase` (hosting) فيصل للجميع فوراً، لذلك `UpdateGate` معطّل على الويب.
- غيّرت القواعد أو شكل البيانات بطريقة تكسر النسخ القديمة؟ ارفع `minVersion` في `config/app` بعد توزيع النسخة الجديدة.

### التوقيع (حرج)
- كل APK يجب أن يُوقَّع **بالمفتاح نفسه**، وإلا رفض Android تثبيته فوق السابق واضطر التدريسي لحذف التطبيق → **ضياع الحضور غير المرفوع**.
- `android/app/build.gradle.kts` يقرأ `android/key.properties` (مُهمَل في git)؛ بدونه يوقّع بمفتاح debug للتجربة فقط. `android.yml` يرفض إصدار tag بلا مفتاح.
- أسرار GitHub (Settings → Secrets and variables → Actions):

| الاسم | النوع | المحتوى |
| --- | --- | --- |
| `ANDROID_KEYSTORE_B64` | secret | `base64 -w0 upload-keystore.jks` |
| `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD` | secret | من إنشاء المفتاح |
| `FIREBASE_OPTIONS_DART_B64` | secret | `base64 -w0 lib/firebase_options.dart` |
| `GOOGLE_SERVICES_JSON_B64` | secret | `base64 -w0 android/app/google-services.json` (إن وُجد) |
| `FIREBASE_SERVICE_ACCOUNT_JSON` | secret | حساب خدمة بصلاحيات Rules Admin + Datastore Index Admin + Hosting Admin |
| `FIREBASE_PROJECT_ID` | variable | معرّف مشروع Firebase |

### سير العمل (`.github/workflows/`)
- `ci.yml` (كل push/PR): analyze + الكود المولَّد محدَّث + `flutter test` + بناء الويب، و`rules-tests.yml` (قابل لإعادة الاستعمال) على المحاكي.
- `android.yml`: push يمس `android/` أو `pubspec` (فحص بناء)، أو تشغيل يدوي، أو tag `v*` (إصدار). الـ tag يجب أن يطابق `version` في pubspec.
- `deploy.yml` (يدوي، بيئة `production`): اختبارات القواعد ← نشر القواعد/الفهارس و/أو الويب.
- `setup-check.yml` (يدوي، أو push يمس ملفاته): `tool/check_setup.mjs` يتحقق دون كشف أي سر من الأسرار (يفتح المفتاح بكلمات المرور عبر `tool/CheckKeystore.java` كما يفعل Gradle)، ومن مشروع Firebase الحي: تفعيل Email/Password، وجود Firestore وإغلاقها للزوار، تطابق القواعد المنشورة مع `firestore.rules` (بحساب الخدمة)، صفحة الخصوصية، والبيانات الأولى إن سمحت الصلاحية. للقراءة فقط. التقرير في Job summary؛ وأنا أقرؤه بـ `get_job_logs`.
- `workflow_dispatch` لا يظهر إلا بعد دمج الملف في الفرع الافتراضي.

### Shorebird (عند اعتماده)
1. `shorebird login` ثم `shorebird init` (يضيف `shorebird.yaml` بمعرّف التطبيق — يُلتزَم في المستودع، ليس سراً).
2. تحقّق أن نسخة Flutter مدعومة: `shorebird flutter versions list` (وإلا استعمل `--flutter-version`).
3. الإصدار الأساسي: `shorebird release android --artifact=apk` بدل `flutter build apk` (عدّل `android.yml` حينها، مع `SHOREBIRD_TOKEN` وإجراء `shorebirdtech/setup-shorebird`).
4. التعديلات: `shorebird patch android` — جرّبها أولاً على `--track=staging` (مقابل قناة preview) ثم stable.
- الرقعة تصل فقط للنسخ بنفس رقم الإصدار، ولا تغيّر كوداً أصلياً — القاعدة نفسها أعلاه. الخطة المجانية: 5,000 تثبيت رقعة شهرياً.
- ترحيلات مخطط Drift كود Dart (قابلة للترقيع) لكن اختبرها جيداً؛ القاعدة المحلية تحمل بيانات غير مرفوعة.

### `config/app` و`accessRequests` (إضافات على جدول SPEC)
`config/app`: `latestVersion`، `minVersion` (نصوص `X.Y.Z`)، `androidUrl`، `iosUrl`، `notes`. يقرؤها كل حساب نشط، ويكتبها المدراء فقط. تُضبط حالياً من Firebase Console.
`accessRequests/{email}`: `email`، `name`، `note`، `requestedAt` (انظر «طلبات الانضمام» أعلاه).

---

## الاختبارات

- **Flutter** (`test/`): منطق الـ domain والاستيراد، Drift على `NativeDatabase.memory()`، المستودعات على `fake_cloud_firestore`، المصادقة بـ `firebase_auth_mocks` (+`mock_exceptions` لـ `whenCalling`)، واختبارات واجهة من البداية للنهاية.
- في اختبارات الواجهة: تجاوَز `pendingUploadsProvider` بـ `Stream.value(0)` — تدفقات Drift تترك مؤقتاً بعد التفكيك فيفشل الاختبار ثم يعلق 10 دقائق. شغّل دائماً بـ `--timeout`.
- الـ SnackBar العائم قد يغطي زراً سفلياً؛ امسحه قبل النقر في الاختبار.
- **القواعد** (`rules-tests/`): كل اختبار يبدأ بقاعدة نظيفة + بيانات `seed()` في `helpers.js`. عند تعديل القواعد أضف اختبار نجاح واختبار فشل؛ تحقّقنا بالطفرات أن الاختبارات تلتقط إضعاف القواعد.
