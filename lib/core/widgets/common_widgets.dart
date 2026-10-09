import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/l10n.dart';
import '../diagnostics/error_log.dart';
import '../theme/app_settings.dart';

/// The department's round logo (transparent outside the circle).
const deptLogoAsset = 'assets/images/dept_logo.png';

/// University / college / department lines shown on entry screens.
class UniversityHeader extends StatelessWidget {
  const UniversityHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Column(
      children: [
        Image.asset(
          deptLogoAsset,
          key: const Key('header.logo'),
          width: 112,
          height: 112,
          semanticLabel: l10n.departmentName,
        ),
        const SizedBox(height: 12),
        Text(l10n.appTitle,
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center),
        const SizedBox(height: 4),
        Text('${l10n.departmentName} — ${l10n.collegeName}',
            style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
        Text(l10n.universityName, style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
      ],
    );
  }
}

/// Theme + language quick toggles for app bars of pre-login screens.
class SettingsActions extends ConsumerWidget {
  const SettingsActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final controller = ref.read(appSettingsProvider.notifier);
    final dark = settings.themeMode == ThemeMode.dark ||
        (settings.themeMode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          onPressed: () => controller.setLanguage(settings.locale.languageCode == 'ar' ? 'en' : 'ar'),
          child: Text(context.l10n.languageSwitch),
        ),
        IconButton(
          tooltip: context.l10n.toggleTheme,
          icon: Icon(dark ? Icons.light_mode : Icons.dark_mode),
          onPressed: () => controller.setThemeMode(dark ? ThemeMode.light : ThemeMode.dark),
        ),
      ],
    );
  }
}

/// Centers content with a readable maximum width (web/tablets).
class CenteredBody extends StatelessWidget {
  const CenteredBody({super.key, required this.child, this.maxWidth = 480});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) => Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(constraints: BoxConstraints(maxWidth: maxWidth), child: child),
        ),
      );
}

/// Icon + title + body + actions, used for empty / error / gate states.
class MessageView extends StatelessWidget {
  const MessageView({
    super.key,
    required this.icon,
    required this.title,
    this.body,
    this.actions = const [],
  });

  final IconData icon;
  final String title;
  final String? body;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56, color: theme.colorScheme.primary),
          const SizedBox(height: 12),
          Text(title, style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
          if (body != null) ...[
            const SizedBox(height: 8),
            Text(body!, style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
          ],
          if (actions.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center, children: actions),
          ],
        ],
      ),
    );
  }
}

/// Renders an AsyncValue with consistent loading / error UI.
class AsyncBody<T> extends StatelessWidget {
  const AsyncBody({super.key, required this.value, required this.data});

  final AsyncValue<T> value;
  final Widget Function(T data) data;

  @override
  Widget build(BuildContext context) => switch (value) {
        AsyncData(:final value) => data(value),
        AsyncError(:final error, :final stackTrace) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                MessageView(
                  icon: Icons.error_outline,
                  title: context.l10n.errorGeneric(ErrorLog.describe(error)),
                ),
                TextButton(
                  key: const Key('error.details'),
                  onPressed: () => showReportDialog(context, ErrorLog.report(ErrorLog.record(error, stackTrace))),
                  child: Text(context.l10n.errorDetails),
                ),
              ],
            ),
          ),
        _ => const Center(child: CircularProgressIndicator()),
      };
}

/// An error for the user, with «التفاصيل»: a report they can copy and
/// send to the developer. Also kept in [ErrorLog] («سجل الأخطاء»).
void showError(BuildContext context, Object error, [StackTrace? stack]) {
  final entry = ErrorLog.record(error, stack);
  final l10n = context.l10n;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      duration: const Duration(seconds: 8),
      content: Text(l10n.errorGeneric(entry.error)),
      action: SnackBarAction(
        label: l10n.errorDetails,
        onPressed: () => showReportDialog(context, ErrorLog.report(entry)),
      ),
    ));
}

/// A copyable technical report (error details, diagnostics).
Future<void> showReportDialog(BuildContext context, String report, {String? title}) {
  final l10n = context.l10n;
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title ?? l10n.errorReportTitle),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.errorReportHelp, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 8),
              Directionality(
                textDirection: TextDirection.ltr,
                child: SelectableText(report, key: const Key('error.report'), style: const TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          key: const Key('error.copy'),
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: report));
            if (context.mounted) Navigator.pop(context);
          },
          child: Text(l10n.errorCopy),
        ),
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.close)),
      ],
    ),
  );
}

void showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  required String body,
  String? confirmLabel,
  bool destructive = false,
}) async {
  final l10n = context.l10n;
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
        FilledButton(
          style: destructive
              ? FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error)
              : null,
          onPressed: () => Navigator.pop(context, true),
          child: Text(confirmLabel ?? l10n.confirm),
        ),
      ],
    ),
  );
  return result ?? false;
}
