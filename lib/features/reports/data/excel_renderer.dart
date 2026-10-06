import 'dart:typed_data';

import 'package:excel/excel.dart';

import '../domain/report.dart';

/// Renders a [Report] as an .xlsx workbook: one right-to-left sheet per
/// table, title and meta lines on top, bold header row, tones as fills, and
/// numeric columns written as numbers so they can be summed and sorted.
class ExcelRenderer {
  static ExcelColor? _fill(ReportTone tone) => switch (tone) {
        ReportTone.normal || ReportTone.present => null,
        ReportTone.absent => ExcelColor.fromHexString('#FADBD8'),
        ReportTone.late => ExcelColor.fromHexString('#FDEBD0'),
        ReportTone.excused => ExcelColor.fromHexString('#D6EAF8'),
        ReportTone.alert => ExcelColor.fromHexString('#FFF59D'),
        ReportTone.warning => ExcelColor.fromHexString('#FFCC80'),
        ReportTone.dismissal => ExcelColor.fromHexString('#EF9A9A'),
        ReportTone.muted => ExcelColor.fromHexString('#F2F2F2'),
      };

  Uint8List render(Report report, ReportBranding branding) {
    final book = Excel.createExcel();
    final defaultName = book.getDefaultSheet()!;
    final used = <String>{};
    String sheetName(String name) {
      var base = name.replaceAll(RegExp(r'[\\/?*\[\]:]'), ' ').trim();
      if (base.isEmpty) base = 'Sheet';
      if (base.length > 31) base = base.substring(0, 31);
      var candidate = base;
      for (var i = 2; used.contains(candidate); i++) {
        final suffix = ' ($i)';
        candidate = '${base.substring(0, base.length.clamp(0, 31 - suffix.length))}$suffix';
      }
      used.add(candidate);
      return candidate;
    }

    final headerStyle = CellStyle(bold: true, backgroundColorHex: ExcelColor.fromHexString('#EFE6CC'));
    for (final table in report.tables) {
      final sheet = book[sheetName(table.name)];
      var r = 0;
      void line(String text, {bool bold = false}) {
        sheet.updateCell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: r++), TextCellValue(text),
            cellStyle: bold ? CellStyle(bold: true, fontSize: 13) : null);
      }

      line('${branding.university} — ${branding.college} — ${branding.department}');
      line(branding.yearLine);
      line(report.title, bold: true);
      for (final m in report.meta) {
        line(m);
      }
      if (table.heading != null) line(table.heading!, bold: true);
      r++;
      for (var c = 0; c < table.columns.length; c++) {
        sheet.updateCell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r), TextCellValue(table.columns[c].title),
            cellStyle: headerStyle);
        sheet.setColumnWidth(c, (table.columns[c].flex * 10).clamp(6, 60).toDouble());
      }
      r++;
      for (final row in table.rows) {
        for (var c = 0; c < row.length && c < table.columns.length; c++) {
          final cell = row[c];
          final number = table.columns[c].numeric ? num.tryParse(cell.text.replaceAll('%', '').trim()) : null;
          final fill = _fill(cell.tone);
          sheet.updateCell(
            CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r),
            number == null
                ? TextCellValue(cell.text)
                : (number is int ? IntCellValue(number) : DoubleCellValue(number.toDouble())),
            cellStyle: fill == null && !cell.bold ? null : CellStyle(bold: cell.bold, backgroundColorHex: fill ?? ExcelColor.none),
          );
        }
        r++;
      }
      r++;
      for (final n in report.notes) {
        line(n);
      }
    }
    if (!used.contains(defaultName)) book.delete(defaultName);
    book.setDefaultSheet(book.tables.keys.first);
    return _withRtlSheets(book.encode()!);
  }

  /// See ImportTemplates: RTL only sticks on a second pass.
  static Uint8List _withRtlSheets(List<int> bytes) {
    final book = Excel.decodeBytes(bytes);
    for (final sheet in book.tables.values) {
      sheet.isRTL = true;
    }
    return Uint8List.fromList(book.encode()!);
  }
}
