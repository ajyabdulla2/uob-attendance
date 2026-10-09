// Shared fixtures for the Firestore security rules tests.
import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, resolve } from 'node:path';
import { initializeTestEnvironment } from '@firebase/rules-unit-testing';
import { doc, setDoc, Timestamp } from 'firebase/firestore';

const here = dirname(fileURLToPath(import.meta.url));
export const PROJECT_ID = 'demo-uob-attendance';

export async function createEnv() {
  const [host, port] = (process.env.FIRESTORE_EMULATOR_HOST ?? '127.0.0.1:8080').split(':');
  return initializeTestEnvironment({
    projectId: PROJECT_ID,
    firestore: {
      rules: readFileSync(resolve(here, '../../firestore.rules'), 'utf8'),
      host,
      port: Number(port),
    },
  });
}

// --------------------------------------------------------------- accounts --
export const SUPER = 'super@uob.test';
export const DEPUTY = 'deputy@uob.test';
export const SM3 = 'sm3@uob.test'; // stage manager of 3-morning (also teaches)
export const T1 = 't1@uob.test'; // teacher of CS301 (3-morning)
export const T2 = 't2@uob.test'; // teacher in 1-evening only
export const SUSPENDED = 'suspended@uob.test';
export const STRANGER = 'stranger@uob.test'; // verified, but not provisioned

const user = (email, roles, extra = {}) => ({
  email,
  name: `User ${email}`,
  roles,
  stageScopes: [],
  teachingStages: [],
  active: true,
  departmentId: 'cs',
  ...extra,
});

export const users = {
  [SUPER]: user(SUPER, ['superAdmin']),
  [DEPUTY]: user(DEPUTY, ['deputyAdmin']),
  [SM3]: user(SM3, ['stageManager', 'teacher'], { stageScopes: ['3-morning'] }),
  [T1]: user(T1, ['teacher'], { teachingStages: ['3-morning'] }),
  [T2]: user(T2, ['teacher'], { teachingStages: ['1-evening'] }),
  [SUSPENDED]: user(SUSPENDED, ['teacher'], { active: false, teachingStages: ['3-morning'] }),
};

/** Firestore client authenticated as [email] (verified by default). */
export function as(env, email, { verified = true } = {}) {
  return env
    .authenticatedContext(`uid-${email}`, { email, email_verified: verified })
    .firestore();
}

// ------------------------------------------------------------------ dates --
export const HOUR = 3600 * 1000;
export const DAY = 24 * HOUR;
export const LOCK_HOURS = 48;

export function utcMidnight(offsetDays = 0) {
  const now = new Date();
  return new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate() + offsetDays));
}

export function dateKey(d) {
  return d.toISOString().slice(0, 10).replaceAll('-', '');
}

/** lockAt exactly as the rules require for teacher-opened sessions. */
export function lockAtFor(date) {
  return new Date(date.getTime() + (24 + LOCK_HOURS) * HOUR);
}

// ------------------------------------------------------------- reference --
export const COURSE = 'CS301_3-morning';
export const COURSE_EVE = 'CS101_1-evening';
export const GROUP_A = `${COURSE}__A`;
export const THEORY_T1 = `${COURSE}__theory__all__${T1}`;
export const PRACTICAL_T1 = `${COURSE}__practical__A__${T1}`;

export function sessionId(courseId, type, target, date, lectureNo = 1) {
  return `${courseId}__${type}__${target}__${dateKey(date)}__${lectureNo}`;
}

export function sessionData({
  courseId = COURSE,
  stageId = '3-morning',
  type = 'theory',
  target = 'all',
  date = utcMidnight(0),
  lectureNo = 1,
  locked = false,
  lockAt = lockAtFor(date),
  openedBy = T1,
  updatedAt,
} = {}) {
  return {
    courseId,
    stageId,
    yearId: '2026-2027',
    type,
    target,
    groupId: type === 'practical' ? `${courseId}__${target}` : null,
    dateKey: dateKey(date),
    date: Timestamp.fromDate(date),
    lectureNo,
    locked,
    lockAt: Timestamp.fromDate(lockAt),
    openedBy,
    updatedBy: openedBy,
    ...(updatedAt === undefined ? {} : { updatedAt }),
  };
}

export const OPEN_SID = sessionId(COURSE, 'theory', 'all', utcMidnight(0));
export const LOCKED_SID = sessionId(COURSE, 'theory', 'all', utcMidnight(-1));
export const EXPIRED_SID = sessionId(COURSE, 'theory', 'all', utcMidnight(-10));

export function student(id, stageId, extra = {}) {
  return {
    universityId: id,
    fullName: `طالب ${id}`,
    stageId,
    level: Number(stageId[0]),
    shift: stageId.split('-')[1],
    section: 'أ',
    status: 'continuing',
    carryOver: false,
    sortKey: `طالب ${id}|${id}`,
    departmentId: 'cs',
    ...extra,
  };
}

/** Seeds the baseline dataset with rules disabled. */
export async function seed(env) {
  await env.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();
    for (const [email, data] of Object.entries(users)) {
      await setDoc(doc(db, 'users', email), data);
    }
    await setDoc(doc(db, 'academicYears', '2026-2027'), {
      label: '2026-2027', semester: 1, active: true, lockHours: LOCK_HOURS,
    });
    await setDoc(doc(db, 'stages', '3-morning'), { level: 3, shift: 'morning', sections: ['أ', 'ب'] });
    await setDoc(doc(db, 'courses', COURSE), {
      code: 'CS301', name: 'هياكل البيانات', stageId: '3-morning', semester: 1, units: 3, hasPractical: true,
    });
    await setDoc(doc(db, 'courses', COURSE_EVE), {
      code: 'CS101', name: 'مقدمة', stageId: '1-evening', semester: 1, units: 2, hasPractical: false,
    });
    await setDoc(doc(db, 'groups', GROUP_A), {
      courseId: COURSE, stageId: '3-morning', name: 'A', studentIds: ['1001'],
    });
    await setDoc(doc(db, 'assignments', THEORY_T1), {
      teacherId: T1, courseId: COURSE, stageId: '3-morning', type: 'theory', target: 'all',
    });
    await setDoc(doc(db, 'assignments', PRACTICAL_T1), {
      teacherId: T1, courseId: COURSE, stageId: '3-morning', type: 'practical', target: 'A', groupId: GROUP_A,
    });
    await setDoc(doc(db, 'students', '1001'), student('1001', '3-morning'));
    await setDoc(doc(db, 'students', '2001'), student('2001', '1-evening'));

    const now = Timestamp.now();
    await setDoc(doc(db, 'sessions', OPEN_SID), sessionData({ updatedAt: now }));
    await setDoc(doc(db, 'sessions', LOCKED_SID), sessionData({ date: utcMidnight(-1), locked: true, updatedAt: now }));
    await setDoc(doc(db, 'sessions', EXPIRED_SID), sessionData({ date: utcMidnight(-10), updatedAt: now }));
    await setDoc(doc(db, 'sessions', OPEN_SID, 'records', '1001'), {
      studentId: '1001', status: 'present', updatedBy: T1, updatedAt: now,
    });
    await setDoc(doc(db, 'leaves', 'leave-1'), {
      studentId: '1001', stageId: '3-morning', type: 'sick',
      from: Timestamp.fromDate(utcMidnight(-3)), to: Timestamp.fromDate(utcMidnight(-2)),
      referenceNo: '12/ط', approvedBy: SM3,
    });
  });
}
