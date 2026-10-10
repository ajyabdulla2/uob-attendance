/// «سجلات غير مرفوعة»: a local notification on the phone when attendance
/// saved on it has not reached the server for a day (no connection, or the
/// app was not opened again). Rescheduled after every sync.
abstract final class UnsentReminder {
  static const after = Duration(days: 1);

  /// Notification ID (one reminder at a time).
  static const id = 1;

  /// When to remind, given the oldest write still on the phone; null when
  /// everything was uploaded (cancel).
  static DateTime? at(DateTime? oldestPending, DateTime now) {
    if (oldestPending == null) return null;
    final due = oldestPending.add(after);
    final soonest = now.add(const Duration(minutes: 1));
    return due.isAfter(soonest) ? due : soonest;
  }
}
