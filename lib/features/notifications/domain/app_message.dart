import '../../../core/config/app_config.dart';
import '../../../core/firebase/firestore_converters.dart';
import '../../auth/domain/app_user.dart';

enum MessageAudience {
  all,
  teachers,
  stageManagers,
  stage,

  /// One person (`inbox/{to}/items`), from the super admin.
  person;

  /// What «رسالة جديدة» offers (a personal message is sent from
  /// «متابعة التدريسيين»).
  static const broadcast = [all, teachers, stageManagers, stage];
}

/// `messages/{id}` — رسالة من الإدارة (or a stage manager to their stage).
final class AppMessage {
  const AppMessage({
    required this.id,
    required this.title,
    required this.body,
    required this.audience,
    required this.createdBy,
    this.stageId,
    this.to,
    this.createdAt,
    this.departmentId = AppConfig.departmentId,
  });

  final String id;
  final String title;
  final String body;
  final MessageAudience audience;
  final String? stageId;

  /// The recipient of a [MessageAudience.person] message.
  final String? to;
  final String createdBy;
  final DateTime? createdAt;
  final String departmentId;

  /// Whether [user] should see it (everyone may read; the app filters).
  /// Admins and the sender see every message.
  bool isFor(AppUser user) {
    if (user.hasRole(UserRole.superAdmin) || user.hasRole(UserRole.deputyAdmin) || createdBy == user.id) return true;
    return switch (audience) {
      MessageAudience.all => true,
      MessageAudience.teachers => user.hasRole(UserRole.teacher),
      MessageAudience.stageManagers => user.hasRole(UserRole.stageManager),
      MessageAudience.stage => stageId != null && (user.stageScopes.contains(stageId) || user.teachingStages.contains(stageId)),
      MessageAudience.person => to == user.id,
    };
  }

  /// An `inbox/{to}/items/{id}` document.
  factory AppMessage.personal(String id, String to, Map<String, Object?> map) => AppMessage(
        id: id,
        title: Fs.str(map['title']),
        body: Fs.str(map['body']),
        audience: MessageAudience.person,
        to: to,
        createdBy: Fs.str(map['createdBy']),
        createdAt: Fs.date(map['createdAt']),
        departmentId: Fs.str(map['departmentId'], AppConfig.departmentId),
      );

  factory AppMessage.fromMap(String id, Map<String, Object?> map) => AppMessage(
        id: id,
        title: Fs.str(map['title']),
        body: Fs.str(map['body']),
        audience: Fs.enumByName(MessageAudience.values, map['audience'], MessageAudience.all),
        stageId: Fs.strOrNull(map['stageId']),
        createdBy: Fs.str(map['createdBy']),
        createdAt: Fs.date(map['createdAt']),
        departmentId: Fs.str(map['departmentId'], AppConfig.departmentId),
      );

  /// A broadcast `messages/{id}`; a personal one has no audience field.
  Map<String, Object?> toMap() => {
        'title': title.trim(),
        'body': body.trim(),
        if (audience != MessageAudience.person) 'audience': audience.name,
        if (audience == MessageAudience.stage) 'stageId': stageId,
        'createdBy': createdBy,
        'departmentId': departmentId,
      };
}
