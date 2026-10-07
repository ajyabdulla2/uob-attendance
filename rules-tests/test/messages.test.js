// رسائل الإدارة: admins write to anyone, stage managers to their stages;
// every active account reads; nobody edits.
import { describe, it, before, beforeEach, after } from 'node:test';
import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import { collection, deleteDoc, doc, getDocs, limit, orderBy, query, serverTimestamp, setDoc, updateDoc } from 'firebase/firestore';
import { createEnv, seed, as, SUPER, SM3, T1, SUSPENDED, STRANGER } from './helpers.js';

let env;
before(async () => { env = await createEnv(); });
beforeEach(async () => { await env.clearFirestore(); await seed(env); });
after(async () => { await env.cleanup(); });

const msg = (by, extra = {}) => ({
  title: 'اجتماع القسم', body: 'غداً الساعة 10', audience: 'all', createdBy: by,
  createdAt: serverTimestamp(), departmentId: 'cs', ...extra,
});

describe('messages', () => {
  it('admins send to everyone; stage managers only to their stage', async () => {
    await assertSucceeds(setDoc(doc(as(env, SUPER), 'messages', 'm1'), msg(SUPER)));
    await assertSucceeds(setDoc(doc(as(env, SM3), 'messages', 'm2'), msg(SM3, { audience: 'stage', stageId: '3-morning' })));
    await assertFails(setDoc(doc(as(env, SM3), 'messages', 'm3'), msg(SM3)));
    await assertFails(setDoc(doc(as(env, SM3), 'messages', 'm4'), msg(SM3, { audience: 'stage', stageId: '1-evening' })));
    await assertFails(setDoc(doc(as(env, T1), 'messages', 'm5'), msg(T1)));
  });

  it('the sender, a server time and known fields are required', async () => {
    const db = as(env, SUPER);
    await assertFails(setDoc(doc(db, 'messages', 'x1'), msg(T1)));
    await assertFails(setDoc(doc(db, 'messages', 'x2'), { ...msg(SUPER), createdAt: new Date(2020, 1, 1) }));
    await assertFails(setDoc(doc(db, 'messages', 'x3'), msg(SUPER, { extra: 1 })));
    await assertFails(setDoc(doc(db, 'messages', 'x4'), msg(SUPER, { title: '' })));
    await assertFails(setDoc(doc(db, 'messages', 'x5'), msg(SUPER, { audience: 'stage' })));
  });

  it('active accounts read; nobody edits; the sender or an admin deletes', async () => {
    await setDoc(doc(as(env, SM3), 'messages', 'm'), msg(SM3, { audience: 'stage', stageId: '3-morning' }));
    await assertSucceeds(getDocs(query(collection(as(env, T1), 'messages'), orderBy('createdAt', 'desc'), limit(30))));
    await assertFails(getDocs(collection(as(env, SUSPENDED), 'messages')));
    await assertFails(getDocs(collection(as(env, STRANGER), 'messages')));
    await assertFails(updateDoc(doc(as(env, SM3), 'messages', 'm'), { title: 'تعديل' }));
    await assertFails(deleteDoc(doc(as(env, T1), 'messages', 'm')));
    await assertSucceeds(deleteDoc(doc(as(env, SM3), 'messages', 'm')));
  });
});
