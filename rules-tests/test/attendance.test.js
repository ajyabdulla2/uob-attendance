// sessions, records, stats and edit requests (locking rules).
import { describe, it, before, beforeEach, after } from 'node:test';
import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import {
  doc, getDoc, increment, serverTimestamp, setDoc, updateDoc, writeBatch, Timestamp,
} from 'firebase/firestore';
import {
  createEnv, seed, as, sessionData, sessionId, utcMidnight, lockAtFor, HOUR,
  SUPER, SM3, T1, T2, COURSE, OPEN_SID, LOCKED_SID, EXPIRED_SID,
} from './helpers.js';

let env;
before(async () => { env = await createEnv(); });
beforeEach(async () => { await env.clearFirestore(); await seed(env); });
after(async () => { await env.cleanup(); });

const record = (studentId, status, by) => ({
  studentId, status, note: '', updatedBy: by, updatedAt: serverTimestamp(),
});

describe('opening a session', () => {
  it('assigned teacher opens today\'s session together with its records (one batch)', async () => {
    const db = as(env, T1);
    const sid = sessionId(COURSE, 'theory', 'all', utcMidnight(0), 2);
    const batch = writeBatch(db);
    batch.set(doc(db, 'sessions', sid), sessionData({ lectureNo: 2, updatedAt: serverTimestamp() }));
    batch.set(doc(db, 'sessions', sid, 'records', '1001'), record('1001', 'absent', T1));
    await assertSucceeds(batch.commit());
  });

  it('assigned teacher opens a practical session for their group only', async () => {
    const db = as(env, T1);
    const sidA = sessionId(COURSE, 'practical', 'A', utcMidnight(0));
    await assertSucceeds(setDoc(doc(db, 'sessions', sidA),
      sessionData({ type: 'practical', target: 'A', updatedAt: serverTimestamp() })));
    const sidB = sessionId(COURSE, 'practical', 'B', utcMidnight(0));
    await assertFails(setDoc(doc(db, 'sessions', sidB),
      sessionData({ type: 'practical', target: 'B', updatedAt: serverTimestamp() })));
  });

  it('a teacher without an assignment cannot open a session', async () => {
    const db = as(env, T2);
    const sid = sessionId(COURSE, 'theory', 'all', utcMidnight(0), 3);
    await assertFails(setDoc(doc(db, 'sessions', sid),
      sessionData({ lectureNo: 3, openedBy: T2, updatedAt: serverTimestamp() })));
  });

  it('a teacher cannot choose their own lock deadline, open it pre-locked-free in the future, or forge ids', async () => {
    const db = as(env, T1);
    const today = utcMidnight(0);
    const sid = sessionId(COURSE, 'theory', 'all', today, 4);
    await assertFails(setDoc(doc(db, 'sessions', sid), sessionData({
      lectureNo: 4, lockAt: new Date(today.getTime() + 1000 * HOUR), updatedAt: serverTimestamp(),
    })));
    const future = utcMidnight(5);
    await assertFails(setDoc(doc(db, 'sessions', sessionId(COURSE, 'theory', 'all', future)),
      sessionData({ date: future, updatedAt: serverTimestamp() })));
    await assertFails(setDoc(doc(db, 'sessions', 'random-id'), sessionData({ updatedAt: serverTimestamp() })));
  });

  it('a teacher cannot open a session whose lock window already passed', async () => {
    const old = utcMidnight(-20);
    await assertFails(setDoc(doc(as(env, T1), 'sessions', sessionId(COURSE, 'theory', 'all', old)),
      sessionData({ date: old, lockAt: lockAtFor(old), updatedAt: serverTimestamp() })));
  });

  it('stage manager can open (back-dated) sessions in their stage', async () => {
    const old = utcMidnight(-20);
    await assertSucceeds(setDoc(doc(as(env, SM3), 'sessions', sessionId(COURSE, 'theory', 'all', old)),
      sessionData({ date: old, openedBy: SM3, updatedAt: serverTimestamp() })));
  });

  it('requires a server timestamp', async () => {
    const sid = sessionId(COURSE, 'theory', 'all', utcMidnight(0), 5);
    await assertFails(setDoc(doc(as(env, T1), 'sessions', sid),
      sessionData({ lectureNo: 5, updatedAt: Timestamp.fromDate(new Date(2020, 1, 1)) })));
  });
});

