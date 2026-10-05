import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/domain/stage_ref.dart';
import '../../../core/utils/arabic_text.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../l10n/l10n.dart';
import '../../auth/application/auth_providers.dart';
import '../../auth/domain/app_user.dart';
import '../../auth/domain/permissions.dart';
import '../../data_fix/application/data_fix_providers.dart';
import '../../data_fix/domain/fix_plan.dart';
import '../../import/domain/value_parsers.dart';
import '../application/users_providers.dart';
import '../data/accounts_repository.dart';
import '../domain/access_request.dart';
import '../domain/account_form.dart';

/// Admins: approve join requests, add accounts and grant roles / stage
/// scopes / suspension — without the Firebase Console.
class AccountsScreen extends ConsumerStatefulWidget {
  const AccountsScreen({super.key});

  @override
  ConsumerState<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends ConsumerState<AccountsScreen> {
  String _query = '';

  String get _actor => ref.read(signedInUserProvider).id;

  /// Runs a write and reports the outcome; returns whether it succeeded.
  Future<bool> _save(Future<void> Function() action, String done) async {
    final l10n = context.l10n;
    try {
      await action();
      if (mounted) showSnack(context, done);
      return true;
    } on AccountExistsException {
      if (mounted) showSnack(context, l10n.accountsExists);
    } on FirebaseException catch (e) {
      if (mounted) {
        showSnack(context, e.code == 'permission-denied' ? l10n.permissionDenied : l10n.errorGeneric(e.message ?? e.code));
      }
    }
    return false;
  }

  Future<void> _add() async {
    final account = await showAccountEditor(context, mode: AccountEditorMode.create);
    if (account == null || !mounted) return;
    await _save(() => ref.read(accountsRepositoryProvider).create(account, actor: _actor),
        context.l10n.accountsCreated(bidiIsolate(account.id)));
  }

  Future<void> _edit(AppUser before) async {
    final perms = ref.read(permissionsProvider);
    final after = await showAccountEditor(
      context,
      mode: AccountEditorMode.edit,
      initial: before,
      onDelete: perms.canDeleteAccount(before) ? () => _delete(before) : null,
      onChangeEmail: perms.canRenameTeachers && before.id != _actor ? () => _changeEmail(before) : null,
    );
    if (after == null || !mounted) return;
    await _save(() => ref.read(accountsRepositoryProvider).update(before, after, actor: _actor), context.l10n.accountsSaved);
  }

  /// Moves an account (e.g. imported with a wrong e-mail) and its class
  /// links to the correct e-mail; the owner then activates with it.
  Future<void> _changeEmail(AppUser user) async {
    final l10n = context.l10n;
    final to = await showDialog<String>(context: context, builder: (_) => _NewEmailDialog(current: user.id));
    if (to == null || !mounted) return;
    final repo = ref.read(dataFixRepositoryProvider);
    try {
      final plan = await repo.planTeacherRename(user.id, to, actor: _actor);
      if (!mounted) return;
      if (plan.problems.isNotEmpty) {
        showSnack(context, l10n.fixProblem(plan.problems.first, plan.mergeInto));
        return;
      }
      final body = l10n.accountChangeEmailBody(
        bidiIsolate(user.id),
        plan.counts[FixCount.assignments] ?? 0,
        bidiIsolate(to),
      );
      final ok = await confirmDialog(
        context,
        title: l10n.accountChangeEmail,
        body: plan.mergeInto == null ? body : '$body\n\n${l10n.fixMerge(plan.mergeInto!)}',
        confirmLabel: l10n.accountChangeEmail,
      );
      if (!ok || !mounted) return;
      await _save(() => repo.apply(plan), l10n.accountEmailChanged);
    } on FirebaseException catch (e) {
      if (mounted) {
        showSnack(context, e.code == 'permission-denied' ? l10n.permissionDenied : l10n.errorGeneric(e.message ?? e.code));
      }
    }
  }

  /// Removes an account that never recorded a lecture (e.g. imported with a
  /// wrong e-mail), with its class links.
  Future<void> _delete(AppUser user) async {
    final l10n = context.l10n;
    final repo = ref.read(dataFixRepositoryProvider);
    try {
      final plan = await repo.planTeacherDeletion(onlyEmail: user.id, actor: _actor);
      if (!mounted) return;
      if (plan.problems.isNotEmpty) {
        showSnack(context, l10n.fixProblem(plan.problems.first, plan.mergeInto));
        return;
      }
      final ok = await confirmDialog(
        context,
        title: l10n.accountDelete,
        body: l10n.accountDeleteBody(bidiIsolate(user.id), plan.counts[FixCount.assignments] ?? 0),
        confirmLabel: l10n.accountDelete,
        destructive: true,
      );
      if (!ok || !mounted) return;
      await _save(() => repo.apply(plan), l10n.accountDeleted);
    } on FirebaseException catch (e) {
      if (mounted) {
        showSnack(context, e.code == 'permission-denied' ? l10n.permissionDenied : l10n.errorGeneric(e.message ?? e.code));
      }
    }
  }

  Future<void> _approve(AccessRequest request) async {
    final account = await showAccountEditor(
      context,
      mode: AccountEditorMode.approve,
      initial: AppUser(email: request.email, name: request.name),
    );
    if (account == null || !mounted) return;
    await _save(() => ref.read(accountsRepositoryProvider).approve(account, actor: _actor),
        context.l10n.accountsApproved(account.name));
  }

  Future<void> _reject(AccessRequest request) async {
    final l10n = context.l10n;
    final ok = await confirmDialog(
      context,
      title: l10n.accountsRejectTitle,
      body: l10n.accountsRejectBody(bidiIsolate(request.email)),
      confirmLabel: l10n.accountsReject,
      destructive: true,
    );
    if (!ok || !mounted) return;
    await _save(() => ref.read(accountsRepositoryProvider).reject(request, actor: _actor), l10n.accountsRejected);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final perms = ref.watch(permissionsProvider);
    final requests = ref.watch(accessRequestsProvider).value ?? const [];
    return Scaffold(
      appBar: AppBar(title: Text(l10n.accountsTitle)),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('accounts.add'),
        onPressed: _add,
        icon: const Icon(Icons.person_add_alt_1),
        label: Text(l10n.accountsAdd),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: [
          if (requests.isNotEmpty) ...[
            _RequestsCard(requests: requests, onApprove: _approve, onReject: _reject),
            const SizedBox(height: 16),
          ],
          TextField(
            key: const Key('accounts.search'),
            decoration: InputDecoration(labelText: l10n.accountsSearch, prefixIcon: const Icon(Icons.search)),
            onChanged: (v) => setState(() => _query = ArabicText.normalizeForCompare(v.trim())),
          ),
          const SizedBox(height: 8),
          AsyncBody<List<AppUser>>(
            value: ref.watch(allUsersProvider),
            data: (users) {
              final shown = [
                for (final u in users)
                  if (_query.isEmpty ||
                      ArabicText.normalizeForCompare(u.displayName).contains(_query) ||
                      u.id.contains(_query.toLowerCase()))
                    u,
              ];
              if (shown.isEmpty) {
                return Card(child: ListTile(leading: const Icon(Icons.info_outline), title: Text(l10n.accountsEmpty)));
              }
              return Card(
                child: Column(
                  children: [
                    for (final u in shown)
                      _AccountTile(user: u, perms: perms, onTap: perms.canEditAccount(u) ? () => _edit(u) : null),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _RequestsCard extends StatelessWidget {
  const _RequestsCard({required this.requests, required this.onApprove, required this.onReject});

  final List<AccessRequest> requests;
  final void Function(AccessRequest) onApprove;
  final void Function(AccessRequest) onReject;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Card(
      key: const Key('accounts.requests'),
      color: theme.colorScheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              leading: const Icon(Icons.how_to_reg),
              title: Text(l10n.accountsRequestsTitle(requests.length), style: theme.textTheme.titleMedium),
            ),
            for (final r in requests) ...[
              const Divider(height: 1),
              ListTile(
                title: Text(r.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.email, textDirection: TextDirection.ltr),
                    if (r.note.isNotEmpty) Text(r.note),
                    if (r.requestedAt != null)
                      Text(
                        l10n.accountsRequestedOn(
                            MaterialLocalizations.of(context).formatShortDate(r.requestedAt!.toLocal())),
                        style: theme.textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 12, bottom: 4),
                child: OverflowBar(
                  alignment: MainAxisAlignment.end,
                  spacing: 8,
                  children: [
                    TextButton(
                      key: Key('accounts.reject.${r.email}'),
                      onPressed: () => onReject(r),
                      child: Text(l10n.accountsReject),
                    ),
                    FilledButton(
                      key: Key('accounts.approve.${r.email}'),
                      onPressed: () => onApprove(r),
                      child: Text(l10n.accountsApprove),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  const _AccountTile({required this.user, required this.perms, required this.onTap});

  final AppUser user;
  final Permissions perms;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final icon = user.hasRole(UserRole.superAdmin) || user.hasRole(UserRole.deputyAdmin)
        ? Icons.admin_panel_settings
        : user.hasRole(UserRole.stageManager)
            ? Icons.supervisor_account
            : Icons.person;
    final roles = [for (final r in UserRole.values) if (user.hasRole(r)) l10n.role(r)].join(' · ');
    final scopes = user.hasRole(UserRole.stageManager) && user.stageScopes.isNotEmpty
        ? user.stageScopes.map(l10n.stageId).join('، ')
        : null;
    return ListTile(
      key: Key('accounts.user.${user.id}'),
      leading: CircleAvatar(child: Icon(icon)),
      title: Text(user.displayName.isEmpty ? user.id : user.displayName),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(user.id, textDirection: TextDirection.ltr, style: theme.textTheme.bodySmall),
          if (roles.isNotEmpty) Text(roles),
          if (scopes != null) Text(scopes, style: theme.textTheme.bodySmall),
        ],
      ),
      trailing: !user.active
          ? Chip(
              label: Text(l10n.accountsSuspended),
              backgroundColor: theme.colorScheme.errorContainer,
              avatar: const Icon(Icons.block, size: 18),
            )
          : onTap == null
              ? Tooltip(message: l10n.accountsLocked, child: const Icon(Icons.lock_outline))
              : const Icon(Icons.edit_outlined),
      onTap: onTap,
    );
  }
}

// ------------------------------------------------------------------ editor --

enum AccountEditorMode { create, approve, edit }

/// Shows the account form; returns the normalized account, or null when
/// cancelled. [onDelete] / [onChangeEmail] add «حذف الحساب» / «تغيير البريد»
/// (the dialog closes first).
Future<AppUser?> showAccountEditor(
  BuildContext context, {
  required AccountEditorMode mode,
  AppUser? initial,
  VoidCallback? onDelete,
  VoidCallback? onChangeEmail,
}) =>
    showDialog<AppUser>(
      context: context,
      builder: (_) => _AccountEditorDialog(
        mode: mode,
        initial: initial ?? const AppUser(email: '', name: ''),
        onDelete: onDelete,
        onChangeEmail: onChangeEmail,
      ),
    );

/// Asks for the correct e-mail of an account.
class _NewEmailDialog extends StatefulWidget {
  const _NewEmailDialog({required this.current});

  final String current;

  @override
  State<_NewEmailDialog> createState() => _NewEmailDialogState();
}

class _NewEmailDialogState extends State<_NewEmailDialog> {
  final _email = TextEditingController();
  bool _invalid = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _submit() {
    final email = ValueParsers.email(_email.text);
    if (email == null) {
      setState(() => _invalid = true);
      return;
    }
    Navigator.pop(context, email);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.accountChangeEmail),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.current, textDirection: TextDirection.ltr, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 12),
          TextField(
            key: const Key('account.newEmail'),
            controller: _email,
            autofocus: true,
            keyboardType: TextInputType.emailAddress,
            textDirection: TextDirection.ltr,
            decoration: InputDecoration(
              labelText: l10n.accountNewEmail,
              prefixIcon: const Icon(Icons.alternate_email),
              errorText: _invalid ? l10n.validationEmail : null,
            ),
            onSubmitted: (_) => _submit(),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
        FilledButton(key: const Key('account.newEmail.ok'), onPressed: _submit, child: Text(l10n.confirm)),
      ],
    );
  }
}

class _AccountEditorDialog extends ConsumerStatefulWidget {
  const _AccountEditorDialog({required this.mode, required this.initial, this.onDelete, this.onChangeEmail});

  final AccountEditorMode mode;
  final AppUser initial;
  final VoidCallback? onDelete;
  final VoidCallback? onChangeEmail;

  @override
  ConsumerState<_AccountEditorDialog> createState() => _AccountEditorDialogState();
}

class _AccountEditorDialogState extends ConsumerState<_AccountEditorDialog> {
  late final _email = TextEditingController(text: widget.initial.email);
  late final _name = TextEditingController(text: widget.initial.name);
  late final _title = TextEditingController(text: widget.initial.title);
  late final _phone = TextEditingController(text: widget.initial.phone);
  late final Set<UserRole> _roles = {...widget.initial.roles};
  late final Set<String> _scopes = {...widget.initial.stageScopes};
  late bool _active = widget.initial.active;
  List<AccountIssue> _issues = const [];

  @override
  void dispose() {
    _email.dispose();
    _name.dispose();
    _title.dispose();
    _phone.dispose();
    super.dispose();
  }

  AppUser get _draft => AccountForm.normalize(AppUser(
        email: _email.text.trim().toLowerCase(),
        name: _name.text,
        title: _title.text,
        phone: _phone.text,
        roles: _roles,
        stageScopes: [..._scopes],
        teachingStages: widget.initial.teachingStages,
        active: _active,
      ));

  void _submit() {
    final draft = _draft;
    final issues = AccountForm.validate(draft);
    if (issues.isNotEmpty) {
      setState(() => _issues = issues);
      return;
    }
    Navigator.pop(context, draft);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final perms = ref.watch(permissionsProvider);
    final isNew = widget.mode != AccountEditorMode.edit;
    // New accounts are never the editor's own; for edits, guard self and admins.
    final canChangeAccess = isNew || perms.canChangeAccessOf(widget.initial);
    String? issue(AccountIssue i, String text) => _issues.contains(i) ? text : null;

    return AlertDialog(
      title: Text(switch (widget.mode) {
        AccountEditorMode.create => l10n.accountEditNew,
        AccountEditorMode.approve => l10n.accountEditApprove,
        AccountEditorMode.edit => l10n.accountEditTitle,
      }),
      scrollable: true,
      content: SizedBox(
        width: 440,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.mode == AccountEditorMode.create) ...[
              TextField(
                key: const Key('account.email'),
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                textDirection: TextDirection.ltr,
                decoration: InputDecoration(
                  labelText: l10n.fieldEmail,
                  prefixIcon: const Icon(Icons.alternate_email),
                  errorText: issue(AccountIssue.invalidEmail, l10n.validationEmail),
                ),
              ),
              const SizedBox(height: 4),
              Text(l10n.accountsAddHint, style: theme.textTheme.bodySmall),
            ] else
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.alternate_email),
                title: Text(widget.initial.email, textDirection: TextDirection.ltr),
                trailing: widget.onChangeEmail == null
                    ? null
                    : TextButton(
                        key: const Key('account.changeEmail'),
                        onPressed: () {
                          Navigator.pop(context);
                          widget.onChangeEmail!();
                        },
                        child: Text(l10n.accountChangeEmail),
                      ),
              ),
            const SizedBox(height: 8),
            TextField(
              key: const Key('account.name'),
              controller: _name,
              decoration: InputDecoration(
                labelText: l10n.fieldName,
                errorText: issue(AccountIssue.nameRequired, l10n.validationRequired),
              ),
            ),
            const SizedBox(height: 8),
            TextField(controller: _title, decoration: InputDecoration(labelText: l10n.fieldTitle)),
            const SizedBox(height: 8),
            TextField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              textDirection: TextDirection.ltr,
              decoration: InputDecoration(labelText: l10n.fieldPhone),
            ),
            const SizedBox(height: 16),
            Text(l10n.accountRoles, style: theme.textTheme.titleSmall),
            if (!canChangeAccess)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(l10n.accountSelfLocked, style: theme.textTheme.bodySmall),
              ),
            for (final role in UserRole.values)
              CheckboxListTile(
                key: Key('account.role.${role.name}'),
                contentPadding: EdgeInsets.zero,
                value: _roles.contains(role),
                title: Text(l10n.role(role)),
                onChanged: canChangeAccess && perms.canGrantRole(role)
                    ? (on) => setState(() => on! ? _roles.add(role) : _roles.remove(role))
                    : null,
              ),
            if (_issues.contains(AccountIssue.noRole))
              Text(l10n.accountIssueRole, style: TextStyle(color: theme.colorScheme.error)),
            if (_roles.contains(UserRole.stageManager)) ...[
              const SizedBox(height: 8),
              Text(l10n.accountStageScopes, style: theme.textTheme.titleSmall),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final s in StageRef.all)
                    FilterChip(
                      key: Key('account.scope.${s.id}'),
                      label: Text(l10n.stage(s)),
                      selected: _scopes.contains(s.id),
                      onSelected: canChangeAccess
                          ? (on) => setState(() => on ? _scopes.add(s.id) : _scopes.remove(s.id))
                          : null,
                    ),
                ],
              ),
              if (_issues.contains(AccountIssue.noStageScope))
                Text(l10n.accountIssueStage, style: TextStyle(color: theme.colorScheme.error)),
            ],
            if (widget.mode == AccountEditorMode.edit)
              SwitchListTile(
                key: const Key('account.active'),
                contentPadding: EdgeInsets.zero,
                value: _active,
                title: Text(l10n.accountActive),
                subtitle: Text(l10n.accountActiveHint),
                onChanged: canChangeAccess ? (on) => setState(() => _active = on) : null,
              ),
          ],
        ),
      ),
      actions: [
        if (widget.onDelete != null)
          TextButton.icon(
            key: const Key('account.delete'),
            style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
            icon: const Icon(Icons.delete_outline),
            label: Text(l10n.accountDelete),
            onPressed: () {
              Navigator.pop(context);
              widget.onDelete!();
            },
          ),
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
        FilledButton(
          key: const Key('account.save'),
          onPressed: _submit,
          child: Text(widget.mode == AccountEditorMode.approve ? l10n.accountsApprove : l10n.save),
        ),
      ],
    );
  }
}
