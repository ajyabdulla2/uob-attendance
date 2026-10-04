import '../../../core/config/app_config.dart';
import '../../../core/domain/stage_ref.dart';
import '../../../core/firebase/doc_ids.dart';
import '../../../core/firebase/firestore_converters.dart';
import '../../../core/utils/arabic_text.dart';

/// مستمر، مؤجل، راسب بالغياب، منسحب، منقول إلى القسم.
enum StudentStatus { continuing, postponed, failedByAbsence, withdrawn, transferredIn }

/// `students/{universityId}`.
final class Student {
  Student({
    required String universityId,
    required String fullName,
    required this.stage,
    this.section = '',
    this.status = StudentStatus.continuing,
    this.carryOver = false,
    this.departmentId = AppConfig.departmentId,
  })  : universityId = DocIds.normalizeUniversityId(universityId),
        fullName = ArabicText.collapseSpaces(fullName);

  final String universityId;

  /// الاسم الرباعي.
  final String fullName;
  final StageRef stage;

  /// الشعبة (empty when the stage has no sections).
  final String section;
  final StudentStatus status;

  /// طالب محمَّل: attends exams only — excluded from attendance lists and
  /// percentages (SPEC «الطلبة المحمَّلون»).
  final bool carryOver;
  final String departmentId;

  String get id => DocIds.student(universityId);
  String get stageId => stage.id;
  String get sortKey => ArabicText.sortKey(fullName, universityId);

  /// Appears in attendance lists and counts toward percentages.
  bool get attendsLectures =>
      !carryOver &&
      (status == StudentStatus.continuing || status == StudentStatus.transferredIn);

  factory Student.fromMap(String id, Map<String, Object?> map) => Student(
        universityId: Fs.str(map['universityId'], id),
        fullName: Fs.str(map['fullName']),
        stage: StageRef.tryParse(Fs.str(map['stageId'])) ?? const StageRef(1, Shift.morning),
        section: Fs.str(map['section']),
        status: Fs.enumByName(StudentStatus.values, map['status'], StudentStatus.continuing),
        carryOver: Fs.boolean(map['carryOver']),
        departmentId: Fs.str(map['departmentId'], AppConfig.departmentId),
      );

  Map<String, Object?> toMap() => {
        'universityId': universityId,
        'fullName': fullName,
        'stageId': stageId,
        'level': stage.level,
        'shift': stage.shift.name,
        'section': section,
        'status': status.name,
        'carryOver': carryOver,
        'sortKey': sortKey,
        'departmentId': departmentId,
      };

  /// Orders by [sortKey] (alphabetical, transferred students in place).
  static int compare(Student a, Student b) => a.sortKey.compareTo(b.sortKey);
}
