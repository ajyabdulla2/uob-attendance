// Data fixes (DataFixRepository): changing a university ID, a course code or
// a teacher's e-mail moves documents to new keys; undoing a wrong import
// deletes them. These tests replay the repository's batches phase by phase.
import { describe, it, before, beforeEach, after } from 'node:test';
import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import {
  arrayRemove, deleteDoc, doc, getDoc, serverTimestamp, setDoc, writeBatch,
} from 'firebase/firestore';
import {
  createEnv, seed, as, sessionData, student, users,
  SUPER, DEPUTY, SM3, T1, T2, COURSE, COURSE_EVE, GROUP_A, THEORY_T1, PRACTICAL_T1, OPEN_SID,
} from './helpers.js';

let env;
before(async () => { env = await createEnv(); });
beforeEach(async () => { await env.clearFirestore(); await seed(env); });
after(async () => { await env.cleanup(); });

const audit = (db, actor, action) => [doc(db, 'auditLog', `${action}-${Date.now()}`), {
  actor, action, targetPath: 'x', at: serverTimestamp(), departmentId: 'cs',
}];

async function seedStat() {
  await env.withSecurityRulesDisabled(async (ctx) => {
    await setDoc(doc(ctx.firestore(), 'stats', `${COURSE}__1001`), {
      courseId: COURSE, studentId: '1001', stageId: '3-morning', lastSessionId: OPEN_SID,
      bySession: { [OPEN_SID]: 'absent' },
    });
  });
}

describe('changing a course code', () => {
  const NEW = 'CS311_3-morning';
  const remap = (id) => `${NEW}${id.substring(COURSE.length)}`;

  it('an admin moves the course phase by phase: course → groups → links → lectures and stats → old course', async () => {
    await seedStat();
    const db = as(env, DEPUTY);
    const old = (await getDoc(doc(db, 'courses', COURSE))).data();

    await assertSucceeds(setDoc(doc(db, 'courses', NEW), { ...old, code: 'CS311', updatedAt: serverTimestamp(), updatedBy: DEPUTY }));

    let b = writeBatch(db);
    b.set(doc(db, 'groups', remap(GROUP_A)), {
      courseId: NEW, stageId: '3-morning', name: 'A', studentIds: ['1001'], updatedAt: serverTimestamp(),
    });
    b.delete(doc(db, 'groups', GROUP_A));
    await assertSucceeds(b.commit());

    b = writeBatch(db);
    b.set(doc(db, 'assignments', remap(THEORY_T1)), {
      teacherId: T1, courseId: NEW, stageId: '3-morning', type: 'theory', target: 'all', groupId: null,
      updatedAt: serverTimestamp(), updatedBy: DEPUTY,
    });
    b.set(doc(db, 'assignments', remap(PRACTICAL_T1)), {
      teacherId: T1, courseId: NEW, stageId: '3-morning', type: 'practical', target: 'A', groupId: remap(GROUP_A),
      updatedAt: serverTimestamp(), updatedBy: DEPUTY,
    });
    b.delete(doc(db, 'assignments', THEORY_T1));
    b.delete(doc(db, 'assignments', PRACTICAL_T1));
    await assertSucceeds(b.commit());

    b = writeBatch(db);
    b.set(doc(db, 'sessions', remap(OPEN_SID)), {
      ...sessionData({ courseId: NEW }), updatedAt: serverTimestamp(), updatedBy: DEPUTY,
    });
    b.set(doc(db, 'sessions', remap(OPEN_SID), 'records', '1001'), {
      studentId: '1001', status: 'present', updatedBy: DEPUTY, updatedAt: serverTimestamp(),
    });
    b.delete(doc(db, 'sessions', OPEN_SID, 'records', '1001'));
    b.delete(doc(db, 'sessions', OPEN_SID));
    b.set(doc(db, 'stats', `${NEW}__1001`), {
      courseId: NEW, studentId: '1001', stageId: '3-morning', lastSessionId: remap(OPEN_SID),
      bySession: { [remap(OPEN_SID)]: 'absent' }, updatedAt: serverTimestamp(),
    }, { merge: true });
    b.delete(doc(db, 'stats', `${COURSE}__1001`));
    await assertSucceeds(b.commit());

    b = writeBatch(db);
    b.delete(doc(db, 'courses', COURSE));
    b.set(...audit(db, DEPUTY, 'course.rename'));
    await assertSucceeds(b.commit());

    // The teacher keeps recording on the renamed class.
    await assertSucceeds(getDoc(doc(as(env, T1), 'sessions', remap(OPEN_SID))));
  });

  it('the new course must be committed before its groups (rules read it with get())', async () => {
    const db = as(env, SUPER);
    const old = (await getDoc(doc(db, 'courses', COURSE))).data();
    const b = writeBatch(db);
    b.set(doc(db, 'courses', NEW), { ...old, code: 'CS311' });
    b.set(doc(db, 'groups', remap(GROUP_A)), { courseId: NEW, stageId: '3-morning', name: 'A', studentIds: [] });
    await assertFails(b.commit());
  });

  it('stage managers and teachers cannot move courses', async () => {
    const old = { code: 'CS311', name: 'هياكل البيانات', stageId: '3-morning', semester: 1, units: 3, hasPractical: true };
    await assertFails(setDoc(doc(as(env, SM3), 'courses', NEW), old));
    await assertFails(setDoc(doc(as(env, T1), 'courses', NEW), old));
  });
});

