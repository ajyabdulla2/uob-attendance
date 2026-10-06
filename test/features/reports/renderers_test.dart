import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uob_attendance/features/reports/data/excel_renderer.dart';
import 'package:uob_attendance/features/reports/data/pdf_renderer.dart';
import 'package:uob_attendance/features/reports/domain/report.dart';

final branding = ReportBranding(
  university: 'جامعة البصرة',
  college: 'كلية التربية للعلوم الصرفة',
  department: 'قسم علوم الحاسوب',
  yearLine: 'السنة الدراسية 2026-2027 — الفصل 1',
  printedLine: 'طُبع في 6/10/2026',
  pageLabel: (p, n) => 'صفحة $p من $n',
  signatureHint: 'الاسم والتوقيع',
);

final sample = Report(
  title: 'سجل حضور مادة هياكل البيانات',
  fileBase: 'سجل هياكل البيانات 3-morning',
  meta: const ['المرحلة الثالثة — صباحي · نظري · كل الشعب', 'المحاضرات: 3'],
  tables: [
    ReportTable(
      name: 'السجل',
      columns: const [
        ReportColumn('ت', flex: 0.5, numeric: true),
        ReportColumn('الاسم', flex: 4),
        ReportColumn('1/10', numeric: true),
        ReportColumn('النسبة', numeric: true),
      ],
      rows: [
        for (var i = 1; i <= 60; i++)
          [
            ReportCell('$i'),
            ReportCell('طالب رقم $i علي حسين CS101'),
            ReportCell(i.isEven ? 'ح' : 'غ', tone: i.isEven ? ReportTone.present : ReportTone.absent),
            ReportCell('${(i % 20) * 1.5}', tone: i % 20 > 9 ? ReportTone.warning : ReportTone.normal),
          ],
      ],
    ),
  ],
  notes: const ['ح = حاضر، غ = غائب'],
  signatures: const ['التدريسي', 'مسؤول المرحلة', 'رئيس القسم'],
);

void main() {
  test('PDF: Arabic text, many pages, header on each page', () async {
    final renderer = PdfRenderer(
      regularFont: File('assets/fonts/cairo/Cairo-Regular.ttf').readAsBytesSync(),
      boldFont: File('assets/fonts/cairo/Cairo-Bold.ttf').readAsBytesSync(),
      logo: File('assets/images/dept_logo.png').readAsBytesSync(),
    );
    final bytes = await renderer.render(sample, branding);
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    expect(bytes.length, greaterThan(20000));
    final out = Platform.environment['REPORT_PREVIEW'];
    if (out != null) File(out).writeAsBytesSync(bytes);
  });

  test('Excel: RTL sheet, header row, numbers as numbers', () {
    final bytes = ExcelRenderer().render(sample, branding);
    final book = Excel.decodeBytes(bytes);
    final sheet = book.tables['السجل']!;
    expect(sheet.isRTL, isTrue);
    expect(book.tables.keys, ['السجل']);
    final rows = sheet.rows;
    final headerRow = rows.indexWhere((r) => r.isNotEmpty && r.first?.value.toString() == 'ت');
    expect(headerRow, greaterThan(0));
    expect(rows[headerRow + 1][0]!.value, isA<IntCellValue>());
    expect(rows[headerRow + 1][1]!.value.toString(), 'طالب رقم 1 علي حسين CS101');
    expect(rows[headerRow + 1][3]!.value, isA<DoubleCellValue>()); // 1.5
    expect(sample.fileName('pdf'), 'سجل_هياكل_البيانات_3-morning.pdf');
  });

  test('sheet names are cut to 31 characters and kept unique', () {
    final long = 'اسم طويل جداً لورقة في ملف إكسل يتجاوز الحد';
    final r = Report(title: 't', fileBase: 'f', tables: [
      ReportTable(name: long, columns: const [ReportColumn('a')], rows: const []),
      ReportTable(name: long, columns: const [ReportColumn('a')], rows: const []),
    ]);
    final names = Excel.decodeBytes(ExcelRenderer().render(r, branding)).tables.keys.toList();
    expect(names, hasLength(2));
    expect(names.every((n) => n.length <= 31), isTrue);
    expect(names.toSet(), hasLength(2));
  });
}
