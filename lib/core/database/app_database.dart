import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../features/assignments/domain/assignment.dart';
import '../../features/courses/domain/course.dart';
import '../../features/courses/domain/practical_group.dart';
import '../../features/students/domain/student.dart';

part 'app_database.g.dart';

// =============================================================================
// Local SQLite store (Drift).
//
// SPEC «العمل دون اتصال»: everything a teacher needs is mirrored locally, and
// every write goes to an explicit upload queue (outbox) before Firestore, so
// nothing is lost if the app is closed offline. Phase 1 provides the schema,
// the cache mirrors and the outbox API; the sync engine comes in phase 2.
// =============================================================================

/// Mirror of `students` for the stages the user can see.
@DataClassName('LocalStudentRow')
class LocalStudents extends Table {
  TextColumn get id => text()();
  TextColumn get universityId => text()();
  TextColumn get fullName => text()();
  TextColumn get stageId => text()();
  TextColumn get section => text().withDefault(const Constant(''))();
  TextColumn get status => text()();
  BoolColumn get carryOver => boolean().withDefault(const Constant(false))();
  TextColumn get sortKey => text()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Mirror of `courses`.
@DataClassName('LocalCourseRow')
class LocalCourses extends Table {
  TextColumn get id => text()();
  TextColumn get code => text()();
  TextColumn get name => text()();
  TextColumn get stageId => text()();
  IntColumn get semester => integer()();
  IntColumn get units => integer()();
  BoolColumn get hasPractical => boolean()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Mirror of `groups` (student IDs stored as a JSON array).
@DataClassName('LocalGroupRow')
class LocalGroups extends Table {
  TextColumn get id => text()();
  TextColumn get courseId => text()();
  TextColumn get stageId => text()();
  TextColumn get name => text()();
  TextColumn get studentIdsJson => text().withDefault(const Constant('[]'))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Mirror of the signed-in teacher's `assignments`.
@DataClassName('LocalAssignmentRow')
class LocalAssignments extends Table {
  TextColumn get id => text()();
  TextColumn get teacherId => text()();
  TextColumn get courseId => text()();
  TextColumn get stageId => text()();
  TextColumn get type => text()();
  TextColumn get target => text()();
  TextColumn get groupId => text().nullable()();
  TextColumn get courseName => text().withDefault(const Constant(''))();
  TextColumn get teacherName => text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Kinds of queued Firestore writes.
enum OutboxOp { set, merge, delete }

/// Upload queue («طابور رفع»). Each row is one document write; rows sharing a
/// [batchId] must be committed together (e.g. session + records + stats).
@DataClassName('OutboxEntry')
class OutboxEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get batchId => text()();
  TextColumn get op => textEnum<OutboxOp>()();
  TextColumn get path => text()();
  TextColumn get payloadJson => text().withDefault(const Constant('{}'))();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
}

/// Small key/value store for sync bookkeeping (last sync times…).
@DataClassName('SyncStateRow')
class SyncStates extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(
  tables: [LocalStudents, LocalCourses, LocalGroups, LocalAssignments, OutboxEntries, SyncStates],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() => driftDatabase(
        name: 'uob_attendance',
        // Web needs sqlite3.wasm + drift_worker.js in web/ (see CLAUDE.md).
        web: DriftWebOptions(
          sqlite3Wasm: Uri.parse('sqlite3.wasm'),
          driftWorker: Uri.parse('drift_worker.js'),
        ),
      );

  // ------------------------------------------------------------ students --

  /// Replaces the cached students of [stageId] with [students].
  Future<void> replaceStudentsOfStage(String stageId, Iterable<Student> students) =>
      transaction(() async {
        await (delete(localStudents)..where((t) => t.stageId.equals(stageId))).go();
        await batch((b) => b.insertAll(localStudents, students.map(_studentRow)));
      });

  /// Students of [stageId] in register order (sortKey).
  Stream<List<Student>> watchStudentsOfStage(String stageId, {bool attendingOnly = false}) {
    final query = select(localStudents)
      ..where((t) => t.stageId.equals(stageId))
      ..orderBy([(t) => OrderingTerm.asc(t.sortKey)]);
    return query.watch().map((rows) {
      final students = rows.map(_studentFromRow);
      return (attendingOnly ? students.where((s) => s.attendsLectures) : students).toList();
    });
  }

  LocalStudentsCompanion _studentRow(Student s) => LocalStudentsCompanion.insert(
        id: s.id,
        universityId: s.universityId,
        fullName: s.fullName,
        stageId: s.stageId,
        section: Value(s.section),
        status: s.status.name,
        carryOver: Value(s.carryOver),
        sortKey: s.sortKey,
      );

  Student _studentFromRow(LocalStudentRow r) => Student.fromMap(r.id, {
        'universityId': r.universityId,
        'fullName': r.fullName,
        'stageId': r.stageId,
        'section': r.section,
        'status': r.status,
        'carryOver': r.carryOver,
      });

  // ------------------------------------------------------------- courses --

  Future<void> upsertCourses(Iterable<Course> courses) => batch((b) => b.insertAllOnConflictUpdate(
        localCourses,
        courses.map((c) => LocalCoursesCompanion.insert(
              id: c.id,
              code: c.code,
              name: c.name,
              stageId: c.stageId,
              semester: c.semester,
              units: c.units,
              hasPractical: c.hasPractical,
            )),
      ));

  Future<List<Course>> coursesOfStage(String stageId) async {
    final rows = await (select(localCourses)
          ..where((t) => t.stageId.equals(stageId))
          ..orderBy([(t) => OrderingTerm.asc(t.code)]))
        .get();
    return [
      for (final r in rows)
        Course.fromMap(r.id, {
          'code': r.code,
          'name': r.name,
          'stageId': r.stageId,
          'semester': r.semester,
          'units': r.units,
          'hasPractical': r.hasPractical,
        }),
    ];
  }

  // -------------------------------------------------------------- groups --

  Future<void> upsertGroups(Iterable<PracticalGroup> groups) => batch((b) => b.insertAllOnConflictUpdate(
        localGroups,
        groups.map((g) => LocalGroupsCompanion.insert(
              id: g.id,
              courseId: g.courseId,
              stageId: g.stageId,
              name: g.name,
              studentIdsJson: Value(jsonEncode(g.studentIds)),
            )),
      ));

  Future<PracticalGroup?> groupById(String id) async {
    final r = await (select(localGroups)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (r == null) return null;
    return PracticalGroup(
      courseId: r.courseId,
      stageId: r.stageId,
      name: r.name,
      studentIds: (jsonDecode(r.studentIdsJson) as List).cast<String>(),
    );
  }

  // --------------------------------------------------------- assignments --

  /// Replaces the cached assignments of [teacherId] (downloaded at login).
  Future<void> replaceAssignmentsOfTeacher(String teacherId, Iterable<Assignment> items) =>
      transaction(() async {
        await (delete(localAssignments)..where((t) => t.teacherId.equals(teacherId))).go();
        await batch((b) => b.insertAll(
              localAssignments,
              items.map((a) => LocalAssignmentsCompanion.insert(
                    id: a.id,
                    teacherId: a.teacherId,
                    courseId: a.courseId,
                    stageId: a.stageId,
                    type: a.type.name,
                    target: a.target,
                    groupId: Value(a.groupId),
                    courseName: Value(a.courseName),
                    teacherName: Value(a.teacherName),
                  )),
            ));
      });

  Stream<List<Assignment>> watchAssignmentsOfTeacher(String teacherId) =>
      (select(localAssignments)..where((t) => t.teacherId.equals(teacherId)))
          .watch()
          .map((rows) => [
                for (final r in rows)
                  Assignment.fromMap(r.id, {
                    'teacherId': r.teacherId,
                    'courseId': r.courseId,
                    'stageId': r.stageId,
                    'type': r.type,
                    'target': r.target,
                    'groupId': r.groupId,
                    'courseName': r.courseName,
                    'teacherName': r.teacherName,
                  }),
              ]);

  // -------------------------------------------------------------- outbox --

  /// Queues writes that must be uploaded together; returns their row IDs.
  Future<List<int>> enqueue(
    String batchId,
    List<({OutboxOp op, String path, Map<String, Object?> data})> writes, {
    DateTime? now,
  }) =>
      transaction(() async {
        final at = now ?? DateTime.now();
        return [
          for (final w in writes)
            await into(outboxEntries).insert(OutboxEntriesCompanion.insert(
              batchId: batchId,
              op: w.op,
              path: w.path,
              payloadJson: Value(jsonEncode(w.data)),
              createdAt: at,
            )),
        ];
      });

  /// Number of queued writes («X سجلات بانتظار الرفع»).
  Stream<int> watchPendingCount() {
    final count = outboxEntries.id.count();
    return (selectOnly(outboxEntries)..addColumns([count])).map((r) => r.read(count) ?? 0).watchSingle();
  }

  /// Oldest pending batch (all its rows), or empty when the queue is empty.
  Future<List<OutboxEntry>> nextBatch() async {
    final first = await (select(outboxEntries)
          ..orderBy([(t) => OrderingTerm.asc(t.id)])
          ..limit(1))
        .getSingleOrNull();
    if (first == null) return const [];
    return (select(outboxEntries)
          ..where((t) => t.batchId.equals(first.batchId))
          ..orderBy([(t) => OrderingTerm.asc(t.id)]))
        .get();
  }

  /// Removes an uploaded batch.
  Future<void> completeBatch(String batchId) =>
      (delete(outboxEntries)..where((t) => t.batchId.equals(batchId))).go();

  /// Records a failed upload attempt (the batch stays queued).
  Future<void> failBatch(String batchId, String error) => customUpdate(
        'UPDATE outbox_entries SET attempts = attempts + 1, last_error = ? WHERE batch_id = ?',
        variables: [Variable.withString(error), Variable.withString(batchId)],
        updates: {outboxEntries},
      );

  /// Oldest queued write time — for the «not uploaded for 24 h» warning.
  Future<DateTime?> oldestPendingAt() async {
    final row = await (select(outboxEntries)
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)])
          ..limit(1))
        .getSingleOrNull();
    return row?.createdAt;
  }

  // ---------------------------------------------------------- sync state --

  Future<String?> readState(String key) async =>
      (await (select(syncStates)..where((t) => t.key.equals(key))).getSingleOrNull())?.value;

  Future<void> writeState(String key, String value) =>
      into(syncStates).insertOnConflictUpdate(SyncStatesCompanion.insert(key: key, value: value));

  /// Wipes every local table (used on sign-out when nothing is pending).
  Future<void> clearAll() => transaction(() async {
        for (final table in allTables) {
          await delete(table).go();
        }
      });
}
