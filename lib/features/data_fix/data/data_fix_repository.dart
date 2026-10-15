import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/firebase/collections.dart';
import '../../../core/firebase/doc_ids.dart';
import '../../../core/firebase/firestore_converters.dart';
import '../../../core/utils/arabic_text.dart';
import '../../audit/domain/audit_entry.dart';
import '../../import/domain/value_parsers.dart';
import '../../students/domain/student.dart';
import '../domain/fix_plan.dart';

/// تصحيح البيانات (admins only): change a university ID, a course code or a
/// teacher's e-mail — moving everything linked to it — and undo wrong
/// imports. IDs are document keys, so a change copies every document to its
/// new key and deletes the old one.
///
/// Every `plan…` reads the current state and returns a preview with the
/// writes; [apply] commits them. A plan is safe to re-run after an
/// interruption: the old main document goes last, and when the new one
/// already exists with the same name it is merged into instead of refused.
class DataFixRepository {
  DataFixRepository(this._fs);

  final FirebaseFirestore _fs;

  static Object get _now => FieldValue.serverTimestamp();

  // ------------------------------------------------------------ students --

  Future<FixPlan> planStudentRename(String fromRaw, String toRaw, {required String actor}) async {
    final from = DocIds.student(fromRaw);
    final to = DocIds.student(toRaw);
    if (from.isEmpty || to.isEmpty) return FixPlan.refused(FixProblem.invalidId);
    if (from == to) return FixPlan.refused(FixProblem.sameId);
    final oldSnap = await _fs.collection(Col.students).doc(from).get();
    if (!oldSnap.exists) return FixPlan.refused(FixProblem.notFound);
    final oldData = oldSnap.data()!;
    final old = Student.fromMap(from, oldData);
    final targetSnap = await _fs.collection(Col.students).doc(to).get();
    String? mergeInto;
    if (targetSnap.exists) {
      final other = Student.fromMap(to, targetSnap.data()!);
      if (!_sameName(other.fullName, old.fullName)) {
        return FixPlan.refused(FixProblem.targetExists, name: other.fullName);
      }
      mergeInto = other.fullName;
    }

    final create = [
      if (!targetSnap.exists)
        [
          FixWrite.set('${Col.students}/$to', {
            ...oldData,
            ...Student.fromMap(to, {...oldData, 'universityId': to}).toMap(),
            'updatedAt': _now,
            'updatedBy': actor,
          }),
        ],
    ];

    final stages = {old.stageId};
    final stats = await _fs.collection(Col.stats).where('studentId', isEqualTo: from).get();
    final statItems = [
      for (final d in stats.docs)
        [
          FixWrite.merge('${Col.stats}/${DocIds.stat(Fs.str(d.data()['courseId']), to)}', {
            ...d.data(),
            'studentId': to,
            'updatedAt': _now,
          }),
          FixWrite.delete(d.reference.path),
        ],
    ];
    stages.addAll([for (final d in stats.docs) Fs.str(d.data()['stageId'])].where((s) => s.isNotEmpty));

    final groups = await _fs.collection(Col.groups).where('studentIds', arrayContains: from).get();
    final groupItems = [
      for (final d in groups.docs)
        [
          FixWrite.update(d.reference.path, {
            'studentIds': {for (final id in Fs.strings(d.data()['studentIds'])) id == from ? to : id}.toList(),
            'updatedAt': _now,
          }),
        ],
    ];

    final leaves = await _fs.collection(Col.leaves).where('studentId', isEqualTo: from).get();
    final leaveItems = [
      for (final d in leaves.docs) [FixWrite.update(d.reference.path, {'studentId': to})],
    ];

    // Attendance records live under the sessions of the stages the student
    // was in. The session's updatedAt changes too, so teachers' phones
    // download it again.
    final recordItems = <List<FixWrite>>[];
    for (final stageId in stages) {
      final sessions = await _fs.collection(Col.sessions).where('stageId', isEqualTo: stageId).get();
      final found = await Future.wait([
        for (final s in sessions.docs) s.reference.collection(Col.records).doc(from).get(),
      ]);
      for (var i = 0; i < found.length; i++) {
        final record = found[i];
        if (!record.exists) continue;
        final session = sessions.docs[i].reference;
        final target = session.collection(Col.records).doc(to);
        var keepTarget = false;
        if (mergeInto != null) {
          final t = await target.get();
          keepTarget = t.exists && _isLater(t.data()!['updatedAt'], record.data()!['updatedAt']);
        }
        recordItems.add([
          if (!keepTarget)
            FixWrite.set(target.path, {
              ...record.data()!,
              'studentId': to,
              'updatedBy': actor,
              'updatedAt': _now,
            }),
          FixWrite.delete(record.reference.path),
          FixWrite.update(session.path, {'updatedAt': _now, 'updatedBy': actor}),
        ]);
      }
    }

    return FixPlan(
      counts: {
        FixCount.students: 1,
        FixCount.stats: statItems.length,
        FixCount.groups: groupItems.length,
        FixCount.leaves: leaveItems.length,
        FixCount.records: recordItems.length,
      },
      phases: [
        create,
        [...statItems, ...groupItems, ...leaveItems, ...recordItems],
        [
          [
            FixWrite.delete('${Col.students}/$from'),
            _audit(actor, 'student.rename', '${Col.students}/$to',
                stageId: old.stageId, before: {'id': from}, after: {'id': to}),
          ],
        ],
      ],
      mergeInto: mergeInto,
    );
  }

