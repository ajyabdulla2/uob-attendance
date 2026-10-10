// uob-push: sends phone notifications (FCM) for the attendance app, which
// runs on Firebase's free Spark plan (no Cloud Functions).
//
//   POST /send   Authorization: Bearer <Firebase ID token>
//                {"to": ["teacher@…"], "title": "…", "body": "…"}
//     Only an active super admin (users/{email}.roles has superAdmin) may
//     send. Device tokens come from presence/{email}.pushToken, written by
//     each teacher's own app. Answers {"sent", "noDevice", "failed"}.
//   GET /health  whether the service account can read Firestore and send.
//
// Secrets/vars (wrangler): SERVICE_ACCOUNT_JSON (roles: Cloud Datastore
// Viewer + Firebase Cloud Messaging API Admin), PROJECT_ID.
import { accessToken, verifyIdToken } from './google.js';

export const LIMITS = { recipients: 500, title: 120, body: 2000 };

const ALLOWED_ORIGINS = new Set([
  'https://basrah-researches.web.app',
  'https://basrah-researches.firebaseapp.com',
  'http://localhost:8080',
]);

function cors(origin) {
  return ALLOWED_ORIGINS.has(origin)
    ? {
        'access-control-allow-origin': origin,
        'access-control-allow-methods': 'POST, GET, OPTIONS',
        'access-control-allow-headers': 'authorization, content-type',
        'access-control-max-age': '86400',
        vary: 'origin',
      }
    : {};
}

function json(status, body, origin) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { 'content-type': 'application/json; charset=utf-8', ...cors(origin) },
  });
}

// Calls fetch as a plain function: Cloudflare Workers throw «Illegal
// invocation» when it is called as a method of the context object.
function callFetch(ctx, url, init) {
  const fetchFn = ctx.fetch;
  return fetchFn(url, init);
}

const firestoreBase = (projectId) =>
  `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents`;

async function getDoc(path, ctx) {
  const res = await callFetch(ctx, `${firestoreBase(ctx.projectId)}/${path}`, {
    headers: { authorization: `Bearer ${ctx.token}` },
  });
  if (res.status === 404) return null;
  if (!res.ok) throw new Error(`firestore ${res.status}: ${await res.text()}`);
  return (await res.json()).fields ?? {};
}

async function getDocs(paths, ctx) {
  const prefix = `projects/${ctx.projectId}/databases/(default)/documents`;
  const res = await callFetch(ctx, `${firestoreBase(ctx.projectId)}:batchGet`, {
    method: 'POST',
    headers: { authorization: `Bearer ${ctx.token}`, 'content-type': 'application/json' },
    body: JSON.stringify({ documents: paths.map((p) => `${prefix}/${p}`) }),
  });
  if (!res.ok) throw new Error(`firestore ${res.status}: ${await res.text()}`);
  const out = new Map();
  for (const r of await res.json()) {
    if (r.found) out.set(r.found.name.slice(prefix.length + 1), r.found.fields ?? {});
  }
  return out;
}

export function isActiveSuperAdmin(fields) {
  if (!fields || fields.active?.booleanValue !== true) return false;
  const roles = fields.roles?.arrayValue?.values ?? [];
  return roles.some((v) => v.stringValue === 'superAdmin');
}

async function sendOne(token, title, body, ctx) {
  const res = await callFetch(ctx, `https://fcm.googleapis.com/v1/projects/${ctx.projectId}/messages:send`, {
    method: 'POST',
    headers: { authorization: `Bearer ${ctx.token}`, 'content-type': 'application/json' },
    body: JSON.stringify({
      message: {
        token,
        notification: { title, body },
        data: { route: '/notifications' },
        android: { priority: 'HIGH', notification: { channel_id: 'department', sound: 'default' } },
      },
    }),
  });
  return res.ok;
}

