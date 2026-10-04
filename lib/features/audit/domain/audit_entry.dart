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
