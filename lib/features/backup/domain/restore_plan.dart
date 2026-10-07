import '../../../core/firebase/collections.dart';
import '../../data_fix/domain/fix_plan.dart';
import 'backup_file.dart';

/// Collections a backup copies. editRequests, accessRequests and the audit
/// log are kept in the file as history but are not written back: the rules
/// only let their authors create them (pending request, own e-mail, own
/// audit entry).
abstract final class BackupScope {
  static const collections = [
    Col.academicYears,
    Col.stages,
    Col.users,
    Col.courses,
    Col.students,
    Col.groups,
    Col.assignments,
    Col.sessions,
    Col.leaves,
    Col.stats,
    Col.warningLists,
    Col.config,
    Col.editRequests,
    Col.accessRequests,
    Col.auditLog,
  ];

  static const notRestored = {Col.editRequests, Col.accessRequests, Col.auditLog};

  /// The rules check parents with get()/exists(), which only see committed
  /// data, so restore writes run in this order and never share a batch:
  /// courses before groups, groups and teachers before assignments, a
  /// session before its records.
  static const phases = [
    [Col.academicYears, Col.stages, Col.users, Col.courses, Col.students, Col.config],
    [Col.groups],
    [Col.assignments, Col.leaves, Col.stats, Col.warningLists],
    [Col.sessions],
  ];
}

/// The writes that put [data] back. Documents are overwritten (never merged)
/// so the restored state is the backup's; documents created after the
/// backup are left alone.
///
/// The rules pin a few fields to the writer, so these are rewritten:
/// a session's and record's `updatedAt` (server time — phones then
/// download them again), a record's `updatedBy` and an approved leave's
/// `approvedBy` (the restorer). The restorer's own account is skipped so a
/// restore cannot lock them out, and a deanery decision that already exists
/// is skipped because it is frozen ([skipPaths]).
List<List<List<FixWrite>>> restorePhases(
  BackupData data, {
  required String actor,
  required Object serverTime,
  Set<String> skipPaths = const {},
}) {
  FixWrite? write(String collection, String id, Map<String, Object?> doc) {
    final path = '$collection/$id';
    if (skipPaths.contains(path)) return null;
    if (collection == Col.users && id == actor) return null;
    final fields = {...doc};
    switch (collection) {
      case Col.sessions:
        fields['updatedAt'] = serverTime;
      case Col.leaves when fields['approvedBy'] != null:
        fields['approvedBy'] = actor;
    }
    return FixWrite.set(path, fields);
  }

  final phases = <List<List<FixWrite>>>[
    for (final names in BackupScope.phases)
      [
        for (final c in names)
          for (final e in (data.collections[c] ?? const <String, Map<String, Object?>>{}).entries)
            if (write(c, e.key, e.value) case final w?) [w],
      ],
  ];
  phases.add([
    for (final s in data.records.entries)
      for (final r in s.value.entries)
        [
          FixWrite.set('${Col.sessions}/${s.key}/${Col.records}/${r.key}', {
            ...r.value,
            'updatedBy': actor,
            'updatedAt': serverTime,
          }),
        ],
  ]);
  return [
    for (final p in phases)
      if (p.isNotEmpty) p,
  ];
}