/** Validates a /send request body; returns the cleaned fields or an error. */
export function parseSend(body) {
  if (!body || typeof body !== 'object') return { error: 'body' };
  const to = Array.isArray(body.to) ? [...new Set(body.to.map((e) => String(e).trim().toLowerCase()).filter(Boolean))] : [];
  const title = typeof body.title === 'string' ? body.title.trim() : '';
  const text = typeof body.body === 'string' ? body.body.trim() : '';
  if (to.length === 0 || to.length > LIMITS.recipients) return { error: 'to' };
  if (!title || title.length > LIMITS.title) return { error: 'title' };
  if (text.length > LIMITS.body) return { error: 'body' };
  if (to.some((e) => e.includes('/'))) return { error: 'to' };
  return { to, title, body: text };
}

export function createHandler({ fetchFn = fetch, nowMs = () => Date.now() } = {}) {
  return async function handle(request, env) {
    const origin = request.headers.get('origin') ?? '';
    const url = new URL(request.url);
    if (request.method === 'OPTIONS') return new Response(null, { status: 204, headers: cors(origin) });
    const projectId = env.PROJECT_ID;
    let serviceAccount;
    try {
      serviceAccount = JSON.parse(env.SERVICE_ACCOUNT_JSON ?? '');
    } catch {
      return json(500, { error: 'not-configured' }, origin);
    }
    const google = { fetchFn, nowMs: nowMs() };

    if (request.method === 'GET' && url.pathname === '/health') {
      const out = { firestore: false, fcm: false };
      try {
        const ctx = { fetch: fetchFn, projectId, token: await accessToken(serviceAccount, google) };
        out.firestore = (await getDoc('config/app', ctx)) !== undefined;
        // validate_only with a dummy token: 400 means FCM is reachable and
        // the role works; 403 means the API is off or the role is missing.
        const res = await fetchFn(`https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`, {
          method: 'POST',
          headers: { authorization: `Bearer ${ctx.token}`, 'content-type': 'application/json' },
          body: JSON.stringify({ validate_only: true, message: { token: 'health-check', notification: { title: 'x' } } }),
        });
        out.fcm = res.ok || res.status === 400;
        if (!out.fcm) out.fcmStatus = res.status;
      } catch (e) {
        out.error = String(e.message ?? e);
      }
      return json(out.firestore && out.fcm ? 200 : 503, out, origin);
    }

    if (request.method !== 'POST' || url.pathname !== '/send') return json(404, { error: 'not-found' }, origin);

    let claims;
    try {
      const bearer = /^Bearer (.+)$/.exec(request.headers.get('authorization') ?? '')?.[1];
      claims = await verifyIdToken(bearer, projectId, google);
    } catch {
      return json(401, { error: 'unauthenticated' }, origin);
    }
    const email = String(claims.email ?? '').toLowerCase();
    if (!email || claims.email_verified !== true) return json(403, { error: 'permission-denied' }, origin);

    let parsed;
    try {
      parsed = parseSend(await request.json());
    } catch {
      parsed = { error: 'body' };
    }
    if (parsed.error) return json(400, { error: `invalid-${parsed.error}` }, origin);

    try {
      const ctx = { fetch: fetchFn, projectId, token: await accessToken(serviceAccount, google) };
      if (!isActiveSuperAdmin(await getDoc(`users/${encodeURIComponent(email)}`, ctx))) {
        return json(403, { error: 'permission-denied' }, origin);
      }
      const presence = await getDocs(parsed.to.map((e) => `presence/${e}`), ctx);
      let sent = 0, noDevice = 0, failed = 0;
      const tokens = [];
      for (const to of parsed.to) {
        const token = presence.get(`presence/${to}`)?.pushToken?.stringValue;
        if (token) tokens.push(token);
        else noDevice++;
      }
      // A few dozen teachers at most: small parallel groups.
      for (let i = 0; i < tokens.length; i += 20) {
        const results = await Promise.all(tokens.slice(i, i + 20).map((t) => sendOne(t, parsed.title, parsed.body, ctx)));
        for (const ok of results) ok ? sent++ : failed++;
      }
      return json(200, { sent, noDevice, failed }, origin);
    } catch (e) {
      return json(502, { error: 'upstream', detail: String(e.message ?? e).slice(0, 300) }, origin);
    }
  };
}

const handle = createHandler();
export default { fetch: (request, env) => handle(request, env) };
