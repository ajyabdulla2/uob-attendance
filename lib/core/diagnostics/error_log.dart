import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';

/// One error the user saw (or that escaped to the framework).
final class ErrorEntry {
  const ErrorEntry({required this.at, required this.where, required this.error, required this.stack});

  final DateTime at;
  final String where;
  final String error;
  final String stack;
}

/// The last errors of this run, kept so a user can copy a report and send
/// it to the developer («التفاصيل» / «سجل الأخطاء»). Nothing leaves the
/// phone by itself.
abstract final class ErrorLog {
  static const max = 30;
  static final entries = <ErrorEntry>[];

  /// «account · version» — set by the signed-in shell.
  static String context = '';

  /// Current route — set by the router.
  static String Function()? route;

  static ErrorEntry record(Object error, [StackTrace? stack, String? where]) {
    String here = where ?? '';
    if (here.isEmpty) {
      try {
        here = route?.call() ?? '';
      } on Object {
        here = '';
      }
    }
    final entry = ErrorEntry(
      at: DateTime.now(),
      where: here,
      error: describe(error),
      stack: (stack?.toString() ?? '').split('\n').where((l) => l.trim().isNotEmpty).take(12).join('\n'),
    );
    entries.add(entry);
    if (entries.length > max) entries.removeAt(0);
    return entry;
  }

  /// The useful part of an error: Firebase / platform codes and messages.
  static String describe(Object error) => switch (error) {
        FirebaseException e => '[${e.plugin}/${e.code}] ${e.message ?? ''}',
        PlatformException e => 'PlatformException(${e.code}) ${e.message ?? ''} ${e.details ?? ''}'.trim(),
        _ => '$error',
      };

  static String report(ErrorEntry e) => [
        'UoB Attendance — error report',
        'time: ${e.at.toIso8601String().substring(0, 19)}',
        if (context.isNotEmpty) context,
        if (e.where.isNotEmpty) 'screen: ${e.where}',
        'error: ${e.error}',
        if (e.stack.isNotEmpty) 'stack:\n${e.stack}',
      ].join('\n');

  static String reportAll() =>
      entries.isEmpty ? '' : entries.reversed.map(report).join('\n\n——————\n\n');
}
