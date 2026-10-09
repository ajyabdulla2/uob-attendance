// «تسجيل محاضرة فائتة» (MissedLectureRepository.save): a stage manager or an
// admin writes a lecture whose teacher window has passed, for any class of
// the stage, in one batch — session, records, stats of the non-present and
// an audit entry. Teachers and managers of other stages cannot.
import { describe, it, before, beforeEach, after } from 'node:test';
import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import { collection, doc, serverTimestamp, writeBatch } from 'firebase/firestore';
import {
  createEnv, seed, as, sessionData, sessionId, utcMidnight, lockAtFor,
  SUPER, SM3, T1, COURSE, COURSE_EVE,
} from './helpers.js';

let env;
before(async () => { env = await createEnv(); });
beforeEach(async () => { await env.clearFirestore(); await seed(env); });
after(async () => { await env.cleanup(); });

/** The batch the app sends, for one student marked [status]. */
function missedBatch(db, actor, {
  courseId = COURSE, stageId = '3-morning', type = 'theory', target = 'all', daysAgo = 4, studentId = '1001',
  status = 'absent',
} = {}) {
  const date = utcMidnight(-daysAgo);
  const sid = sessionId(courseId, type, target, date, 1);
  const ref = doc(db, 'sessions', sid);
  const batch = writeBatch(db);
  batch.set(ref, {
    ...sessionData({ courseId, stageId, type, target, date, lockAt: lockAtFor(date), openedBy: actor }),
    counts: { present: 0, absent: 1, late: 0, excused: 0 },
    updatedBy: actor,
    updatedAt: serverTimestamp(),
  });
  batch.set(doc(ref, 'records', studentId), {
    studentId, status, note: '', updatedBy: actor, updatedAt: serverTimestamp(),
  });
  batch.set(doc(db, 'stats', `${courseId}__${studentId}`), {
    courseId, studentId, stageId, lastSessionId: sid, bySession: { [sid]: status },
    updatedAt: serverTimestamp(), departmentId: 'cs',
  }, { merge: true });
  batch.set(doc(collection(db, 'auditLog')), {
    actor, action: 'session.missed', targetPath: `sessions/${sid}`, stageId,
    after: { lectureNo: 1, absent: 1 }, at: serverTimestamp(), departmentId: 'cs',
  });
  return batch;
}

describe('missed lecture', () => {
  it('a stage manager records a lecture of 4 days ago for a class of the stage', async () => {
    await assertSucceeds(missedBatch(as(env, SM3), SM3).commit());
  });

  it('an admin records a practical group a month back', async () => {
    await assertSucceeds(missedBatch(as(env, SUPER), SUPER, { type: 'practical', target: 'A', daysAgo: 30 }).commit());
  });

  it('the class teacher cannot: the lecture is past its lock window', async () => {
    await assertFails(missedBatch(as(env, T1), T1).commit());
  });

  it('a stage manager cannot record a class of another stage', async () => {
    await assertFails(missedBatch(as(env, SM3), SM3, {
      courseId: COURSE_EVE, stageId: '1-evening', studentId: '2001',
    }).commit());
  });
});
