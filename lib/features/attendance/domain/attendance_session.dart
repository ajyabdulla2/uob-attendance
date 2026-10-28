import '../../../core/config/app_config.dart';
import '../../../core/firebase/doc_ids.dart';
import '../../../core/firebase/firestore_converters.dart';
import '../../assignments/domain/assignment.dart';

/// حاضر، غائب، متأخر، مُجاز. «متأخر» is documentary only and never affects
/// the percentage (SPEC §4).
enum AttendanceStatus { present, absent, late, excused }

/// `sessions/{id}` — created only when a teacher opens a lecture, so
/// cancelled lectures and holidays never count against anyone.
final class AttendanceSession {
  AttendanceSession({
    required this.courseId,
    required this.stageId,
    required this.yearId,
    required this.type,
    required this.target,
    required DateTime date,
    required this.lectureNo,
    required this.openedBy,
    required this.lockAt,
    this.groupId,
    this.locked = false,
    this.excluded = false,
    this.counts = const {},
    this.deviceCreatedAt,
    this.updatedAt,
    this.departmentId = AppConfig.departmentId,
  }) : date = DateTime.utc(date.year, date.month, date.day);

  final String courseId;
  final String stageId;
  final String yearId;
  final AssignmentType type;
  final String target;
  final String? groupId;

  /// Calendar date of the lecture (UTC midnight of that date).
  final DateTime date;

  /// 1 for the first lecture of the day for this class, 2 for the second…
  final int lectureNo;
  final String openedBy;
  final bool locked;

  /// «لا تُحتسب هذه المحاضرة» (طلب القسم: e.g. the students did not come):
  /// the records stay as marked, but nobody's absence in it counts — every
  /// student's `stats.bySession` entry for it is [excludedValue].
  final bool excluded;

  /// The `stats.bySession` value of an excluded lecture. Readers drop it
  /// (and app versions that predate it read it as «حاضر»).
  static const excludedValue = 'excluded';

  /// After this instant teachers can no longer edit (rules enforce it).
  final DateTime lockAt;
  final Map<AttendanceStatus, int> counts;

  /// Device clock at creation — kept beside the server time (SPEC «وقت الهاتف
  /// قد يكون خاطئاً»).
  final DateTime? deviceCreatedAt;
  final DateTime? updatedAt;
  final String departmentId;

  String get id => DocIds.session(
        courseId: courseId,
        type: type.name,
        target: target,
        date: date,
        lectureNo: lectureNo,
      );

  String get dateKey => DocIds.dateKey(date);

  /// Lock deadline rule shared with firestore.rules:
  /// end of the lecture day + [lockHours].
  static DateTime lockAtFor(DateTime date, int lockHours) =>
      DateTime.utc(date.year, date.month, date.day).add(Duration(hours: 24 + lockHours));

  bool isLockedAt(DateTime now) => locked || now.isAfter(lockAt);

  factory AttendanceSession.fromMap(String id, Map<String, Object?> map) {
    final countsMap = Fs.map(map['counts']);
    return AttendanceSession(
      courseId: Fs.str(map['courseId']),
      stageId: Fs.str(map['stageId']),
      yearId: Fs.str(map['yearId']),
      type: Fs.enumByName(AssignmentType.values, map['type'], AssignmentType.theory),
      target: Fs.str(map['target'], DocIds.allSections),
      groupId: Fs.strOrNull(map['groupId']),
      date: Fs.date(map['date']) ?? DateTime.utc(1970),
      lectureNo: Fs.integer(map['lectureNo'], 1),
      openedBy: Fs.str(map['openedBy']),
      locked: Fs.boolean(map['locked']),
      excluded: Fs.boolean(map['excluded']),
      lockAt: Fs.date(map['lockAt']) ?? DateTime.utc(1970),
      counts: {
        for (final s in AttendanceStatus.values)
          if (countsMap[s.name] is num) s: (countsMap[s.name] as num).toInt(),
      },
      deviceCreatedAt: Fs.date(map['deviceCreatedAt']),
      updatedAt: Fs.date(map['updatedAt']),
      departmentId: Fs.str(map['departmentId'], AppConfig.departmentId),
    );
  }

  /// [updatedAt] is written by the repository as a server timestamp.
  Map<String, Object?> toMap() => {
        'courseId': courseId,
        'stageId': stageId,
        'yearId': yearId,
        'type': type.name,
        'target': target,
        'groupId': groupId,
        'dateKey': dateKey,
        'date': Fs.timestamp(date),
        'lectureNo': lectureNo,
        'openedBy': openedBy,
        'updatedBy': openedBy,
        'locked': locked,
        if (excluded) 'excluded': true,
        'lockAt': Fs.timestamp(lockAt),
        'counts': {for (final e in counts.entries) e.key.name: e.value},
        'deviceCreatedAt': Fs.timestamp(deviceCreatedAt),
        'departmentId': departmentId,
      };
}

/// `sessions/{id}/records/{studentId}` — one per student.
final class AttendanceRecord {
  const AttendanceRecord({
    required this.studentId,
    required this.status,
    required this.updatedBy,
    this.note = '',
    this.updatedAt,
    this.deviceUpdatedAt,
  });

  final String studentId;
  final AttendanceStatus status;
  final String note;
  final String updatedBy;

  /// Server time (conflict resolution: the latest write wins).
  final DateTime? updatedAt;
  final DateTime? deviceUpdatedAt;

  factory AttendanceRecord.fromMap(String id, Map<String, Object?> map) => AttendanceRecord(
        studentId: Fs.str(map['studentId'], id),
        status: Fs.enumByName(AttendanceStatus.values, map['status'], AttendanceStatus.present),
        note: Fs.str(map['note']),
        updatedBy: Fs.str(map['updatedBy']),
        updatedAt: Fs.date(map['updatedAt']),
        deviceUpdatedAt: Fs.date(map['deviceUpdatedAt']),
      );

  Map<String, Object?> toMap() => {
        'studentId': studentId,
        'status': status.name,
        'note': note,
        'updatedBy': updatedBy,
        'deviceUpdatedAt': Fs.timestamp(deviceUpdatedAt),
      };
}
