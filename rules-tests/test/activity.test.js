// «متابعة التدريسيين»: presence/{email} written by the account's own app
// (server time only), read by the super admin; inbox/{email}/items written
// by the super admin, read and deleted by its owner.
import { describe, it, before, beforeEach, after } from 'node:test';
import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import {
  collection, deleteDoc, doc, getDoc, getDocs, limit, orderBy, query, serverTimestamp, setDoc, Timestamp, where,
} from 'firebase/firestore';
import { createEnv, seed, as, SUPER, DEPUTY, SM3, T1, T2 } from './helpers.js';

let env;
before(async () => { env = await createEnv(); });
beforeEach(async () => { await env.clearFirestore(); await seed(env); });
after(async () => { await env.cleanup(); });

const seen = (email) => ({
  email, lastSeenAt: serverTimestamp(), platform: 'android', appVersion: '1.3.0', departmentId: 'cs',
});

describe('presence', () => {
  it('an account records its own last seen and upload', async () => {
    const ref = doc(as(env, T1), 'presence', T1);
    await assertSucceeds(setDoc(ref, seen(T1), { merge: true }));
    await assertSucceeds(setDoc(ref, { email: T1, lastSeenAt: serverTimestamp(), lastUploadAt: serverTimestamp() },
      { merge: true }));
    // A later «seen» keeps the stored upload time.
    await assertSucceeds(setDoc(ref, seen(T1), { merge: true }));
  });

  it('nobody writes another account’s presence or a made-up time', async () => {
    await assertFails(setDoc(doc(as(env, T1), 'presence', T2), seen(T2), { merge: true }));
    await assertFails(setDoc(doc(as(env, SUPER), 'presence', T1), seen(T1), { merge: true }));
    await assertFails(setDoc(doc(as(env, T1), 'presence', T1),
      { ...seen(T1), lastSeenAt: Timestamp.fromDate(new Date(2030, 0, 1)) }));
    await assertFails(setDoc(doc(as(env, T1), 'presence', T1),
      { ...seen(T1), lastUploadAt: Timestamp.fromDate(new Date(2030, 0, 1)) }));
    await assertFails(setDoc(doc(as(env, T1), 'presence', T1), { ...seen(T1), roles: ['superAdmin'] }));
  });

  it('only the super admin reads it', async () => {
    await assertSucceeds(setDoc(doc(as(env, T1), 'presence', T1), seen(T1)));
    await assertSucceeds(getDocs(collection(as(env, SUPER), 'presence')));
    await assertFails(getDocs(collection(as(env, DEPUTY), 'presence')));
    await assertFails(getDocs(collection(as(env, SM3), 'presence')));
    await assertFails(getDoc(doc(as(env, T1), 'presence', T1)));
  });

  it('the super admin lists a teacher’s lectures, latest first, and counts them', async () => {
    const q = query(collection(as(env, SUPER), 'sessions'), where('openedBy', '==', T1));
    await assertSucceeds(getDocs(query(q, orderBy('date', 'desc'), limit(5))));
  });
});

const message = (by) => ({ title: 'سجّل حضورك', body: 'تذكير', createdBy: by, createdAt: serverTimestamp(), departmentId: 'cs' });

describe('inbox', () => {
  it('the super admin sends; the owner reads and deletes', async () => {
    const ref = doc(collection(as(env, SUPER), 'inbox', T1, 'items'));
    await assertSucceeds(setDoc(ref, message(SUPER)));
    await assertSucceeds(getDocs(query(collection(as(env, T1), 'inbox', T1, 'items'), orderBy('createdAt', 'desc'), limit(30))));
    await assertSucceeds(deleteDoc(doc(as(env, T1), 'inbox', T1, 'items', ref.id)));
  });

  it('others neither send nor read someone else’s', async () => {
    await assertFails(setDoc(doc(collection(as(env, DEPUTY), 'inbox', T1, 'items')), message(DEPUTY)));
    await assertFails(setDoc(doc(collection(as(env, T2), 'inbox', T1, 'items')), message(T2)));
    await assertFails(setDoc(doc(collection(as(env, SUPER), 'inbox', T1, 'items')), message(T1)));
    await assertFails(setDoc(doc(collection(as(env, SUPER), 'inbox', T1, 'items')), { ...message(SUPER), audience: 'all' }));
    await assertFails(getDocs(collection(as(env, T2), 'inbox', T1, 'items')));
  });
});
