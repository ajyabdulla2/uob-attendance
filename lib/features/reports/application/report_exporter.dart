import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/common_widgets.dart';
import '../../../l10n/l10n.dart';
import '../../academic/domain/academic_year.dart';
import '../data/excel_renderer.dart';
import '../data/pdf_renderer.dart';
import '../domain/report.dart';

enum ReportFormat { pdf, excel }

/// Fonts and logo for PDFs, loaded once from the app bundle (fonts in the
/// bundle are Flutter's; the PDF embeds its own copy).
final pdfRendererProvider = FutureProvider<PdfRenderer>((ref) async {
  Future<Uint8List> load(String path) async => (await rootBundle.load(path)).buffer.asUint8List();
  return PdfRenderer(
    regularFont: await load('assets/fonts/cairo/Cairo-Regular.ttf'),
    boldFont: await load('assets/fonts/cairo/Cairo-Bold.ttf'),
    logo: await load(deptLogoAsset),
  );
});

ReportBranding brandingFor(AppLocalizations l10n, MaterialLocalizations m, AcademicYear? year, DateTime now) =>
    ReportBranding(
      university: l10n.universityName,
      college: l10n.collegeName,
      department: l10n.departmentName,
      yearLine: year == null ? '' : l10n.homeActiveYear(year.id, '${year.semester}'),
      printedLine: l10n.reportPrinted(m.formatShortDate(now)),
      pageLabel: (p, n) => l10n.reportPage(p, n),
      signatureHint: l10n.reportSignatureHint,
    );

/// Saves several PDF reports as one file (one per page group).
Future<void> exportPdfBatch(
  BuildContext context,
  WidgetRef ref, {
  required List<Report> reports,
  required String fileName,
  required AcademicYear? year,
}) async {
  if (reports.isEmpty) return;
  final l10n = context.l10n;
  final m = MaterialLocalizations.of(context);
  try {
    final renderer = await ref.read(pdfRendererProvider.future);
    final bytes = await renderer.renderAll(reports, brandingFor(l10n, m, year, DateTime.now()));
    final saved = await FilePicker.saveFile(
      fileName: fileName,
      bytes: bytes,
      mimeType: 'application/pdf',
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
    );
    if (saved != null && context.mounted) showSnack(context, l10n.reportSaved);
  } on Object catch (e) {
    if (context.mounted) showSnack(context, l10n.errorGeneric('$e'));
  }
}

/// Asks PDF or Excel, renders [build]'s report and lets the user save it
/// (Android: the system «save as» dialog; web: a download).
Future<void> exportReport(
  BuildContext context,
  WidgetRef ref, {
  required Report Function(ReportFormat format) build,
  required AcademicYear? year,
  Set<ReportFormat> formats = const {ReportFormat.pdf, ReportFormat.excel},
}) async {
  final l10n = context.l10n;
  final m = MaterialLocalizations.of(context);
  final format = formats.length == 1
      ? formats.first
      : await showModalBottomSheet<ReportFormat>(
          context: context,
          showDragHandle: true,
          builder: (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  key: const Key('export.pdf'),
                  leading: const Icon(Icons.picture_as_pdf),
                  title: Text(l10n.reportPdf),
                  subtitle: Text(l10n.reportPdfHelp),
                  onTap: () => Navigator.pop(context, ReportFormat.pdf),
                ),
                ListTile(
                  key: const Key('export.excel'),
                  leading: const Icon(Icons.table_view),
                  title: Text(l10n.reportExcel),
                  subtitle: Text(l10n.reportExcelHelp),
                  onTap: () => Navigator.pop(context, ReportFormat.excel),
                ),
              ],
            ),
          ),
        );
  if (format == null || !context.mounted) return;
  try {
    final report = build(format);
    final branding = brandingFor(l10n, m, year, DateTime.now());
    final Uint8List bytes;
    final String mime;
    final String ext;
    switch (format) {
      case ReportFormat.pdf:
        bytes = await (await ref.read(pdfRendererProvider.future)).render(report, branding);
        mime = 'application/pdf';
        ext = 'pdf';
      case ReportFormat.excel:
        bytes = ExcelRenderer().render(report, branding);
        mime = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
        ext = 'xlsx';
    }
    final saved = await FilePicker.saveFile(
      fileName: report.fileName(ext),
      bytes: bytes,
      mimeType: mime,
      type: FileType.custom,
      allowedExtensions: [ext],
    );
    if (saved != null && context.mounted) showSnack(context, l10n.reportSaved);
  } on Object catch (e) {
    if (context.mounted) showSnack(context, l10n.errorGeneric('$e'));
  }
}
