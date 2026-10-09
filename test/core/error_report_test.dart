import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uob_attendance/core/diagnostics/error_log.dart';
import 'package:uob_attendance/core/widgets/common_widgets.dart';
import 'package:uob_attendance/l10n/app_localizations.dart';

void main() {
  setUp(ErrorLog.entries.clear);

  test('reports name the Firebase or platform code and the context', () {
    ErrorLog.context = 'account: t@uob.iq (teacher)';
    final e = ErrorLog.record(
      FirebaseException(plugin: 'cloud_firestore', code: 'permission-denied', message: 'Missing permissions'),
      null,
      '/department',
    );
    final report = ErrorLog.report(e);
    expect(report, contains('[cloud_firestore/permission-denied] Missing permissions'));
    expect(report, contains('account: t@uob.iq (teacher)'));
    expect(report, contains('screen: /department'));
    expect(ErrorLog.describe(PlatformException(code: 'firebase_firestore', message: 'PERMISSION_DENIED')),
        contains('PERMISSION_DENIED'));
    for (var i = 0; i < ErrorLog.max + 5; i++) {
      ErrorLog.record('e$i');
    }
    expect(ErrorLog.entries, hasLength(ErrorLog.max));
  });

  testWidgets('an error offers «التفاصيل» with a report that can be copied', (tester) async {
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') copied = (call.arguments as Map)['text'] as String;
      return null;
    });
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('ar'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => showError(context, FirebaseException(plugin: 'cloud_firestore', code: 'permission-denied')),
            child: const Text('go'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('التفاصيل'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('error.report')), findsOneWidget);
    await tester.tap(find.byKey(const Key('error.copy')));
    await tester.pumpAndSettle();
    expect(copied, contains('[cloud_firestore/permission-denied]'));
    expect(ErrorLog.entries, hasLength(1));
  });
}
