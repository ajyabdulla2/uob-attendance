import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';

import '../domain/import_models.dart';

/// Reads `.xlsx` and `.csv` files into a [SheetTable] of strings.
///
/// Pure Dart (no Flutter import): `package:excel` exports names that clash
/// with Flutter's (`TextSpan`, `Border`).
abstract final class SpreadsheetReader {
  /// Sheet names that hold template instructions rather than data.
  static const _instructionSheets = {'تعليمات', 'instructions', 'readme'};

  static SheetTable read(Uint8List bytes, String fileName) {
    final name = fileName.toLowerCase();
    if (bytes.isEmpty) throw const SpreadsheetException(FileProblem.empty);
    if (name.endsWith('.xlsx')) return readXlsx(bytes);
    if (name.endsWith('.csv')) return readCsv(bytes);
    if (name.endsWith('.xls')) throw const SpreadsheetException(FileProblem.legacyXls);
    throw SpreadsheetException(FileProblem.unsupportedFormat, fileName);
  }

  // ------------------------------------------------------------------ xlsx --
  static SheetTable readXlsx(Uint8List bytes) {
    final Excel book;
    try {
      book = Excel.decodeBytes(repairForPackageExcel(bytes));
    } catch (e) {
      throw SpreadsheetException(FileProblem.corrupt, '$e');
    }

    // Prefer the workbook's default sheet; else the first non-empty data sheet.
    final defaultName = book.getDefaultSheet();
    final candidates = [
      if (defaultName != null && book.tables[defaultName] != null) defaultName,
      ...book.tables.keys.where((k) => k != defaultName),
    ].where((k) => !_instructionSheets.contains(k.trim().toLowerCase()));

    for (final sheetName in candidates) {
      final rows = [
        for (final row in book.tables[sheetName]!.rows) [for (final cell in row) cellToString(cell?.value)],
      ];
      final table = _toTable(rows);
      if (table != null) return table;
    }
    throw const SpreadsheetException(FileProblem.empty);
  }

  static const _workbookRels = 'xl/_rels/workbook.xml.rels';
  static final _absoluteTarget = RegExp('Target=(["\'])/xl/');
  static final _emptyInlineString = RegExp('(<c\\b[^>]*\\bt=(["\'])inlineStr\\2[^>]*?)(?:/>|></c>)');

  /// Repairs valid workbooks that package:excel cannot read. Files written by
  /// Python's openpyxl (common with AI agents):
  ///  * name their parts with absolute paths
  ///    (`Target="/xl/worksheets/sheet1.xml"`), but package:excel prefixes
  ///    `xl/` to every target and then cannot find the sheet;
  ///  * write empty text cells as `<c t="inlineStr"></c>`, but package:excel
  ///    expects a `<t>` element in every inline string.
  /// Other workbooks are returned untouched.
  static Uint8List repairForPackageExcel(Uint8List bytes) {
    final Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(bytes);
    } catch (_) {
      return bytes; // Let package:excel report the damage.
    }
    var changed = false;
    final out = Archive();
    for (final file in archive.files) {
      final isRels = file.name == _workbookRels;
      final isSheet = file.name.startsWith('xl/worksheets/') && file.name.endsWith('.xml');
      if (!file.isFile || !(isRels || isSheet)) {
        out.addFile(file);
        continue;
      }
      final xml = utf8.decode(file.content as List<int>);
      final fixed = isRels
          ? xml.replaceAllMapped(_absoluteTarget, (m) => 'Target=${m[1]}')
          : xml.replaceAllMapped(_emptyInlineString, (m) => '${m[1]}><is><t></t></is></c>');
      if (fixed == xml) {
        out.addFile(file);
      } else {
        changed = true;
        final encoded = utf8.encode(fixed);
        out.addFile(ArchiveFile(file.name, encoded.length, encoded));
      }
    }
    return changed ? Uint8List.fromList(ZipEncoder().encode(out)!) : bytes;
  }

  /// Converts any cell value to the string a person would see.
  static String cellToString(CellValue? value) => switch (value) {
        null => '',
        TextCellValue v => v.value.toString(),
        IntCellValue v => '${v.value}',
        DoubleCellValue v => v.value == v.value.roundToDouble() && v.value.abs() < 1e15
            ? '${v.value.toInt()}'
            : '${v.value}',
        BoolCellValue v => v.value ? 'true' : 'false',
        DateCellValue v =>
          '${v.year.toString().padLeft(4, '0')}-${v.month.toString().padLeft(2, '0')}-${v.day.toString().padLeft(2, '0')}',
        DateTimeCellValue v => v.asDateTimeLocal().toIso8601String(),
        TimeCellValue v => v.toString(),
        FormulaCellValue v => v.formula,
      }
          .trim();

  // ------------------------------------------------------------------- csv --
  static SheetTable readCsv(Uint8List bytes) {
    var data = bytes;
    // Strip a UTF-8 BOM (Excel's «CSV UTF-8» adds one).
    if (data.length >= 3 && data[0] == 0xEF && data[1] == 0xBB && data[2] == 0xBF) {
      data = Uint8List.sublistView(data, 3);
    }
    final String text;
    try {
      text = utf8.decode(data);
    } on FormatException {
      // Typically Windows-1256 from «CSV (Comma delimited)» on Arabic Windows.
      throw const SpreadsheetException(FileProblem.notUtf8Csv);
    }
    final List<List<dynamic>> decoded;
    try {
      decoded = Csv(dynamicTyping: false).decode(text);
    } catch (e) {
      throw SpreadsheetException(FileProblem.corrupt, '$e');
    }
    final table = _toTable([
      for (final row in decoded) [for (final cell in row) '${cell ?? ''}'.trim()],
    ]);
    if (table == null) throw const SpreadsheetException(FileProblem.empty);
    return table;
  }

  /// First non-empty row is the header; trailing empty rows/columns dropped.
  static SheetTable? _toTable(List<List<String>> rows) {
    final start = rows.indexWhere((r) => r.any((c) => c.isNotEmpty));
    if (start < 0) return null;
    var headers = rows[start];
    var width = headers.length;
    while (width > 0 && headers[width - 1].isEmpty) {
      width--;
    }
    headers = headers.sublist(0, width);
    final body = rows.sublist(start + 1);
    var end = body.length;
    while (end > 0 && body[end - 1].every((c) => c.isEmpty)) {
      end--;
    }
    return SheetTable(headers: headers, rows: body.sublist(0, end));
  }
}
