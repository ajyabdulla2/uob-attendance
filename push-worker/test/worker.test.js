import { test, beforeEach } from 'node:test';
import assert from 'node:assert/strict';
import { createHandler, parseSend, isActiveSuperAdmin } from '../src/index.js';
import { b64url, resetCaches, verifyIdToken } from '../src/google.js';

const PROJECT = 'demo-uob';
const NOW = Date.UTC(2026, 9, 10, 12);
const RS256 = { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' };
const gen = () => crypto.subtle.generateKey(
  { ...RS256, modulusLength: 2048, publicExponent: new Uint8Array([1, 0, 1]) }, true, ['sign', 'verify']);

// Google's ID-token key, and the service account's key.
const google = await gen();
const jwk = { ...(await crypto.subtle.exportKey('jwk', google.publicKey)), kid: 'k1', alg: 'RS256', use: 'sig' };
const sa = await gen();
const pkcs8 = Buffer.from(await crypto.subtle.exportKey('pkcs8', sa.privateKey)).toString('base64');
const SERVICE_ACCOUNT = JSON.stringify({
  client_email: 'push@demo.iam.gserviceaccount.com',
  private_key: `-----BEGIN PRIVATE KEY-----\n${pkcs8}\n-----END PRIVATE KEY-----\n`,
});
const env = { PROJECT_ID: PROJECT, SERVICE_ACCOUNT_JSON: SERVICE_ACCOUNT };

async function idToken(claims, key = google.privateKey, kid = 'k1') {
  const now = Math.floor(NOW / 1000);
  const h = b64url(JSON.stringify({ alg: 'RS256', kid, typ: 'JWT' }));
  const c = b64url(JSON.stringify({
    aud: PROJECT, iss: `https://securetoken.google.com/${PROJECT}`, sub: 'uid', iat: now - 10, exp: now + 3000,
    email_verified: true, ...claims,
  }));
  const sig = await crypto.subtle.sign(RS256, key, new TextEncoder().encode(`${h}.${c}`));
  return `${h}.${c}.${b64url(sig)}`;
}

const SUPER = 'admin@uob.iq';
const userDoc = (roles, active = true) => ({
  fields: { active: { booleanValue: active }, roles: { arrayValue: { values: roles.map((r) => ({ stringValue: r })) } } },
});

/** A fake Google: JWKS, OAuth, Firestore (users + presence) and FCM. */
function fakeGoogle({ users = { [SUPER]: userDoc(['superAdmin']) }, tokens = {}, badTokens = [] } = {}) {
  const calls = { fcm: [] };
  const fetchFn = async (url, init = {}) => {
    const u = String(url);
    const ok = (body, status = 200, headers = {}) => new Response(JSON.stringify(body), { status, headers });
    if (u.includes('securetoken')) return ok({ keys: [jwk] }, 200, { 'cache-control': 'max-age=600' });
    if (u.startsWith('https://oauth2.googleapis.com/token')) {
      const assertion = new URLSearchParams(init.body).get('assertion');
      const [h, c, s] = assertion.split('.');
      const valid = await crypto.subtle.verify(RS256, sa.publicKey,
        Buffer.from(s.replace(/-/g, '+').replace(/_/g, '/'), 'base64'), new TextEncoder().encode(`${h}.${c}`));
      return valid ? ok({ access_token: 'sa-token', expires_in: 3600 }) : ok({ error: 'bad' }, 400);
    }
    assert.equal(init.headers?.authorization, 'Bearer sa-token');
    if (u.endsWith(':batchGet')) {
      const { documents } = JSON.parse(init.body);
      return ok(documents.map((name) => {
        const email = name.split('/presence/')[1];
        return tokens[email]
          ? { found: { name, fields: { pushToken: { stringValue: tokens[email] } } } }
          : { missing: name };
      }));
    }
    const user = /\/documents\/users\/(.+)$/.exec(u);
    if (user) {
      const doc = users[decodeURIComponent(user[1])];
      return doc ? ok(doc) : ok({}, 404);
    }
    if (u.includes('fcm.googleapis.com')) {
      const { message } = JSON.parse(init.body);
      calls.fcm.push(message);
      return badTokens.includes(message.token) ? ok({ error: { status: 'NOT_FOUND' } }, 404) : ok({ name: 'm' });
    }
    throw new Error(`unexpected ${u}`);
  };
  return { fetchFn, calls };
}

const send = (handler, body, token) => handler(new Request('https://w.dev/send', {
  method: 'POST',
  headers: { 'content-type': 'application/json', ...(token ? { authorization: `Bearer ${token}` } : {}) },
  body: JSON.stringify(body),
}), env);

beforeEach(() => resetCaches());

test('the super admin sends to teachers with a device; the others are counted', async () => {
  const g = fakeGoogle({ tokens: { 't1@uob.iq': 'tok1', 't2@uob.iq': 'tok2' }, badTokens: ['tok2'] });
  const res = await send(createHandler({ fetchFn: g.fetchFn, nowMs: () => NOW }),
    { to: ['t1@uob.iq', 'T2@uob.iq', 't3@uob.iq'], title: 'تذكير', body: 'سجّل الحضور' }, await idToken({ email: SUPER }));
  assert.equal(res.status, 200);
  assert.deepEqual(await res.json(), { sent: 1, noDevice: 1, failed: 1 });
  assert.equal(g.calls.fcm[0].notification.title, 'تذكير');
  assert.equal(g.calls.fcm[0].android.notification.channel_id, 'department');
  assert.equal(g.calls.fcm[0].data.route, '/notifications');
});

test('anyone else is refused before anything is sent', async () => {
  const g = fakeGoogle({
    users: { 'dep@uob.iq': userDoc(['deputyAdmin']), 'off@uob.iq': userDoc(['superAdmin'], false) },
    tokens: { 't1@uob.iq': 'tok1' },
  });
  const h = createHandler({ fetchFn: g.fetchFn, nowMs: () => NOW });
  const body = { to: ['t1@uob.iq'], title: 'x' };
  assert.equal((await send(h, body)).status, 401);
  assert.equal((await send(h, body, 'not.a.token')).status, 401);
  assert.equal((await send(h, body, await idToken({ email: 'dep@uob.iq' }))).status, 403);
  assert.equal((await send(h, body, await idToken({ email: 'off@uob.iq' }))).status, 403);
  assert.equal((await send(h, body, await idToken({ email: 'nobody@uob.iq' }))).status, 403);
  assert.equal((await send(h, body, await idToken({ email: SUPER, email_verified: false }))).status, 403);
  // Forged or foreign tokens.
  const other = await gen();
  assert.equal((await send(h, body, await idToken({ email: SUPER }, other.privateKey))).status, 401);
  assert.equal((await send(h, body, await idToken({ email: SUPER, aud: 'other-project' }))).status, 401);
  assert.equal((await send(h, body, await idToken({ email: SUPER, exp: Math.floor(NOW / 1000) - 3600 }))).status, 401);
  assert.equal(g.calls.fcm.length, 0);
});

test('request bodies are bounded', () => {
  assert.equal(parseSend({ to: [], title: 'x' }).error, 'to');
  assert.equal(parseSend({ to: ['a@b'], title: '' }).error, 'title');
  assert.equal(parseSend({ to: ['a@b'], title: 'x'.repeat(121) }).error, 'title');
  assert.equal(parseSend({ to: ['a@b'], title: 'x', body: 'y'.repeat(2001) }).error, 'body');
  assert.equal(parseSend({ to: ['../users/x'], title: 'x' }).error, 'to');
  assert.equal(parseSend({ to: Array.from({ length: 501 }, (_, i) => `t${i}@x`), title: 'x' }).error, 'to');
  assert.deepEqual(parseSend({ to: [' A@B ', 'a@b'], title: ' t ' }), { to: ['a@b'], title: 't', body: '' });
});

test('roles are read from the Firestore REST shape', () => {
  assert.equal(isActiveSuperAdmin(userDoc(['teacher', 'superAdmin']).fields), true);
  assert.equal(isActiveSuperAdmin(userDoc(['deputyAdmin']).fields), false);
  assert.equal(isActiveSuperAdmin(null), false);
});

test('ID tokens: unknown key id is refused', async () => {
  const g = fakeGoogle();
  await assert.rejects(verifyIdToken(await idToken({ email: SUPER }, google.privateKey, 'k2'), PROJECT,
    { fetchFn: g.fetchFn, nowMs: NOW }), /unknown key/);
});

test('web panel preflight gets CORS headers for the app origin only', async () => {
  const h = createHandler({ fetchFn: fakeGoogle().fetchFn, nowMs: () => NOW });
  const pre = (origin) => h(new Request('https://w.dev/send', { method: 'OPTIONS', headers: { origin } }), env);
  assert.equal((await pre('https://basrah-researches.web.app')).headers.get('access-control-allow-origin'),
    'https://basrah-researches.web.app');
  assert.equal((await pre('https://evil.example')).headers.get('access-control-allow-origin'), null);
});
