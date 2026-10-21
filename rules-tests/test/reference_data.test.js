// students, courses, groups, assignments, stages, academicYears.
import { describe, it, before, beforeEach, after } from 'node:test';
import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import {
  arrayRemove, arrayUnion, collection, deleteDoc, doc, getDoc, getDocs, limit, query, serverTimestamp, setDoc, updateDoc,
  where, writeBatch,
} from 'firebase/firestore';
import {
  createEnv, seed, as, student, SUPER, DEPUTY, SM3, T1, T2, COURSE, COURSE_EVE, GROUP_A, THEORY_T1,
} from './helpers.js';

let env;
before(async () => { env = await createEnv(); });
beforeEach(async () => { await env.clearFirestore(); await seed(env); });
after(async () => { await env.cleanup(); });

describe('students: reading (privacy)', () => {
  it('admins read every student', async () => {
    await assertSucceeds(getDoc(doc(as(env, SUPER), 'students', '2001')));
    await assertSucceeds(getDocs(collection(as(env, DEPUTY), 'students')));
  });

  it('stage manager reads only their stage', async () => {
    const db = as(env, SM3);
    await assertSucceeds(getDoc(doc(db, 'students', '1001')));
    await assertFails(getDoc(doc(db, 'students', '2001')));
    await assertSucceeds(getDocs(query(collection(db, 'students'), where('stageId', '==', '3-morning'))));
    await assertFails(getDocs(query(collection(db, 'students'), where('stageId', '==', '1-evening'))));
    await assertFails(getDocs(collection(db, 'students')));
  });

  it('teacher reads only students of stages they teach', async () => {
    await assertSucceeds(getDoc(doc(as(env, T1), 'students', '1001')));
    await assertFails(getDoc(doc(as(env, T1), 'students', '2001')));
    await assertFails(getDoc(doc(as(env, T2), 'students', '1001')));
    await assertSucceeds(getDocs(query(collection(as(env, T1), 'students'), where('stageId', '==', '3-morning'))));
  });
});

describe('students: writing (import)', () => {
  it('stage manager imports students into their stage only', async () => {
    const db = as(env, SM3);
    await assertSucceeds(setDoc(doc(db, 'students', '1002'), student('1002', '3-morning')));
    await assertFails(setDoc(doc(db, 'students', '2002'), student('2002', '1-evening')));
  });

  it('stage manager cannot move a student out of their stage, nor overwrite another stage', async () => {
    const db = as(env, SM3);
    await assertFails(updateDoc(doc(db, 'students', '1001'), { stageId: '4-morning' }));
    await assertFails(setDoc(doc(db, 'students', '2001'), student('2001', '3-morning')));
  });

  it('stage manager can update status (e.g. transferred-in)', async () => {
    await assertSucceeds(updateDoc(doc(as(env, SM3), 'students', '1001'), { status: 'transferredIn' }));
  });

  it('teachers cannot write students', async () => {
    await assertFails(setDoc(doc(as(env, T1), 'students', '1003'), student('1003', '3-morning')));
    await assertFails(updateDoc(doc(as(env, T1), 'students', '1001'), { status: 'withdrawn' }));
  });

  it('rejects invalid student docs', async () => {
    const db = as(env, SUPER);
    await assertFails(setDoc(doc(db, 'students', '9'), student('8', '3-morning'))); // id ≠ universityId
    await assertFails(setDoc(doc(db, 'students', '9'), student('9', '5-morning')));
    await assertFails(setDoc(doc(db, 'students', '9'), student('9', '3-morning', { status: 'graduated' })));
    await assertFails(setDoc(doc(db, 'students', '9'), student('9', '3-morning', { fullName: '' })));
  });

  it('only admins delete students', async () => {
    await assertFails(deleteDoc(doc(as(env, SM3), 'students', '1001')));
    await assertSucceeds(deleteDoc(doc(as(env, DEPUTY), 'students', '1001')));
  });
});