  /// Deletes students of [stageId] (or only [onlyId]) that have no
  /// attendance, statistics or leave — the undo of a wrong import.
  Future<FixPlan> planStudentDeletion(String stageId, {String? onlyId, required String actor}) async {
    final candidates = <String>[];
    final single = onlyId == null ? '' : DocIds.student(onlyId);
    if (single.isNotEmpty) {
      final snap = await _fs.collection(Col.students).doc(single).get();
      if (!snap.exists || snap.data()!['stageId'] != stageId) return FixPlan.refused(FixProblem.notFound);
      candidates.add(single);
    } else {
      final all = await _fs.collection(Col.students).where('stageId', isEqualTo: stageId).get();
      candidates.addAll([for (final d in all.docs) d.id]);
    }

    final history = <String>{};
    final stats = await _fs.collection(Col.stats).where('stageId', isEqualTo: stageId).get();
    history.addAll([for (final d in stats.docs) Fs.str(d.data()['studentId'])]);
    final leaves = await _fs.collection(Col.leaves).where('stageId', isEqualTo: stageId).get();
    history.addAll([for (final d in leaves.docs) Fs.str(d.data()['studentId'])]);
    final sessions = await _fs.collection(Col.sessions).where('stageId', isEqualTo: stageId).get();
    if (single.isNotEmpty) {
      final found = await Future.wait([
        for (final s in sessions.docs) s.reference.collection(Col.records).doc(single).get(),
      ]);
      if (found.any((r) => r.exists)) history.add(single);
    } else {
      final records = await Future.wait([for (final s in sessions.docs) s.reference.collection(Col.records).get()]);
      for (final r in records) {
        history.addAll([for (final d in r.docs) d.id]);
      }
    }

    final deletable = [for (final id in candidates) if (!history.contains(id)) id];
    final kept = candidates.length - deletable.length;
    if (deletable.isEmpty) {
      return FixPlan(problems: const [FixProblem.nothingToDelete], counts: {FixCount.kept: kept});
    }
    final gone = deletable.toSet();
    final groups = await _fs.collection(Col.groups).where('stageId', isEqualTo: stageId).get();
    final groupItems = [
      for (final d in groups.docs)
        if (Fs.strings(d.data()['studentIds']).any(gone.contains))
          [
            FixWrite.update(d.reference.path, {
              'studentIds': [for (final id in Fs.strings(d.data()['studentIds'])) if (!gone.contains(id)) id],
              'updatedAt': _now,
            }),
          ],
    ];
    return FixPlan(
      counts: {FixCount.students: deletable.length, FixCount.groups: groupItems.length, FixCount.kept: kept},
      phases: [
        [
          ...groupItems,
          for (final id in deletable) [FixWrite.delete('${Col.students}/$id')],
          [
            _audit(actor, 'students.delete', Col.students,
                stageId: stageId, before: {'count': deletable.length, 'ids': deletable.take(100).toList()}),
          ],
        ],
      ],
    );
  }

