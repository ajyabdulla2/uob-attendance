import '../../../core/config/app_config.dart';
import '../../../core/firebase/firestore_converters.dart';

/// `auditLog/{id}` — append-only («من عدّل ماذا»). `at` is a server timestamp
/// set by the repository.
final class AuditEntry {
  const AuditEntry({
    required this.actor,
    required this.action,
    required this.targetPath,
    this.stageId,
    this.before,
    this.after,
    this.at,
    this.departmentId = AppConfig.departmentId,
  });

  final String actor;

  /// e.g. `record.update`, `students.import`, `assignment.create`.
  final String action;
  final String targetPath;
  final String? stageId;
  final Map<String, Object?>? before;
  final Map<String, Object?>? after;
  final DateTime? at;
  final String departmentId;

  factory AuditEntry.fromMap(Map<String, Object?> map) => AuditEntry(
        actor: Fs.str(map['actor']),
        action: Fs.str(map['action']),
        targetPath: Fs.str(map['targetPath']),
        stageId: Fs.strOrNull(map['stageId']),
        before: map['before'] is Map ? Fs.map(map['before']) : null,
        after: map['after'] is Map ? Fs.map(map['after']) : null,
        at: Fs.date(map['at']),
        departmentId: Fs.str(map['departmentId'], AppConfig.departmentId),
      );

  Map<String, Object?> toMap() => {
        'actor': actor,
        'action': action,
        'targetPath': targetPath,
        'stageId': stageId,
        'before': before,
        'after': after,
        'departmentId': departmentId,
      };
}

/// «بحث» in the audit log for what the server cannot filter: a student's
/// university ID (or any text) in the target path or the before/after values.
abstract final class AuditFilter {
  static bool matches(AuditEntry e, String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    bool inValue(Object? v) => switch (v) {
          Map m => m.entries.any((x) => '${x.key}'.toLowerCase().contains(q) || inValue(x.value)),
          List l => l.any(inValue),
          null => false,
          _ => '$v'.toLowerCase().contains(q),
        };
    return e.targetPath.toLowerCase().contains(q) || e.actor.toLowerCase().contains(q) || inValue(e.before) || inValue(e.after);
  }
}
