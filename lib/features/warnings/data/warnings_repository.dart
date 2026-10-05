import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/firebase/collections.dart';
import '../../audit/domain/audit_entry.dart';
import '../../stats/domain/standings.dart';
import '../../stats/domain/student_course_stat.dart';
import '../domain/warning_list.dart';

/// Decision lists (SPEC «قوائم القرارات»): a department decision stays
/// editable and can be regenerated; a deanery decision carries the order
/// number and date and is frozen by the rules.
class WarningsRepository {
  WarningsRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _lists => _db.collection(Col.warningLists);

  Stream<List<WarningList>> watchStage(String stageId) =>
      _lists.where('stageId', isEqualTo: stageId).snapshots().map((snap) {
        final list = [for (final d in snap.docs) WarningList.fromMap(d.id, d.data())];
        return list..sort((a, b) => (b.createdAt ?? DateTime(9999)).compareTo(a.createdAt ?? DateTime(9999)));
      });

  static List<WarningListEntry> entriesOf(Iterable<Standing> standings) => [
        for (final s in standings)
          WarningListEntry(
            studentId: s.student.id,
            studentName: s.student.fullName,
            courseId: s.course.id,
            courseName: s.course.name,
            type: s.type,
            percent: double.parse(s.summary.percent.toStringAsFixed(2)),
            absences: s.summary.absences,
            planned: s.summary.planned,
            section: s.student.section,
          ),
      ];

  /// Saves a department decision for [level] (optionally one course).
  Future<String> saveDepartment({
    required String stageId,
    required WarningLevel level,
    required String? courseId,
    required Iterable<Standing> standings,
    required String actor,
  }) async {
    final ref = _lists.doc();
    final list = WarningList(
      id: ref.id,
      stageId: stageId,
      courseId: courseId,
      level: level,
      decision: DecisionType.department,
      entries: entriesOf(standings),
      createdBy: actor,
    );
    final batch = _db.batch()
      ..set(ref, {...list.toMap(), 'createdAt': FieldValue.serverTimestamp(), 'updatedAt': FieldValue.serverTimestamp()})
      ..set(_db.collection(Col.auditLog).doc(), _audit(actor, 'warnings.create', list, after: {'count': list.entries.length}));
    await batch.commit();
    return ref.id;
  }

  /// Re-generates a department decision from today's standings.
  Future<void> regenerate(WarningList list, Iterable<Standing> standings, {required String actor}) {
    final entries = entriesOf(standings);
    final batch = _db.batch()
      ..update(_lists.doc(list.id), {
        'entries': [for (final e in entries) e.toMap()],
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': actor,
      })
      ..set(_db.collection(Col.auditLog).doc(), _audit(actor, 'warnings.regenerate', list,
          before: {'count': list.entries.length}, after: {'count': entries.length}));
    return batch.commit();
  }

  /// Turns a department decision into the final deanery decision (admins).
  Future<void> finalize(WarningList list, {required String orderNumber, required DateTime orderDate, required String actor}) {
    final batch = _db.batch()
      ..update(_lists.doc(list.id), {
        'decision': DecisionType.deanery.name,
        'orderNumber': orderNumber.trim(),
        'orderDate': Timestamp.fromDate(orderDate),
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': actor,
      })
      ..set(_db.collection(Col.auditLog).doc(), _audit(actor, 'warnings.finalize', list,
          after: {'orderNumber': orderNumber.trim(), 'orderDate': orderDate.toIso8601String()}));
    return batch.commit();
  }

  Future<void> delete(WarningList list, {required String actor}) {
    final batch = _db.batch()
      ..delete(_lists.doc(list.id))
      ..set(_db.collection(Col.auditLog).doc(), _audit(actor, 'warnings.delete', list, before: {'count': list.entries.length}));
    return batch.commit();
  }

  Map<String, Object?> _audit(String actor, String action, WarningList list,
          {Map<String, Object?>? before, Map<String, Object?>? after}) =>
      {
        ...AuditEntry(
          actor: actor,
          action: action,
          targetPath: '${Col.warningLists}/${list.id}',
          stageId: list.stageId,
          before: before,
          after: {...?after, 'level': list.level.name, 'courseId': list.courseId},
        ).toMap(),
        'at': FieldValue.serverTimestamp(),
      };
}
