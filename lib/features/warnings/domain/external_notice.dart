import '../../../core/config/app_config.dart';
import '../../../core/firebase/doc_ids.dart';
import '../../../core/firebase/firestore_converters.dart';
import '../../attendance/domain/attendance_session.dart';
import '../../stats/domain/student_course_stat.dart';

/// `externalNotices/{id}` — «كتاب خارجي»: a تنبيه/إنذار/فصل issued to a
/// student outside the app (e.g. on paper before the app), entered so the
/// app counts it. The student stands at least at [level] in [courseIds]
/// from [date]; a new absence after it moves them to the next level.
final class ExternalNotice {
  const ExternalNotice({
    this.id = '',
    required this.studentId,
    required this.stageId,
    required this.courseIds,
    required this.level,
    required this.date,
    this.reference = '',
    this.note = '',
    this.createdBy = '',
    this.departmentId = AppConfig.departmentId,
  });

  final String id;
  final String studentId;
  final String stageId;
  final List<String> courseIds;

  /// alert / warning / dismissal (never none).
  final WarningLevel level;

  /// The letter's day (UTC midnight).
  final DateTime date;

  /// The letter's number, if any.
  final String reference;
  final String note;
  final String createdBy;
  final String departmentId;

  String get dateKey => DocIds.dateKey(date);

  factory ExternalNotice.fromMap(String id, Map<String, Object?> map) => ExternalNotice(
        id: id,
        studentId: Fs.str(map['studentId']),
        stageId: Fs.str(map['stageId']),
        courseIds: [for (final c in (map['courseIds'] as List?) ?? const []) '$c'],
        level: Fs.enumByName(WarningLevel.values, map['level'], WarningLevel.alert),
        date: Fs.date(map['date']) ?? DateTime.utc(2000),
        reference: Fs.str(map['reference']),
        note: Fs.str(map['note']),
        createdBy: Fs.str(map['createdBy']),
        departmentId: Fs.str(map['departmentId'], AppConfig.departmentId),
      );

  /// Without `createdAt` (the repository adds the server time).
  Map<String, Object?> toMap() => {
        'studentId': studentId,
        'stageId': stageId,
        'courseIds': courseIds,
        'level': level.name,
        'date': Fs.timestamp(date),
        'reference': reference.trim(),
        'note': note.trim(),
        'createdBy': createdBy,
        'departmentId': departmentId,
      };

  static WarningLevel next(WarningLevel l) => switch (l) {
        WarningLevel.none => WarningLevel.alert,
        WarningLevel.alert => WarningLevel.warning,
        WarningLevel.warning || WarningLevel.dismissal => WarningLevel.dismissal,
      };

  /// The level a student holds in one course (or course part [type]) by
  /// their letters: the highest letter covering it, one level up when they
  /// were absent after its date (absences on [excusedDays] do not count).
  /// Null when no letter covers it.
  static ({WarningLevel level, bool absentSince, ExternalNotice notice})? standing(
    Iterable<ExternalNotice> notices, {
    required String courseId,
    required Map<String, AttendanceStatus> bySession,
    Set<String> excusedDays = const {},
    String? type,
  }) {
    ExternalNotice? top;
    for (final n in notices) {
      if (!n.courseIds.contains(courseId)) continue;
      if (top == null || n.level.index > top.level.index || (n.level == top.level && n.date.isAfter(top.date))) top = n;
    }
    if (top == null) return null;
    final absentSince = bySession.entries.any((e) {
      if (e.value != AttendanceStatus.absent) return false;
      final parts = e.key.split('__');
      if (parts.length != 5) return false;
      if (type != null && parts[1] != type) return false;
      return parts[3].compareTo(top!.dateKey) > 0 && !excusedDays.contains(parts[3]);
    });
    return (level: absentSince ? next(top.level) : top.level, absentSince: absentSince, notice: top);
  }
}
