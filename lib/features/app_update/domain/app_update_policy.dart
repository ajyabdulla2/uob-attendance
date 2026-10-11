import '../../../core/firebase/firestore_converters.dart';

/// `major.minor.patch` (the build number after `+` is ignored).
final class AppVersion implements Comparable<AppVersion> {
  const AppVersion(this.major, this.minor, [this.patch = 0]);

  final int major;
  final int minor;
  final int patch;

  static final _pattern = RegExp(r'^v?(\d+)\.(\d+)(?:\.(\d+))?(?:[+-].*)?$');

  /// Parses "1.2.3", "1.2.3+45", "v1.2" …; null when malformed.
  static AppVersion? tryParse(String? raw) {
    final m = _pattern.firstMatch(raw?.trim() ?? '');
    if (m == null) return null;
    return AppVersion(int.parse(m[1]!), int.parse(m[2]!), int.parse(m[3] ?? '0'));
  }

  @override
  int compareTo(AppVersion other) => major != other.major
      ? major.compareTo(other.major)
      : minor != other.minor
          ? minor.compareTo(other.minor)
          : patch.compareTo(other.patch);

  bool operator <(AppVersion other) => compareTo(other) < 0;

  @override
  bool operator ==(Object other) => other is AppVersion && compareTo(other) == 0;

  @override
  int get hashCode => Object.hash(major, minor, patch);

  @override
  String toString() => '$major.$minor.$patch';
}

enum UpdateUrgency { none, optional, required }

/// What «إصدار التطبيق» refuses to save.
enum ReleaseIssue { latestMissing, latestInvalid, minimumInvalid, minimumAboveLatest, urlInvalid }

/// `config/app` — set by an admin after publishing a new build that needs
/// installing (native changes; pure Dart changes may arrive as OTA patches).
final class AppUpdatePolicy {
  const AppUpdatePolicy({this.latest, this.minimum, this.androidUrl, this.iosUrl, this.notes = ''});

  /// Newest published version: older installs see «إصدار جديد متاح».
  final AppVersion? latest;

  /// Oldest version still allowed to work (e.g. after an incompatible
  /// change to the rules or data): older installs must update.
  final AppVersion? minimum;
  final String? androidUrl;
  final String? iosUrl;
  final String notes;

  factory AppUpdatePolicy.fromMap(Map<String, Object?> map) => AppUpdatePolicy(
        latest: AppVersion.tryParse(Fs.strOrNull(map['latestVersion'])),
        minimum: AppVersion.tryParse(Fs.strOrNull(map['minVersion'])),
        androidUrl: Fs.strOrNull(map['androidUrl']),
        iosUrl: Fs.strOrNull(map['iosUrl']),
        notes: Fs.str(map['notes']),
      );

  Map<String, Object?> toMap() => {
        'latestVersion': latest?.toString(),
        'minVersion': minimum?.toString(),
        'androidUrl': androidUrl,
        'iosUrl': iosUrl,
        'notes': notes,
      };

  UpdateUrgency evaluate(AppVersion current) {
    if (minimum != null && current < minimum!) return UpdateUrgency.required;
    if (latest != null && current < latest!) return UpdateUrgency.optional;
    return UpdateUrgency.none;
  }

  String? downloadUrl({required bool ios}) => ios ? iosUrl : androidUrl;

  /// Checks the «إصدار التطبيق» form: a valid latest version, an optional
  /// minimum not above it, and https download links (or none).
  static List<ReleaseIssue> check({
    required String latest,
    String minimum = '',
    String androidUrl = '',
    String iosUrl = '',
  }) {
    final l = AppVersion.tryParse(latest);
    final m = AppVersion.tryParse(minimum);
    bool badUrl(String u) {
      if (u.trim().isEmpty) return false;
      final uri = Uri.tryParse(u.trim());
      return uri == null || uri.scheme != 'https' || uri.host.isEmpty;
    }

    return [
      if (latest.trim().isEmpty) ReleaseIssue.latestMissing else if (l == null) ReleaseIssue.latestInvalid,
      if (minimum.trim().isNotEmpty && m == null) ReleaseIssue.minimumInvalid,
      if (l != null && m != null && l < m) ReleaseIssue.minimumAboveLatest,
      if (badUrl(androidUrl) || badUrl(iosUrl)) ReleaseIssue.urlInvalid,
    ];
  }

  /// The policy the form describes (call after [check] passes).
  factory AppUpdatePolicy.fromForm({
    required String latest,
    String minimum = '',
    String androidUrl = '',
    String iosUrl = '',
    String notes = '',
  }) {
    String? orNull(String v) => v.trim().isEmpty ? null : v.trim();
    return AppUpdatePolicy(
      latest: AppVersion.tryParse(latest),
      minimum: AppVersion.tryParse(minimum),
      androidUrl: orNull(androidUrl),
      iosUrl: orNull(iosUrl),
      notes: notes.trim(),
    );
  }
}
