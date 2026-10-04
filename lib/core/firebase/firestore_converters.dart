import 'package:cloud_firestore/cloud_firestore.dart';

/// Lenient readers for Firestore maps (tolerate missing / legacy values).
abstract final class Fs {
  static String str(Object? v, [String fallback = '']) => v is String ? v : fallback;

  static String? strOrNull(Object? v) => v is String && v.isNotEmpty ? v : null;

  static int integer(Object? v, [int fallback = 0]) =>
      v is int ? v : (v is num ? v.toInt() : fallback);

  static double dbl(Object? v, [double fallback = 0]) => v is num ? v.toDouble() : fallback;

  static bool boolean(Object? v, [bool fallback = false]) => v is bool ? v : fallback;

  static List<String> strings(Object? v) =>
      v is Iterable ? v.whereType<String>().toList(growable: false) : const [];

  static Map<String, Object?> map(Object? v) =>
      v is Map ? v.map((k, val) => MapEntry('$k', val)) : const {};

  static DateTime? date(Object? v) => switch (v) {
        Timestamp t => t.toDate(),
        DateTime d => d,
        String s => DateTime.tryParse(s),
        _ => null,
      };

  static Timestamp? timestamp(DateTime? d) => d == null ? null : Timestamp.fromDate(d);

  static T enumByName<T extends Enum>(List<T> values, Object? v, T fallback) {
    if (v is! String) return fallback;
    for (final e in values) {
      if (e.name == v) return e;
    }
    return fallback;
  }
}
