import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/widgets/common_widgets.dart';
import '../../../l10n/l10n.dart';
import '../../auth/application/auth_providers.dart';
import '../application/app_update_providers.dart';
import '../domain/app_update_policy.dart';

/// «إصدار التطبيق» (admins): edits `config/app` — the latest version, its
/// download link and the optional minimum — instead of Firebase Console.
///
/// Icons: only ones already in the 1.4.0 release (Shorebird patches cannot
/// add glyphs, see CLAUDE.md).
class AppReleaseScreen extends ConsumerWidget {
  const AppReleaseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final policy = ref.watch(appPolicyProvider);
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.releaseTitle)),
      body: AsyncBody<AppUpdatePolicy?>(
        value: policy,
        // Keyed on the loaded policy, so the form starts from what is saved.
        data: (p) => _ReleaseForm(key: ValueKey(p?.toMap().toString()), saved: p),
      ),
    );
  }
}

class _ReleaseForm extends ConsumerStatefulWidget {
  const _ReleaseForm({super.key, required this.saved});

  final AppUpdatePolicy? saved;

  @override
  ConsumerState<_ReleaseForm> createState() => _ReleaseFormState();
}

class _ReleaseFormState extends ConsumerState<_ReleaseForm> {
  late final _latest = TextEditingController(text: widget.saved?.latest?.toString() ?? '');
  late final _minimum = TextEditingController(text: widget.saved?.minimum?.toString() ?? '');
  late final _android = TextEditingController(text: widget.saved?.androidUrl ?? '');
  late final _ios = TextEditingController(text: widget.saved?.iosUrl ?? '');
  late final _notes = TextEditingController(text: widget.saved?.notes ?? '');
  bool _busy = false;
  bool _tried = false;

  @override
  void dispose() {
    for (final c in [_latest, _minimum, _android, _ios, _notes]) {
      c.dispose();
    }
    super.dispose();
  }

  List<ReleaseIssue> get _issues => AppUpdatePolicy.check(
        latest: _latest.text,
        minimum: _minimum.text,
        androidUrl: _android.text,
        iosUrl: _ios.text,
      );

  Future<void> _save() async {
    final l10n = context.l10n;
    setState(() => _tried = true);
    if (_issues.isNotEmpty) return;
    final after = AppUpdatePolicy.fromForm(
      latest: _latest.text,
      minimum: _minimum.text,
      androidUrl: _android.text,
      iosUrl: _ios.text,
      notes: _notes.text,
    );
    // Raising the minimum locks older installs out: ask first.
    final newMinimum = after.minimum;
    if (newMinimum != null && newMinimum != widget.saved?.minimum) {
      final ok = await confirmDialog(context,
          title: l10n.releaseConfirmTitle,
          body: l10n.releaseConfirmBody('$newMinimum'),
          confirmLabel: l10n.save,
          destructive: true);
      if (!ok || !mounted) return;
    }
    setState(() => _busy = true);
    try {
      await ref
          .read(configRepositoryProvider)
          .saveAppPolicy(widget.saved, after, actor: ref.read(signedInUserProvider).id);
      if (mounted) showSnack(context, l10n.releaseSaved);
    } on Object catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final issues = _tried ? _issues : const <ReleaseIssue>[];
    final installed = ref.watch(installedVersionProvider).value;
    final latest = AppVersion.tryParse(_latest.text);
    final minimum = AppVersion.tryParse(_minimum.text);

    String? versionError(ReleaseIssue invalid) => issues.contains(invalid) ? l10n.releaseVersionInvalid : null;
    InputDecoration url(String label) => InputDecoration(
          labelText: label,
          errorText: issues.contains(ReleaseIssue.urlInvalid) ? l10n.releaseUrlInvalid : null,
        );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(l10n.releaseHelp, style: theme.textTheme.bodySmall),
        if (installed != null) ...[
          const SizedBox(height: 8),
          Text(l10n.releaseInstalled(bidiIsolate('$installed')), style: theme.textTheme.bodySmall),
        ],
        const SizedBox(height: 12),
        TextField(
          key: const Key('release.latest'),
          controller: _latest,
          textDirection: TextDirection.ltr,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            labelText: l10n.releaseLatest,
            errorText: issues.contains(ReleaseIssue.latestMissing)
                ? l10n.releaseLatestMissing
                : versionError(ReleaseIssue.latestInvalid),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          key: const Key('release.android'),
          controller: _android,
          textDirection: TextDirection.ltr,
          keyboardType: TextInputType.url,
          onChanged: (_) => setState(() {}),
          decoration: url(l10n.releaseAndroidUrl).copyWith(helperText: l10n.releaseUrlHelp, helperMaxLines: 3),
        ),
        if (_android.text.trim().startsWith('https://'))
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              icon: const Icon(Icons.link),
              label: Text(l10n.releaseOpenLink),
              onPressed: () =>
                  launchUrl(Uri.parse(_android.text.trim()), mode: LaunchMode.externalApplication).catchError((_) => false),
            ),
          ),
        const SizedBox(height: 8),
        TextField(
          key: const Key('release.notes'),
          controller: _notes,
          minLines: 2,
          maxLines: 5,
          maxLength: 500,
          decoration: InputDecoration(labelText: l10n.releaseNotes),
        ),
        TextField(
          key: const Key('release.minimum'),
          controller: _minimum,
          textDirection: TextDirection.ltr,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            labelText: l10n.releaseMinimum,
            helperText: l10n.releaseMinimumHelp,
            helperMaxLines: 3,
            errorText: issues.contains(ReleaseIssue.minimumAboveLatest)
                ? l10n.releaseMinimumAboveLatest
                : versionError(ReleaseIssue.minimumInvalid),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          key: const Key('release.ios'),
          controller: _ios,
          textDirection: TextDirection.ltr,
          keyboardType: TextInputType.url,
          onChanged: (_) => setState(() {}),
          decoration: url(l10n.releaseIosUrl),
        ),
        const SizedBox(height: 16),
        if (latest != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text([
                l10n.releasePreview(bidiIsolate('$latest')),
                if (minimum != null) l10n.releasePreviewRequired(bidiIsolate('$minimum')),
              ].join('\n')),
            ),
          ),
        const SizedBox(height: 8),
        FilledButton.icon(
          key: const Key('release.save'),
          icon: const Icon(Icons.save),
          label: Text(l10n.save),
          onPressed: _busy ? null : _save,
        ),
      ],
    );
  }
}