  // ------------------------------------------------------------- courses --

  Future<FixPlan> planCourseRename(String stageId, String fromCode, String toCode, {required String actor}) async {
    final fromC = DocIds.normalizeCourseCode(fromCode);
    final toC = DocIds.normalizeCourseCode(toCode);
    if (fromC.isEmpty || toC.isEmpty) return FixPlan.refused(FixProblem.invalidId);
    if (fromC == toC) return FixPlan.refused(FixProblem.sameId);
    final from = DocIds.course(fromC, stageId);
    final to = DocIds.course(toC, stageId);
    final oldSnap = await _fs.collection(Col.courses).doc(from).get();
    if (!oldSnap.exists) return FixPlan.refused(FixProblem.notFound);
    final oldData = oldSnap.data()!;
    final targetSnap = await _fs.collection(Col.courses).doc(to).get();
    String? mergeInto;
    if (targetSnap.exists) {
      final other = Fs.str(targetSnap.data()!['name']);
      if (!_sameName(other, Fs.str(oldData['name']))) return FixPlan.refused(FixProblem.targetExists, name: other);
      mergeInto = other;
    }
    String remap(String id) => id.startsWith('${from}__') ? '$to${id.substring(from.length)}' : id;

    final create = [
      if (!targetSnap.exists)
        [
          FixWrite.set('${Col.courses}/$to', {...oldData, 'code': toC, 'updatedAt': _now, 'updatedBy': actor}),
        ],
    ];

    final groups = await _fs.collection(Col.groups).where('courseId', isEqualTo: from).get();
    final groupItems = <List<FixWrite>>[];
    for (final d in groups.docs) {
      final newId = remap(d.id);
      var studentIds = Fs.strings(d.data()['studentIds']);
      if (mergeInto != null) {
        final t = await _fs.collection(Col.groups).doc(newId).get();
        if (t.exists) studentIds = {...Fs.strings(t.data()!['studentIds']), ...studentIds}.toList();
      }
      groupItems.add([
        FixWrite.set('${Col.groups}/$newId', {
          ...d.data(),
          'courseId': to,
          'studentIds': studentIds,
          'updatedAt': _now,
        }),
        FixWrite.delete(d.reference.path),
      ]);
    }

    final assignments = await _fs.collection(Col.assignments).where('courseId', isEqualTo: from).get();
    final assignmentItems = [
      for (final d in assignments.docs)
        [
          FixWrite.set('${Col.assignments}/${remap(d.id)}', {
            ...d.data(),
            'courseId': to,
            'groupId': d.data()['groupId'] is String ? remap(d.data()['groupId'] as String) : null,
            'updatedAt': _now,
            'updatedBy': actor,
          }),
          FixWrite.delete(d.reference.path),
        ],
    ];

    final sessions = await _fs.collection(Col.sessions).where('courseId', isEqualTo: from).get();
    final sessionItems = <List<FixWrite>>[];
    var records = 0;
    for (final d in sessions.docs) {
      final newSid = remap(d.id);
      final recs = await d.reference.collection(Col.records).get();
      records += recs.docs.length;
      sessionItems.add([
        FixWrite.set('${Col.sessions}/$newSid', {
          ...d.data(),
          'courseId': to,
          'groupId': d.data()['groupId'] is String ? remap(d.data()['groupId'] as String) : null,
          'updatedAt': _now,
          'updatedBy': actor,
        }),
        for (final r in recs.docs)
          FixWrite.set('${Col.sessions}/$newSid/${Col.records}/${r.id}', {
            ...r.data(),
            'updatedBy': actor,
            'updatedAt': _now,
          }),
        for (final r in recs.docs) FixWrite.delete(r.reference.path),
        FixWrite.delete(d.reference.path),
      ]);
    }

    final stats = await _fs.collection(Col.stats).where('courseId', isEqualTo: from).get();
    final statItems = [
      for (final d in stats.docs)
        [
          FixWrite.merge('${Col.stats}/${DocIds.stat(to, Fs.str(d.data()['studentId']))}', {
            ...d.data(),
            'courseId': to,
            if (d.data()['lastSessionId'] is String) 'lastSessionId': remap(d.data()['lastSessionId'] as String),
            'bySession': {for (final e in Fs.map(d.data()['bySession']).entries) remap(e.key): e.value},
            'updatedAt': _now,
          }),
          FixWrite.delete(d.reference.path),
        ],
    ];

    return FixPlan(
      counts: {
        FixCount.courses: 1,
        FixCount.groups: groupItems.length,
        FixCount.assignments: assignmentItems.length,
        FixCount.sessions: sessionItems.length,
        FixCount.records: records,
        FixCount.stats: statItems.length,
      },
      // The rules check a group's / assignment's / session's course and an
      // assignment's group with get(): parents are committed first.
      phases: [
        create,
        groupItems,
        assignmentItems,
        [...sessionItems, ...statItems],
        [
          [
            FixWrite.delete('${Col.courses}/$from'),
            _audit(actor, 'course.rename', '${Col.courses}/$to',
                stageId: stageId, before: {'id': from}, after: {'id': to}),
          ],
        ],
      ],
      mergeInto: mergeInto,
    );
  }

