import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/firebase/server_time.dart';

/// JSON for queued writes. Plain values pass through; the two Firestore
/// specials are tagged so they survive the trip through SQLite:
///   [serverTime]          ⇄ `{"$": "serverTime"}` → FieldValue.serverTimestamp()
///   DateTime / Timestamp  ⇄ `{"$": "ts", "v": "<ISO-8601 UTC>"}` → Timestamp
abstract final class OutboxCodec {
  static const _tag = r'$';

  static String encode(Map<String, Object?> data) => jsonEncode(toJsonSafe(data));

  /// [data] with the Firestore specials tagged (ready for `jsonEncode`).
  static Map<String, Object?> toJsonSafe(Map<String, Object?> data) =>
      (_encode(data) as Map).cast<String, Object?>();

  /// Decoded for Firestore (FieldValue / Timestamp restored).
  static Map<String, Object?> decode(String json) =>
      (_decode(jsonDecode(json)) as Map).cast<String, Object?>();

  static Object? _encode(Object? v) => switch (v) {
        null || String() || num() || bool() => v,
        ServerTime() => {_tag: 'serverTime'},
        DateTime() => {_tag: 'ts', 'v': v.toUtc().toIso8601String()},
        Timestamp() => {_tag: 'ts', 'v': v.toDate().toUtc().toIso8601String()},
        Map() => {for (final e in v.entries) '${e.key}': _encode(e.value)},
        Iterable() => [for (final x in v) _encode(x)],
        _ => throw ArgumentError.value(v, 'value', 'Unsupported in queued writes'),
      };

  static Object? _decode(Object? v) {
    if (v is List) return [for (final x in v) _decode(x)];
    if (v is! Map) return v;
    switch (v[_tag]) {
      case 'serverTime':
        return FieldValue.serverTimestamp();
      case 'ts':
        return Timestamp.fromDate(DateTime.parse(v['v'] as String));
    }
    return {for (final e in v.entries) '${e.key}': _decode(e.value)};
  }
}
