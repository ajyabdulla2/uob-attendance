// Google credentials without any SDK (Cloudflare Workers and Node 20+ both
// have WebCrypto): verify a Firebase ID token, and get an OAuth access token
// for the service account.

const enc = new TextEncoder();

export function b64url(bytes) {
  const s = typeof bytes === 'string' ? bytes : String.fromCharCode(...new Uint8Array(bytes));
  return btoa(s).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
}

export function b64urlDecode(s) {
  const b = atob(s.replace(/-/g, '+').replace(/_/g, '/') + '='.repeat((4 - (s.length % 4)) % 4));
  return Uint8Array.from(b, (c) => c.charCodeAt(0));
}

const RS256 = { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' };

export const SECURETOKEN_JWKS =
  'https://www.googleapis.com/service_accounts/v1/jwk/securetoken@system.gserviceaccount.com';

let jwksCache = { keys: null, until: 0 };

/** Google's current signing keys for Firebase ID tokens (cached per max-age). */
async function signingKeys(fetchFn, nowMs) {
  if (jwksCache.keys && nowMs < jwksCache.until) return jwksCache.keys;
  const res = await fetchFn(SECURETOKEN_JWKS);
  if (!res.ok) throw new Error(`jwks ${res.status}`);
  const { keys } = await res.json();
  const maxAge = Number(/max-age=(\d+)/.exec(res.headers.get('cache-control') ?? '')?.[1] ?? 3600);
  jwksCache = { keys, until: nowMs + maxAge * 1000 };
  return keys;
}

export function resetCaches() {
  jwksCache = { keys: null, until: 0 };
  tokenCache = { token: null, until: 0 };
}

/**
 * The claims of a valid Firebase ID token of [projectId], or throws.
 * https://firebase.google.com/docs/auth/admin/verify-id-tokens#verify_id_tokens_using_a_third-party_jwt_library
 */
export async function verifyIdToken(idToken, projectId, { fetchFn = fetch, nowMs = Date.now() } = {}) {
  const parts = (idToken ?? '').split('.');
  if (parts.length !== 3) throw new Error('malformed token');
  const header = JSON.parse(new TextDecoder().decode(b64urlDecode(parts[0])));
  const claims = JSON.parse(new TextDecoder().decode(b64urlDecode(parts[1])));
  if (header.alg !== 'RS256') throw new Error('bad alg');
  const jwk = (await signingKeys(fetchFn, nowMs)).find((k) => k.kid === header.kid);
  if (!jwk) throw new Error('unknown key');
  const key = await crypto.subtle.importKey('jwk', jwk, RS256, false, ['verify']);
  const ok = await crypto.subtle.verify(RS256, key, b64urlDecode(parts[2]), enc.encode(`${parts[0]}.${parts[1]}`));
  if (!ok) throw new Error('bad signature');
  const now = Math.floor(nowMs / 1000);
  const skew = 60;
  if (claims.aud !== projectId) throw new Error('bad audience');
  if (claims.iss !== `https://securetoken.google.com/${projectId}`) throw new Error('bad issuer');
  if (!(claims.exp > now - skew)) throw new Error('expired');
  if (!(claims.iat <= now + skew)) throw new Error('issued in the future');
  if (!claims.sub) throw new Error('no subject');
  return claims;
}

function pemToPkcs8(pem) {
  const body = pem.replace(/-----[^-]+-----/g, '').replace(/\s+/g, '');
  return Uint8Array.from(atob(body), (c) => c.charCodeAt(0));
}

export const SCOPES = [
  'https://www.googleapis.com/auth/datastore',
  'https://www.googleapis.com/auth/firebase.messaging',
];

let tokenCache = { token: null, until: 0 };

/** An OAuth access token for the service account (cached until near expiry). */
export async function accessToken(serviceAccount, { fetchFn = fetch, nowMs = Date.now() } = {}) {
  if (tokenCache.token && nowMs < tokenCache.until) return tokenCache.token;
  const iat = Math.floor(nowMs / 1000);
  const header = b64url(JSON.stringify({ alg: 'RS256', typ: 'JWT' }));
  const claims = b64url(JSON.stringify({
    iss: serviceAccount.client_email,
    scope: SCOPES.join(' '),
    aud: 'https://oauth2.googleapis.com/token',
    iat,
    exp: iat + 3600,
  }));
  const key = await crypto.subtle.importKey('pkcs8', pemToPkcs8(serviceAccount.private_key), RS256, false, ['sign']);
  const sig = await crypto.subtle.sign(RS256, key, enc.encode(`${header}.${claims}`));
  const res = await fetchFn('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'content-type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
      assertion: `${header}.${claims}.${b64url(sig)}`,
    }),
  });
  if (!res.ok) throw new Error(`oauth ${res.status}: ${await res.text()}`);
  const { access_token: token, expires_in: ttl } = await res.json();
  tokenCache = { token, until: nowMs + (Number(ttl ?? 3600) - 120) * 1000 };
  return token;
}
