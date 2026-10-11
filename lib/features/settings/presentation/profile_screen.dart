import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import '../../../core/theme/app_settings.dart';
import '../../../core/diagnostics/error_log.dart';
import '../../../core/firebase/firebase_providers.dart';
import '../../../core/firebase/rules_version.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../l10n/l10n.dart';
import '../../auth/application/auth_providers.dart';
import '../../push/application/push_providers.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/presentation/delete_account.dart';

/// SPEC «الملف الشخصي»: البيانات، تغيير كلمة المرور، اللغة، الوضع الليلي، تسجيل الخروج.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late final TextEditingController _phone =
      TextEditingController(text: ref.read(signedInUserProvider).phone);

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  Future<void> _savePhone() async {
    final l10n = context.l10n;
    try {
      await ref.read(usersRepositoryProvider).updatePhone(ref.read(signedInUserProvider).id, _phone.text);
      if (mounted) showSnack(context, l10n.profilePhoneSaved);
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  Future<void> _changePassword() async {
    final l10n = context.l10n;
    try {
      await ref.read(authRepositoryProvider).sendPasswordReset(ref.read(signedInUserProvider).email);
      if (mounted) showSnack(context, l10n.profileResetLinkSent);
    } on AuthException catch (e) {
      if (mounted) showSnack(context, l10n.authFailure(e));
    }
  }

  Future<void> _signOut() async {
    final l10n = context.l10n;
    // SPEC: never sign out silently with un-uploaded records.
    if (!kIsWeb) {
      final pending = await ref.read(appDatabaseProvider).watchPendingCount().first;
      if (pending > 0) {
        if (mounted) showSnack(context, l10n.signOutPending(pending));
        return;
      }
    }
    if (!mounted) return;
    if (await confirmDialog(context, title: l10n.signOut, body: l10n.signOutConfirm, confirmLabel: l10n.signOut)) {
      await ref.read(pushActionsProvider).forget();
      await ref.read(authRepositoryProvider).signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final user = ref.watch(signedInUserProvider);
    final settings = ref.watch(appSettingsProvider);
    final controller = ref.read(appSettingsProvider.notifier);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileTitle)),
      body: Align(
        alignment: AlignmentDirectional.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.displayName, style: theme.textTheme.titleLarge),
                      Text(user.email, textDirection: TextDirection.ltr, style: theme.textTheme.bodySmall),
                      const SizedBox(height: 4),
                      Text([for (final r in user.roles) l10n.role(r)].join('، ')),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _phone,
                              keyboardType: TextInputType.phone,
                              textDirection: TextDirection.ltr,
                              decoration: InputDecoration(labelText: l10n.profilePhone, prefixIcon: const Icon(Icons.phone)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          FilledButton(onPressed: _savePhone, child: Text(l10n.save)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.profileTheme, style: theme.textTheme.titleMedium),
                      const SizedBox(height: 8),
                      SegmentedButton<ThemeMode>(
                        segments: [
                          ButtonSegment(value: ThemeMode.system, icon: const Icon(Icons.brightness_auto), label: Text(l10n.themeSystem)),
                          ButtonSegment(value: ThemeMode.light, icon: const Icon(Icons.light_mode), label: Text(l10n.themeLight)),
                          ButtonSegment(value: ThemeMode.dark, icon: const Icon(Icons.dark_mode), label: Text(l10n.themeDark)),
                        ],
                        selected: {settings.themeMode},
                        onSelectionChanged: (s) => controller.setThemeMode(s.first),
                      ),
                      const SizedBox(height: 16),
                      Text(l10n.profileLanguage, style: theme.textTheme.titleMedium),
                      const SizedBox(height: 8),
                      SegmentedButton<String>(
                        segments: [
                          ButtonSegment(value: 'ar', label: Text(l10n.languageArabic)),
                          ButtonSegment(value: 'en', label: Text(l10n.languageEnglish)),
                        ],
                        selected: {settings.locale.languageCode},
                        onSelectionChanged: (s) => controller.setLanguage(s.first),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.password),
                      title: Text(l10n.profileChangePassword),
                      onTap: _changePassword,
                    ),
                    ListTile(
                      key: const Key('profile.errors'),
                      leading: const Icon(Icons.report_outlined),
                      title: Text(l10n.errorLogAction),
                      subtitle: Text(l10n.errorLogCount(ErrorLog.entries.length)),
                      onTap: () async {
                        // With the state of the deployed rules: the usual cause of
                        // «permission-denied» right after an update.
                        final rules = RulesVersion.describe(await RulesVersion.isDeployed(ref.read(firestoreProvider)));
                        if (!context.mounted) return;
                        await showReportDialog(
                          context,
                          [rules, ErrorLog.context, ErrorLog.entries.isEmpty ? l10n.errorLogEmpty : ErrorLog.reportAll()]
                              .where((x) => x.isNotEmpty)
                              .join('\n\n'),
                          title: l10n.errorLogAction,
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.logout, color: theme.colorScheme.error),
                      title: Text(l10n.signOut, style: TextStyle(color: theme.colorScheme.error)),
                      onTap: _signOut,
                    ),
                    ListTile(
                      key: const Key('profile.deleteAccount'),
                      leading: Icon(Icons.delete_forever, color: theme.colorScheme.error),
                      title: Text(l10n.deleteAccount, style: TextStyle(color: theme.colorScheme.error)),
                      onTap: () => deleteAccountFlow(context, ref, email: user.id),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
