import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uob_attendance/core/widgets/file_delivery.dart';
import 'package:uob_attendance/l10n/app_localizations.dart';

void main() {
  testWidgets('an exported file is offered for sharing or saving', (tester) async {
    FileDelivery? result = FileDelivery.save;
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('ar'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () async => result = await deliverFile(
            context,
            bytes: Uint8List(1),
            fileName: 'a.pdf',
            mimeType: 'application/pdf',
          ),
          child: const Text('export'),
        ),
      ),
    ));
    await tester.tap(find.text('export'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('deliver.share')), findsOneWidget);
    expect(find.byKey(const Key('deliver.save')), findsOneWidget);
    expect(find.text('مشاركة'), findsOneWidget);

    // Closing the sheet cancels.
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(result, isNull);
  });
}
