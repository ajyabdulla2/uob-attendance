import 'dart:io';
import 'dart:math';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uob_attendance/features/reports/data/pdf_renderer.dart';
import 'package:uob_attendance/features/reports/data/report_records_repository.dart';
import 'package:uob_attendance/features/reports/domain/report.dart';
import 'package:uob_attendance/features/reports/domain/report_record.dart';

import 'renderers_test.dart' show branding, sample;

void main() {
  group('ReportRecord', () {
    test('IDs: 24 characters from the unambiguous alphabet (what the rules accept)', () {
      final rules = RegExp(r'^[A-HJKMNP-TV-Z2-9]{24}$');
      final r = Random(7);
      final ids = {for (var i = 0; i < 500; i++) ReportRecord.newId(r)};
      expect(ids, hasLength(500));
      expect(ids.every(rules.hasMatch), isTrue);
      expect(rules.hasMatch(ReportRecord.alphabet.substring(0, 24)), isTrue);
      expect(rules.hasMatch(ReportRecord.alphabet.substring(6)), isTrue, reason: 'every letter passes the rules');
      expect(ReportRecord.alphabet.length, 30);
    });

    test('printed code and link', () {
      const id = 'K7QM2XRT9HBWPZ4NCV8DJEAF';
      expect(ReportRecord.codeOf(id), 'K7QM-2XRT-9HBW-PZ4N-CV8D-JEAF');
      final stamp = ReportRecord.stampFor('https://x.web.app', id);
      expect(stamp.url, 'https://x.web.app/verify.html#$id');
      expect(stamp.code, 'K7QM-2XRT-9HBW-PZ4N-CV8D-JEAF');
    });

    test('snapshot keeps the printed text; rows become maps (no arrays of arrays)', () {
      final m = ReportRecord.toMap(sample, issuedBy: 't1@uob.test', issuerName: 'م. أحمد', departmentId: 'cs');
      expect(m['title'], sample.title);
      expect(m['meta'], sample.meta);
      expect(m['signatures'], sample.signatures);
      final table = (m['tables']! as List).single as Map;
      expect(table['columns'], ['ت', 'الاسم', '1/10', 'النسبة']);
      final rows = table['rows'] as List;
      expect(rows, hasLength(60));
      expect((rows.first as Map)['c'], ['1', 'طالب رقم 1 علي حسين CS101', 'غ', '1.5']);
      expect(m.containsKey('issuedAt'), isFalse, reason: 'server time is added on write');
    });
  });

  test('issue: one record per report, stamped in order', () async {
    final fs = FakeFirebaseFirestore();
    final repo = ReportRecordsRepository(fs);
    final second = Report(title: 'كتاب إنذار', fileBase: 'w', tables: const []);
    final out = await repo.issue([sample, second], issuedBy: 't1@uob.test', issuerName: 'م. أحمد', site: 'https://x.web.app');
    expect(out.map((r) => r.title), [sample.title, 'كتاب إنذار']);
    final snap = await fs.collection('reportVerifications').get();
    expect(snap.docs, hasLength(2));
    for (final r in out) {
      final id = r.stamp!.url.split('#').last;
      final doc = await fs.collection('reportVerifications').doc(id).get();
      expect(doc.data()!['title'], r.title);
      expect(doc.data()!['issuedBy'], 't1@uob.test');
      expect(doc.data()!['issuedAt'], isNotNull);
      expect(r.stamp!.code, ReportRecord.codeOf(id));
    }
  });

  test('PDF with a stamp: QR on every page, and a QR poster', () async {
    final renderer = PdfRenderer(
      regularFont: File('assets/fonts/cairo/Cairo-Regular.ttf').readAsBytesSync(),
      boldFont: File('assets/fonts/cairo/Cairo-Bold.ttf').readAsBytesSync(),
      logo: File('assets/images/dept_logo.png').readAsBytesSync(),
    );
    final b = ReportBranding(
      university: branding.university,
      college: branding.college,
      department: branding.department,
      yearLine: branding.yearLine,
      printedLine: branding.printedLine,
      pageLabel: branding.pageLabel,
      signatureHint: branding.signatureHint,
      verifyHint: 'امسح الرمز للتحقق',
    );
    final plain = await renderer.render(sample, b);
    final stamped = await renderer.render(
      sample.stamped(ReportRecord.stampFor('https://x.web.app', 'K7QM2XRT9HBWPZ4NCV8DJEAF')),
      b,
    );
    expect(String.fromCharCodes(stamped.take(5)), '%PDF-');
    expect(stamped.length, greaterThan(plain.length), reason: 'the QR adds drawing to every page');
    final out = Platform.environment['REPORT_PREVIEW'];
    if (out != null) File(out.replaceFirst('.pdf', '_qr.pdf')).writeAsBytesSync(stamped);

    final poster = await renderer.renderPoster(
      title: 'إعلانات القسم',
      lines: const ['امسح الرمز'],
      url: 'https://x.web.app/announcements.html',
      branding: b,
    );
    expect(String.fromCharCodes(poster.take(5)), '%PDF-');
    if (out != null) File(out.replaceFirst('.pdf', '_poster.pdf')).writeAsBytesSync(poster);
  });
}
