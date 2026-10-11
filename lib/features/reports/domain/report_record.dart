import 'dart:math';

import 'report.dart';

/// `reportVerifications/{id}`: a frozen copy of an issued PDF, read by the
/// public verification page (`web/verify.html`) when someone scans the QR on
/// the paper.
///
/// The ID is the only secret: random, long enough that it cannot be guessed,
/// and the rules allow reading one record by ID but never listing them. So
/// whoever holds the paper sees what is already printed on it, nothing more.
abstract final class ReportRecord {
  /// No 0/O, 1/I/L or U: easy to read back from paper and type by hand
  /// (the page upper-cases what is typed).
  static const alphabet = 'ABCDEFGHJKMNPQRSTVWXYZ23456789';

  /// 30^24 ≈ 2^117.
  static const idLength = 24;

  static String newId([Random? random]) {
    final r = random ?? Random.secure();
    return String.fromCharCodes([
      for (var i = 0; i < idLength; i++) alphabet.codeUnitAt(r.nextInt(alphabet.length)),
    ]);
  }

  /// The ID in groups of four, as printed under the QR.
  static String codeOf(String id) => [
        for (var i = 0; i < id.length; i += 4) id.substring(i, min(i + 4, id.length)),
      ].join('-');

  /// The fragment keeps the ID out of the hosting server's request logs.
  static String urlFor(String site, String id) => '$site/verify.html#$id';

  static ReportStamp stampFor(String site, String id) => ReportStamp(url: urlFor(site, id), code: codeOf(id));

  /// The record's fields, without `issuedAt` (server time, added on write).
  /// Firestore has no arrays of arrays, so each row is `{c: [cells]}`.
  static Map<String, Object?> toMap(
    Report report, {
    required String issuedBy,
    required String issuerName,
    required String departmentId,
  }) =>
      {
        'title': report.title,
        'meta': report.meta,
        'paragraphs': report.paragraphs,
        'tables': [
          for (final t in report.tables)
            {
              'heading': t.heading ?? '',
              'columns': [for (final c in t.columns) c.title],
              'rows': [
                for (final row in t.rows) {'c': [for (final cell in row) cell.text]},
              ],
            },
        ],
        'notes': report.notes,
        'signatures': report.signatures,
        'issuedBy': issuedBy,
        'issuerName': issuerName,
        'departmentId': departmentId,
      };
}