describe('changing a university ID', () => {
  it('an admin copies the student, moves records/stats/groups/leaves, then deletes the old ID', async () => {
    await seedStat();
    const db = as(env, DEPUTY);
    await assertSucceeds(setDoc(doc(db, 'students', '1009'),
      { ...student('1009', '3-morning'), updatedAt: serverTimestamp(), updatedBy: DEPUTY }));

    const b = writeBatch(db);
    b.set(doc(db, 'stats', `${COURSE}__1009`), {
      courseId: COURSE, studentId: '1009', stageId: '3-morning', lastSessionId: OPEN_SID,
      bySession: { [OPEN_SID]: 'absent' }, updatedAt: serverTimestamp(),
    }, { merge: true });
    b.delete(doc(db, 'stats', `${COURSE}__1001`));
    b.update(doc(db, 'groups', GROUP_A), { studentIds: ['1009'], updatedAt: serverTimestamp() });
    b.update(doc(db, 'leaves', 'leave-1'), { studentId: '1009' });
    b.set(doc(db, 'sessions', OPEN_SID, 'records', '1009'), {
      studentId: '1009', status: 'present', note: '', updatedBy: DEPUTY, updatedAt: serverTimestamp(),
    });
    b.delete(doc(db, 'sessions', OPEN_SID, 'records', '1001'));
    b.update(doc(db, 'sessions', OPEN_SID), { updatedAt: serverTimestamp(), updatedBy: DEPUTY });
    await assertSucceeds(b.commit());

    const last = writeBatch(db);
    last.delete(doc(db, 'students', '1001'));
    last.set(...audit(db, DEPUTY, 'student.rename'));
    await assertSucceeds(last.commit());
  });

  it('a stage manager cannot delete the old student (the tool is for admins)', async () => {
    await assertFails(deleteDoc(doc(as(env, SM3), 'students', '1001')));
  });
});

describe('changing a teacher\'s e-mail', () => {
  const NEW = 'real.t1@gmail.com';

  it('the super admin creates the account, then moves the links, then deletes the old account', async () => {
    const db = as(env, SUPER);
    await assertSucceeds(setDoc(doc(db, 'users', NEW),
      { ...users[T1], email: NEW, updatedAt: serverTimestamp(), updatedBy: SUPER }));

    const b = writeBatch(db);
    b.set(doc(db, 'assignments', `${COURSE}__theory__all__${NEW}`), {
      teacherId: NEW, courseId: COURSE, stageId: '3-morning', type: 'theory', target: 'all',
      updatedAt: serverTimestamp(), updatedBy: SUPER,
    });
    b.delete(doc(db, 'assignments', THEORY_T1));
    await assertSucceeds(b.commit());

    const last = writeBatch(db);
    last.delete(doc(db, 'users', T1));
    last.set(...audit(db, SUPER, 'user.rename'));
    await assertSucceeds(last.commit());
  });

  it('links to the new e-mail need the account committed first (exists() check)', async () => {
    const db = as(env, SUPER);
    const b = writeBatch(db);
    b.set(doc(db, 'users', NEW), { ...users[T1], email: NEW });
    b.set(doc(db, 'assignments', `${COURSE}__theory__all__${NEW}`), {
      teacherId: NEW, courseId: COURSE, stageId: '3-morning', type: 'theory', target: 'all',
    });
    await assertFails(b.commit());
  });

  it('a deputy admin cannot delete accounts, so cannot finish an e-mail change', async () => {
    await assertFails(deleteDoc(doc(as(env, DEPUTY), 'users', T1)));
  });
});

describe('undoing a wrong import', () => {
  it('an admin deletes students and never-taught courses with their links, and trims teachingStages', async () => {
    const db = as(env, DEPUTY);
    const b = writeBatch(db);
    b.delete(doc(db, 'students', '2001'));
    b.delete(doc(db, 'courses', COURSE_EVE));
    b.update(doc(db, 'users', T2), { teachingStages: arrayRemove('1-evening'), updatedAt: serverTimestamp() });
    b.set(...audit(db, DEPUTY, 'courses.delete'));
    await assertSucceeds(b.commit());
  });

  it('stage managers cannot delete students or courses', async () => {
    await assertFails(deleteDoc(doc(as(env, SM3), 'courses', COURSE)));
    await assertFails(deleteDoc(doc(as(env, SM3), 'students', '1001')));
  });
});