  /// Deletes courses of [stageId] (or only [onlyCode]) that never had a
  /// lecture, with their practical groups and teacher links.
  Future<FixPlan> planCourseDeletion(String stageId, {String? onlyCode, required String actor}) async {
    final candidates = <String>[];
    final code = onlyCode == null ? '' : DocIds.normalizeCourseCode(onlyCode);
    if (code.isNotEmpty) {
      final id = DocIds.course(code, stageId);
      if (!(await _fs.collection(Col.courses).doc(id).get()).exists) return FixPlan.refused(FixProblem.notFound);
      candidates.add(id);
    } else {
      final all = await _fs.collection(Col.courses).where('stageId', isEqualTo: stageId).get();
      candidates.addAll([for (final d in all.docs) d.id]);
    }

    final sessions = await _fs.collection(Col.sessions).where('stageId', isEqualTo: stageId).get();
    final taught = {for (final d in sessions.docs) Fs.str(d.data()['courseId'])};
    final deletable = [for (final id in candidates) if (!taught.contains(id)) id];
    final kept = candidates.length - deletable.length;
    if (deletable.isEmpty) {
      return FixPlan(problems: const [FixProblem.nothingToDelete], counts: {FixCount.kept: kept});
    }
    final gone = deletable.toSet();
    bool ofGone(QueryDocumentSnapshot<Map<String, dynamic>> d) => gone.contains(d.data()['courseId']);

    final groups = (await _fs.collection(Col.groups).where('stageId', isEqualTo: stageId).get()).docs.where(ofGone);
    final stageLinks = (await _fs.collection(Col.assignments).where('stageId', isEqualTo: stageId).get()).docs;
    final links = stageLinks.where(ofGone).toList();
    final stats = (await _fs.collection(Col.stats).where('stageId', isEqualTo: stageId).get()).docs.where(ofGone);

    // Teachers left without any class in the stage lose read access to it.
    final stillTeaching = {for (final d in stageLinks) if (!ofGone(d)) Fs.str(d.data()['teacherId'])};
    final userItems = <List<FixWrite>>[];
    for (final teacher in {for (final d in links) Fs.str(d.data()['teacherId'])}.difference(stillTeaching)) {
      final user = await _fs.collection(Col.users).doc(teacher).get();
      if (!user.exists) continue;
      final roles = Fs.strings(user.data()!['roles']);
      if (roles.contains('superAdmin') || roles.contains('deputyAdmin')) continue;
      if (!Fs.strings(user.data()!['teachingStages']).contains(stageId)) continue;
      userItems.add([
        FixWrite.update(user.reference.path, {
          'teachingStages': FieldValue.arrayRemove([stageId]),
          'updatedAt': _now,
        }),
      ]);
    }

    return FixPlan(
      counts: {
        FixCount.courses: deletable.length,
        FixCount.groups: groups.length,
        FixCount.assignments: links.length,
        FixCount.kept: kept,
      },
      phases: [
        [
          for (final d in [...links, ...groups, ...stats]) [FixWrite.delete(d.reference.path)],
          for (final id in deletable) [FixWrite.delete('${Col.courses}/$id')],
          ...userItems,
          [
            _audit(actor, 'courses.delete', Col.courses,
                stageId: stageId, before: {'count': deletable.length, 'ids': deletable.take(100).toList()}),
          ],
        ],
      ],
    );
  }

