// Backup and restore (BackupRepository): admins read everything, records in
// one collection-group query; the super admin writes a backup back in the
// phases of restorePhases() with the fields the rules pin to the writer.
import { describe, it, before, beforeEach, after } from 'node:test';
import assert from 'node:assert/strict';
import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import {
  collection, collectionGroup, deleteDoc, doc, getCountFromServer, getDoc, getDocs, limit, orderBy, query,
  serverTimestamp, setDoc, Timestamp, where, writeBatch,
} from 'firebase/firestore';
import { createEnv, seed, as, SUPER, DEPUTY, SM3, T1, OPEN_SID } from './helpers.js';

let env;
before(async () => { env = await createEnv(); });
beforeEach(async () => { await env.clearFirestore(); await seed(env); });
after(async () => { await env.cleanup(); });

// Mirrors BackupScope.phases (restore_plan.dart).
const PHASES = [
  ['academicYears', 'stages', 'users', 'courses', 'students', 'config'],
  ['groups'],
  ['assignments', 'leaves', 'stats', 'warningLists'],
  ['sessions'],
];

async function snapshot() {
  const data = { collections: {}, records: {} };
  await env.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();
    for (const c of PHASES.flat()) {
      data.collections[c] = {};
      for (const d of (await getDocs(collection(db, c))).docs) data.collections[c][d.id] = d.data();
    }
    for (const d of (await getDocs(collectionGroup(db, 'records'))).docs) {
      const sid = d.ref.parent.parent.id;
      (data.records[sid] ??= {})[d.id] = d.data();
    }
  });
  return data;
}

async function restore(db, actor, data) {
  for (const names of PHASES) {
    const batch = writeBatch(db);
    for (const c of names) {
      for (const [id, fields] of Object.entries(data.collections[c])) {
        if (c === 'users' && id === actor) continue;
        const out = { ...fields };
        if (c === 'sessions') out.updatedAt = serverTimestamp();
        if (c === 'leaves' && out.approvedBy != null) out.approvedBy = actor;
        batch.set(doc(db, c, id), out);
      }
    }
    await batch.commit();
  }
  const batch = writeBatch(db);
  for (const [sid, recs] of Object.entries(data.records)) {
    for (const [studentId, fields] of Object.entries(recs)) {
      batch.set(doc(db, 'sessions', sid, 'records', studentId), {
        ...fields, updatedBy: actor, updatedAt: serverTimestamp(),
      });
    }
  }
  await batch.commit();
}

describe('backup reads', () => {
  it('admins read every record in one collection-group query, and count them', async () => {
    for (const who of [SUPER, DEPUTY]) {
      const db = as(env, who);
      await assertSucceeds(getDocs(query(collectionGroup(db, 'records'), limit(1000))));
      await assertSucceeds(getCountFromServer(collectionGroup(db, 'records')));
    }
  });

  it('stage managers and teachers cannot read records across sessions', async () => {
    for (const who of [SM3, T1]) {
      const db = as(env, who);
      await assertFails(getDocs(collectionGroup(db, 'records')));
      await assertFails(getCountFromServer(collectionGroup(db, 'records')));
    }
  });

  it('admins read the history collections and config/backup is theirs to write', async () => {
    const db = as(env, DEPUTY);
    for (const c of ['auditLog', 'editRequests', 'accessRequests', 'config', 'users', 'stats']) {
      await assertSucceeds(getDocs(collection(db, c)));
    }
    await assertSucceeds(setDoc(doc(db, 'config', 'backup'), {
      at: serverTimestamp(), by: DEPUTY, documents: 10, withRecords: true,
    }));
    await assertFails(setDoc(doc(as(env, SM3), 'config', 'backup'), { by: SM3 }));
  });
});