describe('courses', () => {
  const course = (code, stageId, extra = {}) => ({
    code, name: 'مادة', stageId, semester: 1, units: 3, hasPractical: true, ...extra,
  });

  it('any active user reads courses', async () => {
    await assertSucceeds(getDoc(doc(as(env, T2), 'courses', COURSE)));
  });

  it('only admins import courses', async () => {
    await assertSucceeds(setDoc(doc(as(env, DEPUTY), 'courses', 'CS302_3-morning'), course('CS302', '3-morning')));
    await assertFails(setDoc(doc(as(env, SM3), 'courses', 'CS303_3-morning'), course('CS303', '3-morning')));
    await assertFails(setDoc(doc(as(env, T1), 'courses', 'CS304_3-morning'), course('CS304', '3-morning')));
  });

  it('rejects malformed courses', async () => {
    const db = as(env, SUPER);
    await assertFails(setDoc(doc(db, 'courses', 'WRONG'), course('CS305', '3-morning')));
    await assertFails(setDoc(doc(db, 'courses', 'CS305_3-morning'), course('CS305', '3-morning', { units: 0 })));
    await assertFails(setDoc(doc(db, 'courses', 'CS305_3-morning'), course('CS305', '3-morning', { semester: 3 })));
  });
});

describe('practical groups', () => {
  const group = (courseId, stageId, name) => ({ courseId, stageId, name, studentIds: [] });

  it('stage manager creates groups for courses in their stage', async () => {
    const db = as(env, SM3);
    await assertSucceeds(setDoc(doc(db, 'groups', `${COURSE}__B`), group(COURSE, '3-morning', 'B')));
  });

  it('stage manager cannot create groups for another stage — even by lying about stageId', async () => {
    const db = as(env, SM3);
    await assertFails(setDoc(doc(db, 'groups', `${COURSE_EVE}__A`), group(COURSE_EVE, '1-evening', 'A')));
    await assertFails(setDoc(doc(db, 'groups', `${COURSE_EVE}__A`), group(COURSE_EVE, '3-morning', 'A')));
  });

  it('teacher reads groups of stages they teach, but cannot write', async () => {
    await assertSucceeds(getDoc(doc(as(env, T1), 'groups', GROUP_A)));
    await assertFails(getDoc(doc(as(env, T2), 'groups', GROUP_A)));
    await assertFails(updateDoc(doc(as(env, T1), 'groups', GROUP_A), { studentIds: [] }));
  });

  it('stage manager moves a student between groups in one batch (sizes may differ)', async () => {
    const db = as(env, SM3);
    await assertSucceeds(setDoc(doc(db, 'groups', `${COURSE}__B`), group(COURSE, '3-morning', 'B')));
    const move = (who) => {
      const fs = as(env, who);
      const b = writeBatch(fs);
      const stamp = { updatedAt: serverTimestamp(), updatedBy: who };
      b.update(doc(fs, 'groups', GROUP_A), { studentIds: arrayRemove('1001'), ...stamp });
      b.update(doc(fs, 'groups', `${COURSE}__B`), { studentIds: arrayUnion('1001'), ...stamp });
      return b.commit();
    };
    await assertFails(move(T1));
    await assertFails(move(T2));
    await assertSucceeds(move(SM3));
    const b = await getDoc(doc(db, 'groups', `${COURSE}__B`));
    if (JSON.stringify(b.data().studentIds) !== '["1001"]') throw new Error('not moved');
  });

  it('stage manager repeats a move in another course of the stage in the same batch', async () => {
    const other = 'CS302_3-morning';
    await env.withSecurityRulesDisabled(async (ctx) => {
      const db = ctx.firestore();
      await setDoc(doc(db, 'courses', other), { code: 'CS302', name: 'Lab 2', stageId: '3-morning', semester: 1, units: 3, hasPractical: true });
      await setDoc(doc(db, 'groups', `${other}__A`), group(other, '3-morning', 'A'));
      await updateDoc(doc(db, 'groups', `${other}__A`), { studentIds: ['1001'] });
      await setDoc(doc(db, 'groups', `${COURSE}__B`), group(COURSE, '3-morning', 'B'));
      await setDoc(doc(db, 'groups', `${other}__B`), group(other, '3-morning', 'B'));
      await setDoc(doc(db, 'groups', `${COURSE_EVE}__A`), group(COURSE_EVE, '1-evening', 'A'));
    });
    const move = (who, extra) => {
      const fs = as(env, who);
      const b = writeBatch(fs);
      const stamp = { updatedAt: serverTimestamp(), updatedBy: who };
      for (const c of [COURSE, extra]) {
        b.update(doc(fs, 'groups', `${c}__A`), { studentIds: arrayRemove('1001'), ...stamp });
        b.update(doc(fs, 'groups', `${c}__B`), { studentIds: arrayUnion('1001'), ...stamp });
      }
      return b.commit();
    };
    await assertFails(move(T1, other));
    await assertSucceeds(move(SM3, other));
    const b = await getDoc(doc(as(env, SM3), 'groups', `${other}__B`));
    if (JSON.stringify(b.data().studentIds) !== '["1001"]') throw new Error('not moved');
    // A course of another stage cannot ride along.
    const fs = as(env, SM3);
    const bad = writeBatch(fs);
    bad.update(doc(fs, 'groups', `${COURSE_EVE}__A`), { studentIds: arrayUnion('1001'), updatedAt: serverTimestamp(), updatedBy: SM3 });
    await assertFails(bad.commit());
  });
});

