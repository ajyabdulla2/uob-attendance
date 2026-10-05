import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uob_attendance/core/widgets/common_widgets.dart';
import 'package:uob_attendance/features/auth/domain/app_user.dart';
import 'package:uob_attendance/features/import/application/import_controller.dart';
import 'package:uob_attendance/features/import/data/import_templates.dart';
import 'package:uob_attendance/features/import/domain/import_models.dart';
import 'package:uob_attendance/features/import/presentation/import_screen.dart';

import '../helpers/pump_app.dart';

void main() {
  group('login screen', () {
    testWidgets('is Arabic, right-to-left and uses Cairo', (tester) async {
      await pumpApp(tester);
      expect(find.text('تسجيل الدخول'), findsOneWidget);
      expect(find.text('نظام الحضور والغياب'), findsOneWidget);
      final context = tester.element(find.byKey(const Key('login.email')));
      expect(Directionality.of(context), TextDirection.rtl);
      expect(Theme.of(context).textTheme.bodyMedium?.fontFamily, 'Cairo');
      expect(find.byKey(const Key('header.logo')), findsOneWidget);
      // The logo is bundled (a missing asset only shows up at runtime).
      expect((await rootBundle.load(deptLogoAsset)).lengthInBytes, greaterThan(10000));
    });

    testWidgets('validates fields and switches to activation mode', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.byKey(const Key('login.submit')));
      await tester.pump();
      expect(find.text('هذا الحقل مطلوب'), findsNWidgets(2));

      await tester.enterText(find.byKey(const Key('login.email')), 'not-an-email');
      await tester.tap(find.byKey(const Key('login.submit')));
      await tester.pump();
      expect(find.text('صيغة البريد غير صحيحة'), findsOneWidget);

      await tester.tap(find.byKey(const Key('login.toggleMode')));
      await tester.pump();
      expect(find.text('تفعيل حساب جديد'), findsOneWidget);
      await tester.enterText(find.byKey(const Key('login.email')), 't@uobasrah.edu.iq');
      await tester.enterText(find.byKey(const Key('login.password')), 'short');
      await tester.enterText(find.byKey(const Key('login.confirm')), 'other');
      await tester.tap(find.byKey(const Key('login.submit')));
      await tester.pump();
      expect(find.text('كلمة المرور 8 أحرف على الأقل'), findsOneWidget);
      expect(find.text('كلمتا المرور غير متطابقتين'), findsOneWidget);
    });

    testWidgets('switches to English (left-to-right) and dark mode', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();
      expect(find.text('Sign in'), findsWidgets);
      expect(Directionality.of(tester.element(find.byKey(const Key('login.email')))), TextDirection.ltr);
      await tester.tap(find.byTooltip('Toggle dark mode'));
      await tester.pumpAndSettle();
      expect(Theme.of(tester.element(find.byKey(const Key('login.email')))).brightness, Brightness.dark);
    });
  });

  group('gates', () {
    testWidgets('unverified e-mail goes to the verification screen', (tester) async {
      await pumpApp(tester, user: MockUser(email: 't@uobasrah.edu.iq', isEmailVerified: false));
      expect(find.text('تأكيد البريد'), findsOneWidget);
    });

    testWidgets('a verified but unregistered e-mail is told to contact the department', (tester) async {
      await pumpApp(tester, user: MockUser(email: 'x@uobasrah.edu.iq', isEmailVerified: true));
      expect(find.text('الحساب غير مضاف'), findsOneWidget);
    });
  });

  group('signed in', () {
    testWidgets('a teacher sees home and profile only', (tester) async {
      await pumpApp(
        tester,
        user: MockUser(email: 't@uobasrah.edu.iq', isEmailVerified: true),
        profile: const AppUser(email: 't@uobasrah.edu.iq', name: 'علي', title: 'مدرس'),
      );
      expect(find.text('أهلاً، مدرس علي'), findsOneWidget);
      expect(find.text('لم تُسند إليك مواد بعد.'), findsOneWidget);
      expect(find.text('الاستيراد'), findsNothing);
      expect(find.text('الربط'), findsNothing);
      expect(find.text('الملف الشخصي'), findsOneWidget);
    });

    testWidgets('super admin initializes setup, then imports students through the preview', (tester) async {
      final env = await pumpApp(
        tester,
        user: MockUser(email: adminEmail, isEmailVerified: true),
        profile: const AppUser(email: adminEmail, name: 'المدير', roles: {UserRole.superAdmin, UserRole.teacher}),
      );
      expect(find.text('مدير عام'), findsOneWidget);

      // Initial setup card → creates 8 stages + active year.
      await tester.tap(find.text('تهيئة الآن'));
      await tester.pumpAndSettle();
      expect((await env.db.collection('stages').get()).docs, hasLength(8));

      // Go to import (navigation rail on wide screens).
      await tester.tap(find.text('الاستيراد'));
      await tester.pumpAndSettle();
      expect(find.byType(ImportScreen), findsOneWidget);
      expect(find.text('تنزيل القالب'), findsOneWidget);

      // Load the students template as if picked from disk.
      final container = ProviderScope.containerOf(tester.element(find.byType(ImportScreen)));
      await container
          .read(importControllerProvider(ImportKind.students).notifier)
          .loadFile(ImportTemplates.build(ImportKind.students), 'students.xlsx');
      await tester.pumpAndSettle();
      expect(find.text('جديد: 2'), findsOneWidget);
      // The earlier «تمت التهيئة» snackbar floats over the bottom save button.
      tester.state<ScaffoldMessengerState>(find.byType(ScaffoldMessenger)).clearSnackBars();
      await tester.pumpAndSettle();
      expect(find.textContaining('علي حسين جاسم محمد'), findsOneWidget);

      await tester.tap(find.byKey(const Key('import.save.students')));
      await tester.pumpAndSettle();
      expect(find.text('تأكيد الحفظ'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'حفظ'));
      await tester.pumpAndSettle();

      expect(find.text('تم الحفظ: أُضيف 2 وحُدِّث 0.'), findsOneWidget);
      final students = await env.db.collection('students').get();
      expect(students.docs.map((d) => d.id), unorderedEquals(['2026001', '2026002']));
      expect(students.docs.first.data()['updatedBy'], adminEmail);
    });

    testWidgets('assignments screen lists courses of the selected stage', (tester) async {
      final env = await pumpApp(
        tester,
        user: MockUser(email: adminEmail, isEmailVerified: true),
        profile: const AppUser(email: adminEmail, name: 'المدير', roles: {UserRole.deputyAdmin}),
      );
      await env.db.doc('courses/CS101_1-morning').set({
        'code': 'CS101', 'name': 'أساسيات البرمجة', 'stageId': '1-morning', 'semester': 1, 'units': 3, 'hasPractical': true,
      });
      await tester.tap(find.text('الربط'));
      await tester.pumpAndSettle();
      expect(find.text('ربط التدريسيين بالمواد'), findsOneWidget);
      expect(find.text('أساسيات البرمجة'), findsOneWidget);
      await tester.tap(find.text('أساسيات البرمجة'));
      await tester.pumpAndSettle();
      expect(find.text('لم يُسند النظري بعد.'), findsOneWidget);
      expect(find.text('لا توجد مجاميع عملي بعد.'), findsOneWidget);
    });
  });

  group('update notice (config/app)', () {
    final teacher = MockUser(email: 't@uobasrah.edu.iq', isEmailVerified: true);
    const profile = AppUser(email: 't@uobasrah.edu.iq', name: 'علي');

    testWidgets('no policy or up to date → no banner', (tester) async {
      await pumpApp(tester, user: teacher, profile: profile, appPolicy: {'latestVersion': '1.0.0'});
      expect(find.byKey(const Key('update.banner')), findsNothing);
      expect(find.text('أهلاً، علي'), findsOneWidget);
    });

    testWidgets('newer version → dismissible banner above the screen', (tester) async {
      await pumpApp(tester, user: teacher, profile: profile,
          appPolicy: {'latestVersion': '1.1.0', 'androidUrl': 'https://example.org/app.apk'});
      expect(find.byKey(const Key('update.banner')), findsOneWidget);
      expect(find.textContaining('إصدار جديد'), findsOneWidget);
      expect(find.text('أهلاً، علي'), findsOneWidget); // still usable
      await tester.tap(find.text('لاحقاً'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('update.banner')), findsNothing);
    });

    testWidgets('below the minimum version → blocking update screen', (tester) async {
      await pumpApp(tester, user: teacher, profile: profile,
          appPolicy: {'latestVersion': '2.0.0', 'minVersion': '2.0.0'});
      expect(find.byKey(const Key('update.required')), findsOneWidget);
      expect(find.text('يجب تحديث التطبيق'), findsOneWidget);
      expect(find.text('أهلاً، علي'), findsNothing);
    });
  });
}
