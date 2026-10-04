import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/widgets/common_widgets.dart';
import '../../../l10n/l10n.dart';
import '../application/app_update_providers.dart';
import '../domain/app_update_policy.dart';

/// Wraps the signed-in area: shows «إصدار جديد متاح» above the content, or a
/// blocking screen when the installed build is older than `config/app.minVersion`.
class UpdateGate extends ConsumerWidget {
  const UpdateGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final update = ref.watch(appUpdateProvider);
    if (update == null) return child;
    if (update.urgency == UpdateUrgency.required) return _UpdateRequiredView(update: update);
    if (ref.watch(updateBannerDismissedProvider)) return child;
    return Column(
      children: [
        _UpdateBanner(update: update),
        // The banner already consumed the status-bar inset.
        Expanded(child: MediaQuery.removePadding(context: context, removeTop: true, child: child)),
      ],
    );
  }
}

Future<void> _openDownload(BuildContext context, String? url) async {
  final l10n = context.l10n;
  if (url == null) {
    showSnack(context, l10n.updateNoLink);
    return;
  }
  final ok = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication).catchError((_) => false);
  if (!ok && context.mounted) showSnack(context, l10n.updateOpenFailed(bidiIsolate(url)));
}

class _UpdateBanner extends ConsumerWidget {
  const _UpdateBanner({required this.update});

  final AppUpdateState update;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return Material(
      key: const Key('update.banner'),
      color: scheme.secondaryContainer,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 8, 8),
          child: Row(
            children: [
              Icon(Icons.system_update, color: scheme.onSecondaryContainer),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.updateAvailable(bidiIsolate('${update.latest ?? ''}')),
                      style: TextStyle(color: scheme.onSecondaryContainer, fontWeight: FontWeight.w600),
                    ),
                    if (update.notes.isNotEmpty)
                      Text(update.notes, style: TextStyle(color: scheme.onSecondaryContainer)),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => ref.read(updateBannerDismissedProvider.notifier).dismiss(),
                child: Text(l10n.updateLater),
              ),
              FilledButton(
                onPressed: () => _openDownload(context, update.url),
                child: Text(l10n.updateDownload),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UpdateRequiredView extends StatelessWidget {
  const _UpdateRequiredView({required this.update});

  final AppUpdateState update;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      key: const Key('update.required'),
      body: CenteredBody(
        child: MessageView(
          icon: Icons.system_update,
          title: l10n.updateRequiredTitle,
          body: [
            l10n.updateRequiredBody(bidiIsolate('${update.installed}')),
            if (update.notes.isNotEmpty) update.notes,
          ].join('\n\n'),
          actions: [
            FilledButton.icon(
              onPressed: () => _openDownload(context, update.url),
              icon: const Icon(Icons.download),
              label: Text(l10n.updateDownload),
            ),
          ],
        ),
      ),
    );
  }
}
