import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/common_widgets.dart';
import '../../../l10n/l10n.dart';
import '../../users/application/users_providers.dart';
import '../../users/domain/access_request.dart';
import '../application/auth_providers.dart';

/// Verified e-mail but no usable profile: not provisioned, suspended, or the
/// profile could not be loaded. A not-provisioned person can ask to join.
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
        child: Column(
          children: [
            MessageView(
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
            if (status is NotProvisioned) _JoinRequestPanel(email: status.email),
          ],
        ),
      ),
    );
  }
}

/// Files `accessRequests/{email}`, or shows the pending one. Approval creates
/// the account, which moves the person past this screen by itself.
class _JoinRequestPanel extends ConsumerStatefulWidget {
  const _JoinRequestPanel({required this.email});

  final String email;

  @override
  ConsumerState<_JoinRequestPanel> createState() => _JoinRequestPanelState();
}

class _JoinRequestPanelState extends ConsumerState<_JoinRequestPanel> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _note = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action, String done) async {
    setState(() => _busy = true);
    try {
      await action();
      if (mounted) showSnack(context, done);
    } on FirebaseException catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final repo = ref.read(accountsRepositoryProvider);
    await _run(
      () => repo.submitRequest(email: widget.email, name: _name.text, note: _note.text),
      context.l10n.joinSent,
    );
  }

  Future<void> _cancel() =>
      _run(() => ref.read(accountsRepositoryProvider).cancelRequest(widget.email), context.l10n.joinCancelled);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final mine = ref.watch(myAccessRequestProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: switch (mine) {
          AsyncData(value: final AccessRequest request) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.hourglass_top),
                  title: Text(l10n.joinTitle),
                  subtitle: Text(l10n.joinPending(_date(context, request.requestedAt))),
                ),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: TextButton(
                    key: const Key('join.cancel'),
                    onPressed: _busy ? null : _cancel,
                    child: Text(l10n.joinCancel),
                  ),
                ),
              ],
            ),
          AsyncData() => Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l10n.joinTitle, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(l10n.joinBody),
                  const SizedBox(height: 12),
                  TextFormField(
                    key: const Key('join.name'),
                    controller: _name,
                    maxLength: AccessRequest.maxName,
                    decoration: InputDecoration(labelText: l10n.joinName, prefixIcon: const Icon(Icons.badge_outlined)),
                    validator: (v) => (v ?? '').trim().isEmpty ? l10n.validationRequired : null,
                  ),
                  TextFormField(
                    key: const Key('join.note'),
                    controller: _note,
                    maxLength: AccessRequest.maxNote,
                    maxLines: 2,
                    decoration: InputDecoration(labelText: l10n.joinNote, hintText: l10n.joinNoteHint),
                  ),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    key: const Key('join.submit'),
                    onPressed: _busy ? null : _submit,
                    icon: const Icon(Icons.send),
                    label: Text(l10n.joinSubmit),
                  ),
                ],
              ),
            ),
          AsyncError(:final error) => Text(l10n.errorGeneric('$error')),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }

  static String _date(BuildContext context, DateTime? date) =>
      date == null ? '…' : MaterialLocalizations.of(context).formatShortDate(date.toLocal());
}
