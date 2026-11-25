// «كتب خارجية» (externalNotices): letters issued outside the app, added or
// deleted by whoever manages the stage; read by them only.
import { describe, it, before, beforeEach, after } from 'node:test';
import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import {
  collection, deleteDoc, doc, getDocs, query, serverTimestamp, setDoc, updateDoc, where, Timestamp,
} from 'firebase/firestore';
import { createEnv, seed, as, SUPER, SM3, T1, T2, COURSE, COURSE_EVE } from './helpers.js';

let env;
before(async () => { env = await createEnv(); });
beforeEach(async () => { await env.clearFirestore(); await seed(env); });
after(async () => { await env.cleanup(); });

const notice = (by, extra = {}) => ({
  studentId: '1001', stageId: '3-morning', courseIds: [COURSE], level: 'alert',
  date: Timestamp.fromDate(new Date(Date.UTC(2026, 10, 10))), reference: '12/ت', note: '',
  createdBy: by, createdAt: serverTimestamp(), departmentId: 'cs', ...extra,
});

describe('external letters', () => {
  it('a stage manager adds one for their stage, reads and deletes it; edits are refused', async () => {
    const db = as(env, SM3);
    await assertSucceeds(setDoc(doc(db, 'externalNotices', 'n1'), notice(SM3)));
    await assertSucceeds(getDocs(query(collection(db, 'externalNotices'), where('stageId', '==', '3-morning'))));
    await assertFails(updateDoc(doc(db, 'externalNotices', 'n1'), { level: 'warning' }));
    await assertSucceeds(deleteDoc(doc(db, 'externalNotices', 'n1')));
  });

  it('refused for another stage, for teachers, in someone else\'s name or malformed', async () => {
    await assertFails(setDoc(doc(as(env, SM3), 'externalNotices', 'n1'),
      notice(SM3, { stageId: '1-evening', courseIds: [COURSE_EVE] })));
    await assertFails(setDoc(doc(as(env, T1), 'externalNotices', 'n1'), notice(T1)));
    await assertFails(setDoc(doc(as(env, SM3), 'externalNotices', 'n1'), notice(SUPER)));
    await assertFails(setDoc(doc(as(env, SM3), 'externalNotices', 'n1'), notice(SM3, { level: 'none' })));
    await assertFails(setDoc(doc(as(env, SM3), 'externalNotices', 'n1'), notice(SM3, { courseIds: [] })));
    await assertFails(setDoc(doc(as(env, SM3), 'externalNotices', 'n1'), notice(SM3, { extra: 1 })));
    await assertSucceeds(setDoc(doc(as(env, SUPER), 'externalNotices', 'n2'),
      notice(SUPER, { studentId: '2001', stageId: '1-evening', courseIds: [COURSE_EVE] })));
  });

  it('teachers do not read them', async () => {
    await assertSucceeds(setDoc(doc(as(env, SM3), 'externalNotices', 'n1'), notice(SM3)));
    await assertFails(getDocs(query(collection(as(env, T1), 'externalNotices'), where('stageId', '==', '3-morning'))));
    await assertFails(getDocs(query(collection(as(env, T2), 'externalNotices'), where('stageId', '==', '3-morning'))));
  });
});
