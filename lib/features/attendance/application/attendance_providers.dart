import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/firebase/doc_ids.dart';
import '../../../core/firebase/firebase_providers.dart';
import '../../academic/domain/academic_year.dart';
import '../../assignments/domain/assignment.dart';
import '../../auth/application/auth_providers.dart';
import '../../courses/domain/course.dart';
import '../../courses/domain/practical_group.dart';
import '../../leaves/domain/leave.dart';
import '../../stats/domain/absence_summary.dart';
import '../../students/domain/student.dart';
import '../data/attendance_store.dart';
import '../data/outbox_uploader.dart';
import '../data/teacher_data_sync.dart';
import '../domain/attendance_session.dart';

/// Local-first features (SQLite + outbox) run on phones. The web admin panel
/// has no local database; widget tests that do not exercise these screens
/// turn them off too.
final localFirstProvider = Provider<bool>((ref) => !kIsWeb);

final attendanceStoreProvider = Provider<AttendanceStore>(
  (ref) => AttendanceStore(ref.watch(appDatabaseProvider)),
);

final teacherDataSyncProvider = Provider<TeacherDataSync>(
  (ref) => TeacherDataSync(ref.watch(appDatabaseProvider), ref.watch(firestoreProvider)),
);

final outboxUploaderProvider = Provider<OutboxUploader>(
  (ref) => OutboxUploader(ref.watch(appDatabaseProvider), FirestoreRemoteWriter(ref.watch(firestoreProvider))),
);

/// «موادي» from the local mirror (works offline after the first download).
final localClassesProvider = StreamProvider.autoDispose<List<Assignment>>((ref) {
  final me = ref.watch(signedInUserProvider);
  return ref.watch(appDatabaseProvider).watchAssignmentsOfTeacher(me.id);
});

final localClassProvider = Provider.autoDispose.family<Assignment?, String>(
  (ref, id) => ref.watch(localClassesProvider).value?.where((a) => a.id == id).firstOrNull,
);

/// Active academic year as last downloaded (lock window, weeks…).
final cachedYearProvider = FutureProvider.autoDispose<AcademicYear?>((ref) {
  ref.watch(syncControllerProvider.select((s) => s.lastDownloadAt));
  return ref.watch(teacherDataSyncProvider).cachedYear();
});

/// A practical group as cached on the phone (refreshed when a class opens).
final localGroupProvider = StreamProvider.autoDispose.family<PracticalGroup?, String>(
  (ref, id) => ref.watch(appDatabaseProvider).watchGroupById(id),
);

/// Students who attend a class, in register order: the whole stage, one
/// section, or one practical group.
final classStudentsProvider = StreamProvider.autoDispose.family<List<Student>, String>((ref, id) async* {
  final a = ref.watch(localClassProvider(id));
  if (a == null) {
    yield const [];
    return;
  }
  final db = ref.watch(appDatabaseProvider);
  PracticalGroup? group;
  if (a.groupId != null) {
    final g = ref.watch(localGroupProvider(a.groupId!));
    if (!g.hasValue) return;
    group = g.value;
  }
  yield* db.watchStudentsOfStage(a.stageId, attendingOnly: true).map((students) => [
        for (final s in students)
          if (switch (a.type) {
            AssignmentType.practical => group?.studentIds.contains(s.id) ?? false,
            AssignmentType.theory => a.target == DocIds.allSections || s.section == a.target,
          })
            s,
      ]);
});

final classSessionsProvider = StreamProvider.autoDispose.family<List<AttendanceSession>, String>((ref, id) {
  final a = ref.watch(localClassProvider(id));
  if (a == null) return Stream.value(const []);
  return ref.watch(attendanceStoreProvider).watchClassSessions(a);
});

/// Statuses of a class's lectures on this phone: session → student → status.
final classMarksProvider =
    StreamProvider.autoDispose.family<Map<String, Map<String, AttendanceStatus>>, String>((ref, id) {
  final sessions = ref.watch(classSessionsProvider(id)).value ?? const <AttendanceSession>[];
  return ref.watch(attendanceStoreProvider).watchMarks([for (final s in sessions) s.id]);
});

/// Bumped after the register fetches the course's stats and leaves.
class StandingCacheTick extends Notifier<int> {
  @override
  int build() => 0;
  void bump() => state++;
}

final standingCacheTickProvider = NotifierProvider<StandingCacheTick, int>(StandingCacheTick.new);

/// What the class's percentages are computed from: the course's statuses
/// as last fetched from the server, overridden by this phone's own marks for
/// this class (fresher), the stage's approved leaves and the year.
final class ClassAbsenceData {
  const ClassAbsenceData({
    required this.course,
    required this.year,
    required this.type,
    required this.bySession,
    required this.leaves,
  });

  final Course course;
  final AcademicYear year;

  /// `theory` / `practical` when the year keeps two percentages, else null.
  final String? type;

  /// studentId → sessionId → status.
  final Map<String, Map<String, AttendanceStatus>> bySession;
  final Map<String, List<Leave>> leaves;

