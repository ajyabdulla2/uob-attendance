#!/usr/bin/env node
// Verifies the release/deploy setup without printing any secret:
//   * GitHub secrets: Firebase options, upload keystore, service account.
//   * The live Firebase project: Email/Password sign-in, Firestore, the
//     deployed rules (vs firestore.rules), Hosting, and the first data.
// Read-only: it never creates accounts or writes data.
//
// Run by .github/workflows/setup-check.yml (report in the job summary).
// Locally:  FIREBASE_OPTIONS_DART_B64=$(base64 -w0 lib/firebase_options.dart) node tool/check_setup.mjs
// Exit code 1 when a required item is missing or broken.
import { execFileSync } from 'node:child_process';
import { createSign } from 'node:crypto';
import { appendFileSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const env = process.env;
const inActions = env.GITHUB_ACTIONS === 'true';
const tmp = mkdtempSync(join(tmpdir(), 'setup-check-'));

const ICON = { ok: '✅', fail: '❌', warn: '⚠️', skip: '➖' };
const results = [];
function report(section, item, status, detail = '') {
  results.push({ section, item, status, detail });
  console.log(`${ICON[status]} [${section}] ${item}${detail ? ` — ${detail}` : ''}`);
}
function mask(value) {
  if (inActions && value) console.log(`::add-mask::${value}`);
}

// ---------------------------------------------------------------- helpers

/** Decodes a base64 secret; null when it is not base64 of a text file. */
function decodeB64(raw) {
  const text = raw.replace(/\s+/g, '');
  if (!/^[A-Za-z0-9+/]+={0,2}$/.test(text)) return null;
  return Buffer.from(text, 'base64');
}

/** `static const FirebaseOptions web = FirebaseOptions(apiKey: '…', …);` → { web: {apiKey, …} } */
function parseFirebaseOptions(source) {
  const platforms = {};
  for (const m of source.matchAll(/static const FirebaseOptions (\w+) = FirebaseOptions\(([\s\S]*?)\);/g)) {
    const fields = {};
    for (const f of m[2].matchAll(/(\w+):\s*['"]([^'"]*)['"]/g)) fields[f[1]] = f[2];
    platforms[m[1]] = fields;
  }
  return platforms;
}

async function request(url, options = {}) {
  try {
    const res = await fetch(url, { ...options, signal: AbortSignal.timeout(20000) });
    const text = await res.text();
    let json = null;
    try { json = JSON.parse(text); } catch { /* not JSON */ }
    return { status: res.status, json, text };
  } catch (e) {
    return { status: 0, json: null, text: String(e.cause?.code ?? e.message) };
  }
}
const errorMessage = (r) => r.json?.error?.message ?? r.text.slice(0, 160);

async function accessToken(sa) {
  const now = Math.floor(Date.now() / 1000);
  const part = (o) => Buffer.from(JSON.stringify(o)).toString('base64url');
  const unsigned = `${part({ alg: 'RS256', typ: 'JWT' })}.${part({
    iss: sa.client_email,
    scope: 'https://www.googleapis.com/auth/cloud-platform',
    aud: 'https://oauth2.googleapis.com/token',
    iat: now,
    exp: now + 600,
  })}`;
  const signature = createSign('RSA-SHA256').update(unsigned).sign(sa.private_key, 'base64url');
  const r = await request('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'content-type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
      assertion: `${unsigned}.${signature}`,
    }),
  });
  if (r.status !== 200) throw new Error(r.json?.error_description ?? r.json?.error ?? r.text.slice(0, 160));
  mask(r.json.access_token);
  return r.json.access_token;
}

// ------------------------------------------------------------- 1. Firebase options

