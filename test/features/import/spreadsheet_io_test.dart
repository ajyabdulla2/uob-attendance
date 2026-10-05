import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uob_attendance/features/import/data/import_templates.dart';
import 'package:uob_attendance/features/import/data/spreadsheet_reader.dart';
import 'package:uob_attendance/features/import/domain/import_models.dart';
import 'package:uob_attendance/features/import/domain/import_parsers.dart';

Uint8List utf8Bytes(String s, {bool bom = false}) =>
    Uint8List.fromList([if (bom) ...[0xEF, 0xBB, 0xBF], ...utf8.encode(s)]);

void main() {
  group('templates', () {
    for (final kind in ImportKind.values) {
      test('$kind template reads back with its headers and valid example rows', () {
        final bytes = ImportTemplates.build(kind);
        final table = SpreadsheetReader.read(bytes, ImportTemplates.fileName(kind));
        expect(table.headers, ImportTemplates.headers(kind));
        expect(table.rows, ImportTemplates.exampleRows(kind));

        final preview = switch (kind) {
          ImportKind.students => parseStudents(table, existing: const {}),
          ImportKind.teachers => parseTeachers(table, existing: const {}),
          ImportKind.courses => parseCourses(table, existing: const {}),
        };
        expect(preview.fileIssues, isEmpty);
        expect(preview.rows.every((r) => r.action == RowAction.create), isTrue,
            reason: preview.rows.map((r) => r.issues).toString());
      });
    }

    test('data sheet is right-to-left, default, and instructions are separate', () {
      final book = Excel.decodeBytes(ImportTemplates.build(ImportKind.students));
      expect(book.getDefaultSheet(), 'الطلبة');
      expect(book.tables.keys, containsAll(['الطلبة', 'تعليمات']));
      expect(book.tables['الطلبة']!.isRTL, isTrue);
    });
  });

  group('xlsx reading', () {
    test('converts numeric cells to plain text and skips leading blank rows', () {
      final book = Excel.createExcel();
      final sheet = book[book.getDefaultSheet()!];
      sheet.appendRow([null]);
      sheet.appendRow([TextCellValue('الاسم الرباعي'), TextCellValue('الرقم الجامعي'), TextCellValue('الوحدات')]);
      sheet.appendRow([TextCellValue(' علي '), IntCellValue(2026001), DoubleCellValue(3.0)]);
      sheet.appendRow([TextCellValue('x'), DoubleCellValue(12.5), BoolCellValue(true)]);
      final table = SpreadsheetReader.read(Uint8List.fromList(book.encode()!), 'f.XLSX');
      expect(table.headers, ['الاسم الرباعي', 'الرقم الجامعي', 'الوحدات']);
      expect(table.rows[0], ['علي', '2026001', '3']);
      expect(table.rows[1], ['x', '12.5', 'true']);
    });

    // test/fixtures/openpyxl_teachers.xlsx: written by Python openpyxl 3.1.5
    // (fake data) — absolute part names and empty inline-string cells, which
    // package:excel cannot read on its own.
    test('reads workbooks written by openpyxl (AI agents, Python scripts)', () {
      final bytes = File('test/fixtures/openpyxl_teachers.xlsx').readAsBytesSync();
      expect(() => Excel.decodeBytes(bytes), throwsA(anything), reason: 'package:excel alone still fails');

      final table = SpreadsheetReader.read(bytes, 'openpyxl_teachers.xlsx');
      expect(table.headers, ['الاسم', 'اللقب العلمي', 'البريد الجامعي', 'الهاتف']);
      expect(table.rows, [
        ['تدريسي تجريبي أول', 'مدرس', 'first.teacher@example.edu', ''],
        ['تدريسي تجريبي ثان', '', 'second.teacher@example.edu', '07701234567'],
      ]);
      expect(parseTeachers(table, existing: const {}).rows.map((r) => r.action), everyElement(RowAction.create));
    });

    test('leaves ordinary workbooks byte-for-byte untouched', () {
      final bytes = ImportTemplates.build(ImportKind.courses);
      expect(identical(SpreadsheetReader.repairForPackageExcel(bytes), bytes), isTrue);
    });

    test('corrupt files are reported, not thrown raw', () {
      expect(
        () => SpreadsheetReader.read(Uint8List.fromList([1, 2, 3, 4]), 'bad.xlsx'),
        throwsA(isA<SpreadsheetException>().having((e) => e.problem, 'problem', FileProblem.corrupt)),
      );
    });
  });

  group('csv reading', () {
    test('handles BOM, quotes, CRLF and pads short rows', () {
      final table = SpreadsheetReader.read(
        utf8Bytes('الاسم الرباعي,الرقم الجامعي,الشعبة\r\n"حسن, علي",101\r\nزيد,102,ب\r\n\r\n', bom: true),
        'students.csv',
      );
      expect(table.headers, ['الاسم الرباعي', 'الرقم الجامعي', 'الشعبة']);
      expect(table.rows, [
        ['حسن, علي', '101', ''],
        ['زيد', '102', 'ب'],
      ]);
    });

    test('detects semicolon separators', () {
      final table = SpreadsheetReader.read(utf8Bytes('a;b\n1;2\n'), 'x.csv');
      expect(table.headers, ['a', 'b']);
      expect(table.rows.single, ['1', '2']);
    });

    test('rejects non-UTF-8 CSV (e.g. Windows-1256) with a clear problem code', () {
      // "علي" in Windows-1256.
      final bytes = Uint8List.fromList([0xDA, 0xE1, 0xED, 0x2C, 0x31, 0x0A]);
      expect(
        () => SpreadsheetReader.read(bytes, 'x.csv'),
        throwsA(isA<SpreadsheetException>().having((e) => e.problem, 'problem', FileProblem.notUtf8Csv)),
      );
    });
  });

  test('legacy .xls, unknown formats and empty files', () {
    Matcher problem(FileProblem p) => throwsA(isA<SpreadsheetException>().having((e) => e.problem, 'problem', p));
    expect(() => SpreadsheetReader.read(Uint8List.fromList([1]), 'a.xls'), problem(FileProblem.legacyXls));
    expect(() => SpreadsheetReader.read(Uint8List.fromList([1]), 'a.pdf'), problem(FileProblem.unsupportedFormat));
    expect(() => SpreadsheetReader.read(Uint8List(0), 'a.csv'), problem(FileProblem.empty));
    expect(() => SpreadsheetReader.read(utf8Bytes('\n\n'), 'a.csv'), problem(FileProblem.empty));
  });
}
