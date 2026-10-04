// warningLists (department vs deanery), leaves, auditLog.
import { describe, it, before, beforeEach, after } from 'node:test';
import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import {
  deleteDoc, doc, getDoc, serverTimestamp, setDoc, updateDoc, Timestamp,
} from 'firebase/firestore';
import { createEnv, seed, as, utcMidnight, SUPER, DEPUTY, SM3, T1, T2 } from './helpers.js';

let env;
before(async () => { env = await createEnv(); });
beforeEach(async () => { await env.clearFirestore(); await seed(env); });
after(async () => { await env.cleanup(); });

const list = (stageId, decision, extra = {}) => ({
  stageId, level: 'warning', decision, entries: [{ studentId: '1001', courseId: 'CS301_3-morning', percent: 11.1 }],
  ...extra,
});
const order = { orderNumber: '3/4/1234', orderDate: Timestamp.fromDate(new Date()) };

describe('warning lists: department (provisional) vs deanery (final)', () => {
  it('stage manager creates and edits department decisions for their stage only', async () => {
    const db = as(env, SM3);
    await assertSucceeds(setDoc(doc(db, 'warningLists', 'w1'), list('3-morning', 'department')));
    await assertSucceeds(updateDoc(doc(db, 'warningLists', 'w1'), { entries: [] }));
    await assertFails(setDoc(doc(db, 'warningLists', 'w2'), list('1-evening', 'department')));
  });

  it('stage manager cannot issue or convert to a deanery decision', async () => {
    const db = as(env, SM3);
    await assertFails(setDoc(doc(db, 'warningLists', 'w3'), list('3-morning', 'deanery', order)));
    await env.withSecurityRulesDisabled((ctx) => setDoc(doc(ctx.firestore(), 'warningLists', 'w1'), list('3-morning', 'department')));
    await assertFails(updateDoc(doc(db, 'warningLists', 'w1'), { decision: 'deanery', ...order }));
  });

  it('admins convert to deanery only with an order number and date', async () => {
    await env.withSecurityRulesDisabled((ctx) => setDoc(doc(ctx.firestore(), 'warningLists', 'w1'), list('3-morning', 'department')));
    await assertFails(updateDoc(doc(as(env, DEPUTY), 'warningLists', 'w1'), { decision: 'deanery' }));
    await assertSucceeds(updateDoc(doc(as(env, DEPUTY), 'warningLists', 'w1'), { decision: 'deanery', ...order }));
  });

  it('a deanery decision is frozen: no edit, no delete — even for the super admin', async () => {
    await env.withSecurityRulesDisabled((ctx) => setDoc(doc(ctx.firestore(), 'warningLists', 'w9'), list('3-morning', 'deanery', order)));
    await assertFails(updateDoc(doc(as(env, SUPER), 'warningLists', 'w9'), { entries: [] }));
    await assertFails(updateDoc(doc(as(env, SUPER), 'warningLists', 'w9'), { decision: 'department' }));
    await assertFails(deleteDoc(doc(as(env, SUPER), 'warningLists', 'w9')));
  });

  it('department decisions can be deleted (regenerated); teachers have no access', async () => {
    await env.withSecurityRulesDisabled((ctx) => setDoc(doc(ctx.firestore(), 'warningLists', 'w1'), list('3-morning', 'department')));
    await assertFails(getDoc(doc(as(env, T1), 'warningLists', 'w1')));
    await assertSucceeds(deleteDoc(doc(as(env, SM3), 'warningLists', 'w1')));
  });
});

describe('leaves', () => {
  const leave = (approvedBy, extra = {}) => ({
    studentId: '1001', stageId: '3-morning', type: 'sick',
    from: Timestamp.fromDate(utcMidnight(-1)), to: Timestamp.fromDate(utcMidnight(0)),
    referenceNo: '55', approvedBy, ...extra,
  });

  it('stage manager records and approves leaves in their stage (as themselves)', async () => {
    const db = as(env, SM3);
    await assertSucceeds(setDoc(doc(db, 'leaves', 'l2'), leave(SM3)));
    await assertSucceeds(setDoc(doc(db, 'leaves', 'l3'), leave(null)));
    await assertFails(setDoc(doc(db, 'leaves', 'l4'), leave(SUPER)));
    await assertFails(setDoc(doc(db, 'leaves', 'l5'), leave(SM3, { stageId: '1-evening' })));
  });

  it('rejects inverted date ranges and unknown types', async () => {
    const db = as(env, SM3);
    await assertFails(setDoc(doc(db, 'leaves', 'l6'), leave(SM3, {
      from: Timestamp.fromDate(utcMidnight(1)), to: Timestamp.fromDate(utcMidnight(0)),
    })));
    await assertFails(setDoc(doc(db, 'leaves', 'l7'), leave(SM3, { type: 'vacation' })));
  });

  it('teachers read leaves of stages they teach (to mark «مُجاز» offline) but never write', async () => {
    await assertSucceeds(getDoc(doc(as(env, T1), 'leaves', 'leave-1')));
    await assertFails(getDoc(doc(as(env, T2), 'leaves', 'leave-1')));
    await assertFails(setDoc(doc(as(env, T1), 'leaves', 'l8'), leave(null)));
  });
});

describe('audit log is append-only', () => {
  const entry = (actor) => ({
    actor, action: 'record.update', targetPath: 'sessions/x/records/1001', stageId: '3-morning',
    before: { status: 'present' }, after: { status: 'absent' }, at: serverTimestamp(),
  });

  it('any active user appends entries as themselves', async () => {
    await assertSucceeds(setDoc(doc(as(env, T1), 'auditLog', 'a1'), entry(T1)));
    await assertFails(setDoc(doc(as(env, T1), 'auditLog', 'a2'), entry(SM3)));
    await assertFails(setDoc(doc(as(env, T1), 'auditLog', 'a3'), { ...entry(T1), at: Timestamp.fromDate(new Date(2020, 0, 1)) }));
  });

  it('nobody updates or deletes entries', async () => {
    await env.withSecurityRulesDisabled((ctx) => setDoc(doc(ctx.firestore(), 'auditLog', 'a1'), { ...entry(T1), at: Timestamp.now() }));
    await assertFails(updateDoc(doc(as(env, SUPER), 'auditLog', 'a1'), { action: 'x' }));
    await assertFails(deleteDoc(doc(as(env, SUPER), 'auditLog', 'a1')));
  });

  it('admins and the stage manager read; teachers do not', async () => {
    await env.withSecurityRulesDisabled((ctx) => setDoc(doc(ctx.firestore(), 'auditLog', 'a1'), { ...entry(T1), at: Timestamp.now() }));
    await assertSucceeds(getDoc(doc(as(env, SUPER), 'auditLog', 'a1')));
    await assertSucceeds(getDoc(doc(as(env, SM3), 'auditLog', 'a1')));
    await assertFails(getDoc(doc(as(env, T1), 'auditLog', 'a1')));
  });
});
