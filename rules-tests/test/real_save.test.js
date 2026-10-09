// A lecture saved the way the phone uploads it: the session (created, as
// OutboxUploader does when the server has none), every student's record and
// the stats of those not present — one batch, a real class size.
import { describe, it, before, beforeEach, after } from 'node:test';
import { assertSucceeds } from '@firebase/rules-unit-testing';
import { doc, serverTimestamp, setDoc, writeBatch, Timestamp } from 'firebase/firestore';
import {
  createEnv, seed, as, sessionData, sessionId, utcMidnight, student, T1, COURSE, GROUP_A,
} from './helpers.js';

let env;
before(async () => { env = await createEnv(); });
beforeEach(async () => { await env.clearFirestore(); await seed(env); });
after(async () => { await env.cleanup(); });

async function addStudents(n) {
  const ids = [];
  await env.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();
    for (let i = 0; i < n; i++) {
      const id = `30${String(i).padStart(3, '0')}`;
      ids.push(id);
      await setDoc(doc(db, 'students', id), student(id, '3-morning'));
    }
  });
  return ids;
}

function lecture(db, { type, target, ids, absent }) {
  const sid = sessionId(COURSE, type, target, utcMidnight(0), 7);
  const batch = writeBatch(db);
  batch.set(doc(db, 'sessions', sid), {
    ...sessionData({ type, target, lectureNo: 7, updatedAt: serverTimestamp() }),
    counts: { present: ids.length - absent, absent, late: 0, excused: 0 },
    deviceCreatedAt: Timestamp.now(),
    departmentId: 'cs',
  });
  ids.forEach((id, i) => {
    const status = i < absent ? 'absent' : 'present';
    batch.set(doc(db, 'sessions', sid, 'records', id), {
      studentId: id, status, note: '', updatedBy: T1, updatedAt: serverTimestamp(), deviceUpdatedAt: Timestamp.now(),
    }, { merge: true });
    if (status !== 'present') {
      batch.set(doc(db, 'stats', `${COURSE}__${id}`), {
        courseId: COURSE, studentId: id, stageId: '3-morning', lastSessionId: sid,
        bySession: { [sid]: status }, updatedAt: serverTimestamp(), departmentId: 'cs',
      }, { merge: true });
    }
  });
  return batch;
}

describe('a real-sized first save of a lecture', () => {
  for (const absent of [1, 10, 30]) {
    it(`theory, 65 students, ${absent} absent`, async () => {
      const ids = await addStudents(65);
      await assertSucceeds(lecture(as(env, T1), { type: 'theory', target: 'all', ids, absent }).commit());
    });
  }

  it('practical group, 25 students, 5 absent', async () => {
    const ids = await addStudents(25);
    await assertSucceeds(lecture(as(env, T1), { type: 'practical', target: 'A', ids, absent: 5 }).commit());
  });
});