  // ------------------------------------------------------------ teachers --

  // ------------------------------------------------------------ lectures --

  /// Deletes every lecture recorded from [from] to [to] (whole days, at most
  /// [maxDays]), in [stageId] or every stage, and only [courseId] /
  /// [onlySessionIds] when given — e.g. days entered at random
  /// while trying the app out. With each lecture go its records, its entry
  /// in the students' `stats` (so the percentages drop it) and the pending
  /// edit requests about it (rejected with [rejectNote]; the rules keep
  /// requests). Phones drop their copy when the class next opens
  /// (`TeacherDataSync.pullClassSessions`).
  Future<FixPlan> planLectureDeletion(
    DateTime from,
    DateTime to, {
    String? stageId,
    String? courseId,
    Set<String>? onlySessionIds,
    required String actor,
    required String rejectNote,
  }) async {
    final keys = <String>[];
    for (var d = DateTime.utc(from.year, from.month, from.day);
        !d.isAfter(DateTime.utc(to.year, to.month, to.day)) && keys.length < maxDays;
        d = d.add(const Duration(days: 1))) {
      keys.add(DocIds.dateKey(d));
    }
    final sessions = <QueryDocumentSnapshot<Map<String, dynamic>>>[];
    for (var i = 0; i < keys.length; i += 30) {
      final snap = await _fs
          .collection(Col.sessions)
          .where('dateKey', whereIn: keys.sublist(i, i + 30 > keys.length ? keys.length : i + 30))
          .get();
      sessions.addAll([
        for (final d in snap.docs)
          if ((stageId == null || d.data()['stageId'] == stageId) &&
              (courseId == null || d.data()['courseId'] == courseId) &&
              (onlySessionIds == null || onlySessionIds.contains(d.id)))
            d,
      ]);
    }
    if (sessions.isEmpty) return FixPlan.refused(FixProblem.nothingToDelete);
    sessions.sort((a, b) => a.id.compareTo(b.id));
    final gone = {for (final d in sessions) d.id};

    // The students' statistics: rewrite bySession without these lectures.
    final courses = {for (final d in sessions) (Fs.str(d.data()['courseId']), Fs.str(d.data()['stageId']))};
    final statItems = <List<FixWrite>>[];
    for (final (courseId, stage) in courses) {
      final stats = await _fs
          .collection(Col.stats)
          .where('stageId', isEqualTo: stage)
          .where('courseId', isEqualTo: courseId)
          .get();
      for (final d in stats.docs) {
        final bySession = Fs.map(d.data()['bySession']);
        if (!bySession.keys.any(gone.contains)) continue;
        statItems.add([
          // The whole document: `update` of a map field merges on some
          // clients instead of replacing it.
          FixWrite.set(d.reference.path, {
            ...d.data(),
            'bySession': {for (final e in bySession.entries) if (!gone.contains(e.key)) e.key: e.value},
            'updatedAt': _now,
          }),
        ]);
      }
    }

    final pending = await _fs.collection(Col.editRequests).where('status', isEqualTo: 'pending').get();
    final requestItems = [
      for (final d in pending.docs)
        if (gone.contains(d.data()['sessionId']))
          [
            FixWrite.update(d.reference.path, {
              'status': 'rejected',
              'decidedBy': actor,
              'decidedAt': _now,
              'decisionNote': rejectNote,
              'updatedAt': _now,
            }),
          ],
    ];

    var records = 0;
    final sessionItems = <List<FixWrite>>[];
    for (final d in sessions) {
      final recs = await d.reference.collection(Col.records).get();
      records += recs.docs.length;
      sessionItems.add([for (final r in recs.docs) FixWrite.delete(r.reference.path), FixWrite.delete(d.reference.path)]);
    }

    return FixPlan(
      counts: {FixCount.sessions: sessions.length, FixCount.records: records, FixCount.stats: statItems.length},
      // Statistics and requests first: if a run stops half-way, the lectures
      // are still there to be found by the next run.
      phases: [
        [...statItems, ...requestItems],
        [
          ...sessionItems,
          [
            _audit(actor, 'sessions.delete', Col.sessions,
                stageId: stageId,
                before: {
                  'from': keys.first,
                  'to': keys.last,
                  'courseId': ?courseId,
                  'count': sessions.length,
                  'ids': gone.take(100).toList(),
                }),
          ],
        ],
      ],
      sessionIds: [for (final d in sessions) d.id],
    );
  }

