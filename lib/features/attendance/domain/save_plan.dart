import '../../../core/config/app_config.dart';
import '../../../core/firebase/collections.dart';
import '../../../core/firebase/doc_ids.dart';
import '../../../core/firebase/server_time.dart';
import '../../assignments/domain/assignment.dart';
import 'attendance_session.dart';

/// One student's mark in the register: status + optional note.
final class Mark {
  const Mark(this.status, [this.note = '']);

  static const present = Mark(AttendanceStatus.present);

  final AttendanceStatus status;
  final String note;

  Mark copyWith({AttendanceStatus? status, String? note}) => Mark(status ?? this.status, note ?? this.note);

  @override
  bool operator ==(Object other) => other is Mark && other.status == status && other.note == note;

  @override
  int get hashCode => Object.hash(status, note);
}

/// Kinds of queued writes (mirrors the outbox ops).
enum WriteKind { createOrUpdate, merge }

/// A Firestore write planned by [SavePlan] (values may contain [serverTime]
/// and `Timestamp`s; the uploader converts them).
final class PlannedWrite {
  const PlannedWrite(this.kind, this.path, this.data);

  final WriteKind kind;
  final String path;
  final Map<String, Object?> data;
}

/// Why a save is refused before anything is written.
enum SaveRefusal { futureDate, locked, noStudents }

class SaveRefusedException implements Exception {
  const SaveRefusedException(this.reason);
  final SaveRefusal reason;

  @override
  String toString() => 'SaveRefusedException($reason)';
}

/// What saving a lecture writes (pure; unit-tested).
///
/// * The session is `createOrUpdate`: created with every field the rules
///   check, or — when it already exists on the server (another device opened
///   it) — only `counts / updatedAt / updatedBy` change, the only fields a
///   teacher may touch.
/// * A record per student on the first save; afterwards only changed ones.
/// * A `stats` entry `bySession[sessionId] = status` for students who are
///   not simply present, and for any status change (idempotent; see rules).
/// * An excluded lecture («لا تُحتسب») sets every student's entry to
///   [AttendanceSession.excludedValue]; turning it back on rewrites every
///   student's real status. The records keep the marks either way.
final class SavePlan {
  const SavePlan({required this.session, required this.writes, required this.changedStudents});

  final AttendanceSession session;
  final List<PlannedWrite> writes;
  final Set<String> changedStudents;

  bool get isEmpty => writes.isEmpty;

  static SavePlan build({
    required Assignment assignment,
    required String yearId,
    required int lockHours,
    required DateTime date,
    required int lectureNo,
    required Map<String, Mark> marks,
    required Map<String, Mark> previous,
    required String actor,
    required DateTime now,
    String? openedBy,
    bool canOverrideLock = false,
    bool excluded = false,
    bool previousExcluded = false,
  }) {
    if (marks.isEmpty) throw const SaveRefusedException(SaveRefusal.noStudents);
    final day = DateTime.utc(date.year, date.month, date.day);
    final today = DateTime.utc(now.year, now.month, now.day);
    if (day.isAfter(today)) throw const SaveRefusedException(SaveRefusal.futureDate);

    final counts = {for (final s in AttendanceStatus.values) s: 0};
    for (final m in marks.values) {
      counts[m.status] = counts[m.status]! + 1;
    }
    final session = AttendanceSession(
      courseId: assignment.courseId,
      stageId: assignment.stageId,
      yearId: yearId,
      type: assignment.type,
      target: assignment.target,
      groupId: assignment.groupId,
      date: day,
      lectureNo: lectureNo,
      openedBy: openedBy ?? actor,
      lockAt: AttendanceSession.lockAtFor(day, lockHours),
      excluded: excluded,
      counts: counts,
      deviceCreatedAt: now,
    );
    if (!canOverrideLock && session.isLockedAt(now.toUtc())) {
      throw const SaveRefusedException(SaveRefusal.locked);
    }

    final isNew = previous.isEmpty;
    final changed = <String>{
      for (final e in marks.entries)
        if (isNew || previous[e.key] != e.value) e.key,
    };
    // Turning «لا تُحتسب» on or off changes every student's stats entry.
    final toggled = isNew ? excluded : excluded != previousExcluded;
    final sid = session.id;
    final countsMap = {for (final e in counts.entries) e.key.name: e.value};
    final writes = <PlannedWrite>[];
    if (changed.isNotEmpty || toggled) {
      writes.add(PlannedWrite(WriteKind.createOrUpdate, '${Col.sessions}/$sid', {
        'create': {
          ...session.toMap(),
          'updatedBy': actor,
          'updatedAt': serverTime,
          'counts': countsMap,
        },
        // Only sent when it is or was set, so ordinary saves keep the
        // fields older rules allowed.
        'update': {
          'counts': countsMap,
          'updatedAt': serverTime,
          'updatedBy': actor,
          if (excluded || previousExcluded) 'excluded': excluded,
        },
      }));
      for (final id in marks.keys) {
        final mark = marks[id]!;
        if (changed.contains(id)) {
          writes.add(PlannedWrite(WriteKind.merge, '${Col.sessions}/$sid/${Col.records}/$id', {
            'studentId': id,
            'status': mark.status.name,
            'note': mark.note.trim(),
            'updatedBy': actor,
            'updatedAt': serverTime,
            'deviceUpdatedAt': now.toUtc(),
          }));
        }
        final before = previous[id]?.status;
        final String? stat;
        if (excluded) {
          stat = toggled ? AttendanceSession.excludedValue : null;
        } else if (toggled) {
          stat = mark.status.name;
        } else if (!changed.contains(id)) {
          stat = null;
        } else {
          final statusChanged = isNew ? mark.status != AttendanceStatus.present : before != mark.status;
          stat = statusChanged ? mark.status.name : null;
        }
        if (stat != null) {
          writes.add(PlannedWrite(WriteKind.merge, '${Col.stats}/${DocIds.stat(assignment.courseId, id)}', {
            'courseId': assignment.courseId,
            'studentId': id,
            'stageId': assignment.stageId,
            'lastSessionId': sid,
            'bySession': {sid: stat},
            'updatedAt': serverTime,
            'departmentId': AppConfig.departmentId,
          }));
        }
      }
    }
    return SavePlan(session: session, writes: writes, changedStudents: changed);
  }
}
