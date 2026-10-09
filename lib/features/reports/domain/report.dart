/// A printable / exportable report, independent of the output format
/// (PDF for printing and signing, Excel for further work). Builders in
/// `reports/domain/*_report.dart` turn domain data into one of these.
library;

enum ReportOrientation { portrait, landscape }

/// Colour hint for a cell; renderers map it to the app's status palette.
enum ReportTone { normal, present, absent, late, excused, alert, warning, dismissal, muted }

final class ReportColumn {
  const ReportColumn(this.title, {this.flex = 1, this.numeric = false});

  final String title;

  /// Relative width in the PDF.
  final double flex;

  /// Centred in the PDF, written as a number in Excel when it parses.
  final bool numeric;
}

final class ReportCell {
  const ReportCell(this.text, {this.tone = ReportTone.normal, this.bold = false});

  final String text;
  final ReportTone tone;
  final bool bold;
}

/// One table: a PDF section (with its own heading) and an Excel sheet.
final class ReportTable {
  const ReportTable({required this.name, required this.columns, required this.rows, this.heading});

  /// Sheet name (≤ 31 characters in Excel).
  final String name;

  /// Shown above the table in the PDF (null = no heading).
  final String? heading;
  final List<ReportColumn> columns;
  final List<List<ReportCell>> rows;
}

/// Department identity printed at the top of every PDF page.
final class ReportBranding {
  const ReportBranding({
    required this.university,
    required this.college,
    required this.department,
    required this.yearLine,
    required this.printedLine,
    required this.pageLabel,
    required this.signatureHint,
  });

  final String university;
  final String college;
  final String department;

  /// e.g. «السنة الدراسية 2026-2027 — الفصل 1».
  final String yearLine;

  /// e.g. «طُبع في 6/10/2026».
  final String printedLine;

  /// Builds «صفحة 1 من 3».
  final String Function(int page, int pages) pageLabel;

  /// Under each signature line, e.g. «الاسم والتوقيع».
  final String signatureHint;
}

final class Report {
  const Report({
    required this.title,
    required this.fileBase,
    required this.tables,
    this.meta = const [],
    this.paragraphs = const [],
    this.notes = const [],
    this.signatures = const [],
    this.orientation = ReportOrientation.portrait,
  });

  final String title;

  /// File name without extension (ASCII-safe characters are kept).
  final String fileBase;

  /// Lines under the title: course, stage, class, period…
  final List<String> meta;

  /// Running text before the tables (a letter's body).
  final List<String> paragraphs;
  final List<ReportTable> tables;

  /// Legend / footnotes after the tables.
  final List<String> notes;

  /// Signature boxes at the end (e.g. التدريسي، مسؤول المرحلة، رئيس القسم).
  final List<String> signatures;
  final ReportOrientation orientation;

  /// A file-system-safe name: Arabic letters are fine, separators are not.
  String fileName(String extension) {
    final safe = fileBase.replaceAll(RegExp(r'[\\/:*?"<>|\s]+'), '_');
    return '$safe.$extension';
  }
}
