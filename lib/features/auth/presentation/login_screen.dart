import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/common_widgets.dart';
import '../../../l10n/l10n.dart';
import '../../import/domain/value_parsers.dart';
import '../application/auth_providers.dart';
import '../data/auth_repository.dart';

/// E-mail/password sign-in, with an «activate account» mode for teachers the
/// department has already registered, and password reset.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _activating = false;
  bool _obscure = true;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final repo = ref.read(authRepositoryProvider);
    try {
      if (_activating) {
        await repo.activateAccount(email: _email.text, password: _password.text);
      } else {
        await repo.signIn(email: _email.text, password: _password.text);
      }
      // The router reacts to the auth state change.
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = context.l10n.authFailure(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _forgotPassword() async {
    final l10n = context.l10n;
    final controller = TextEditingController(text: _email.text);
    final email = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.resetPasswordTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.resetPasswordBody),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.emailAddress,
              textDirection: TextDirection.ltr,
              decoration: InputDecoration(labelText: l10n.emailLabel),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          FilledButton(onPressed: () => Navigator.pop(context, controller.text), child: Text(l10n.sendLink)),
        ],
      ),
    );
    controller.dispose();
    if (email == null || ValueParsers.email(email) == null || !mounted) return;
    try {
      await ref.read(authRepositoryProvider).sendPasswordReset(email);
    } on AuthException catch (e) {
      // Do not reveal whether the account exists; only surface transport errors.
      if (e.failure == AuthFailure.network || e.failure == AuthFailure.tooManyRequests) {
        if (mounted) showSnack(context, context.l10n.authFailure(e));
        return;
      }
    }
    if (mounted) showSnack(context, l10n.passwordResetSent);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(actions: const [SettingsActions()]),
      body: CenteredBody(
        child: Form(
          key: _formKey,
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const UniversityHeader(),
                const SizedBox(height: 32),
                Text(
                  _activating ? l10n.activateTitle : l10n.loginTitle,
                  style: theme.textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                if (_activating) ...[
                  const SizedBox(height: 8),
                  Text(l10n.activateHint, style: theme.textTheme.bodySmall, textAlign: TextAlign.center),
                ],
                const SizedBox(height: 24),
                TextFormField(
                  key: const Key('login.email'),
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email, AutofillHints.username],
                  // Addresses are Latin: keep them left-to-right inside the RTL UI.
                  textDirection: TextDirection.ltr,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(labelText: l10n.emailLabel, prefixIcon: const Icon(Icons.email_outlined)),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return l10n.validationRequired;
                    if (ValueParsers.email(v) == null) return l10n.validationEmail;
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const Key('login.password'),
                  controller: _password,
                  obscureText: _obscure,
                  autofillHints: [_activating ? AutofillHints.newPassword : AutofillHints.password],
                  textDirection: TextDirection.ltr,
                  textInputAction: _activating ? TextInputAction.next : TextInputAction.done,
                  onFieldSubmitted: _activating ? null : (_) => _submit(),
                  decoration: InputDecoration(
                    labelText: l10n.passwordLabel,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      tooltip: l10n.showPassword,
                      icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return l10n.validationRequired;
                    if (_activating && v.length < 8) return l10n.validationPasswordLength;
                    return null;
                  },
                ),
                if (_activating) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    key: const Key('login.confirm'),
                    controller: _confirm,
                    obscureText: _obscure,
                    textDirection: TextDirection.ltr,
                    onFieldSubmitted: (_) => _submit(),
                    decoration: InputDecoration(
                      labelText: l10n.confirmPasswordLabel,
                      prefixIcon: const Icon(Icons.lock_outline),
                    ),
                    validator: (v) => v != _password.text ? l10n.validationPasswordMatch : null,
                  ),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Text(_error!,
                      key: const Key('login.error'),
                      style: TextStyle(color: theme.colorScheme.error),
                      textAlign: TextAlign.center),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  key: const Key('login.submit'),
                  onPressed: _busy ? null : _submit,
                  child: _busy
                      ? const SizedBox.square(dimension: 22, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(_activating ? l10n.activate : l10n.signIn),
                ),
                const SizedBox(height: 8),
                if (!_activating)
                  TextButton(onPressed: _busy ? null : _forgotPassword, child: Text(l10n.forgotPassword)),
                TextButton(
                  key: const Key('login.toggleMode'),
                  onPressed: _busy
                      ? null
                      : () => setState(() {
                            _activating = !_activating;
                            _error = null;
                          }),
                  child: Text(_activating ? l10n.haveAccount : l10n.haveNoAccount),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
