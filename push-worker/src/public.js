// Public, signed-out reads for the two static pages on Firebase Hosting:
//
//   GET /public/verify/<ID>     web/verify.html: one reportVerifications
//                               record (the QR printed on every issued PDF)
//   GET /public/announcements   web/announcements.html: the latest 30
//
// Firestore's rules no longer let visitors read these collections: this
// worker reads them with its service account, so it can hold all public
// traffic to a daily share of the Spark quota (50,000 document reads a day
// for the whole project, attendance included). Past the share it answers
// 429 and the pages ask the visitor to try again in 24 hours. Cached
// answers cost no Firestore read and are not counted.

/** 15% of Spark's 50,000 reads a day; the PUBLIC_DAILY_READS var overrides it. */
export const PUBLIC_DAILY_READS = 7500;

/** ReportRecord.alphabet × 24 (lib/features/reports/domain/report_record.dart). */
export const RECORD_ID = /^[A-HJKMNP-TV-Z2-9]{24}$/;

export const ANNOUNCEMENTS_LIMIT = 30;

/** Seconds a verified record stays in Cloudflare's cache (it never changes). */
const RECORD_CACHE_S = 7 * 24 * 3600;
const ANNOUNCEMENTS_CACHE_S = 60;

/**
 * The quota day: Firestore's free quota resets at midnight Pacific time.
 * en-CA formats as YYYY-MM-DD.
 */
export function quotaDay(nowMs) {
  return new Intl.DateTimeFormat('en-CA', {
    timeZone: 'America/Los_Angeles', year: 'numeric', month: '2-digit', day: '2-digit',
  }).format(new Date(nowMs));
}

/** Firestore REST values → plain JSON (timestamps as ISO strings). */
export function plain(v) {
  if (v == null) return null;
  if ('stringValue' in v) return v.stringValue;
  if ('integerValue' in v) return Number(v.integerValue);
  if ('doubleValue' in v) return v.doubleValue;
  if ('booleanValue' in v) return v.booleanValue;
  if ('timestampValue' in v) return v.timestampValue;
  if ('nullValue' in v) return null;
  if ('arrayValue' in v) return (v.arrayValue.values ?? []).map(plain);
  if ('mapValue' in v) return plainFields(v.mapValue.fields);
  return null;
}

export const plainFields = (fields) =>
  Object.fromEntries(Object.entries(fields ?? {}).map(([k, v]) => [k, plain(v)]));

/** What a visitor may see of a record (not the issuer's e-mail). */
export function publicRecord(fields) {
  const r = plainFields(fields);
  return {
    title: r.title ?? '',
    meta: r.meta ?? [],
    paragraphs: r.paragraphs ?? [],
    tables: r.tables ?? [],
    notes: r.notes ?? [],
    signatures: r.signatures ?? [],
    issuerName: r.issuerName ?? '',
    issuedAt: r.issuedAt ?? null,
  };
}

export function publicAnnouncement(fields) {
  const a = plainFields(fields);
  return { title: a.title ?? '', body: a.body ?? '', createdAt: a.createdAt ?? null, updatedAt: a.updatedAt ?? null };
}

/** The counter kept by the PublicQuota Durable Object (src/quota.js). */
export function durableQuota(namespace) {
  const stub = namespace.get(namespace.idFromName('public'));
  return {
    used: (day) => stub.used(day),
    add: (day, n) => stub.add(day, n),
  };
}

const CORS = {
  'access-control-allow-origin': '*',
  'access-control-allow-methods': 'GET, OPTIONS',
  'access-control-max-age': '86400',
};

function reply(status, body, cacheSeconds = 0) {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      'content-type': 'application/json; charset=utf-8',
      'cache-control': cacheSeconds ? `public, max-age=${cacheSeconds}` : 'no-store',
      ...CORS,
    },
  });
}

/**
 * Handles /public/*; [read] holds the Firestore calls (service account),
 * [quota] the daily counter, [cache] Cloudflare's cache (or null).
 */
export async function handlePublic(request, { read, quota, cache, limit, nowMs }) {
  if (request.method === 'OPTIONS') return new Response(null, { status: 204, headers: CORS });
  if (request.method !== 'GET') return reply(405, { error: 'method' });
  const url = new URL(request.url);
  const verify = /^\/public\/verify\/([^/]+)$/.exec(url.pathname);
  const isAnnouncements = url.pathname === '/public/announcements';
  if (!verify && !isAnnouncements) return reply(404, { error: 'not-found' });
  if (verify && !RECORD_ID.test(verify[1])) return reply(400, { error: 'invalid-id' });

  // A cached answer reads nothing from Firestore.
  const key = new Request(`${url.origin}${url.pathname}`);
  const hit = cache ? await cache.match(key) : null;
  if (hit) return hit;

  if (!quota) return reply(503, { error: 'not-configured' });
  const day = quotaDay(nowMs());
  if ((await quota.used(day)) >= limit) return reply(429, { error: 'quota', retryAfterHours: 24 });

  let res;
  let reads;
  try {
    if (verify) {
      const fields = await read.record(verify[1]);
      reads = 1; // a missing document is billed as one read too
      res = fields == null
        ? reply(404, { error: 'not-found' })
        : reply(200, { record: publicRecord(fields) }, RECORD_CACHE_S);
    } else {
      const docs = await read.announcements(ANNOUNCEMENTS_LIMIT);
      reads = Math.max(1, docs.length); // a query returning nothing still costs one
      res = reply(200, { items: docs.map(publicAnnouncement) }, ANNOUNCEMENTS_CACHE_S);
    }
  } catch (e) {
    return reply(502, { error: 'upstream' });
  }
  await quota.add(day, reads);
  // Not-found is not cached: a record issued offline appears once the phone syncs.
  if (cache && res.status === 200) await cache.put(key, res.clone());
  return res;
}
