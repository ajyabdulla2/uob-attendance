import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/activity_providers.dart';

/// Reports «last seen» when the app opens and when it comes back to the
/// foreground (throttled in [reportSeen]). On every platform, around the
/// signed-in shell.
class PresenceReporter extends ConsumerStatefulWidget {
  const PresenceReporter({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<PresenceReporter> createState() => _PresenceReporterState();
}

class _PresenceReporterState extends ConsumerState<PresenceReporter> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.microtask(_report);
  }

  void _report() {
    if (mounted) unawaited(ref.read(presenceReporterProvider)());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _report();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
