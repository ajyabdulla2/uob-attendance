import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/common_widgets.dart';
import '../../../l10n/l10n.dart';
import '../../../core/firebase/firebase_providers.dart';
import '../../academic/domain/academic_year.dart';
import '../../auth/application/auth_providers.dart';
import '../data/excel_renderer.dart';
import '../data/pdf_renderer.dart';
import '../data/report_records_repository.dart';
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

final reportRecordsRepositoryProvider = Provider<ReportRecordsRepository>(
  (ref) => ReportRecordsRepository(ref.watch(firestoreProvider)),
);

/// Every issued PDF is official: each report gets a verification record and
/// its QR (Excel is a working copy, so it has none).
Future<List<Report>> _issue(WidgetRef ref, List<Report> reports) {
  final me = ref.read(signedInUserProvider);
  return ref.read(reportRecordsRepositoryProvider).issue(reports, issuedBy: me.id, issuerName: me.name);
}

ReportBranding brandingFor(AppLocalizations l10n, MaterialLocalizations m, AcademicYear? year, DateTime now) =>
    ReportBranding(
      university: l10n.universityName,
      college: l10n.collegeName,
      department: l10n.departmentName,
      yearLine: year == null ? '' : l10n.homeActiveYear(year.id, '${year.semester}'),
      printedLine: l10n.reportPrinted(m.formatShortDate(now)),
      pageLabel: (p, n) => l10n.reportPage(p, n),
      signatureHint: l10n.reportSignatureHint,
      verifyHint: l10n.reportVerifyHint,
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
    final issued = await _issue(ref, reports);
    final bytes = await renderer.renderAll(issued, brandingFor(l10n, m, year, DateTime.now()));
    final saved = await FilePicker.saveFile(
      fileName: fileName,
      bytes: bytes,
      mimeType: 'application/pdf',
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
    );
    if (saved != null && context.mounted) showSnack(context, l10n.reportSaved);
  } on Object catch (e) {
    if (context.mounted) showError(context, e);
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
                  leading: const Icon(Icons.report_outlined),
                  title: Text(l10n.reportPdf),
                  subtitle: Text(l10n.reportPdfHelp),
                  onTap: () => Navigator.pop(context, ReportFormat.pdf),
                ),
                ListTile(
                  key: const Key('export.excel'),
                  leading: const Icon(Icons.table_chart_outlined),
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
        final renderer = await ref.read(pdfRendererProvider.future);
        bytes = await renderer.render((await _issue(ref, [report])).single, branding);
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
    if (context.mounted) showError(context, e);
  }
}

/// A printable QR poster for [url] (e.g. the public announcements page).
Future<void> exportQrPoster(
  BuildContext context,
  WidgetRef ref, {
  required String title,
  required List<String> lines,
  required String url,
  required String fileName,
}) async {
  final l10n = context.l10n;
  final m = MaterialLocalizations.of(context);
  try {
    final renderer = await ref.read(pdfRendererProvider.future);
    final bytes = await renderer.renderPoster(
      title: title,
      lines: lines,
      url: url,
      branding: brandingFor(l10n, m, null, DateTime.now()),
    );
    final saved = await FilePicker.saveFile(
      fileName: fileName,
      bytes: bytes,
      mimeType: 'application/pdf',
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
    );
    if (saved != null && context.mounted) showSnack(context, l10n.reportSaved);
  } on Object catch (e) {
    if (context.mounted) showError(context, e);
  }
}