describe('records and locking', () => {
  it('assigned teacher edits records of an open session', async () => {
    await assertSucceeds(setDoc(doc(as(env, T1), 'sessions', OPEN_SID, 'records', '1001'), record('1001', 'late', T1)));
  });

  it('assigned teacher cannot edit a locked or expired session (needs an edit request)', async () => {
    await assertFails(setDoc(doc(as(env, T1), 'sessions', LOCKED_SID, 'records', '1001'), record('1001', 'absent', T1)));
    await assertFails(setDoc(doc(as(env, T1), 'sessions', EXPIRED_SID, 'records', '1001'), record('1001', 'absent', T1)));
  });

  it('stage manager and admins can edit locked sessions', async () => {
    await assertSucceeds(setDoc(doc(as(env, SM3), 'sessions', LOCKED_SID, 'records', '1001'), record('1001', 'excused', SM3)));
    await assertSucceeds(setDoc(doc(as(env, SUPER), 'sessions', EXPIRED_SID, 'records', '1001'), record('1001', 'excused', SUPER)));
  });

  it('teachers cannot unlock or extend a session', async () => {
    const db = as(env, T1);
    await assertFails(updateDoc(doc(db, 'sessions', LOCKED_SID), { locked: false, updatedAt: serverTimestamp() }));
    await assertFails(updateDoc(doc(db, 'sessions', OPEN_SID), {
      lockAt: Timestamp.fromDate(new Date(Date.now() + 1000 * HOUR)), updatedAt: serverTimestamp(),
    }));
    await assertSucceeds(updateDoc(doc(db, 'sessions', OPEN_SID), {
      counts: { present: 1, absent: 0, late: 0, excused: 0 }, updatedBy: T1, updatedAt: serverTimestamp(),
    }));
  });

  it('stage manager can lock a session', async () => {
    await assertSucceeds(updateDoc(doc(as(env, SM3), 'sessions', OPEN_SID), { locked: true, updatedAt: serverTimestamp() }));
  });

  it('records must carry the real author, a valid status and a server time', async () => {
    const db = as(env, T1);
    await assertFails(setDoc(doc(db, 'sessions', OPEN_SID, 'records', '1001'), record('1001', 'absent', SM3)));
    await assertFails(setDoc(doc(db, 'sessions', OPEN_SID, 'records', '1001'), record('1001', 'sleeping', T1)));
    await assertFails(setDoc(doc(db, 'sessions', OPEN_SID, 'records', '1001'), record('9999', 'absent', T1)));
    await assertFails(setDoc(doc(db, 'sessions', OPEN_SID, 'records', '1001'),
      { ...record('1001', 'absent', T1), updatedAt: Timestamp.fromDate(new Date(2020, 1, 1)) }));
  });

  it('unassigned teacher cannot read or write the records', async () => {
    const db = as(env, T2);
    await assertFails(getDoc(doc(db, 'sessions', OPEN_SID, 'records', '1001')));
    await assertFails(setDoc(doc(db, 'sessions', OPEN_SID, 'records', '1001'), record('1001', 'absent', T2)));
    await assertFails(getDoc(doc(db, 'sessions', OPEN_SID)));
  });
});

describe('stats counters (batch + increment)', () => {
  const stat = (sid, delta) => ({
    courseId: COURSE, studentId: '1001', stageId: '3-morning', lastSessionId: sid,
    absences: increment(delta), updatedAt: serverTimestamp(),
  });

  it('assigned teacher updates counters with records of an open session', async () => {
    const db = as(env, T1);
    const batch = writeBatch(db);
    batch.set(doc(db, 'sessions', OPEN_SID, 'records', '1001'), record('1001', 'absent', T1));
    batch.set(doc(db, 'stats', `${COURSE}__1001`), stat(OPEN_SID, 1), { merge: true });
    await assertSucceeds(batch.commit());
  });

  it('cannot update counters through a locked session or another teacher', async () => {
    await assertFails(setDoc(doc(as(env, T1), 'stats', `${COURSE}__1001`), stat(LOCKED_SID, 1), { merge: true }));
    await assertFails(setDoc(doc(as(env, T2), 'stats', `${COURSE}__1001`), stat(OPEN_SID, 1), { merge: true }));
  });

  it('stat id must match course and student', async () => {
    await assertFails(setDoc(doc(as(env, T1), 'stats', `${COURSE}__2002`), stat(OPEN_SID, 1), { merge: true }));
  });
});

describe('edit requests after locking', () => {
  const req = (by, sid = LOCKED_SID, extra = {}) => ({
    sessionId: sid, studentId: '1001', stageId: '3-morning', reason: 'خطأ في التسجيل',
    requestedStatus: 'present', requestedBy: by, status: 'pending', ...extra,
  });

  it('assigned teacher files a pending request; an unrelated teacher cannot', async () => {
    await assertSucceeds(setDoc(doc(as(env, T1), 'editRequests', 'r1'), req(T1)));
    await assertFails(setDoc(doc(as(env, T2), 'editRequests', 'r2'), req(T2)));
    await assertFails(setDoc(doc(as(env, T1), 'editRequests', 'r3'), req(T1, LOCKED_SID, { status: 'approved' })));
  });

  it('stage manager decides; the requester cannot approve their own request', async () => {
    await env.withSecurityRulesDisabled((ctx) => setDoc(doc(ctx.firestore(), 'editRequests', 'r1'), req(T1)));
    await assertFails(updateDoc(doc(as(env, T1), 'editRequests', 'r1'), { status: 'approved', decidedBy: T1 }));
    await assertSucceeds(updateDoc(doc(as(env, SM3), 'editRequests', 'r1'),
      { status: 'approved', decidedBy: SM3, decisionNote: 'موافق' }));
    await assertFails(updateDoc(doc(as(env, SM3), 'editRequests', 'r1'), { status: 'rejected', decidedBy: SM3 }));
  });
});
