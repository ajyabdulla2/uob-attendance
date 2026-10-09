import '../../../core/domain/stage_ref.dart';
import '../../auth/domain/app_user.dart';

/// Why the account editor cannot save yet.
enum AccountIssue { invalidEmail, nameRequired, noRole, noStageScope }

/// Validation and clean-up for the account editor (pure, unit-tested).
abstract final class AccountForm {
  static final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  /// Trims the text fields; stage scopes only apply to stage managers and
  /// are kept in canonical stage order.
  static AppUser normalize(AppUser u) => u.copyWith(
        name: u.name.trim(),
        title: u.title.trim(),
        phone: u.phone.trim(),
        stageScopes: u.hasRole(UserRole.stageManager)
            ? [for (final s in StageRef.all) if (u.stageScopes.contains(s.id)) s.id]
            : const [],
      );

  static List<AccountIssue> validate(AppUser u) => [
        if (!_email.hasMatch(u.email)) AccountIssue.invalidEmail,
        if (u.name.trim().isEmpty) AccountIssue.nameRequired,
        if (u.roles.isEmpty) AccountIssue.noRole,
        if (u.hasRole(UserRole.stageManager) && u.stageScopes.isEmpty) AccountIssue.noStageScope,
      ];
}
