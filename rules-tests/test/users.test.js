// Identity gates + users collection (roles, deputy limits, self edits).
import { describe, it, before, beforeEach, after } from 'node:test';
import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import { collection, deleteDoc, doc, getDoc, getDocs, setDoc, updateDoc } from 'firebase/firestore';
import {
  createEnv, seed, as, users, SUPER, DEPUTY, SM3, T1, T2, SUSPENDED, STRANGER, COURSE,
} from './helpers.js';

let env;
before(async () => { env = await createEnv(); });
beforeEach(async () => { await env.clearFirestore(); await seed(env); });
after(async () => { await env.cleanup(); });

const newUser = (email, roles, extra = {}) => ({
  email, name: 'جديد', roles, stageScopes: [], teachingStages: [], active: true, ...extra,
});

describe('identity gates', () => {
  it('denies unauthenticated access', async () => {
    const db = env.unauthenticatedContext().firestore();
    await assertFails(getDoc(doc(db, 'courses', COURSE)));
    await assertFails(getDoc(doc(db, 'users', T1)));
  });

  it('denies a provisioned user whose e-mail is not verified', async () => {
    const db = as(env, T1, { verified: false });
    await assertFails(getDoc(doc(db, 'courses', COURSE)));
    await assertFails(getDoc(doc(db, 'users', T1)));
  });

  it('denies a verified account that was never provisioned, but lets it read its own (missing) doc', async () => {
    const db = as(env, STRANGER);
    await assertFails(getDoc(doc(db, 'courses', COURSE)));
    await assertSucceeds(getDoc(doc(db, 'users', STRANGER)));
  });

  it('denies a suspended user, who can still read their own doc', async () => {
    const db = as(env, SUSPENDED);
    await assertFails(getDoc(doc(db, 'courses', COURSE)));
    await assertSucceeds(getDoc(doc(db, 'users', SUSPENDED)));
  });

  it('matches the users doc case-insensitively on the e-mail', async () => {
    const db = as(env, 'T1@UOB.test');
    await assertSucceeds(getDoc(doc(db, 'courses', COURSE)));
  });
});

describe('users: reading', () => {
  it('teacher reads only their own doc', async () => {
    const db = as(env, T1);
    await assertSucceeds(getDoc(doc(db, 'users', T1)));
    await assertFails(getDoc(doc(db, 'users', T2)));
    await assertFails(getDocs(collection(db, 'users')));
  });

  it('admins and stage managers can list users (to pick teachers)', async () => {
    await assertSucceeds(getDocs(collection(as(env, SUPER), 'users')));
    await assertSucceeds(getDocs(collection(as(env, DEPUTY), 'users')));
    await assertSucceeds(getDocs(collection(as(env, SM3), 'users')));
  });
});

describe('users: granting roles', () => {
  it('super admin can create any account, including admins', async () => {
    const db = as(env, SUPER);
    await assertSucceeds(setDoc(doc(db, 'users', 'new-admin@uob.test'), newUser('new-admin@uob.test', ['deputyAdmin'])));
    await assertSucceeds(setDoc(doc(db, 'users', 'new-t@uob.test'), newUser('new-t@uob.test', ['teacher'])));
  });

  it('deputy admin can create teachers and stage managers but never admins', async () => {
    const db = as(env, DEPUTY);
    await assertSucceeds(setDoc(doc(db, 'users', 'new-t@uob.test'), newUser('new-t@uob.test', ['teacher'])));
    await assertSucceeds(setDoc(doc(db, 'users', 'new-sm@uob.test'),
      newUser('new-sm@uob.test', ['stageManager', 'teacher'], { stageScopes: ['2-evening'] })));
    await assertFails(setDoc(doc(db, 'users', 'x@uob.test'), newUser('x@uob.test', ['deputyAdmin'])));
    await assertFails(setDoc(doc(db, 'users', 'y@uob.test'), newUser('y@uob.test', ['superAdmin'])));
  });

  it('deputy admin cannot promote a teacher to admin, nor edit an admin', async () => {
    const db = as(env, DEPUTY);
    await assertFails(updateDoc(doc(db, 'users', T1), { roles: ['teacher', 'deputyAdmin'] }));
    await assertFails(updateDoc(doc(db, 'users', SUPER), { active: false }));
  });

  it('deputy admin can suspend a teacher', async () => {
    await assertSucceeds(updateDoc(doc(as(env, DEPUTY), 'users', T1), { active: false }));
  });

  it('stage manager and teacher cannot create accounts', async () => {
    await assertFails(setDoc(doc(as(env, SM3), 'users', 'z@uob.test'), newUser('z@uob.test', ['teacher'])));
    await assertFails(setDoc(doc(as(env, T1), 'users', 'z@uob.test'), newUser('z@uob.test', ['teacher'])));
  });

  it('rejects malformed user docs (unknown role, id ≠ email)', async () => {
    const db = as(env, SUPER);
    await assertFails(setDoc(doc(db, 'users', 'a@uob.test'), newUser('a@uob.test', ['dean'])));
    await assertFails(setDoc(doc(db, 'users', 'a@uob.test'), newUser('b@uob.test', ['teacher'])));
  });

  it('only the super admin deletes users', async () => {
    await assertFails(deleteDoc(doc(as(env, DEPUTY), 'users', T2)));
    await assertSucceeds(deleteDoc(doc(as(env, SUPER), 'users', T2)));
  });
});

describe('users: self edits', () => {
  it('a teacher can change their phone only', async () => {
    const db = as(env, T1);
    await assertSucceeds(updateDoc(doc(db, 'users', T1), { phone: '07700000000' }));
    await assertFails(updateDoc(doc(db, 'users', T1), { roles: ['teacher', 'stageManager'] }));
    await assertFails(updateDoc(doc(db, 'users', T1), { teachingStages: ['1-morning', '3-morning'] }));
    await assertFails(updateDoc(doc(db, 'users', T1), { name: 'اسم آخر' }));
  });

  it('a suspended user cannot edit their own doc', async () => {
    await assertFails(updateDoc(doc(as(env, SUSPENDED), 'users', SUSPENDED), { phone: '1' }));
  });
});

describe('users: teachingStages maintained by stage managers', () => {
  it('stage manager can add/remove only stages in their scope', async () => {
    const db = as(env, SM3);
    await assertSucceeds(updateDoc(doc(db, 'users', T2), { teachingStages: ['1-evening', '3-morning'] }));
    await assertSucceeds(updateDoc(doc(db, 'users', T2), { teachingStages: ['1-evening'] }));
    await assertFails(updateDoc(doc(db, 'users', T2), { teachingStages: ['1-evening', '4-morning'] }));
    await assertFails(updateDoc(doc(db, 'users', T2), { teachingStages: [] })); // 1-evening is not theirs
  });

  it('stage manager cannot touch roles', async () => {
    await assertFails(updateDoc(doc(as(env, SM3), 'users', T2), { roles: ['teacher', 'stageManager'] }));
  });

  it('stage manager cannot widen their own scope', async () => {
    await assertFails(updateDoc(doc(as(env, SM3), 'users', SM3), { stageScopes: ['3-morning', '4-morning'] }));
  });
});

// Sanity: fixtures are what the tests assume.
it('fixtures', () => {
  if (!users[SM3].stageScopes.includes('3-morning')) throw new Error('bad fixtures');
});