describe('restore', () => {
  it('the super admin writes a backup back phase by phase', async () => {
    const data = await snapshot();
    await env.withSecurityRulesDisabled(async (ctx) => {
      const db = ctx.firestore();
      await deleteDoc(doc(db, 'sessions', OPEN_SID, 'records', '1001'));
      await deleteDoc(doc(db, 'students', '1001'));
      await deleteDoc(doc(db, 'leaves', 'leave-1'));
    });
    await assertSucceeds(restore(as(env, SUPER), SUPER, data));
    await env.withSecurityRulesDisabled(async (ctx) => {
      const db = ctx.firestore();
      assert.equal((await getDoc(doc(db, 'students', '1001'))).data().fullName, 'طالب 1001');
      assert.equal((await getDoc(doc(db, 'sessions', OPEN_SID, 'records', '1001'))).data().status, 'present');
      assert.equal((await getDoc(doc(db, 'leaves', 'leave-1'))).data().approvedBy, SUPER);
    });
  });

  it('without the rewritten fields the writes are refused', async () => {
    const data = await snapshot();
    const db = as(env, SUPER);
    const rec = data.records[OPEN_SID]['1001'];
    await assertFails(setDoc(doc(db, 'sessions', OPEN_SID, 'records', '1001'), rec));
    await assertFails(setDoc(doc(db, 'sessions', OPEN_SID), data.collections.sessions[OPEN_SID]));
    await env.withSecurityRulesDisabled(async (ctx) => deleteDoc(doc(ctx.firestore(), 'leaves', 'leave-1')));
    await assertFails(setDoc(doc(db, 'leaves', 'leave-1'), data.collections.leaves['leave-1']));
  });

  it('a frozen deanery decision cannot be written again (the restore skips it)', async () => {
    const list = {
      stageId: '3-morning', level: 'warning', decision: 'deanery', entries: [],
      orderNumber: '12', orderDate: Timestamp.now(),
    };
    await env.withSecurityRulesDisabled(async (ctx) => setDoc(doc(ctx.firestore(), 'warningLists', 'w1'), list));
    await assertFails(setDoc(doc(as(env, SUPER), 'warningLists', 'w1'), list));
    await env.withSecurityRulesDisabled(async (ctx) => deleteDoc(doc(ctx.firestore(), 'warningLists', 'w1')));
    await assertSucceeds(setDoc(doc(as(env, SUPER), 'warningLists', 'w1'), list));
  });
});

describe('audit log viewer and department dashboard', () => {
  it('stage managers page through the audit log of their stage only', async () => {
    const db = as(env, SM3);
    await assertSucceeds(getDocs(query(collection(db, 'auditLog'),
      where('stageId', '==', '3-morning'), orderBy('at', 'desc'), limit(50))));
    await assertFails(getDocs(query(collection(db, 'auditLog'), orderBy('at', 'desc'), limit(50))));
    await assertFails(getDocs(query(collection(db, 'auditLog'),
      where('stageId', '==', '1-evening'), orderBy('at', 'desc'), limit(50))));
    await assertSucceeds(getDocs(query(collection(as(env, DEPUTY), 'auditLog'), orderBy('at', 'desc'), limit(50))));
  });

  it('search: by user and by days, within the stage for stage managers', async () => {
    const from = Timestamp.fromDate(new Date(2026, 9, 1));
    const db = as(env, SM3);
    await assertSucceeds(getDocs(query(collection(db, 'auditLog'), where('stageId', '==', '3-morning'),
      where('actor', '==', SM3), where('at', '>=', from), orderBy('at', 'desc'), limit(50))));
    await assertFails(getDocs(query(collection(db, 'auditLog'),
      where('actor', '==', SM3), orderBy('at', 'desc'), limit(50))));
    const admin = as(env, DEPUTY);
    await assertSucceeds(getDocs(query(collection(admin, 'auditLog'),
      where('actor', '==', SM3), where('at', '>=', from), orderBy('at', 'desc'), limit(50))));
  });

  it('admins count every stage; stage managers cannot count the department', async () => {
    const db = as(env, DEPUTY);
    await assertSucceeds(getCountFromServer(query(collection(db, 'students'), where('stageId', '==', '1-evening'))));
    await assertSucceeds(getCountFromServer(query(collection(db, 'courses'), where('stageId', '==', '1-evening'))));
    await assertSucceeds(getCountFromServer(query(collection(db, 'sessions'),
      where('stageId', '==', '3-morning'), where('dateKey', '==', '20261007'))));
    await assertSucceeds(getCountFromServer(query(collection(db, 'editRequests'),
      where('stageId', '==', '3-morning'), where('status', '==', 'pending'))));
    await assertSucceeds(getCountFromServer(collection(db, 'accessRequests')));
    await assertSucceeds(getCountFromServer(query(collection(db, 'users'), where('active', '==', true))));
    await assertFails(getCountFromServer(query(collection(as(env, SM3), 'students'), where('stageId', '==', '1-evening'))));
    await assertFails(getCountFromServer(collection(as(env, SM3), 'accessRequests')));
  });
});

describe('rules version canary', () => {
  it('only the current version can be read', async () => {
    await assertSucceeds(getDoc(doc(as(env, T1), 'rulesVersion', '2026-10-28a')));
    await assertFails(getDoc(doc(as(env, T1), 'rulesVersion', '2026-01-01')));
  });
});
