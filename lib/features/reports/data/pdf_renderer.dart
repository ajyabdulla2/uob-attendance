import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../domain/report.dart';

/// Renders a [Report] as an A4 PDF: Arabic (RTL) with the bundled Cairo
/// font, the department header on every page, tables whose header row
/// repeats across pages, and signature boxes at the end.
///
/// Fonts and logo come in as bytes so this stays testable without Flutter's
/// asset bundle.
class PdfRenderer {
  PdfRenderer({required Uint8List regularFont, required Uint8List boldFont, this.logo})
      : _regular = pw.Font.ttf(ByteData.sublistView(regularFont)),
        _bold = pw.Font.ttf(ByteData.sublistView(boldFont));

  final pw.Font _regular;
  final pw.Font _bold;
  final Uint8List? logo;

  static const _ink = PdfColor.fromInt(0xFF1A1714);
  static const _line = PdfColor.fromInt(0xFF9E9E9E);
  static const _headerFill = PdfColor.fromInt(0xFFEFE6CC);

  static PdfColor? _fill(ReportTone tone) => switch (tone) {
        ReportTone.normal || ReportTone.present => null,
        ReportTone.absent => const PdfColor.fromInt(0xFFFADBD8),
        ReportTone.late => const PdfColor.fromInt(0xFFFDEBD0),
        ReportTone.excused => const PdfColor.fromInt(0xFFD6EAF8),
        ReportTone.alert => const PdfColor.fromInt(0xFFFFF59D),
        ReportTone.warning => const PdfColor.fromInt(0xFFFFCC80),
        ReportTone.dismissal => const PdfColor.fromInt(0xFFEF9A9A),
        ReportTone.muted => const PdfColor.fromInt(0xFFF2F2F2),
      };

  Future<Uint8List> render(Report report, ReportBranding branding) => renderAll([report], branding);

  /// Several reports in one file, each starting on a new page (a batch of
  /// warning letters).
  Future<Uint8List> renderAll(List<Report> reports, ReportBranding branding) async {
    final doc = pw.Document(
      title: reports.first.title,
      author: branding.department,
      theme: pw.ThemeData.withFont(base: _regular, bold: _bold),
    );
    for (final report in reports) {
      _addReport(doc, report, branding);
    }
    return doc.save();
  }

  void _addReport(pw.Document doc, Report report, ReportBranding branding) {
    final format = report.orientation == ReportOrientation.landscape ? PdfPageFormat.a4.landscape : PdfPageFormat.a4;
    doc.addPage(pw.MultiPage(
      pageFormat: format,
      margin: const pw.EdgeInsets.fromLTRB(28, 24, 28, 28),
      textDirection: pw.TextDirection.rtl,
      header: (context) => _header(branding, context),
      footer: (context) => pw.Container(
        alignment: pw.Alignment.center,
        margin: const pw.EdgeInsets.only(top: 6),
        child: pw.Text(branding.pageLabel(context.pageNumber, context.pagesCount),
            style: const pw.TextStyle(fontSize: 8, color: _line)),
      ),
      build: (context) => [
        pw.SizedBox(height: 6),
        pw.Center(
          child: pw.Text(report.title,
              textAlign: pw.TextAlign.center, style: pw.TextStyle(font: _bold, fontSize: 15, color: _ink)),
        ),
        for (final line in report.meta)
          pw.Center(child: pw.Text(line, textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 10))),
        pw.SizedBox(height: 10),
        for (final p in report.paragraphs)
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 8),
            child: pw.Text(p, textAlign: pw.TextAlign.justify, style: const pw.TextStyle(fontSize: 12, lineSpacing: 4)),
          ),
        for (final table in report.tables) ...[
          if (table.heading != null)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 6, bottom: 4),
              child: pw.Text(table.heading!, style: pw.TextStyle(font: _bold, fontSize: 11)),
            ),
          _table(table),
          pw.SizedBox(height: 10),
        ],
        for (final n in report.notes)
          pw.Text(n, style: const pw.TextStyle(fontSize: 8, color: _line)),
        if (report.signatures.isNotEmpty) ...[
          pw.SizedBox(height: 28),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              for (final s in report.signatures)
                pw.Column(children: [
                  pw.Text(s, style: pw.TextStyle(font: _bold, fontSize: 10)),
                  pw.SizedBox(height: 30),
                  pw.Container(width: 120, height: 0.6, color: _ink),
                  pw.SizedBox(height: 2),
                  pw.Text(branding.signatureHint, style: const pw.TextStyle(fontSize: 7, color: _line)),
                ]),
            ],
          ),
        ],
      ],
    ));
  }

  pw.Widget _header(ReportBranding b, pw.Context context) {
    final logoBytes = logo;
    return pw.Column(children: [
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          if (logoBytes != null) pw.Image(pw.MemoryImage(logoBytes), width: 52, height: 52),
          pw.SizedBox(width: 10),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(b.university, style: pw.TextStyle(font: _bold, fontSize: 11)),
                pw.Text(b.college, style: const pw.TextStyle(fontSize: 10)),
                pw.Text(b.department, style: const pw.TextStyle(fontSize: 10)),
              ],
            ),
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(b.yearLine, style: const pw.TextStyle(fontSize: 9)),
              pw.Text(b.printedLine, style: const pw.TextStyle(fontSize: 8, color: _line)),
            ],
          ),
        ],
      ),
      pw.SizedBox(height: 4),
      pw.Container(height: 1.2, color: const PdfColor.fromInt(0xFFB8860B)),
    ]);
  }

  /// pdf's Table lays columns out left-to-right; reversing them puts the
  /// first column on the right, as Arabic readers expect.
  pw.Widget _table(ReportTable t) {
    final cols = t.columns.reversed.toList();
    pw.Widget cell(String text,
            {bool header = false, ReportTone tone = ReportTone.normal, bool bold = false, bool numeric = false}) =>
        pw.Container(
          color: header ? _headerFill : _fill(tone),
          padding: const pw.EdgeInsets.symmetric(horizontal: 3, vertical: 3),
          alignment: numeric || header ? pw.Alignment.center : pw.Alignment.centerRight,
          child: pw.Text(
            text,
            textAlign: numeric || header ? pw.TextAlign.center : pw.TextAlign.right,
            style: pw.TextStyle(fontSize: 8.5, font: header || bold ? _bold : _regular),
          ),
        );
    return pw.Table(
      border: pw.TableBorder.all(color: _line, width: 0.5),
      columnWidths: {for (var i = 0; i < cols.length; i++) i: pw.FlexColumnWidth(cols[i].flex)},
      defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
      children: [
        pw.TableRow(repeat: true, children: [for (final c in cols) cell(c.title, header: true)]),
        for (final row in t.rows)
          pw.TableRow(children: [
            for (var k = t.columns.length - 1; k >= 0; k--)
              cell(
                k < row.length ? row[k].text : '',
                tone: k < row.length ? row[k].tone : ReportTone.normal,
                bold: k < row.length && row[k].bold,
                numeric: t.columns[k].numeric,
              ),
          ]),
      ],
    );
  }
}
