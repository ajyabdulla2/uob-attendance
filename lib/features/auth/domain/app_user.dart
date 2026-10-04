import '../../../core/config/app_config.dart';
import '../../../core/firebase/doc_ids.dart';
import '../../../core/firebase/firestore_converters.dart';

/// The four permission levels from the SPEC. One account may combine an
/// administrative role with [teacher].
enum UserRole { superAdmin, deputyAdmin, stageManager, teacher }

/// A document in `users/{email}` — both the account's roles and the
/// teacher's profile (SPEC: «التدريسيون: الاسم، اللقب العلمي، البريد، الهاتف»).
final class AppUser {
  const AppUser({
    required this.email,
    required this.name,
    this.title = '',
    this.phone = '',
    this.roles = const {UserRole.teacher},
    this.stageScopes = const [],
    this.teachingStages = const [],
    this.active = true,
    this.departmentId = AppConfig.departmentId,
  });

  /// Lower-cased e-mail; also the document ID.
  final String email;
  final String name;

  /// اللقب العلمي (e.g. مدرس، أستاذ مساعد).
  final String title;
  final String phone;
  final Set<UserRole> roles;

  /// Stages this account manages as a stage manager (e.g. `3-morning`).
  final List<String> stageScopes;

  /// Stages this teacher has assignments in (maintained with assignments).
  final List<String> teachingStages;

  /// Suspended accounts (`active == false`) cannot access any data.
  final bool active;
  final String departmentId;

  String get id => DocIds.user(email);

  bool hasRole(UserRole role) => roles.contains(role);

  /// «أ.م.د. فلان» style display name.
  String get displayName => title.isEmpty ? name : '$title $name';

  factory AppUser.fromMap(String id, Map<String, Object?> map) => AppUser(
        email: Fs.str(map['email'], id),
        name: Fs.str(map['name']),
        title: Fs.str(map['title']),
        phone: Fs.str(map['phone']),
        roles: {
          for (final r in Fs.strings(map['roles'])) ?UserRole.values.asNameMap()[r],
        },
        stageScopes: Fs.strings(map['stageScopes']),
        teachingStages: Fs.strings(map['teachingStages']),
        active: Fs.boolean(map['active']),
        departmentId: Fs.str(map['departmentId'], AppConfig.departmentId),
      );

  Map<String, Object?> toMap() => {
        'email': id,
        'name': name,
        'title': title,
        'phone': phone,
        'roles': [for (final r in UserRole.values) if (roles.contains(r)) r.name],
        'stageScopes': stageScopes,
        'teachingStages': teachingStages,
        'active': active,
        'departmentId': departmentId,
      };

  AppUser copyWith({
    String? name,
    String? title,
    String? phone,
    Set<UserRole>? roles,
    List<String>? stageScopes,
    List<String>? teachingStages,
    bool? active,
  }) =>
      AppUser(
        email: email,
        name: name ?? this.name,
        title: title ?? this.title,
        phone: phone ?? this.phone,
        roles: roles ?? this.roles,
        stageScopes: stageScopes ?? this.stageScopes,
        teachingStages: teachingStages ?? this.teachingStages,
        active: active ?? this.active,
        departmentId: departmentId,
      );
}
