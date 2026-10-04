import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/common_widgets.dart';
import '../../../l10n/l10n.dart';
import '../application/auth_providers.dart';
import '../data/auth_repository.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  bool _busy = false;

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } on AuthException catch (e) {
      if (mounted) showSnack(context, context.l10n.authFailure(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _checkVerified() => _run(() async {
        final verified = await ref.read(authRepositoryProvider).reloadUser();
        if (!verified && mounted) showSnack(context, context.l10n.verifyNotYet);
      });

  Future<void> _resend() => _run(() async {
        await ref.read(authRepositoryProvider).resendVerification();
        if (mounted) showSnack(context, context.l10n.verifySent);
      });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final repo = ref.read(authRepositoryProvider);
    final status = ref.watch(authStatusProvider);
    final email = status is NeedsVerification ? status.email : '';
    return Scaffold(
      appBar: AppBar(actions: const [SettingsActions()]),
      body: CenteredBody(
        child: MessageView(
          icon: Icons.mark_email_unread_outlined,
          title: l10n.verifyTitle,
          body: l10n.verifyBody(bidiIsolate(email)),
          actions: [
            FilledButton(onPressed: _busy ? null : _checkVerified, child: Text(l10n.verifyDone)),
            OutlinedButton(onPressed: _busy ? null : _resend, child: Text(l10n.verifyResend)),
            TextButton(onPressed: _busy ? null : repo.signOut, child: Text(l10n.signOut)),
          ],
        ),
      ),
    );
  }
}