describe('assignments (teacher ↔ course / practical group)', () => {
  const theory = (teacherId, courseId = COURSE, stageId = '3-morning', target = 'all') => ({
    teacherId, courseId, stageId, type: 'theory', target, groupId: null,
  });
  const practical = (teacherId, target, courseId = COURSE, stageId = '3-morning') => ({
    teacherId, courseId, stageId, type: 'practical', target, groupId: `${courseId}__${target}`,
  });

  it('stage manager links a teacher in their stage', async () => {
    const db = as(env, SM3);
    await assertSucceeds(setDoc(doc(db, 'assignments', `${COURSE}__theory__all__${T2}`), theory(T2)));
    await assertSucceeds(setDoc(doc(db, 'assignments', `${COURSE}__practical__A__${T2}`), practical(T2, 'A')));
  });

  it('stage manager cannot link in another stage', async () => {
    const db = as(env, SM3);
    await assertFails(setDoc(doc(db, 'assignments', `${COURSE_EVE}__theory__all__${T2}`),
      theory(T2, COURSE_EVE, '1-evening')));
    await assertFails(setDoc(doc(db, 'assignments', `${COURSE_EVE}__theory__all__${T2}`),
      theory(T2, COURSE_EVE, '3-morning')));
  });

  it('practical assignment requires an existing group; teacher must exist', async () => {
    const db = as(env, SUPER);
    await assertFails(setDoc(doc(db, 'assignments', `${COURSE}__practical__Z__${T2}`), practical(T2, 'Z')));
    await assertFails(setDoc(doc(db, 'assignments', `${COURSE}__theory__all__ghost@uob.test`), theory('ghost@uob.test')));
  });

  it('rejects an id that does not match the content', async () => {
    await assertFails(setDoc(doc(as(env, SUPER), 'assignments', `${COURSE}__theory__all__${T1}`), theory(T2)));
  });

  it('teachers cannot link themselves', async () => {
    await assertFails(setDoc(doc(as(env, T2), 'assignments', `${COURSE}__theory__all__${T2}`), theory(T2)));
  });

  it('teacher reads only their own assignments', async () => {
    const db = as(env, T1);
    await assertSucceeds(getDoc(doc(db, 'assignments', THEORY_T1)));
    await assertSucceeds(getDocs(query(collection(db, 'assignments'), where('teacherId', '==', T1))));
    await assertFails(getDocs(collection(db, 'assignments')));
    await assertFails(getDoc(doc(as(env, T2), 'assignments', THEORY_T1)));
  });

  it('stage manager removes links in their stage', async () => {
    await assertSucceeds(deleteDoc(doc(as(env, SM3), 'assignments', THEORY_T1)));
  });
});