  /// The longest period one lecture deletion covers.
  static const maxDays = 31;

  /// Deletes a teacher account (or, without [onlyEmail], every plain
  /// teacher account) that never recorded a lecture, with its class links —
  /// e.g. accounts imported with wrong e-mails. Accounts with history keep
  /// it intact: suspend them instead. Super admin only (rules).
  Future<FixPlan> planTeacherDeletion({String? onlyEmail, required String actor}) async {
    final me = DocIds.user(actor);
    final candidates = <String>[];
    final single = (onlyEmail ?? '').trim().isNotEmpty;
    if (single) {
      final email = ValueParsers.email(onlyEmail!);
      if (email == null) return FixPlan.refused(FixProblem.invalidId);
      if (email == me) return FixPlan.refused(FixProblem.ownAccount);
      if (!(await _fs.collection(Col.users).doc(email).get()).exists) return FixPlan.refused(FixProblem.notFound);
      candidates.add(email);
    } else {
      final teachers = await _fs.collection(Col.users).where('roles', arrayContains: 'teacher').get();
      candidates.addAll([
        for (final d in teachers.docs)
          if (d.id != me && Fs.strings(d.data()['roles']).every((r) => r == 'teacher')) d.id,
      ]);
    }

    final recorded = await Future.wait([
      for (final email in candidates)
        Future.wait([
          _fs.collection(Col.sessions).where('openedBy', isEqualTo: email).limit(1).get(),
          _fs.collection(Col.sessions).where('updatedBy', isEqualTo: email).limit(1).get(),
        ]).then((r) => r.any((q) => q.docs.isNotEmpty)),
    ]);
    final deletable = [for (var i = 0; i < candidates.length; i++) if (!recorded[i]) candidates[i]];
    final kept = candidates.length - deletable.length;
    if (deletable.isEmpty) {
      return single
          ? FixPlan.refused(FixProblem.hasHistory)
          : FixPlan(problems: const [FixProblem.nothingToDelete], counts: {FixCount.kept: kept});
    }

    final links = await Future.wait([
      for (final email in deletable) _fs.collection(Col.assignments).where('teacherId', isEqualTo: email).get(),
    ]);
    final linkItems = [
      for (final q in links)
        for (final d in q.docs) [FixWrite.delete(d.reference.path)],
    ];
    return FixPlan(
      counts: {FixCount.users: deletable.length, FixCount.assignments: linkItems.length, FixCount.kept: kept},
      phases: [
        [
          ...linkItems,
          for (final email in deletable) [FixWrite.delete('${Col.users}/$email')],
          [
            _audit(actor, 'users.delete', Col.users,
                before: {'count': deletable.length, 'ids': deletable.take(100).toList()}),
          ],
        ],
      ],
    );
  }

