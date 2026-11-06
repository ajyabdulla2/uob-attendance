import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../l10n/l10n.dart';

/// How an exported file leaves the app.
enum FileDelivery { save, share }

/// Hands an exported file to the user: on a phone they choose «حفظ في
/// الهاتف» (the system save dialog) or «مشاركة» (WhatsApp, e-mail, Drive…
/// through the system share sheet); on the web it downloads. Returns how it
/// went out, or null when they cancelled.
Future<FileDelivery?> deliverFile(
  BuildContext context, {
  required Uint8List bytes,
  required String fileName,
  required String mimeType,
  List<String>? extensions,
}) async {
  final l10n = context.l10n;
  final how = kIsWeb
      ? FileDelivery.save
      : await showModalBottomSheet<FileDelivery>(
          context: context,
          showDragHandle: true,
          builder: (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  key: const Key('deliver.share'),
                  leading: const Icon(Icons.share),
                  title: Text(l10n.fileShare),
                  subtitle: Text(l10n.fileShareHelp),
                  onTap: () => Navigator.pop(context, FileDelivery.share),
                ),
                ListTile(
                  key: const Key('deliver.save'),
                  leading: const Icon(Icons.save_alt),
                  title: Text(l10n.fileSave),
                  onTap: () => Navigator.pop(context, FileDelivery.save),
                ),
              ],
            ),
          ),
        );
  switch (how) {
    case null:
      return null;
    case FileDelivery.save:
      final saved = await FilePicker.saveFile(
        fileName: fileName,
        bytes: bytes,
        mimeType: mimeType,
        type: extensions == null ? FileType.any : FileType.custom,
        allowedExtensions: extensions,
      );
      // On the web the download starts without a path.
      return saved != null || kIsWeb ? FileDelivery.save : null;
    case FileDelivery.share:
      final dir = await Directory((await getTemporaryDirectory()).path).createTemp('share');
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(bytes, flush: true);
      final result = await SharePlus.instance.share(ShareParams(files: [XFile(file.path, mimeType: mimeType)]));
      return result.status == ShareResultStatus.dismissed ? null : FileDelivery.share;
  }
}