const S1 = 'إعداد Firebase للتطبيق';
let projectId = null;
let apiKey = null;
{
  const raw = env.FIREBASE_OPTIONS_DART_B64 ?? '';
  if (!raw.trim()) {
    report(S1, 'FIREBASE_OPTIONS_DART_B64', 'fail', 'السر غير موجود. القيمة: base64 -w0 lib/firebase_options.dart');
  } else if (raw.includes('DefaultFirebaseOptions')) {
    report(S1, 'FIREBASE_OPTIONS_DART_B64', 'fail', 'لُصق محتوى الملف نفسه؛ المطلوب ناتج base64 -w0 lib/firebase_options.dart');
  } else {
    const bytes = decodeB64(raw);
    const source = bytes?.toString('utf8') ?? '';
    if (!source.includes('DefaultFirebaseOptions')) {
      report(S1, 'FIREBASE_OPTIONS_DART_B64', 'fail', 'ليس base64 لملف firebase_options.dart الناتج من flutterfire configure');
    } else if (source.includes('PLACEHOLDER')) {
      report(S1, 'FIREBASE_OPTIONS_DART_B64', 'fail', 'هذا الملف المؤقت؛ نفّذ flutterfire configure أولاً');
    } else {
      const platforms = parseFirebaseOptions(source);
      const ids = new Set(Object.values(platforms).map((p) => p.projectId).filter(Boolean));
      if (ids.size !== 1) {
        report(S1, 'FIREBASE_OPTIONS_DART_B64', 'fail', `معرّف المشروع غير واضح (${[...ids].join(', ') || 'لا يوجد'})`);
      } else {
        projectId = [...ids][0];
        apiKey = (platforms.web ?? platforms.android ?? Object.values(platforms)[0]).apiKey ?? null;
        for (const p of Object.values(platforms)) mask(p.apiKey);
        report(S1, 'FIREBASE_OPTIONS_DART_B64', 'ok', `المشروع ${projectId}`);
        for (const [name, required] of [['android', true], ['web', true], ['ios', false]]) {
          if (platforms[name]) report(S1, `منصة ${name}`, 'ok');
          else report(S1, `منصة ${name}`, required ? 'fail' : 'warn',
            `غير مسجّلة؛ أعد flutterfire configure --platforms=android,ios,web${required ? '' : ' (لازمة لنسخة iOS لاحقاً)'}`);
        }
      }
    }
  }

  const gs = env.GOOGLE_SERVICES_JSON_B64 ?? '';
  if (!gs.trim()) {
    report(S1, 'GOOGLE_SERVICES_JSON_B64', 'skip', 'اختياري؛ التطبيق يقرأ الإعداد من firebase_options.dart');
  } else {
    let json = null;
    try { json = JSON.parse(decodeB64(gs)?.toString('utf8') ?? ''); } catch { /* reported below */ }
    const gradle = readFileSync(join(root, 'android/app/build.gradle.kts'), 'utf8');
    const appId = gradle.match(/applicationId\s*=\s*"([^"]+)"/)?.[1];
    const packages = (json?.client ?? []).map((c) => c.client_info?.android_client_info?.package_name);
    if (!json) report(S1, 'GOOGLE_SERVICES_JSON_B64', 'fail', 'ليس base64 لملف JSON');
    else if (projectId && json.project_info?.project_id !== projectId) {
      report(S1, 'GOOGLE_SERVICES_JSON_B64', 'fail', `لمشروع آخر (${json.project_info?.project_id})`);
    } else if (!packages.includes(appId)) {
      report(S1, 'GOOGLE_SERVICES_JSON_B64', 'warn', `لا يحوي الحزمة ${appId}`);
    } else report(S1, 'GOOGLE_SERVICES_JSON_B64', 'ok', `المشروع ${json.project_info?.project_id}`);

    // Without the Dart options, still check the live project with the Android key.
    const key = json?.client?.flatMap((c) => c.api_key ?? []).map((k) => k.current_key).find(Boolean);
    mask(key);
    if (!projectId && json?.project_info?.project_id && key) {
      projectId = json.project_info.project_id;
      apiKey = key;
    }
  }
}

// ------------------------------------------------------------- 2. Upload keystore

