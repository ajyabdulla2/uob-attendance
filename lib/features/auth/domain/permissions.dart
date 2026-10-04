import '../../../core/domain/stage_ref.dart';
import 'app_user.dart';

/// Client-side mirror of the permission matrix in SPEC «الأدوار والصلاحيات».
///
/// Used only to show/hide UI. The real enforcement lives in
/// `firestore.rules`; keep the two consistent.
final class Permissions {
  const Permissions(this.user);

  final AppUser user;

  bool get _active => user.active;

  bool get isSuperAdmin => _active && user.hasRole(UserRole.superAdmin);
  bool get isDeputyAdmin => _active && user.hasRole(UserRole.deputyAdmin);
  bool get isAdmin => isSuperAdmin || isDeputyAdmin;
  bool get isStageManager => _active && user.hasRole(UserRole.stageManager);
  bool get isTeacher => _active && user.hasRole(UserRole.teacher);

  /// Every role records attendance for its own courses.
  bool get canRecordAttendance => _active;

  bool canManageStage(String stageId) =>
      isAdmin || (isStageManager && user.stageScopes.contains(stageId));

  /// Stages this account can manage, in canonical order.
  List<StageRef> get manageableStages => [
        for (final s in StageRef.all)
          if (canManageStage(s.id)) s,
      ];

  // ------------------------------------------------------------- import --
  bool get canImportStudents => isAdmin || isStageManager;
  bool canImportStudentsInto(String stageId) => canManageStage(stageId);
  bool get canImportTeachers => isAdmin;
  bool get canImportCourses => isAdmin;
  bool get canImportAnything => canImportStudents || canImportTeachers || canImportCourses;

  // -------------------------------------------------------------- links --
  bool get canManageAssignments => isAdmin || isStageManager;

  // -------------------------------------------------------- accounts ----
  bool get canManageAccounts => isAdmin;

  /// Deputy admins never grant (or edit holders of) an admin role.
  bool canGrantRole(UserRole role) => switch (role) {
        UserRole.superAdmin || UserRole.deputyAdmin => isSuperAdmin,
        UserRole.stageManager || UserRole.teacher => isAdmin,
      };

  bool canEditAccount(AppUser target) {
    if (isSuperAdmin) return true;
    if (!isDeputyAdmin) return false;
    return !target.hasRole(UserRole.superAdmin) && !target.hasRole(UserRole.deputyAdmin);
  }

  // ------------------------------------------------------------- backup --
  bool get canBackup => isAdmin;
  bool get canRestore => isSuperAdmin;

  // ---------------------------------------------------- decision lists --
  bool get canFinalizeDeaneryDecision => isAdmin;
}
