// The two collections the public web pages read without signing in:
// reportVerifications (the QR on every issued PDF → web/verify.html) and
// announcements (the department's QR poster → web/announcements.html).
import { describe, it, before, beforeEach, after } from 'node:test';
import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import {
  collection, deleteDoc, doc, getDoc, getDocs, limit, orderBy, query, serverTimestamp, setDoc, Timestamp, updateDoc,
} from 'firebase/firestore';
import { createEnv, seed, as, SUPER, DEPUTY, SM3, T1, SUSPENDED, STRANGER } from './helpers.js';

let env;
before(async () => { env = await createEnv(); });
beforeEach(async () => { await env.clearFirestore(); await seed(env); });
after(async () => { await env.cleanup(); });

const anon = () => env.unauthenticatedContext().firestore();

const RID = 'K7QM2XRT9HBWPZ4NCV8DJEAF'; // 24 characters of ReportRecord.alphabet

const record = (by, extra = {}) => ({
  title: 'كتاب إنذار',
  meta: ['المرحلة الثالثة — صباحي'],
  paragraphs: ['نود إعلامكم…'],
  tables: [{ heading: '', columns: ['الاسم', 'الرقم الجامعي'], rows: [{ c: ['طالب تجريبي', '2023001'] }] }],
  notes: [],
  signatures: ['رئيس القسم'],
  issuedBy: by,
  issuerName: 'مستخدم',
  issuedAt: serverTimestamp(),
  departmentId: 'cs',
  ...extra,
});

describe('reportVerifications', () => {
  it('any active account issues a record for itself', async () => {
    await assertSucceeds(setDoc(doc(as(env, T1), 'reportVerifications', RID), record(T1)));
    await assertSucceeds(setDoc(doc(as(env, SUPER), 'reportVerifications', 'ABCDEFGHJKMNPQRSTVWXYZ23'), record(SUPER)));
  });

  it('anyone holding the ID reads it, nobody lists them', async () => {
    await assertSucceeds(setDoc(doc(as(env, T1), 'reportVerifications', RID), record(T1)));
    await assertSucceeds(getDoc(doc(anon(), 'reportVerifications', RID)));
    await assertFails(getDocs(collection(anon(), 'reportVerifications')));
    await assertFails(getDocs(query(collection(as(env, SUPER), 'reportVerifications'), limit(1))));
  });

  it('refuses another issuer, a made-up time, a guessable ID or extra fields', async () => {
    const ref = doc(as(env, T1), 'reportVerifications', RID);
    await assertFails(setDoc(ref, record(SUPER)));
    await assertFails(setDoc(ref, record(T1, { issuedAt: Timestamp.fromDate(new Date(2020, 0, 1)) })));
    await assertFails(setDoc(ref, record(T1, { verified: true })));
    await assertFails(setDoc(ref, record(T1, { title: '' })));
    await assertFails(setDoc(doc(as(env, T1), 'reportVerifications', 'report-1'), record(T1)));
    await assertFails(setDoc(doc(as(env, T1), 'reportVerifications', 'k7qm2xrt9hbwpz4ncv8djeaf'), record(T1)));
  });

  it('refuses accounts that are not active and visitors', async () => {
    await assertFails(setDoc(doc(as(env, SUSPENDED), 'reportVerifications', RID), record(SUSPENDED)));
    await assertFails(setDoc(doc(as(env, STRANGER), 'reportVerifications', RID), record(STRANGER)));
    await assertFails(setDoc(doc(anon(), 'reportVerifications', RID), record(T1)));
  });

  it('a record is never changed or removed, even by its issuer or an admin', async () => {
    await assertSucceeds(setDoc(doc(as(env, T1), 'reportVerifications', RID), record(T1)));
    await assertFails(setDoc(doc(as(env, T1), 'reportVerifications', RID), record(T1, { title: 'غيره' })));
    await assertFails(updateDoc(doc(as(env, SUPER), 'reportVerifications', RID), { title: 'غيره' }));
    await assertFails(deleteDoc(doc(as(env, SUPER), 'reportVerifications', RID)));
  });
});

const announcement = (by, extra = {}) => ({
  title: 'موعد الامتحانات',
  body: 'تبدأ الامتحانات النهائية يوم الأحد.',
  createdBy: by,
  createdAt: serverTimestamp(),
  departmentId: 'cs',
  ...extra,
});

describe('announcements', () => {
  it('admins publish, edit and delete them', async () => {
    const ref = doc(as(env, SUPER), 'announcements', 'a1');
    await assertSucceeds(setDoc(ref, announcement(SUPER)));
    await assertSucceeds(setDoc(doc(as(env, DEPUTY), 'announcements', 'a2'), announcement(DEPUTY)));
    await assertSucceeds(updateDoc(doc(as(env, DEPUTY), 'announcements', 'a1'),
      { title: 'موعد معدّل', body: '', updatedBy: DEPUTY, updatedAt: serverTimestamp() }));
    await assertSucceeds(deleteDoc(doc(as(env, DEPUTY), 'announcements', 'a1')));
  });

  it('others cannot write them', async () => {
    await assertFails(setDoc(doc(as(env, SM3), 'announcements', 'a1'), announcement(SM3)));
    await assertFails(setDoc(doc(as(env, T1), 'announcements', 'a1'), announcement(T1)));
    await assertFails(setDoc(doc(anon(), 'announcements', 'a1'), announcement(T1)));
    await assertSucceeds(setDoc(doc(as(env, SUPER), 'announcements', 'a1'), announcement(SUPER)));
    await assertFails(deleteDoc(doc(as(env, T1), 'announcements', 'a1')));
    await assertFails(updateDoc(doc(as(env, SM3), 'announcements', 'a1'),
      { title: 'x', updatedBy: SM3, updatedAt: serverTimestamp() }));
  });

  it('an edit keeps the author and date, and records the editor', async () => {
    await assertSucceeds(setDoc(doc(as(env, SUPER), 'announcements', 'a1'), announcement(SUPER)));
    const ref = doc(as(env, DEPUTY), 'announcements', 'a1');
    await assertFails(updateDoc(ref, { createdBy: DEPUTY, updatedBy: DEPUTY, updatedAt: serverTimestamp() }));
    await assertFails(updateDoc(ref, { title: 'x', updatedBy: SUPER, updatedAt: serverTimestamp() }));
    await assertFails(updateDoc(ref, { title: 'x', updatedBy: DEPUTY, updatedAt: Timestamp.fromDate(new Date(2020, 0, 1)) }));
    await assertFails(setDoc(doc(as(env, SUPER), 'announcements', 'a2'), announcement(SUPER, { title: '' })));
    await assertFails(setDoc(doc(as(env, SUPER), 'announcements', 'a2'), announcement(DEPUTY)));
  });

  it('visitors read the latest 30 without signing in, not more at once', async () => {
    await assertSucceeds(setDoc(doc(as(env, SUPER), 'announcements', 'a1'), announcement(SUPER)));
    const col = collection(anon(), 'announcements');
    await assertSucceeds(getDocs(query(col, orderBy('createdAt', 'desc'), limit(30))));
    await assertSucceeds(getDoc(doc(anon(), 'announcements', 'a1')));
    await assertFails(getDocs(query(col, orderBy('createdAt', 'desc'), limit(31))));
    await assertFails(getDocs(col));
  });
});
