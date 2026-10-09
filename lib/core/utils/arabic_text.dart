/// Arabic text helpers used for duplicate detection and stable ordering.
abstract final class ArabicText {
  static final _diacritics = RegExp('[ؐ-ًؚ-ٰٟۖ-ۭ]');
  static final _tatweel = RegExp('ـ');
  static final _spaces = RegExp(r'\s+');
  static final _abdSpace = RegExp(r'(^|\s)عبد\s+');

  /// Converts Arabic-Indic (٠-٩) and Persian (۰-۹) digits to ASCII digits.
  static String normalizeDigits(String input) {
    final buffer = StringBuffer();
    for (final rune in input.runes) {
      if (rune >= 0x0660 && rune <= 0x0669) {
        buffer.writeCharCode(0x30 + rune - 0x0660);
      } else if (rune >= 0x06F0 && rune <= 0x06F9) {
        buffer.writeCharCode(0x30 + rune - 0x06F0);
      } else {
        buffer.writeCharCode(rune);
      }
    }
    return buffer.toString();
  }

  /// Trims and collapses internal whitespace (incl. non-breaking spaces).
  static String collapseSpaces(String input) =>
      input.replaceAll(' ', ' ').replaceAll(_spaces, ' ').trim();

  /// Canonical form for comparing names: removes diacritics and tatweel,
  /// unifies alef/hamza forms, ta marbuta, alef maqsura, joins «عبد ال…»
  /// and lower-cases Latin letters. Two names that differ only by spelling
  /// variants common in Iraqi registers compare equal.
  static String normalizeForCompare(String input) {
    var s = collapseSpaces(normalizeDigits(input))
        .replaceAll(_diacritics, '')
        .replaceAll(_tatweel, '')
        .replaceAll(RegExp('[أإآٱ]'), 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي')
        .replaceAll('ؤ', 'و')
        .replaceAll('ئ', 'ي')
        .toLowerCase();
    s = s.replaceAllMapped(_abdSpace, (m) => '${m[1]}عبد');
    return s;
  }

  /// Number of words in a (collapsed) name.
  static int wordCount(String input) {
    final s = collapseSpaces(input);
    return s.isEmpty ? 0 : s.split(' ').length;
  }

  /// Key that orders students alphabetically by their normalized name, with
  /// [tiebreaker] (the university ID) keeping the order stable. A student
  /// transferred in mid-year therefore lands in their alphabetical place
  /// (SPEC: «sortKey يضمن ظهور المنقول بالتسلسل»).
  static String sortKey(String name, String tiebreaker) =>
      '${normalizeForCompare(name)}|$tiebreaker';
}
