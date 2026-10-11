import { test, beforeEach } from 'node:test';
import assert from 'node:assert/strict';
import { createHandler, publicLimit } from '../src/index.js';
import { resetCaches } from '../src/google.js';
import { quotaDay, plain } from '../src/public.js';

const RS256 = { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' };
const sa = await crypto.subtle.generateKey(
  { ...RS256, modulusLength: 2048, publicExponent: new Uint8Array([1, 0, 1]) }, true, ['sign', 'verify']);
const pkcs8 = Buffer.from(await crypto.subtle.exportKey('pkcs8', sa.privateKey)).toString('base64');
const env = {
  PROJECT_ID: 'demo-uob',
  SERVICE_ACCOUNT_JSON: JSON.stringify({
    client_email: 'push@demo.iam.gserviceaccount.com',
    private_key: `-----BEGIN PRIVATE KEY-----\n${pkcs8}\n-----END PRIVATE KEY-----\n`,
  }),
};
const NOW = Date.UTC(2026, 9, 11, 12);
const ID = 'K7QM2XRT9HBWPZ4NCV8DJEAF';
const s = (v) => ({ stringValue: v });
const arr = (xs) => ({ arrayValue: { values: xs } });

const RECORD = {
  title: s('كتاب إنذار'),
  meta: arr([s('المرحلة الثالثة')]),
  tables: arr([{ mapValue: { fields: { heading: s(''), columns: arr([s('الاسم')]),
    rows: arr([{ mapValue: { fields: { c: arr([s('أحمد')]) } } }]) } } }]),
  issuedBy: s('t1@uob.iq'),
  issuerName: s('م. علي'),
  issuedAt: { timestampValue: '2026-10-11T08:30:00Z' },
};

/** Fake Google (OAuth + Firestore) that counts document reads. */
function fakeGoogle({ announcements = 2 } = {}) {
  const calls = { reads: 0 };
  const fetchFn = async (url, init = {}) => {
    const u = String(url);
    const ok = (body, status = 200) => new Response(JSON.stringify(body), { status });
    if (u.startsWith('https://oauth2.googleapis.com/token')) return ok({ access_token: 'sa-token', expires_in: 3600 });
    assert.equal(init.headers?.authorization, 'Bearer sa-token');
    if (u.endsWith(':runQuery')) {
      const q = JSON.parse(init.body).structuredQuery;
      assert.equal(q.from[0].collectionId, 'announcements');
      assert.equal(q.limit, 30);
      calls.reads += Math.max(1, announcements);
      return ok(Array.from({ length: announcements }, (_, i) => ({
        document: { fields: { title: s(`إعلان ${i}`), body: s('نص'), createdBy: s('admin@uob.iq'),
          createdAt: { timestampValue: '2026-10-10T08:00:00Z' } } },
      })));
    }
    const rec = /\/documents\/reportVerifications\/(.+)$/.exec(u);
    if (rec) {
      calls.reads += 1;
      return rec[1] === ID ? ok({ fields: RECORD }) : ok({ error: {} }, 404);
    }
    throw new Error(`unexpected ${u}`);
  };
  return { fetchFn, calls };
}

function memoryQuota() {
  const days = new Map();
  return {
    days,
    used: async (day) => days.get(day) ?? 0,
    add: async (day, n) => days.set(day, (days.get(day) ?? 0) + n).get(day),
  };
}

function memoryCache() {
  const m = new Map();
  return { match: async (r) => m.get(r.url)?.clone(), put: async (r, res) => m.set(r.url, res) };
}

const get = (h, path, e = env) => h(new Request(`https://w.dev${path}`), e);

beforeEach(() => resetCaches());

test('a record is served to anyone, without the issuer e-mail, and counted', async () => {
  const g = fakeGoogle();
  const quota = memoryQuota();
  const h = createHandler({ fetchFn: g.fetchFn, nowMs: () => NOW, quotaFor: () => quota, cache: null });
  const res = await get(h, `/public/verify/${ID}`);
  assert.equal(res.status, 200);
  assert.equal(res.headers.get('access-control-allow-origin'), '*');
  const { record } = await res.json();
  assert.equal(record.title, 'كتاب إنذار');
  assert.deepEqual(record.tables[0].rows[0].c, ['أحمد']);
  assert.equal(record.issuerName, 'م. علي');
  assert.equal(record.issuedAt, '2026-10-11T08:30:00Z');
  assert.equal('issuedBy' in record, false);
  assert.equal(quota.days.get(quotaDay(NOW)), 1);
});

test('an unknown ID is 404 (and costs a read); a malformed one never reaches Firestore', async () => {
  const g = fakeGoogle();
  const quota = memoryQuota();
  const h = createHandler({ fetchFn: g.fetchFn, nowMs: () => NOW, quotaFor: () => quota, cache: null });
  assert.equal((await get(h, '/public/verify/ABCDEFGHJKMNPQRSTVWXYZ23')).status, 404);
  assert.equal((await get(h, '/public/verify/abc')).status, 400);
  assert.equal((await get(h, '/public/verify/..%2Fusers%2Fx')).status, 400);
  assert.equal(g.calls.reads, 1);
  assert.equal(quota.days.get(quotaDay(NOW)), 1);
});

test('announcements: latest 30, each document counted', async () => {
  const g = fakeGoogle({ announcements: 3 });
  const quota = memoryQuota();
  const h = createHandler({ fetchFn: g.fetchFn, nowMs: () => NOW, quotaFor: () => quota, cache: null });
  const res = await get(h, '/public/announcements');
  assert.equal(res.status, 200);
  const { items } = await res.json();
  assert.equal(items.length, 3);
  assert.deepEqual(Object.keys(items[0]).sort(), ['body', 'createdAt', 'title', 'updatedAt']);
  assert.equal(quota.days.get(quotaDay(NOW)), 3);
  // None at all still costs one read.
  const empty = fakeGoogle({ announcements: 0 });
  const q2 = memoryQuota();
  await get(createHandler({ fetchFn: empty.fetchFn, nowMs: () => NOW, quotaFor: () => q2, cache: null }), '/public/announcements');
  assert.equal(q2.days.get(quotaDay(NOW)), 1);
});

test('past the daily share every public request gets 429 «try in 24 hours», with no Firestore read', async () => {
  const g = fakeGoogle({ announcements: 2 });
  const quota = memoryQuota();
  const h = createHandler({ fetchFn: g.fetchFn, nowMs: () => NOW, quotaFor: () => quota, cache: null });
  const small = { ...env, PUBLIC_DAILY_READS: '3' };
  assert.equal((await get(h, '/public/announcements', small)).status, 200); // 2
  assert.equal((await get(h, `/public/verify/${ID}`, small)).status, 200); // 3
  const reads = g.calls.reads;
  const over = await get(h, `/public/verify/${ID}`, small);
  assert.equal(over.status, 429);
  assert.deepEqual(await over.json(), { error: 'quota', retryAfterHours: 24 });
  assert.equal((await get(h, '/public/announcements', small)).status, 429);
  assert.equal(g.calls.reads, reads);
  // A new quota day (midnight Pacific) starts from zero.
  const tomorrow = createHandler({ fetchFn: g.fetchFn, nowMs: () => NOW + 24 * 3600e3, quotaFor: () => quota, cache: null });
  assert.equal((await get(tomorrow, `/public/verify/${ID}`, small)).status, 200);
});

test('PUBLIC_DAILY_READS: a number (0 = off), else the default', () => {
  assert.equal(publicLimit('0'), 0);
  assert.equal(publicLimit('100'), 100);
  for (const v of [undefined, '', 'abc', '-5']) assert.equal(publicLimit(v), 7500);
});

test('the default share is 15% of 50,000', async () => {
  const quota = memoryQuota();
  quota.days.set(quotaDay(NOW), 7499);
  const h = createHandler({ fetchFn: fakeGoogle().fetchFn, nowMs: () => NOW, quotaFor: () => quota, cache: null });
  assert.equal((await get(h, `/public/verify/${ID}`)).status, 200);
  assert.equal((await get(h, `/public/verify/${ID}`)).status, 429);
});

test('a cached record costs nothing and is not counted; not-found is never cached', async () => {
  const g = fakeGoogle();
  const quota = memoryQuota();
  const h = createHandler({ fetchFn: g.fetchFn, nowMs: () => NOW, quotaFor: () => quota, cache: memoryCache() });
  for (let i = 0; i < 3; i++) assert.equal((await get(h, `/public/verify/${ID}`)).status, 200);
  for (let i = 0; i < 2; i++) assert.equal((await get(h, '/public/verify/ABCDEFGHJKMNPQRSTVWXYZ23')).status, 404);
  assert.equal(g.calls.reads, 3);
  assert.equal(quota.days.get(quotaDay(NOW)), 3);
});

test('without the counter binding the public routes refuse (fail closed)', async () => {
  const h = createHandler({ fetchFn: fakeGoogle().fetchFn, nowMs: () => NOW, quotaFor: () => null, cache: null });
  assert.equal((await get(h, `/public/verify/${ID}`)).status, 503);
});

test('quota day follows Pacific time; Firestore values become plain JSON', () => {
  assert.equal(quotaDay(Date.UTC(2026, 9, 11, 6)), '2026-10-10'); // 23:00 PDT
  assert.equal(quotaDay(Date.UTC(2026, 9, 11, 8)), '2026-10-11'); // 01:00 PDT
  assert.deepEqual(plain(arr([s('a'), { integerValue: '2' }, { nullValue: null }])), ['a', 2, null]);
});
