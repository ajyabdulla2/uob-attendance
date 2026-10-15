import '../../auth/domain/permissions.dart';

/// The management tools on the home screen, grouped by what they are for
/// (طلب القسم: one long mixed list was hard to find one's way in).
enum AdminGroup { daily, students, data, communication, system }

enum AdminTool {
  departmentDashboard,
  stageDashboard,
  editRequests,
  teacherActivity,
  coursePanel,
  warnings,
  leaves,
  import,
  assignments,
  accounts,
  dataFix,
  announcements,
  yearSettings,
  backup,
  auditLog,
  appRelease,
}

/// One titled row of tiles.
class AdminSection {
  const AdminSection(this.group, this.tools);

  final AdminGroup group;
  final List<AdminTool> tools;
}

abstract final class AdminMenu {
  static const _layout = <AdminGroup, List<AdminTool>>{
    AdminGroup.daily: [
      AdminTool.departmentDashboard,
      AdminTool.stageDashboard,
      AdminTool.editRequests,
      AdminTool.teacherActivity,
      AdminTool.coursePanel,
    ],
    AdminGroup.students: [AdminTool.warnings, AdminTool.leaves],
    AdminGroup.data: [AdminTool.import, AdminTool.assignments, AdminTool.accounts, AdminTool.dataFix],
    AdminGroup.communication: [AdminTool.announcements],
    AdminGroup.system: [AdminTool.yearSettings, AdminTool.backup, AdminTool.auditLog, AdminTool.appRelease],
  };

  static bool allows(Permissions p, AdminTool tool) => switch (tool) {
    AdminTool.departmentDashboard => p.canViewDepartmentDashboard,
    AdminTool.stageDashboard => p.canViewStageDashboard,
    AdminTool.editRequests => p.canReviewEditRequests,
    AdminTool.teacherActivity => p.canMonitorTeachers,
    AdminTool.coursePanel => p.canViewCoursePanel,
    AdminTool.warnings => p.canViewWarnings,
    AdminTool.leaves => p.canManageLeaves,
    AdminTool.import => p.canImportAnything,
    AdminTool.assignments => p.canManageAssignments,
    AdminTool.accounts => p.canManageAccounts,
    AdminTool.dataFix => p.canFixData,
    AdminTool.announcements => p.canManageAnnouncements,
    AdminTool.yearSettings => p.canEditYear,
    AdminTool.backup => p.canBackup,
    AdminTool.auditLog => p.canViewAuditLog,
    AdminTool.appRelease => p.canManageAppRelease,
  };

  /// The sections this account sees, in order; empty groups are left out.
  /// An empty list = a plain teacher (the home screen shows their courses).
  static List<AdminSection> of(Permissions p) => [
    for (final MapEntry(key: group, value: tools) in _layout.entries)
      if (tools.where((t) => allows(p, t)).toList() case final shown when shown.isNotEmpty) AdminSection(group, shown),
  ];
}
