// «الطلبة»: adding one student (StudentsRepository.add) — the student, a
// practical group's member list and an audit entry in one batch.
import { describe, it, before, beforeEach, after } from 'node:test';
import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import { arrayUnion, collection, doc, getDoc, serverTimestamp, setDoc, writeBatch } from 'firebase/firestore';
import { createEnv, seed, as, student, SUPER, SM3, T1, GROUP_A } from './helpers.js';

let env;
before(async () => { env = await createEnv(); });
beforeEach(async () => { await env.clearFirestore(); await seed(env); });
after(async () => { await env.cleanup(); });

function addBatch(db, actor, id, stageId, groupId) {
  const batch = writeBatch(db);
  batch.set(doc(db, 'students', id), { ...student(id, stageId), createdAt: serverTimestamp(), createdBy: actor });
  if (groupId) {
    batch.update(doc(db, 'groups', groupId),
      { studentIds: arrayUnion(id), updatedAt: serverTimestamp(), updatedBy: actor });
  }
  batch.set(doc(collection(db, 'auditLog')), {
    actor, action: 'student.create', targetPath: `students/${id}`, stageId, at: serverTimestamp(), departmentId: 'cs',
  });
  return batch.commit();
}

describe('adding one student', () => {
  it('a stage manager adds one to their stage, into a practical group', async () => {
    await assertSucceeds(addBatch(as(env, SM3), SM3, '3005', '3-morning', GROUP_A));
  });

  it('an admin adds one to any stage', async () => {
    await assertSucceeds(addBatch(as(env, SUPER), SUPER, '1005', '1-evening'));
  });

  it('a stage manager cannot add to another stage, nor overwrite a student of one', async () => {
    await assertFails(addBatch(as(env, SM3), SM3, '1006', '1-evening'));
    // 2001 is in 1-evening: writing it into 3-morning would be an update the rules refuse.
    await assertFails(addBatch(as(env, SM3), SM3, '2001', '3-morning'));
  });

  it('a stage manager cannot read a missing student (the app relies on the rules instead)', async () => {
    await assertFails(getDoc(doc(as(env, SM3), 'students', '7777')));
    await assertSucceeds(getDoc(doc(as(env, SUPER), 'students', '7777')));
  });

  it('a teacher cannot add students', async () => {
    await assertFails(setDoc(doc(as(env, T1), 'students', '3006'), student('3006', '3-morning')));
  });
});
