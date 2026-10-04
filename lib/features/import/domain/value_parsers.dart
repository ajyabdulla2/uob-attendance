import '../../../core/domain/stage_ref.dart';
import '../../../core/utils/arabic_text.dart';
import '../../students/domain/student.dart';

/// Lenient parsers for the free-text values people type in spreadsheets.
/// All return null for unrecognized input.
abstract final class ValueParsers {
  static String _n(String raw) => ArabicText.normalizeForCompare(raw);

  /// "3", "٣", "الثالثة", "المرحلة الثالثة", "third" → 3.
  static int? level(String raw) {
    final s = _n(raw);
    if (s.isEmpty) return null;
    final digits = RegExp(r'^\D*([1-4])(\.0+)?\D*$').firstMatch(s);
    if (digits != null) return int.parse(digits[1]!);
    const words = {
      1: ['اول', 'first'],
      2: ['ثاني', 'second'],
      3: ['ثالث', 'third'],
      4: ['رابع', 'fourth'],
    };
    for (final entry in words.entries) {
      if (entry.value.any(s.contains)) return entry.key;
    }
    return null;
  }

  /// "صباحي" / "مسائي" (and variants).
  static Shift? shift(String raw) {
    final s = _n(raw);
    if (s.isEmpty) return null;
    if (s.contains('صباح') || s == 'ص' || s.startsWith('morning') || s == 'am') return Shift.morning;
    if (s.contains('مسا') || s == 'م' || s.startsWith('evening') || s == 'pm') return Shift.evening;
    return null;
  }

  /// For courses: "كلاهما" / "صباحي ومسائي" → both shifts.
  static List<Shift>? shifts(String raw) {
    final s = _n(raw);
    if (s.isEmpty) return null;
    final both = s.contains('كلا') ||
        s.contains('الاثنين') ||
        s.contains('both') ||
        (s.contains('صباح') && s.contains('مسا'));
    if (both) return Shift.values;
    final one = shift(raw);
    return one == null ? null : [one];
  }

  /// Empty → continuing (default for new students).
  static StudentStatus? status(String raw) {
    final s = _n(raw);
    if (s.isEmpty) return StudentStatus.continuing;
    if (s.contains('مستمر') || s == 'continuing' || s == 'active') return StudentStatus.continuing;
    if (s.contains('مؤجل') || s.contains('موجل') || s == 'postponed') return StudentStatus.postponed;
    if (s.contains('راسب') || s.contains('failed')) return StudentStatus.failedByAbsence;
    if (s.contains('منسحب') || s.contains('withdrawn')) return StudentStatus.withdrawn;
    if (s.contains('منقول') || s.contains('transfer')) return StudentStatus.transferredIn;
    return null;
  }

  /// نعم/لا, yes/no, true/false, 1/0, ✓/✗. Empty → [fallback].
  static bool? yesNo(String raw, {bool? fallback = false}) {
    final s = _n(raw);
    if (s.isEmpty) return fallback;
    const yes = {'نعم', 'ن', 'اي', 'yes', 'y', 'true', '1', '✓', '✔', 'x', 'محمل', 'يوجد', 'عملي'};
    const no = {'لا', 'كلا', 'no', 'n', 'false', '0', '✗', '-', 'لايوجد', 'لا يوجد'};
    if (yes.contains(s)) return true;
    if (no.contains(s)) return false;
    return null;
  }

  /// 1/2, "الأول"/"الثاني", "first"/"second". Empty → [fallback].
  static int? semester(String raw, {int? fallback}) {
    final s = _n(raw);
    if (s.isEmpty) return fallback;
    final digits = RegExp(r'^\D*([12])(\.0+)?\D*$').firstMatch(s);
    if (digits != null) return int.parse(digits[1]!);
    if (s.contains('اول') || s.contains('first')) return 1;
    if (s.contains('ثاني') || s.contains('second')) return 2;
    return null;
  }

  /// Positive whole number of units ("3", "3.0", "٣").
  static int? units(String raw) {
    final s = ArabicText.normalizeDigits(raw).trim();
    final value = double.tryParse(s);
    if (value == null || value <= 0 || value != value.roundToDouble() || value > 30) return null;
    return value.toInt();
  }

  static final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  /// Lower-cased address, or null when malformed.
  static String? email(String raw) {
    final s = raw.trim().toLowerCase();
    return _email.hasMatch(s) ? s : null;
  }

  /// Keeps digits and a leading "+"; Arabic-Indic digits converted.
  static String phone(String raw) {
    final s = ArabicText.normalizeDigits(raw).trim();
    final plus = s.startsWith('+') ? '+' : '';
    var digits = s.replaceAll(RegExp(r'\D'), '');
    // Excel often strips the leading zero of Iraqi mobiles (7xx…).
    if (plus.isEmpty && digits.length == 10 && digits.startsWith('7')) digits = '0$digits';
    return '$plus$digits';
  }
}
