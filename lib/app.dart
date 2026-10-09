import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_settings.dart';
import 'core/theme/app_theme.dart';
import 'l10n/l10n.dart';

class AttendanceApp extends ConsumerWidget {
  const AttendanceApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    return MaterialApp.router(
      onGenerateTitle: (context) => context.l10n.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: settings.themeMode,
      // Arabic (RTL) by default; Directionality follows the locale.
      locale: settings.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: ref.watch(routerProvider),
      // Android 15+ draws apps edge to edge: keep every page, sheet and
      // bottom button above the system navigation bar.
      builder: (context, child) => ColoredBox(
        color: Theme.of(context).colorScheme.surface,
        child: SafeArea(top: false, child: child ?? const SizedBox.shrink()),
      ),
    );
  }
}

/// Shown when Firebase cannot start (e.g. placeholder firebase_options.dart).
class ConfigErrorApp extends StatelessWidget {
  const ConfigErrorApp({super.key, required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      locale: const Locale('ar'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.settings_suggest, size: 64),
                  const SizedBox(height: 16),
                  Text(context.l10n.configErrorTitle, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(context.l10n.configErrorBody, textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  SelectableText('$error',
                      textDirection: TextDirection.ltr, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