describe('stages and academic years', () => {
  it('everyone active reads; only admins write', async () => {
    await assertSucceeds(getDoc(doc(as(env, T1), 'stages', '3-morning')));
    await assertSucceeds(getDoc(doc(as(env, T1), 'academicYears', '2026-2027')));
    await assertFails(setDoc(doc(as(env, SM3), 'stages', '3-morning'), { level: 3 }));
    await assertFails(updateDoc(doc(as(env, SM3), 'academicYears', '2026-2027'), { lockHours: 999 }));
    await assertSucceeds(setDoc(doc(as(env, DEPUTY), 'stages', '4-evening'), { level: 4, shift: 'evening', sections: [] }));
    await assertFails(setDoc(doc(as(env, SUPER), 'stages', '9-night'), { level: 9 }));
  });

  it('admins save year settings only within sane bounds (lockHours drives session locks)', async () => {
    const y = doc(as(env, DEPUTY), 'academicYears', '2026-2027');
    await assertSucceeds(updateDoc(y, {
      lockHours: 72, weeksPerSemester: 16, semester: 2, lecturesPerUnitPerWeek: 0.5,
      thresholds: { alert: 4, warning: 8, dismissal: 12.5 }, leavesCountAgainst: true, maxLeaveDays: 10,
    }));
    await assertFails(updateDoc(y, { lockHours: 0 }));
    await assertFails(updateDoc(y, { lockHours: 48.5 }));
    await assertFails(updateDoc(y, { lockHours: 2000 }));
    await assertFails(updateDoc(y, { weeksPerSemester: 0 }));
    await assertFails(updateDoc(y, { semester: 3 }));
    await assertFails(updateDoc(y, { lecturesPerUnitPerWeek: 0 }));
    await assertFails(updateDoc(y, { thresholds: { alert: 10, warning: 5, dismissal: 15 } }));
    await assertFails(updateDoc(y, { thresholds: { alert: 5, warning: 10 } }));
  });

  it('annual stages: a list of stages and the year\'s weeks within bounds', async () => {
    const y = doc(as(env, DEPUTY), 'academicYears', '2026-2027');
    await assertSucceeds(updateDoc(y, { annualStages: ['1-morning', '2-evening'], weeksPerYear: 30 }));
    await assertFails(updateDoc(y, { annualStages: '1-morning' }));
    await assertFails(updateDoc(y, { weeksPerYear: 0 }));
    await assertFails(updateDoc(y, { weeksPerYear: 61 }));
    await assertFails(updateDoc(y, { weeksPerYear: 30.5 }));
    await assertFails(updateDoc(doc(as(env, SM3), 'academicYears', '2026-2027'), { annualStages: ['3-morning'] }));
  });
});

