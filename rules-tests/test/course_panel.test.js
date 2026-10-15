// «لوحة المادة» and the class registers read from the server: every query
// names the stage, so a stage manager's reads pass `inStageScope`; the
// admins read every stage; a plain teacher reads neither.
import { describe, it, before, beforeEach, after } from 'node:test';
import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import { collection, doc, getDoc, getDocs, query, where } from 'firebase/firestore';
import { createEnv, seed, as, SUPER, DEPUTY, SM3, T2, COURSE, COURSE_EVE, OPEN_SID, THEORY_T1 } from './helpers.js';

let env;
before(async () => { env = await createEnv(); });
beforeEach(async () => { await env.clearFirestore(); await seed(env); });
after(async () => { await env.cleanup(); });

// The panel's queries, exactly as CoursePanelRepository sends them.
function panelReads(db, courseId, stageId) {
  const byCourse = (name) =>
    getDocs(query(collection(db, name), where('stageId', '==', stageId), where('courseId', '==', courseId)));
  return [
    getDoc(doc(db, 'courses', courseId)),
    getDocs(query(collection(db, 'academicYears'), where('active', '==', true))),
    byCourse('assignments'),
    byCourse('groups'),
    byCourse('sessions'),
    byCourse('stats'),
    getDocs(query(collection(db, 'students'), where('stageId', '==', stageId))),
    getDocs(query(collection(db, 'leaves'), where('stageId', '==', stageId))),
  ];
}

describe('course panel', () => {
  it('a stage manager reads a course of their stage, its lectures and their records', async () => {
    const db = as(env, SM3);
    for (const read of panelReads(db, COURSE, '3-morning')) await assertSucceeds(read);
    await assertSucceeds(getDocs(collection(db, 'sessions', OPEN_SID, 'records')));
    await assertSucceeds(getDoc(doc(db, 'assignments', THEORY_T1)));
  });

  it('the admins read every stage', async () => {
    for (const admin of [SUPER, DEPUTY]) {
      for (const read of panelReads(as(env, admin), COURSE_EVE, '1-evening')) await assertSucceeds(read);
    }
  });

  it('a stage manager cannot read another stage, nor a query without the stage', async () => {
    const db = as(env, SM3);
    await assertFails(getDocs(query(collection(db, 'sessions'), where('stageId', '==', '1-evening'),
      where('courseId', '==', COURSE_EVE))));
    await assertFails(getDocs(query(collection(db, 'stats'), where('stageId', '==', '1-evening'),
      where('courseId', '==', COURSE_EVE))));
    // The register used to ask by course only: the rules cannot prove it.
    await assertFails(getDocs(query(collection(db, 'sessions'), where('courseId', '==', COURSE))));
  });

  it('a teacher of another stage reads none of it', async () => {
    const db = as(env, T2);
    await assertFails(getDocs(query(collection(db, 'sessions'), where('stageId', '==', '3-morning'),
      where('courseId', '==', COURSE))));
    await assertFails(getDocs(collection(db, 'sessions', OPEN_SID, 'records')));
  });
});