  /// Moves an account and its classes to another e-mail (super admin).
  /// History keeps the old e-mail in `openedBy` / `updatedBy`: that is who
  /// signed in at the time.
  Future<FixPlan> planTeacherRename(String fromRaw, String toRaw, {required String actor}) async {
    final from = ValueParsers.email(fromRaw);
    final to = ValueParsers.email(toRaw);
    if (from == null || to == null) return FixPlan.refused(FixProblem.invalidId);
    if (from == to) return FixPlan.refused(FixProblem.sameId);
    if (from == DocIds.user(actor)) return FixPlan.refused(FixProblem.ownAccount);
    final oldSnap = await _fs.collection(Col.users).doc(from).get();
    if (!oldSnap.exists) return FixPlan.refused(FixProblem.notFound);
    final oldData = oldSnap.data()!;
    final targetSnap = await _fs.collection(Col.users).doc(to).get();
    final mergeInto = targetSnap.exists ? Fs.str(targetSnap.data()!['name']) : null;

    final oldStages = Fs.strings(oldData['teachingStages']);
    final create = [
      if (!targetSnap.exists)
        [
          FixWrite.set('${Col.users}/$to', {...oldData, 'email': to, 'updatedAt': _now, 'updatedBy': actor}),
        ]
      else if (!Fs.strings(targetSnap.data()!['teachingStages']).toSet().containsAll(oldStages))
        [
          FixWrite.update('${Col.users}/$to', {
            'teachingStages': FieldValue.arrayUnion(oldStages),
            'updatedAt': _now,
          }),
        ],
    ];

    final assignments = await _fs.collection(Col.assignments).where('teacherId', isEqualTo: from).get();
    final assignmentItems = [
      for (final d in assignments.docs)
        [
          FixWrite.set(
            '${Col.assignments}/${DocIds.assignment(
              courseId: Fs.str(d.data()['courseId']),
              type: Fs.str(d.data()['type']),
              target: Fs.str(d.data()['target']),
              teacherId: to,
            )}',
            {...d.data(), 'teacherId': to, 'updatedAt': _now, 'updatedBy': actor},
          ),
          FixWrite.delete(d.reference.path),
        ],
    ];
    final request = await _fs.collection(Col.accessRequests).doc(to).get();

    return FixPlan(
      counts: {FixCount.users: 1, FixCount.assignments: assignmentItems.length},
      // An assignment's teacher is checked with exists(): the account first.
      phases: [
        create,
        assignmentItems,
        [
          [
            FixWrite.delete('${Col.users}/$from'),
            if (request.exists) FixWrite.delete(request.reference.path),
            _audit(actor, 'user.rename', '${Col.users}/$to', before: {'email': from}, after: {'email': to}),
          ],
        ],
      ],
      mergeInto: mergeInto,
    );
  }

  // --------------------------------------------------------------- apply --

  /// Commits [plan] batch by batch; returns the number of writes.
  Future<int> apply(FixPlan plan, {void Function(int done, int total)? onProgress}) async {
    final batches = FixPlan.pack(plan.phases);
    for (var i = 0; i < batches.length; i++) {
      final batch = _fs.batch();
      for (final w in batches[i]) {
        final ref = _fs.doc(w.path);
        switch (w.op) {
          case FixOp.set:
            batch.set(ref, w.data);
          case FixOp.merge:
            batch.set(ref, w.data, SetOptions(merge: true));
          case FixOp.update:
            batch.update(ref, w.data);
          case FixOp.delete:
            batch.delete(ref);
        }
      }
      await batch.commit();
      onProgress?.call(i + 1, batches.length);
    }
    return plan.writeCount;
  }

  FixWrite _audit(
    String actor,
    String action,
    String targetPath, {
    String? stageId,
    Map<String, Object?>? before,
    Map<String, Object?>? after,
  }) =>
      FixWrite.set(_fs.collection(Col.auditLog).doc().path, {
        ...AuditEntry(
          actor: actor,
          action: action,
          targetPath: targetPath,
          stageId: stageId,
          before: before,
          after: after,
        ).toMap(),
        'at': _now,
      });

  static bool _sameName(String a, String b) => ArabicText.normalizeForCompare(a) == ArabicText.normalizeForCompare(b);

  static bool _isLater(Object? a, Object? b) => switch ((a, b)) {
        (Timestamp x, Timestamp y) => x.compareTo(y) > 0,
        (Timestamp _, null) => true,
        _ => false,
      };
}
