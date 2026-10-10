import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../application/push_providers.dart';

/// Around the signed-in shell: registers the phone for notifications (asks
/// the permission once) and opens «الإشعارات» when one is tapped.
class PushLifecycle extends ConsumerStatefulWidget {
  const PushLifecycle({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<PushLifecycle> createState() => _PushLifecycleState();
}

class _PushLifecycleState extends ConsumerState<PushLifecycle> {
  StreamSubscription<void>? _opened;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      unawaited(ref.read(pushActionsProvider).register());
      _opened = ref.read(deviceNotificationsProvider).opened.listen((_) {
        if (mounted) GoRouter.of(context).push(Routes.notifications);
      });
    });
  }

  @override
  void dispose() {
    _opened?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(tokenRefreshProvider);
    return widget.child;
  }
}
