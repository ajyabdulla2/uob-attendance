import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/common_widgets.dart';
import '../../../l10n/l10n.dart';
import '../application/auth_providers.dart';

/// Verified e-mail but no usable profile: not provisioned, suspended, or the
/// profile could not be loaded.
class NoAccessScreen extends ConsumerWidget {
  const NoAccessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final status = ref.watch(authStatusProvider);
    final (icon, title, body) = switch (status) {
      NotProvisioned(:final email) => (Icons.person_off_outlined, l10n.notProvisionedTitle, l10n.notProvisionedBody(bidiIsolate(email))),
      Suspended() => (Icons.block, l10n.suspendedTitle, l10n.suspendedBody),
      _ => (Icons.cloud_off, l10n.profileErrorTitle, l10n.profileErrorBody),
    };
    return Scaffold(
      appBar: AppBar(actions: const [SettingsActions()]),
      body: CenteredBody(
        child: MessageView(
          icon: icon,
          title: title,
          body: body,
          actions: [
            FilledButton(
              onPressed: () => ref.invalidate(currentProfileProvider),
              child: Text(l10n.retry),
            ),
            TextButton(
              onPressed: () => ref.read(authRepositoryProvider).signOut(),
              child: Text(l10n.signOut),
            ),
          ],
        ),
      ),
    );
  }
}
