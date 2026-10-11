import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../l10n/l10n.dart';
import '../../attendance/application/attendance_providers.dart';
import '../../notifications/application/notifications_providers.dart';
import '../../push/application/push_providers.dart';
import '../application/auth_providers.dart';
import '../data/auth_repository.dart';

/// «حذف الحساب» (App Store guideline 5.1.1(v)): deletes the sign-in account,
/// the private inbox and this phone's push token, then signs out. The staff
/// entry and the recorded attendance stay — department records, said so in
/// the dialog. Refused while records wait for upload, like signing out.
Future<void> deleteAccountFlow(BuildContext context, WidgetRef ref, {required String email}) async {
  final l10n = context.l10n;
  if (ref.read(localFirstProvider)) {
    final pending = await ref.read(appDatabaseProvider).watchPendingCount().first;
    if (pending > 0) {
      if (context.mounted) showSnack(context, l10n.deleteAccountPending(pending));
      return;
    }
  }
  if (!context.mounted) return;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (_) => _DeleteAccountDialog(email: email),
  );
  if (confirmed != true || !context.mounted) return;
  // With the dialog closed: signing out replaces the screens under it.
  final messenger = ScaffoldMessenger.of(context);
  final auth = ref.read(authRepositoryProvider);
  try {
    await auth.deleteAccount();
    await auth.signOut();
    messenger.showSnackBar(SnackBar(content: Text(l10n.deleteAccountDone)));
  } on Object catch (e) {
    if (context.mounted) showError(context, e);
  }
}

class _DeleteAccountDialog extends ConsumerStatefulWidget {
  const _DeleteAccountDialog({required this.email});

  final String email;

  @override
  ConsumerState<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends ConsumerState<_DeleteAccountDialog> {
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _delete() async {
    final l10n = context.l10n;
    final auth = ref.read(authRepositoryProvider);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      // Password first: nothing is deleted if it is wrong.
      await auth.verifyPassword(_password.text);
      await ref.read(pushActionsProvider).forget();
      try {
        await ref.read(messagesRepositoryProvider).clearInbox(widget.email);
      } on Object catch (e) {
        // Not provisioned (no read access) or offline: the account still goes.
        debugPrint('inbox: $e');
      }
      if (mounted) Navigator.pop(context, true);
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = l10n.authFailure(e));
    } on Object catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final error = Theme.of(context).colorScheme.error;
    return AlertDialog(
      title: Text(l10n.deleteAccount),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.deleteAccountBody),
            const SizedBox(height: 16),
            TextField(
              key: const Key('deleteAccount.password'),
              controller: _password,
              obscureText: true,
              textDirection: TextDirection.ltr,
              enabled: !_busy,
              decoration: InputDecoration(labelText: l10n.deleteAccountPassword, errorText: _error),
              onChanged: (_) => setState(() {}),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: _busy ? null : () => Navigator.pop(context, false), child: Text(l10n.cancel)),
        FilledButton(
          key: const Key('deleteAccount.confirm'),
          style: FilledButton.styleFrom(backgroundColor: error),
          onPressed: _busy || _password.text.isEmpty ? null : _delete,
          child: Text(l10n.deleteAccountConfirm),
        ),
      ],
    );
  }
}
