import 'package:flutter_test/flutter_test.dart';
import 'package:uob_attendance/features/auth/domain/app_user.dart';
import 'package:uob_attendance/features/auth/domain/permissions.dart';
import 'package:uob_attendance/features/home/domain/admin_menu.dart';

void main() {
  Permissions perms(Set<UserRole> roles, {bool active = true}) => Permissions(AppUser(
        email: 'x@uob.iq',
        name: 'س',
        roles: roles,
        active: active,
        stageScopes: const ['1-morning'],
      ));

  Map<AdminGroup, List<AdminTool>> menu(Permissions p) => {for (final s in AdminMenu.of(p)) s.group: s.tools};

  test('a plain teacher has no tools (the home screen is their courses)', () {
    expect(AdminMenu.of(perms({UserRole.teacher})), isEmpty);
    expect(AdminMenu.of(perms({UserRole.superAdmin}, active: false)), isEmpty);
  });

  test('a stage manager sees only their tools, grouped and in order', () {
    expect(menu(perms({UserRole.stageManager, UserRole.teacher})), {
      AdminGroup.daily: [AdminTool.stageDashboard, AdminTool.editRequests],
      AdminGroup.students: [AdminTool.warnings, AdminTool.leaves],
      AdminGroup.data: [AdminTool.import, AdminTool.assignments],
      AdminGroup.system: [AdminTool.auditLog],
    });
  });

  test('the super admin sees every tool exactly once, in the five groups', () {
    final sections = AdminMenu.of(perms({UserRole.superAdmin}));
    expect(sections.map((s) => s.group), AdminGroup.values);
    final tools = [for (final s in sections) ...s.tools];
    expect(tools.toSet(), AdminTool.values.toSet());
    expect(tools, hasLength(AdminTool.values.length));
  });

  test('the deputy admin sees every tool, «متابعة التدريسيين» included', () {
    final tools = [for (final s in AdminMenu.of(perms({UserRole.deputyAdmin}))) ...s.tools];
    expect(tools.toSet(), AdminTool.values.toSet());
  });

  test('the super admin may open every tool', () {
    final all = Permissions(const AppUser(email: 'a@uob.iq', name: 'م', roles: {UserRole.superAdmin}));
    for (final t in AdminTool.values) {
      expect(AdminMenu.allows(all, t), isTrue, reason: '$t');
    }
  });
}