const S2 = 'مفتاح توقيع Android';
{
  const names = ['ANDROID_KEYSTORE_B64', 'ANDROID_KEYSTORE_PASSWORD', 'ANDROID_KEY_ALIAS', 'ANDROID_KEY_PASSWORD'];
  const missing = names.filter((n) => !(env[n] ?? '').trim());
  // Only the key password missing: still verify the file, store password and
  // alias with the store password (a PKCS12 key uses the same password).
  const onlyKeyPassword = missing.length === 1 && missing[0] === 'ANDROID_KEY_PASSWORD';
  if (missing.length) {
    report(S2, 'الأسرار', 'fail', `غير موجودة: ${missing.join('، ')}${onlyKeyPassword
      ? ' — أضفه بقيمة ANDROID_KEYSTORE_PASSWORD نفسها إن لم تُدخل كلمة مختلفة للمفتاح' : ''}`);
  }
  if (!missing.length || onlyKeyPassword) {
    const keyEnv = onlyKeyPassword ? { ...env, ANDROID_KEY_PASSWORD: env.ANDROID_KEYSTORE_PASSWORD } : env;
    const bytes = decodeB64(env.ANDROID_KEYSTORE_B64);
    if (!bytes?.length) {
      report(S2, 'ANDROID_KEYSTORE_B64', 'fail', 'ليس base64؛ استعمل base64 -w0 upload-keystore.jks');
    } else {
      const file = join(tmp, 'upload.jks');
      writeFileSync(file, bytes);
      let out;
      try {
        const stdout = execFileSync('java', [join(root, 'tool/CheckKeystore.java'), file], {
          encoding: 'utf8', stdio: ['ignore', 'pipe', 'ignore'], env: keyEnv,
        });
        out = JSON.parse(stdout.trim().split('\n').pop());
      } catch (e) {
        out = { ok: false, error: 'java', detail: e.message };
      }
      const reasons = {
        store_password: 'ANDROID_KEYSTORE_PASSWORD لا يفتح الملف (أو الملف تالف)',
        alias: `ANDROID_KEY_ALIAS غير موجود في الملف؛ الموجود: ${out.aliases || '—'}`,
        key_password: onlyKeyPassword
          ? 'للمفتاح كلمة مرور تختلف عن كلمة مرور الملف؛ ضعها في ANDROID_KEY_PASSWORD'
          : 'ANDROID_KEY_PASSWORD خطأ (في ملفات PKCS12 يساوي كلمة مرور الملف)',
        not_private_key: 'الاسم المستعار لا يحوي مفتاحاً خاصاً',
        format: 'الملف ليس keystore؛ أعد base64 -w0 upload-keystore.jks',
        java: `تعذّر تشغيل Java: ${out.detail ?? ''}`,
      };
      const item = onlyKeyPassword ? 'فتح المفتاح بكلمة مرور الملف' : 'فتح المفتاح بكلمات المرور';
      if (!out.ok) {
        report(S2, item, 'fail', reasons[out.error] ?? out.error);
      } else {
        report(S2, item, 'ok', `بصمة SHA-256: ${out.sha256}`);
        const until = new Date(out.notAfter);
        // Google Play requires validity beyond 22 Oct 2033.
        report(S2, 'مدة الصلاحية', until > new Date('2033-10-22') ? 'ok' : 'warn',
          `حتى ${until.toISOString().slice(0, 10)}`);
      }
    }
  }
}

// ------------------------------------------------------------- 3. Live Firebase project

