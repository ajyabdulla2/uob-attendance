import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/firebase/doc_ids.dart';
import '../../../core/firebase/firestore_converters.dart';
import '../../assignments/domain/assignment.dart';
import '../domain/attendance_session.dart';
import '../domain/save_plan.dart';
import 'outbox_codec.dart';

/// Local-first attendance (SPEC «العمل دون اتصال»): a save writes the
/// session and its records to SQLite and queues the Firestore writes in the
/// same transaction, so a lecture is never half-saved and never lost if the
/// app closes offline. [OutboxUploader] sends the queue later.
class AttendanceStore {
  AttendanceStore(this._db);

  final AppDatabase _db;

  static String sessionIdFor(Assignment a, DateTime date, int lectureNo) => DocIds.session(
        courseId: a.courseId,
        type: a.type.name,
        target: a.target,
        date: date,
        lectureNo: lectureNo,
      );

  /// Session a queued batch belongs to (batch IDs are `sessionId#micros`).
  static String sessionOfBatch(String batchId) => batchId.split('#').first;

  /// Gives up on a batch the server refused: drops it and — unless other
  /// saves of that lecture are still queued — the local copy of the
  /// lecture, so the register shows the server's version after a refresh.
  Future<void> discardRejected(String batchId) => _db.transaction(() async {
        await _db.deleteBatch(batchId);
        final sid = sessionOfBatch(batchId);
        if (!await _db.hasPendingWritesFor(sid)) await _db.deleteLocalSession(sid);
      });

  /// Marks this device last saved for [sessionId] (empty for a new lecture).
  Future<Map<String, Mark>> marksOf(String sessionId) async => {
        for (final r in (await _db.recordsOfSession(sessionId)).values)
          r.studentId: Mark(Fs.enumByName(AttendanceStatus.values, r.status, AttendanceStatus.present), r.note),
      };

  Future<AttendanceSession?> session(String id) async {
    final row = await _db.sessionById(id);
    return row == null ? null : _fromRow(row);
  }

  Stream<List<AttendanceSession>> watchClassSessions(Assignment a) =>
      _db.watchSessionsOfClass(a.courseId, a.type.name, a.target).map((rows) => rows.map(_fromRow).toList());

  /// Statuses per session and student (the register).
  Stream<Map<String, Map<String, AttendanceStatus>>> watchMarks(List<String> sessionIds) =>
      _db.watchRecordsOfSessions(sessionIds).map((bySession) => {
            for (final e in bySession.entries)
              e.key: {
                for (final r in e.value.values)
                  r.studentId: Fs.enumByName(AttendanceStatus.values, r.status, AttendanceStatus.present),
              },
          });

  /// Saves a lecture; throws [SaveRefusedException] when it may not be saved.
  /// Returns the plan (empty when nothing changed since the last save).
  Future<SavePlan> save({
    required Assignment assignment,
    required String yearId,
    required int lockHours,
    required DateTime date,
    required int lectureNo,
    required Map<String, Mark> marks,
    required String actor,
    DateTime? now,
    bool canOverrideLock = false,
    bool excluded = false,
  }) async {
    final at = now ?? DateTime.now();
    final sid = sessionIdFor(assignment, date, lectureNo);
    final existing = await _db.sessionById(sid);
    final plan = SavePlan.build(
      assignment: assignment,
      yearId: existing?.yearId ?? yearId,
      lockHours: lockHours,
      date: date,
      lectureNo: lectureNo,
      marks: marks,
      previous: await marksOf(sid),
      actor: actor,
      now: at,
      openedBy: existing?.openedBy,
      canOverrideLock: canOverrideLock,
      excluded: excluded,
      previousExcluded: existing != null && _fromRow(existing).excluded,
    );
    if (plan.isEmpty) return plan;

    await _db.transaction(() async {
      await _db.upsertSession(_toRow(plan.session, savedAt: at, deviceCreatedAt: existing?.deviceCreatedAt));
      await _db.upsertRecords([
        for (final e in marks.entries)
          LocalRecordsCompanion.insert(
            sessionId: sid,
            studentId: e.key,
            status: e.value.status.name,
            note: Value(e.value.note.trim()),
            updatedBy: actor,
            deviceUpdatedAt: Value(at),
          ),
      ]);
      await _db.enqueue('$sid#${at.microsecondsSinceEpoch}', [
        for (final w in plan.writes)
          (
            op: w.kind == WriteKind.createOrUpdate ? OutboxOp.createOrUpdate : OutboxOp.merge,
            path: w.path,
            data: OutboxCodec.toJsonSafe(w.data),
          ),
      ], now: at);
    });
    return plan;
  }

  /// Stores a session downloaded from the server with all its records —
  /// replacing the local ones (a student renamed by the department leaves
  /// no stale row) — unless this device still has unsent changes for it
  /// (those are newer).
  Future<bool> storeDownloaded(AttendanceSession s, List<AttendanceRecord> records) async {
    if (await _db.hasPendingWritesFor(s.id)) return false;
    await _db.transaction(() async {
      await _db.deleteRecordsOfSession(s.id);
      await _db.upsertSession(_toRow(s, savedAt: s.updatedAt, deviceCreatedAt: s.deviceCreatedAt));
      await _db.upsertRecords([
        for (final r in records)
          LocalRecordsCompanion.insert(
            sessionId: s.id,
            studentId: r.studentId,
            status: r.status.name,
            note: Value(r.note),
            updatedBy: r.updatedBy,
            deviceUpdatedAt: Value(r.deviceUpdatedAt),
          ),
      ]);
    });
    return true;
  }

  static const _excludedKey = 'excluded';

  LocalSessionsCompanion _toRow(AttendanceSession s, {DateTime? savedAt, DateTime? deviceCreatedAt}) =>
      LocalSessionsCompanion.insert(
        id: s.id,
        courseId: s.courseId,
        stageId: s.stageId,
        yearId: s.yearId,
        type: s.type.name,
        target: s.target,
        groupId: Value(s.groupId),
        dateKey: s.dateKey,
        date: s.date,
        lectureNo: s.lectureNo,
        openedBy: s.openedBy,
        lockAt: s.lockAt,
        locked: Value(s.locked),
        // «لا تُحتسب» rides in the counts JSON (no schema change, so the
        // flag reaches phones in a patch; older code ignores the key).
        countsJson: Value(jsonEncode({
          for (final e in s.counts.entries) e.key.name: e.value,
          if (s.excluded) _excludedKey: true,
        })),
        deviceCreatedAt: Value(deviceCreatedAt ?? s.deviceCreatedAt),
        savedAt: Value(savedAt),
      );

  AttendanceSession _fromRow(LocalSessionRow r) {
    final counts = (jsonDecode(r.countsJson) as Map).cast<String, Object?>();
    return AttendanceSession(
      courseId: r.courseId,
      stageId: r.stageId,
      yearId: r.yearId,
      type: Fs.enumByName(AssignmentType.values, r.type, AssignmentType.theory),
      target: r.target,
      groupId: r.groupId,
      date: r.date.toUtc(),
      lectureNo: r.lectureNo,
      openedBy: r.openedBy,
      lockAt: r.lockAt.toUtc(),
      locked: r.locked,
      excluded: counts[_excludedKey] == true,
      counts: {
        for (final s in AttendanceStatus.values)
          if (counts[s.name] is num) s: (counts[s.name] as num).toInt(),
      },
      deviceCreatedAt: r.deviceCreatedAt,
      updatedAt: r.savedAt,
    );
  }
}