  AbsenceSummary summaryOf(String studentId) => AbsenceSummary.of(
        bySession: bySession[studentId] ?? const {},
        leaves: leaves[studentId] ?? const [],
        units: course.units,
        year: year,
        stageId: course.stageId,
        type: type,
      );
}

/// Null until the year and the class have been downloaded.
final classAbsenceDataProvider = FutureProvider.autoDispose.family<ClassAbsenceData?, String>((ref, id) async {
  ref.watch(standingCacheTickProvider);
  final a = ref.watch(localClassProvider(id));
  final marks = ref.watch(classMarksProvider(id)).value;
  final students = ref.watch(classStudentsProvider(id)).value;
  final year = await ref.watch(cachedYearProvider.future);
  if (a == null || marks == null || students == null || year == null) return null;
  final sync = ref.watch(teacherDataSyncProvider);
  final server = await sync.cachedCourseStats(a.courseId);
  final leaves = await sync.cachedLeaves(a.stageId);
  final course = (await ref.watch(appDatabaseProvider).coursesOfStage(a.stageId)).where((c) => c.id == a.courseId).firstOrNull;
  if (course == null) return null;
  final leavesOf = <String, List<Leave>>{};
  for (final l in leaves) {
    (leavesOf[l.studentId] ??= []).add(l);
  }
  return ClassAbsenceData(
    course: course,
    year: year,
    type: year.combinedTheoryPractical ? null : a.type.name,
    bySession: {
      for (final s in students)
        s.id: {
          ...?server[s.id],
          for (final MapEntry(key: sid, value: byStudent) in marks.entries) sid: ?byStudent[s.id],
        },
    },
    leaves: leavesOf,
  );
});

/// Each student's percentage in the class's course (see [ClassAbsenceData]).
/// Empty until the year has been downloaded.
final classStandingsProvider =
    FutureProvider.autoDispose.family<Map<String, AbsenceSummary>, String>((ref, id) async {
  final data = await ref.watch(classAbsenceDataProvider(id).future);
  if (data == null) return const {};
  return {for (final studentId in data.bySession.keys) studentId: data.summaryOf(studentId)};
});

/// Batches the server refused (kept on the phone until retried).
final rejectedUploadsProvider = StreamProvider.autoDispose<List<OutboxEntry>>(
  (ref) => ref.watch(appDatabaseProvider).watchRejected(),
);

/// Time of the oldest write still waiting (SPEC: warn after 24 h).
final oldestPendingProvider = FutureProvider.autoDispose<DateTime?>((ref) {
  ref.watch(pendingUploadsProvider);
  return ref.watch(appDatabaseProvider).oldestPendingAt();
});

// ---------------------------------------------------------------- syncing --

final class SyncState {
  const SyncState({this.running = false, this.lastUploadAt, this.lastDownloadAt, this.problem});

  final bool running;

  /// Last run that emptied the queue.
  final DateTime? lastUploadAt;
  final DateTime? lastDownloadAt;

  /// Why the last run stopped (`unavailable`, `timeout`…), or null.
  final String? problem;

  bool get offline => problem == 'unavailable' || problem == 'timeout' || problem == 'deadline-exceeded';
}

/// Uploads the outbox and refreshes the teacher's data. Triggered at start,
/// on resume, periodically while the app is open (see SyncLifecycle), after
/// every save and by «مزامنة الآن».
///
/// The full download (students of every taught stage) is the expensive part
/// on the Spark quota, so it runs once a day, when the teacher's assignments
/// change, or on «مزامنة الآن».
class SyncController extends Notifier<SyncState> {
  static const downloadEvery = Duration(hours: 24);

  @override
  SyncState build() => const SyncState();

  Future<void> sync({bool forceDownload = false}) async {
    if (state.running || !ref.read(localFirstProvider)) return;
    final status = ref.read(authStatusProvider);
    if (status is! SignedIn) return;
    state = SyncState(running: true, lastUploadAt: state.lastUploadAt, lastDownloadAt: state.lastDownloadAt);

    String? problem;
    var downloadedAt = state.lastDownloadAt;
    final now = DateTime.now();
    try {
      final download = ref.read(teacherDataSyncProvider);
      final last = await download.lastDownloadAt();
      if (forceDownload || last == null || now.difference(last) > downloadEvery) {
        await download.refresh(status.user.id, now: now);
        downloadedAt = now;
      } else {
        downloadedAt ??= last;
      }
    } on FirebaseException catch (e) {
      problem = e.code;
    }

    var uploadedAt = state.lastUploadAt;
    try {
      final report = await ref.read(outboxUploaderProvider).run();
      if (report.completed) uploadedAt = DateTime.now();
      problem ??= report.stoppedBy;
    } on Object catch (e) {
      problem ??= e is FirebaseException ? e.code : '$e';
    }
    state = SyncState(lastUploadAt: uploadedAt, lastDownloadAt: downloadedAt, problem: problem);
  }
}

final syncControllerProvider = NotifierProvider<SyncController, SyncState>(SyncController.new);
