import '../../../core/utils/arabic_text.dart';
import 'import_models.dart';

/// One logical column of an import file and the header spellings accepted
/// for it (Arabic first — the first alias is the template header).
final class ImportColumn {
  const ImportColumn(this.key, this.aliases, {this.required = false});

  final String key;
  final List<String> aliases;
  final bool required;

  String get templateHeader => aliases.first;
}

abstract final class ImportColumns {
  // ---------------------------------------------------------------- students
  static const fullName = ImportColumn('fullName',
      ['الاسم الرباعي', 'الاسم', 'اسم الطالب', 'الاسم الكامل', 'name', 'full name', 'student name'],
      required: true);
  static const universityId = ImportColumn('universityId',
      ['الرقم الجامعي', 'رقم الطالب', 'الرقم', 'university id', 'student id', 'id'],
      required: true);
  static const level = ImportColumn('level', ['المرحلة', 'الصف', 'level', 'stage', 'year']);
  static const shift = ImportColumn('shift', ['الدراسة', 'نوع الدراسة', 'shift', 'study']);
  static const section = ImportColumn('section', ['الشعبة', 'section', 'class']);
  static const status = ImportColumn('status', ['الحالة', 'حالة الطالب', 'status']);
  static const carryOver =
      ImportColumn('carryOver', ['محمّل', 'محمل', 'طالب محمل', 'carry over', 'carryover']);

  // ---------------------------------------------------------------- teachers
  static const teacherName =
      ImportColumn('name', ['الاسم', 'اسم التدريسي', 'الاسم الكامل', 'name', 'full name'], required: true);
  static const title = ImportColumn('title', ['اللقب العلمي', 'اللقب', 'title', 'academic title']);
  static const email = ImportColumn('email',
      ['البريد الجامعي', 'البريد الالكتروني', 'البريد', 'الايميل', 'email', 'e-mail'],
      required: true);
  static const phone = ImportColumn('phone', ['الهاتف', 'رقم الهاتف', 'الموبايل', 'phone', 'mobile']);

  // ----------------------------------------------------------------- courses
  static const code = ImportColumn('code', ['رمز المادة', 'الرمز', 'code', 'course code'], required: true);
  static const courseName =
      ImportColumn('courseName', ['اسم المادة', 'المادة', 'name', 'course name', 'course'], required: true);
  static const courseLevel = ImportColumn('level', ['المرحلة', 'الصف', 'level', 'stage', 'year'], required: true);
  static const courseShift = ImportColumn('shift', ['الدراسة', 'نوع الدراسة', 'shift', 'study']);
  static const semester = ImportColumn('semester', ['الفصل', 'الكورس', 'الفصل الدراسي', 'semester', 'term']);
  static const units = ImportColumn('units', ['الوحدات', 'عدد الوحدات', 'units', 'credits'], required: true);
  static const hasPractical =
      ImportColumn('hasPractical', ['فيها عملي', 'عملي', 'يوجد عملي', 'practical', 'has practical']);

  static List<ImportColumn> of(ImportKind kind) => switch (kind) {
        ImportKind.students => const [fullName, universityId, level, shift, section, status, carryOver],
        ImportKind.teachers => const [teacherName, title, email, phone],
        ImportKind.courses => const [code, courseName, courseLevel, courseShift, semester, units, hasPractical],
      };

  static String normalizeHeader(String header) => ArabicText.normalizeForCompare(header)
      .replaceAll(RegExp(r'[\s_\-:*().#/\\]'), '');

  /// Maps column keys to their index in [headers]. Unrecognized headers are
  /// ignored; the first matching header wins.
  static Map<String, int> match(List<String> headers, List<ImportColumn> columns) {
    final normalized = [for (final h in headers) normalizeHeader(h)];
    final result = <String, int>{};
    for (final column in columns) {
      final aliases = {for (final a in column.aliases) normalizeHeader(a)};
      for (var i = 0; i < normalized.length; i++) {
        if (aliases.contains(normalized[i]) && !result.containsValue(i)) {
          result[column.key] = i;
          break;
        }
      }
    }
    return result;
  }
}
