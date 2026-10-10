import '../../../core/config/app_config.dart';
import '../../../core/firebase/firestore_converters.dart';
import '../../auth/domain/app_user.dart';

/// `presence/{email}`: written by each account's own app — when it was last
/// opened (at most every [Presence.seenEvery]) and when it last uploaded
/// attendance. Read by the super admin only («متابعة التدريسيين»).
final class Presence {
  const Presence({
    required this.email,
    this.lastSeenAt,
    this.lastUploadAt,
    this.platform = '',
    this.appVersion = '',
  });

  /// How often an open app refreshes [lastSeenAt] (the Spark write quota).
  static const seenEvery = Duration(minutes: 30);

  final String email;
  final DateTime? lastSeenAt;
  final DateTime? lastUploadAt;

  /// `android`, `iOS`, `web`…
  final String platform;
  final String appVersion;

  factory Presence.fromMap(String email, Map<String, Object?> map) => Presence(
        email: email,
        lastSeenAt: Fs.date(map['lastSeenAt']),
        lastUploadAt: Fs.date(map['lastUploadAt']),
        platform: Fs.str(map['platform']),
        appVersion: Fs.str(map['appVersion']),
      );

  /// The fields of a «seen» write (the times are server timestamps).
  static Map<String, Object?> seenFields({required String platform, required String appVersion}) => {
        'platform': platform,
        'appVersion': appVersion,
        'departmentId': AppConfig.departmentId,
      };
}

/// How recently a teacher used the app.
enum ActivityLevel {
  /// Never opened this version of the app (no presence yet).
  never,

  /// Not for more than [TeacherActivity.idleAfter].
  idle,

  /// Within [TeacherActivity.idleAfter].
  recent,

  /// Since the start of today.
  today,
}

/// One row of «متابعة التدريسيين».
final class TeacherActivity {
  const TeacherActivity({required this.user, this.presence, required this.level});

  static const idleAfter = Duration(days: 7);

  final AppUser user;
  final Presence? presence;
  final ActivityLevel level;

  DateTime? get lastSeenAt => presence?.lastSeenAt;
  DateTime? get lastUploadAt => presence?.lastUploadAt;

  static ActivityLevel levelOf(DateTime? seen, DateTime now) {
    if (seen == null) return ActivityLevel.never;
    final local = seen.toLocal();
    final today = DateTime(now.year, now.month, now.day);
    if (!local.isBefore(today)) return ActivityLevel.today;
    return now.difference(seen) > idleAfter ? ActivityLevel.idle : ActivityLevel.recent;
  }

  /// Active accounts that teach, least active first (never, then the
  /// longest idle), then by name.
  static List<TeacherActivity> rows(Iterable<AppUser> users, Map<String, Presence> presence, DateTime now) {
    final out = [
      for (final u in users)
        if (u.active && u.hasRole(UserRole.teacher))
          TeacherActivity(user: u, presence: presence[u.id], level: levelOf(presence[u.id]?.lastSeenAt, now)),
    ];
    out.sort((a, b) {
      final byLevel = a.level.index.compareTo(b.level.index);
      if (byLevel != 0) return byLevel;
      final sa = a.lastSeenAt, sb = b.lastSeenAt;
      if (sa != null && sb != null && sa != sb) return sa.compareTo(sb);
      return a.user.name.compareTo(b.user.name);
    });
    return out;
  }
}

/// «منذ 3 ساعات»: the largest whole unit between [at] and [now].
enum AgoUnit { justNow, minutes, hours, days }

({AgoUnit unit, int n}) agoOf(DateTime at, DateTime now) {
  final d = now.difference(at);
  if (d.inMinutes < 1) return (unit: AgoUnit.justNow, n: 0);
  if (d.inHours < 1) return (unit: AgoUnit.minutes, n: d.inMinutes);
  if (d.inDays < 1) return (unit: AgoUnit.hours, n: d.inHours);
  return (unit: AgoUnit.days, n: d.inDays);
}
