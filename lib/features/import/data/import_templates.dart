import 'dart:typed_data';

import 'package:excel/excel.dart';

import '../domain/import_columns.dart';
import '../domain/import_models.dart';

/// Builds the downloadable `.xlsx` templates (SPEC: «بقالب جاهز يُنزَّل من
/// التطبيق»): a right-to-left data sheet with the expected headers and an
/// example row, plus an instructions sheet listing accepted values.
abstract final class ImportTemplates {
  static String sheetName(ImportKind kind) => switch (kind) {
        ImportKind.students => 'الطلبة',
        ImportKind.teachers => 'التدريسيون',
        ImportKind.courses => 'المواد',
      };

  static String fileName(ImportKind kind) => 'uob_${kind.name}_template.xlsx';

  static List<String> headers(ImportKind kind) =>
      [for (final c in ImportColumns.of(kind)) c.templateHeader];

  static List<List<String>> exampleRows(ImportKind kind) => switch (kind) {
        ImportKind.students => const [
            ['علي حسين جاسم محمد', '2026001', 'الأولى', 'صباحي', 'أ', 'مستمر', 'لا'],
            ['زينب كاظم عبد الله علي', '2026002', 'الأولى', 'صباحي', 'ب', 'منقول إلى القسم', 'لا'],
          ],
        ImportKind.teachers => const [
            ['محمد عبد الكريم سلمان', 'مدرس دكتور', 'mohammed.salman@uobasrah.edu.iq', '07701234567'],
          ],
        ImportKind.courses => const [
            ['CS101', 'أساسيات البرمجة', 'الأولى', 'كلاهما', '1', '3', 'نعم'],
            ['CS305', 'نظرية الاحتسابية', 'الثالثة', 'صباحي', '2', '2', 'لا'],
          ],
      };

  static List<List<String>> instructions(ImportKind kind) {
    final common = [
      ['لا تغيّر عناوين الأعمدة في الصف الأول. يمكن حذف صفوف المثال.'],
      ['الخلايا المعلَّمة بـ * إلزامية.'],
    ];
    final specific = switch (kind) {
      ImportKind.students => [
          ['* الاسم الرباعي', 'اسم الطالب الرباعي.'],
          ['* الرقم الجامعي', 'فريد لكل طالب، ويُستعمل لكشف المكرر و«تحديث الموجود».'],
          ['المرحلة', 'الأولى | الثانية | الثالثة | الرابعة (أو 1–4). تُترك فارغة لاستعمال المرحلة المختارة في التطبيق.'],
          ['الدراسة', 'صباحي | مسائي.'],
          ['الشعبة', 'أ، ب… أو فارغة إن لم تكن المرحلة مقسّمة.'],
          ['الحالة', 'مستمر | مؤجل | راسب بالغياب | منسحب | منقول إلى القسم (الافتراضي: مستمر).'],
          ['محمّل', 'نعم | لا — الطالب المحمَّل لا يظهر في قوائم الحضور.'],
        ],
      ImportKind.teachers => [
          ['* الاسم', 'اسم التدريسي.'],
          ['اللقب العلمي', 'مثل: مدرس مساعد، مدرس، أستاذ مساعد، أستاذ.'],
          ['* البريد الجامعي', 'يُستعمل لتفعيل الحساب وتسجيل الدخول، ولكشف المكرر.'],
          ['الهاتف', 'رقم الهاتف (اختياري).'],
        ],
      ImportKind.courses => [
          ['* رمز المادة', 'مثل CS101.'],
          ['* اسم المادة', ''],
          ['* المرحلة', 'الأولى | الثانية | الثالثة | الرابعة (أو 1–4).'],
          ['الدراسة', 'صباحي | مسائي | كلاهما (الفارغ يعني كلاهما).'],
          ['الفصل', '1 | 2 (الأول أو الثاني).'],
          ['* الوحدات', 'عدد صحيح موجب؛ يحدد وزن الغياب في النسبة.'],
          ['فيها عملي', 'نعم | لا.'],
        ],
    };
    return [...common, [], ...specific];
  }

  static Uint8List build(ImportKind kind) {
    final book = Excel.createExcel();
    final defaultName = book.getDefaultSheet()!;
    final dataName = sheetName(kind);

    final data = book[dataName];
    final headerStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#D9E2F3'),
      horizontalAlign: HorizontalAlign.Center,
    );
    final columns = ImportColumns.of(kind);
    for (var c = 0; c < columns.length; c++) {
      data.updateCell(
        CellIndex.indexByColumnRow(columnIndex: c, rowIndex: 0),
        TextCellValue(columns[c].templateHeader),
        cellStyle: headerStyle,
      );
      data.setColumnWidth(c, c == 0 || (kind == ImportKind.teachers && c == 2) ? 34 : 18);
    }
    final examples = exampleRows(kind);
    for (var r = 0; r < examples.length; r++) {
      for (var c = 0; c < examples[r].length; c++) {
        data.updateCell(
          CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r + 1),
          TextCellValue(examples[r][c]),
        );
      }
    }

    final help = book['تعليمات'];
    help.setColumnWidth(0, 24);
    help.setColumnWidth(1, 90);
    final lines = instructions(kind);
    for (var r = 0; r < lines.length; r++) {
      for (var c = 0; c < lines[r].length; c++) {
        help.updateCell(
          CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r),
          TextCellValue(lines[r][c]),
          cellStyle: c == 0 ? CellStyle(bold: true) : null,
        );
      }
    }

    book.setDefaultSheet(dataName);
    if (defaultName != dataName) book.delete(defaultName);
    return _withRtlSheets(book.encode()!);
  }

  /// package:excel only writes `rightToLeft` for sheets that already exist in
  /// the workbook XML, and sheets created in memory get their XML during the
  /// same save. A second pass over the decoded workbook sets it reliably.
  static Uint8List _withRtlSheets(List<int> bytes) {
    final book = Excel.decodeBytes(bytes);
    for (final sheet in book.tables.values) {
      sheet.isRTL = true;
    }
    return Uint8List.fromList(book.encode()!);
  }
}