// The exact query shapes the app issues (lib/features/*/data/*_repository.dart).
// Firestore rejects a query whose filters cannot prove the read rule, so these
// guard against regressions in the Dart repositories.
describe('app query shapes', () => {
  it('groups of a course must be filtered by stageId as well', async () => {
    const sm = as(env, SM3);
    await assertSucceeds(getDocs(query(collection(sm, 'groups'),
      where('stageId', '==', '3-morning'), where('courseId', '==', COURSE))));
    await assertFails(getDocs(query(collection(sm, 'groups'), where('courseId', '==', COURSE))));
    await assertSucceeds(getDocs(query(collection(as(env, T1), 'groups'),
      where('stageId', '==', '3-morning'), where('courseId', '==', COURSE))));
  });

  it('stage manager: courses, students and assignments of a stage; teacher-of-stage cleanup query', async () => {
    const sm = as(env, SM3);
    await assertSucceeds(getDocs(query(collection(sm, 'courses'), where('stageId', '==', '1-evening'))));
    await assertSucceeds(getDocs(query(collection(sm, 'students'), where('stageId', '==', '3-morning'))));
    await assertSucceeds(getDocs(query(collection(sm, 'assignments'), where('stageId', '==', '3-morning'))));
    await assertSucceeds(getDocs(query(collection(sm, 'assignments'),
      where('stageId', '==', '3-morning'), where('teacherId', '==', T1), limit(1))));
    await assertSucceeds(getDocs(query(collection(sm, 'assignments'),
      where('stageId', '==', '3-morning'), where('courseId', '==', COURSE), where('target', '==', 'A'))));
    await assertSucceeds(getDocs(collection(sm, 'users')));
  });

  it('everyone: active academic year and stages', async () => {
    await assertSucceeds(getDocs(query(collection(as(env, T2), 'academicYears'), where('active', '==', true), limit(1))));
    await assertSucceeds(getDocs(collection(as(env, T2), 'stages')));
  });
});

// The exact write payloads the Dart repositories send.
describe('app write shapes', () => {
  it('AssignmentsRepository.assign: link + teachingStages in one batch (stage manager)', async () => {
    const db = as(env, SM3);
    const batch = writeBatch(db);
    batch.set(doc(db, 'assignments', `${COURSE}__theory__all__${T2}`), {
      teacherId: T2, courseId: COURSE, stageId: '3-morning', type: 'theory', target: 'all', groupId: null,
      teacherName: 'T2', courseName: 'هياكل البيانات', departmentId: 'cs',
      createdAt: serverTimestamp(), updatedAt: serverTimestamp(), updatedBy: SM3,
    });
    batch.update(doc(db, 'users', T2), { teachingStages: arrayUnion('3-morning'), updatedAt: serverTimestamp() });
    await assertSucceeds(batch.commit());
  });

  it('ImportWriter: teacher profile merge by a deputy, then the audit entry', async () => {
    const db = as(env, DEPUTY);
    await assertSucceeds(setDoc(doc(db, 'users', T1),
      { name: 'اسم جديد', title: 'مدرس', phone: '0770', updatedAt: serverTimestamp(), updatedBy: DEPUTY },
      { merge: true }));
    await assertSucceeds(setDoc(doc(db, 'auditLog', 'imp1'), {
      actor: DEPUTY, action: 'import.teachers', targetPath: 'users', stageId: null, before: null,
      after: { created: 0, updated: 1, failed: 0 }, at: serverTimestamp(),
    }));
  });

  it('ImportWriter: a stage manager cannot overwrite a student owned by another stage', async () => {
    const db = as(env, SM3);
    await assertFails(setDoc(doc(db, 'students', '2001'),
      { ...student('2001', '3-morning'), updatedAt: serverTimestamp(), updatedBy: SM3 }, { merge: true }));
  });

  it('UsersRepository.updatePhone', async () => {
    await assertSucceeds(updateDoc(doc(as(env, T1), 'users', T1), { phone: '0780', updatedAt: serverTimestamp() }));
  });

  it('CoursesRepository.distributeGroups by a stage manager', async () => {
    const db = as(env, SM3);
    const batch = writeBatch(db);
    batch.set(doc(db, 'groups', `${COURSE}__A`), {
      courseId: COURSE, stageId: '3-morning', name: 'A', studentIds: ['1001'], departmentId: 'cs',
      updatedAt: serverTimestamp(), updatedBy: SM3,
    });
    batch.set(doc(db, 'groups', `${COURSE}__B`), {
      courseId: COURSE, stageId: '3-morning', name: 'B', studentIds: [], departmentId: 'cs',
      updatedAt: serverTimestamp(), updatedBy: SM3,
    });
    await assertSucceeds(batch.commit());
  });
});