const S3 = 'مشروع Firebase';
if (!projectId || !apiKey) {
  report(S3, 'الفحص المباشر', 'skip', 'يحتاج FIREBASE_OPTIONS_DART_B64 أو GOOGLE_SERVICES_JSON_B64 صالحاً');
} else {
  // Sign-in attempt for an address that cannot exist: tells whether the
  // Email/Password provider is enabled without creating anything.
  const auth = await request(
    `https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${apiKey}`,
    {
      method: 'POST',
      headers: { 'content-type': 'application/json' },
      body: JSON.stringify({ email: `setup-check-${Date.now()}@invalid.example`, password: 'setup-check-0', returnSecureToken: false }),
    },
  );
  const authCode = errorMessage(auth).split(/[\s:]/)[0];
  if (['INVALID_LOGIN_CREDENTIALS', 'EMAIL_NOT_FOUND', 'INVALID_PASSWORD'].includes(authCode)) {
    report(S3, 'Authentication: البريد وكلمة المرور', 'ok', 'مفعّل');
  } else if (['PASSWORD_LOGIN_DISABLED', 'OPERATION_NOT_ALLOWED'].includes(authCode)) {
    report(S3, 'Authentication: البريد وكلمة المرور', 'fail', 'غير مفعّل: Authentication ← Sign-in method ← Email/Password');
  } else if (authCode === 'CONFIGURATION_NOT_FOUND') {
    report(S3, 'Authentication: البريد وكلمة المرور', 'fail', 'Authentication غير مُهيّأ: اضغط Get started ثم فعّل Email/Password');
  } else if (auth.status === 0 || authCode === 'TOO_MANY_ATTEMPTS_TRY_LATER') {
    report(S3, 'Authentication: البريد وكلمة المرور', 'warn', `تعذّر التحقق الآن (${auth.status ? authCode : auth.text})`);
  } else {
    report(S3, 'Authentication: البريد وكلمة المرور', 'fail', errorMessage(auth));
  }

  // Anonymous read: our rules (and the production-mode defaults) refuse it.
  const fs = await request(
    `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents/config/app?key=${apiKey}`,
  );
  const fsMsg = errorMessage(fs);
  if (fs.status === 403 && /Missing or insufficient permissions/i.test(fsMsg)) {
    report(S3, 'Cloud Firestore', 'ok', 'القاعدة موجودة وترفض غير المسجّلين');
  } else if (fs.status === 200 || (fs.status === 404 && /Document .* not found/i.test(fsMsg))) {
    report(S3, 'Cloud Firestore', 'fail', 'القاعدة مفتوحة للجميع (قواعد وضع الاختبار؟) — انشر firestore.rules فوراً');
  } else if (/does not exist|has not been used|is disabled|Datastore Mode/i.test(fsMsg)) {
    report(S3, 'Cloud Firestore', 'fail', 'لم تُنشأ قاعدة Firestore (Native mode) بعد');
  } else if (fs.status === 0) {
    report(S3, 'Cloud Firestore', 'warn', `تعذّر الاتصال (${fs.text})`);
  } else {
    report(S3, 'Cloud Firestore', 'fail', `${fs.status}: ${fsMsg}`);
  }

  const site = await request('https://uob-cs-attendance.web.app/privacy.html');
  if (site.status === 200 && site.text.includes('سياسة الخصوصية')) {
    report(S3, 'Hosting: صفحة الخصوصية', 'ok', 'https://uob-cs-attendance.web.app/privacy.html');
  } else {
    report(S3, 'Hosting: صفحة الخصوصية', 'warn', 'لم تُنشر نسخة الويب بعد (Deploy Firebase ← hosting)');
  }
}

// ------------------------------------------------------------- 4. Deploy credentials + server-side checks

