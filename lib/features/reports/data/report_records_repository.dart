import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/config/app_config.dart';
import '../../../core/firebase/collections.dart';
import '../domain/report.dart';
import '../domain/report_record.dart';

class ReportRecordsRepository {
  ReportRecordsRepository(this._fs, {this.wait = const Duration(seconds: 10)});

  final FirebaseFirestore _fs;

  /// How long to wait for the server before printing anyway: offline, the
  /// phone keeps the write and sends it when it reconnects, so the QR starts
  /// working then.
  final Duration wait;

  /// Firestore's limit per batch.
  static const _maxWrites = 500;

  /// Saves one verification record per report and returns them stamped
  /// with their QR (same order).
  Future<List<Report>> issue(
    List<Report> reports, {
    required String issuedBy,
    required String issuerName,
    String site = AppConfig.siteUrl,
  }) async {
    final ids = [for (final _ in reports) ReportRecord.newId()];
    for (var i = 0; i < reports.length; i += _maxWrites) {
      final batch = _fs.batch();
      for (var k = i; k < reports.length && k < i + _maxWrites; k++) {
        batch.set(_fs.collection(Col.reportVerifications).doc(ids[k]), {
          ...ReportRecord.toMap(
            reports[k],
            issuedBy: issuedBy,
            issuerName: issuerName,
            departmentId: AppConfig.departmentId,
          ),
          'issuedAt': FieldValue.serverTimestamp(),
        });
      }
      try {
        await batch.commit().timeout(wait);
      } on TimeoutException {
        // Queued locally (see [wait]).
      }
    }
    return [for (var k = 0; k < reports.length; k++) reports[k].stamped(ReportRecord.stampFor(site, ids[k]))];
  }
}
