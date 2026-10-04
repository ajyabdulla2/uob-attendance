import '../utils/arabic_text.dart';

/// Deterministic document IDs. Security rules recompute some of these
/// (assignments, sessions, stats) — keep both sides in sync with
/// `firestore.rules`.
abstract final class DocIds {
  static const _sep = '__';

  /// Theory "target" covering every section of a stage.
  static const allSections = 'all';

  /// User docs are keyed by the lower-cased e-mail address.
  static String user(String email) => email.trim().toLowerCase();

  /// Student docs are keyed by the normalized university ID.
  static String student(String universityId) => normalizeUniversityId(universityId);

  /// `CS301_3-morning` — a course is per stage (level + shift).
  static String course(String code, String stageId) =>
      '${normalizeCourseCode(code)}_$stageId';

  /// `CS301_3-morning__A`
  static String group(String courseId, String groupName) =>
      '$courseId$_sep${groupName.trim()}';

  /// `{courseId}__{type}__{target}__{teacherEmail}`
  static String assignment({
    required String courseId,
    required String type,
    required String target,
    required String teacherId,
  }) =>
      [courseId, type, target, user(teacherId)].join(_sep);

  /// Session key from the SPEC: `مادة_نوع_مجموعة_تاريخ_رقم-المحاضرة`, so two
  /// devices recording the same lecture write the same document.
  static String session({
    required String courseId,
    required String type,
    required String target,
    required DateTime date,
    required int lectureNo,
  }) =>
      [courseId, type, target, dateKey(date), '$lectureNo'].join(_sep);

  /// `{courseId}__{studentId}`
  static String stat(String courseId, String studentId) => '$courseId$_sep$studentId';

  /// `yyyyMMdd` of the calendar date (time-of-day ignored).
  static String dateKey(DateTime date) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${date.year.toString().padLeft(4, '0')}${two(date.month)}${two(date.day)}';
  }

  /// Digits only (Arabic-Indic digits converted); keeps other characters but
  /// strips whitespace and replaces `/` which Firestore IDs cannot contain.
  static String normalizeUniversityId(String raw) {
    var s = ArabicText.normalizeDigits(raw).replaceAll(RegExp(r'\s+'), '');
    // Excel numbers often arrive as "2023001.0".
    s = s.replaceFirst(RegExp(r'\.0+$'), '');
    return s.replaceAll('/', '-');
  }

  /// Upper-case, no spaces, `/` replaced (e.g. "cs 301" → "CS301").
  static String normalizeCourseCode(String raw) => ArabicText.normalizeDigits(raw)
      .replaceAll(RegExp(r'\s+'), '')
      .replaceAll('/', '-')
      .toUpperCase();
}