const S4 = 'النشر من GitHub والبيانات';
{
  const varProject = (env.FIREBASE_PROJECT_ID ?? '').trim();
  if (!varProject) report(S4, 'المتغير FIREBASE_PROJECT_ID', 'warn', 'غير موجود (يلزم لسير عمل Deploy Firebase)');
  else if (projectId && varProject !== projectId) report(S4, 'المتغير FIREBASE_PROJECT_ID', 'fail', `${varProject} ≠ ${projectId}`);
  else report(S4, 'المتغير FIREBASE_PROJECT_ID', 'ok', varProject);

  let sa = null;
  const rawSa = env.FIREBASE_SERVICE_ACCOUNT_JSON ?? '';
  if (!rawSa.trim()) {
    report(S4, 'FIREBASE_SERVICE_ACCOUNT_JSON', 'warn',
      'غير موجود على مستوى المستودع (يلزم لـ Deploy Firebase؛ وإن وضعته في بيئة production فلا يظهر هنا)');
  } else {
    try { sa = JSON.parse(rawSa); } catch { /* reported below */ }
    if (!sa || sa.type !== 'service_account' || !sa.private_key || !sa.client_email) {
      report(S4, 'FIREBASE_SERVICE_ACCOUNT_JSON', 'fail', 'ليس ملف مفتاح JSON لحساب خدمة (الصق محتوى الملف كما هو)');
      sa = null;
    } else if ((projectId || varProject) && sa.project_id !== (projectId || varProject)) {
      report(S4, 'FIREBASE_SERVICE_ACCOUNT_JSON', 'fail', `لمشروع آخر (${sa.project_id})`);
      sa = null;
    } else {
      mask(sa.private_key_id);
      report(S4, 'FIREBASE_SERVICE_ACCOUNT_JSON', 'ok', sa.client_email);
    }
  }

  const project = projectId || varProject || sa?.project_id;
  let token = null;
  if (sa) {
    try {
      token = await accessToken(sa);
    } catch (e) {
      report(S4, 'تسجيل دخول حساب الخدمة', 'fail', `المفتاح مرفوض (${e.message}) — ربما حُذف؛ أنشئ مفتاحاً جديداً`);
    }
  }

  if (!token) {
    report(S4, 'القواعد المنشورة = firestore.rules', 'skip',
      'يحتاج حساب الخدمة؛ أو انشرها يدوياً: firebase deploy --only firestore:rules,firestore:indexes');
  } else {
    const bearer = { headers: { authorization: `Bearer ${token}` } };
    // `firebase deploy` first asks Service Usage whether the Firestore API is on.
    const usage = await request(`https://serviceusage.googleapis.com/v1/projects/${project}/services/firestore.googleapis.com`, bearer);
    if (usage.status === 200) report(S4, 'دور Service Usage Consumer', 'ok', usage.json.state ?? '');
    else report(S4, 'دور Service Usage Consumer', 'fail',
      `مرفوض (${errorMessage(usage)}) — firebase deploy يفشل بـ 403؛ أضف الدور لحساب الخدمة في IAM`);

    const release =await request(`https://firebaserules.googleapis.com/v1/projects/${project}/releases/cloud.firestore`, bearer);
    const ruleset = release.status === 200
      ? await request(`https://firebaserules.googleapis.com/v1/${release.json.rulesetName}`, bearer)
      : release;
    if (ruleset.status !== 200) {
      report(S4, 'القواعد المنشورة = firestore.rules', release.status === 404 ? 'fail' : 'warn',
        release.status === 404 ? 'لا توجد قواعد منشورة' : `تعذّرت القراءة (${errorMessage(ruleset)}) — يحتاج دور Firebase Rules Admin`);
    } else {
      const deployed = (ruleset.json.source?.files ?? []).map((f) => f.content).join('\n').replace(/\r\n/g, '\n').trimEnd();
      const local = readFileSync(join(root, 'firestore.rules'), 'utf8').replace(/\r\n/g, '\n').trimEnd();
      const when = (ruleset.json.createTime ?? '').slice(0, 10);
      if (deployed === local) {
        report(S4, 'القواعد المنشورة = firestore.rules', 'ok', `منشورة ${when}`);
      } else {
        const hint = /if\s+false/.test(deployed) && !/isActive/.test(deployed)
          ? 'القواعد الافتراضية (ترفض كل شيء) — لم تُنشر قواعد المشروع'
          : /request\.time\s*</.test(deployed)
            ? 'قواعد وضع الاختبار المفتوحة — خطر'
            : `نسخة مختلفة منشورة ${when}`;
        report(S4, 'القواعد المنشورة = firestore.rules', 'fail', `${hint}؛ انشر: Deploy Firebase ← rules`);
      }
    }

    // Composite indexes from firestore.indexes.json (deployed with the rules).
    const wanted = JSON.parse(readFileSync(join(root, 'firestore.indexes.json'), 'utf8')).indexes ?? [];
    const admin = `https://firestore.googleapis.com/v1/projects/${project}/databases/(default)/collectionGroups`;
    for (const ix of wanted) {
      const fields = ix.fields.map((f) => `${f.fieldPath} ${f.order === 'DESCENDING' ? '↓' : '↑'}`).join('، ');
      const label = `فهرس ${ix.collectionGroup} (${fields})`;
      const r = await request(`${admin}/${ix.collectionGroup}/indexes`, bearer);
      if (r.status !== 200) {
        report(S4, label, 'warn', `تعذّرت القراءة (${errorMessage(r)}) — يحتاج دور Datastore Index Admin`);
        continue;
      }
      const same = (r.json.indexes ?? []).find((d) => d.queryScope === ix.queryScope
        && JSON.stringify(d.fields.filter((f) => f.fieldPath !== '__name__').map((f) => [f.fieldPath, f.order]))
          === JSON.stringify(ix.fields.map((f) => [f.fieldPath, f.order])));
      if (!same) report(S4, label, 'fail', 'غير منشور؛ انشر: firebase deploy --only firestore:indexes');
      else report(S4, label, same.state === 'READY' ? 'ok' : 'warn', same.state === 'READY' ? 'جاهز' : `قيد الإنشاء (${same.state})`);
    }

    // Data written by the first steps (needs a role that can read Firestore data).
    const base = `https://firestore.googleapis.com/v1/projects/${project}/databases/(default)/documents`;
    const post = (path, body) => request(`${base}${path}`, {
      method: 'POST',
      headers: { authorization: `Bearer ${token}`, 'content-type': 'application/json' },
      body: JSON.stringify(body),
    });
    const count = async (collectionId) => {
      const r = await post(':runAggregationQuery', {
        structuredAggregationQuery: {
          structuredQuery: { from: [{ collectionId }] },
          aggregations: [{ alias: 'n', count: {} }],
        },
      });
      if (r.status !== 200) return { error: r };
      return { n: Number(r.json?.[0]?.result?.aggregateFields?.n?.integerValue ?? 0) };
    };

    const first = await count('users');
    if (first.error) {
      report(S4, 'البيانات', 'skip', first.error.status === 403
        ? 'حساب الخدمة لا يقرأ البيانات (طبيعي بأدوار النشر فقط)؛ تحقّق بتسجيل الدخول في التطبيق'
        : errorMessage(first.error));
    } else {
      const admins = await post(':runQuery', {
        structuredQuery: {
          from: [{ collectionId: 'users' }],
          where: { fieldFilter: { field: { fieldPath: 'roles' }, op: 'ARRAY_CONTAINS', value: { stringValue: 'superAdmin' } } },
          limit: 20,
        },
      });
      const docs = (admins.json ?? []).map((x) => x.document).filter(Boolean);
      const problems = [];
      let valid = 0;
      for (const d of docs) {
        const id = decodeURIComponent(d.name.split('/').pop());
        const f = d.fields ?? {};
        const issues = [];
        if (id !== id.toLowerCase()) issues.push('معرّف الوثيقة بأحرف كبيرة');
        if (f.email?.stringValue !== id) issues.push('الحقل email لا يطابق معرّف الوثيقة');
        if (f.active?.booleanValue !== true) issues.push('active ليس boolean = true');
        if (f.departmentId?.stringValue !== 'cs') issues.push('departmentId ليس cs');
        for (const k of ['stageScopes', 'teachingStages']) if (!f[k]?.arrayValue) issues.push(`${k} ليس array`);
        if (issues.length) problems.push(issues.join('، '));
        else valid++;
      }
      if (valid) report(S4, 'وثيقة المدير العام (users)', 'ok', `${valid} صحيحة`);
      else report(S4, 'وثيقة المدير العام (users)', 'fail', problems[0]
        ?? 'لا توجد؛ roles يجب أن يكون array يحوي superAdmin (README الخطوة 6)');

      const stages = await count('stages');
      const years = await count('academicYears');
      if (stages.n === 8 && years.n > 0) report(S4, 'تهيئة المراحل والسنة الدراسية', 'ok', `${stages.n} مراحل`);
      else report(S4, 'تهيئة المراحل والسنة الدراسية', 'fail', 'من الرئيسية اضغط «تهيئة الآن»');

      for (const [col, label] of [['students', 'الطلبة'], ['courses', 'المواد'], ['assignments', 'الإسنادات']]) {
        const c = await count(col);
        report(S4, label, c.n > 0 ? 'ok' : 'warn', c.n > 0 ? `${c.n}` : 'لم تُستورد/تُربط بعد');
      }
      report(S4, 'الحسابات (users)', first.n > 1 ? 'ok' : 'warn', first.n > 1 ? `${first.n}` : 'استورد التدريسيين');
    }
  }
}

// ------------------------------------------------------------- report

rmSync(tmp, { recursive: true, force: true });
const failed = results.filter((r) => r.status === 'fail').length;
if (env.GITHUB_STEP_SUMMARY) {
  const lines = ['## فحص الإعداد', ''];
  for (const section of [...new Set(results.map((r) => r.section))]) {
    lines.push(`### ${section}`, '', '| | البند | التفاصيل |', '| --- | --- | --- |');
    for (const r of results.filter((x) => x.section === section)) {
      lines.push(`| ${ICON[r.status]} | ${r.item} | ${r.detail.replace(/\|/g, '\\|')} |`);
    }
    lines.push('');
  }
  lines.push(failed ? `**عدد البنود التي تحتاج إصلاحاً: ${failed}**` : '**كل البنود الإلزامية سليمة.**');
  appendFileSync(env.GITHUB_STEP_SUMMARY, `${lines.join('\n')}\n`);
}
console.log(failed ? `\n${failed} item(s) need fixing.` : '\nAll required items are OK.');
process.exitCode = failed ? 1 : 0;
