// sessions, records, stats and edit requests (locking rules).
import { describe, it, before, beforeEach, after } from 'node:test';
import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import {
  collection, doc, getDoc, getDocs, increment, query, serverTimestamp, setDoc, updateDoc, where, writeBatch, Timestamp,
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

  it('a year without lockHours locks after the default 48 hours (as the app assumes)', async () => {
    await env.withSecurityRulesDisabled(async (ctx) => setDoc(doc(ctx.firestore(), 'academicYears', '2026-2027'), {
      label: '2026-2027', semester: 1, active: true,
    }));
    const db = as(env, T1);
    const sid = sessionId(COURSE, 'theory', 'all', utcMidnight(0), 3);
    await assertSucceeds(setDoc(doc(db, 'sessions', sid), sessionData({ lectureNo: 3, updatedAt: serverTimestamp() })));
    const other = sessionId(COURSE, 'theory', 'all', utcMidnight(0), 4);
    await assertFails(setDoc(doc(db, 'sessions', other), sessionData({
      lectureNo: 4, lockAt: new Date(lockAtFor(utcMidnight(0)).getTime() + HOUR),
      updatedAt: serverTimestamp(),
    })));
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

describe('stats (status per session, idempotent)', () => {
  // The exact payload AttendanceUploader sends (set with merge).
  const stat = (sid, status, extra = {}) => ({
    courseId: COURSE, studentId: '1001', stageId: '3-morning', lastSessionId: sid,
    bySession: { [sid]: status }, updatedAt: serverTimestamp(), departmentId: 'cs', ...extra,
  });
  const statRef = (db, id = `${COURSE}__1001`) => doc(db, 'stats', id);

  it('assigned teacher sets the entry of an open session, together with the record; repeating is harmless', async () => {
    const db = as(env, T1);
    for (let i = 0; i < 2; i++) {
      const batch = writeBatch(db);
      batch.set(doc(db, 'sessions', OPEN_SID, 'records', '1001'), record('1001', 'absent', T1));
      batch.set(statRef(db), stat(OPEN_SID, 'absent'), { merge: true });
      await assertSucceeds(batch.commit());
    }
    await assertSucceeds(setDoc(statRef(db), stat(OPEN_SID, 'present'), { merge: true }));
  });

  it('cannot write through a locked session or as another teacher', async () => {
    await assertFails(setDoc(statRef(as(env, T1)), stat(LOCKED_SID, 'absent'), { merge: true }));
    await assertFails(setDoc(statRef(as(env, T2)), stat(OPEN_SID, 'absent'), { merge: true }));
  });

  it('cannot touch another session\'s entry, forge counters, or use an unknown status', async () => {
    const db = as(env, T1);
    await assertFails(setDoc(statRef(db),
      stat(OPEN_SID, 'absent', { bySession: { [OPEN_SID]: 'absent', [LOCKED_SID]: 'present' } }), { merge: true }));
    await assertFails(setDoc(statRef(db), stat(OPEN_SID, 'absent', { absences: increment(5) }), { merge: true }));
    await assertFails(setDoc(statRef(db), stat(OPEN_SID, 'sleeping'), { merge: true }));
  });

  it('stat id must match course and student', async () => {
    await assertFails(setDoc(statRef(as(env, T1), `${COURSE}__2002`), stat(OPEN_SID, 'absent'), { merge: true }));
  });

  it('stage manager may rewrite any entry (recalculation)', async () => {
    await assertSucceeds(setDoc(statRef(as(env, SM3)),
      stat(OPEN_SID, 'absent', { bySession: { [OPEN_SID]: 'absent', [LOCKED_SID]: 'late' } }), { merge: true }));
  });
});

describe('app save batches (AttendanceUploader payloads)', () => {
  const recordOf = (studentId, status) => ({
    studentId, status, note: '', updatedBy: T1, updatedAt: serverTimestamp(),
    deviceUpdatedAt: Timestamp.now(),
  });

  it('first save: create session (counts, device time) + every record + stats of non-present students', async () => {
    const db = as(env, T1);
    const sid = sessionId(COURSE, 'theory', 'all', utcMidnight(0), 3);
    const batch = writeBatch(db);
    batch.set(doc(db, 'sessions', sid), {
      ...sessionData({ lectureNo: 3, updatedAt: serverTimestamp() }),
      counts: { present: 0, absent: 1, late: 0, excused: 0 },
      deviceCreatedAt: Timestamp.now(), departmentId: 'cs',
    });
    batch.set(doc(db, 'sessions', sid, 'records', '1001'), recordOf('1001', 'absent'), { merge: true });
    batch.set(doc(db, 'stats', `${COURSE}__1001`), {
      courseId: COURSE, studentId: '1001', stageId: '3-morning', lastSessionId: sid,
      bySession: { [sid]: 'absent' }, updatedAt: serverTimestamp(), departmentId: 'cs',
    }, { merge: true });
    await assertSucceeds(batch.commit());
  });

  it('later save of an existing open session: counts/updatedBy only + changed records', async () => {
    const db = as(env, T1);
    const batch = writeBatch(db);
    batch.update(doc(db, 'sessions', OPEN_SID), {
      counts: { present: 1, absent: 0, late: 0, excused: 0 }, updatedAt: serverTimestamp(), updatedBy: T1,
    });
    batch.set(doc(db, 'sessions', OPEN_SID, 'records', '1001'), recordOf('1001', 'present'), { merge: true });
    await assertSucceeds(batch.commit());
  });

  it('a teacher cannot overwrite the identity of a session someone else opened', async () => {
    const db = as(env, T1);
    await assertFails(setDoc(doc(db, 'sessions', OPEN_SID),
      { ...sessionData({ openedBy: T1, updatedAt: serverTimestamp() }), deviceCreatedAt: Timestamp.now() }, { merge: true }));
  });
});

describe('download and register query shapes (teacher)', () => {
  it('own assignments, students of a taught stage, the active year', async () => {
    const db = as(env, T1);
    await assertSucceeds(getDocs(query(collection(db, 'assignments'), where('teacherId', '==', T1))));
    await assertSucceeds(getDocs(query(collection(db, 'students'), where('stageId', '==', '3-morning'))));
    await assertFails(getDocs(query(collection(db, 'students'), where('stageId', '==', '1-evening'))));
    await assertSucceeds(getDoc(doc(db, 'groups', `${COURSE}__A`)));
    await assertSucceeds(getDoc(doc(db, 'courses', COURSE)));
  });

  it('the uploader may check whether a lecture exists yet (get of a missing session)', async () => {
    const sid = sessionId(COURSE, 'theory', 'all', utcMidnight(0), 7);
    const snap = await assertSucceeds(getDoc(doc(as(env, T1), 'sessions', sid)));
    if (snap.exists()) throw new Error('expected a missing session');
    await assertSucceeds(getDoc(doc(as(env, T1), 'sessions', OPEN_SID)));
    await assertFails(getDoc(doc(as(env, T2), 'sessions', sid)));
  });

  it('sessions of one assigned class and their records', async () => {
    const db = as(env, T1);
    await assertSucceeds(getDocs(query(collection(db, 'sessions'),
      where('courseId', '==', COURSE), where('type', '==', 'theory'), where('target', '==', 'all'))));
    await assertSucceeds(getDocs(collection(db, 'sessions', OPEN_SID, 'records')));
    await assertFails(getDocs(query(collection(as(env, T2), 'sessions'),
      where('courseId', '==', COURSE), where('type', '==', 'theory'), where('target', '==', 'all'))));
  });

  it('register percentages: the course\'s stats and the stage\'s leaves', async () => {
    const q = (who, stageId) => getDocs(query(collection(as(env, who), 'stats'),
      where('stageId', '==', stageId), where('courseId', '==', COURSE)));
    await assertSucceeds(q(T1, '3-morning'));
    await assertFails(q(T2, '3-morning'));
    await assertSucceeds(getDocs(query(collection(as(env, T1), 'leaves'), where('stageId', '==', '3-morning'))));
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

describe('edit requests: the app\'s writes', () => {
  it('teacher files; the stage manager approves in one batch (record, counts, stats, request, audit)', async () => {
    const t = as(env, T1);
    await assertSucceeds(setDoc(doc(t, 'editRequests', 'app1'), {
      sessionId: LOCKED_SID, studentId: '1001', stageId: '3-morning', requestedStatus: 'present',
      reason: 'كان حاضراً', requestedBy: T1, currentStatus: 'absent', status: 'pending',
      decidedBy: null, decisionNote: '', departmentId: 'cs', createdAt: serverTimestamp(),
    }));
    await assertSucceeds(getDocs(query(collection(t, 'editRequests'), where('requestedBy', '==', T1))));
    await assertFails(getDocs(query(collection(t, 'editRequests'), where('stageId', '==', '3-morning'),
      where('status', '==', 'pending'))));

    const sm = as(env, SM3);
    await assertSucceeds(getDocs(query(collection(sm, 'editRequests'), where('stageId', '==', '3-morning'),
      where('status', '==', 'pending'))));
    const approve = (who) => {
      const fs = as(env, who);
      const b = writeBatch(fs);
      b.set(doc(fs, 'sessions', LOCKED_SID, 'records', '1001'),
        { studentId: '1001', status: 'present', updatedBy: who, updatedAt: serverTimestamp() }, { merge: true });
      b.update(doc(fs, 'sessions', LOCKED_SID),
        { counts: { present: 1, absent: 0, late: 0, excused: 0 }, updatedAt: serverTimestamp(), updatedBy: who });
      b.set(doc(fs, 'stats', `${COURSE}__1001`), {
        courseId: COURSE, studentId: '1001', stageId: '3-morning', lastSessionId: LOCKED_SID,
        bySession: { [LOCKED_SID]: 'present' }, updatedAt: serverTimestamp(), departmentId: 'cs',
      }, { merge: true });
      b.update(doc(fs, 'editRequests', 'app1'), {
        status: 'approved', decidedBy: who, decidedAt: serverTimestamp(), decisionNote: '', updatedAt: serverTimestamp(),
      });
      b.set(doc(collection(fs, 'auditLog')), {
        actor: who, action: 'record.update', targetPath: `sessions/${LOCKED_SID}/records/1001`, stageId: '3-morning',
        before: { status: 'absent' }, after: { status: 'present' }, departmentId: 'cs', at: serverTimestamp(),
      });
      return b.commit();
    };
    await assertFails(approve(T1));
    await assertSucceeds(approve(SM3));
  });
});

describe('stage dashboard queries', () => {
  it('a stage manager lists the stage\'s lectures of recent days; others cannot', async () => {
    const keys = [0, -1, -2].map((d) => utcMidnight(d).toISOString().slice(0, 10).replaceAll('-', ''));
    const q = (who, stageId) => getDocs(query(collection(as(env, who), 'sessions'),
      where('stageId', '==', stageId), where('dateKey', 'in', keys)));
    await assertSucceeds(q(SM3, '3-morning'));
    await assertSucceeds(q(SUPER, '1-evening'));
    await assertFails(q(SM3, '1-evening'));
    await assertFails(q(T2, '3-morning'));
  });
});
