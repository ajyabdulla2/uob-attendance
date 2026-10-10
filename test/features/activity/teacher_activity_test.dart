import 'package:flutter_test/flutter_test.dart';
import 'package:uob_attendance/features/activity/domain/teacher_activity.dart';
import 'package:uob_attendance/features/auth/domain/app_user.dart';

void main() {
  final now = DateTime(2026, 10, 10, 12);
  AppUser teacher(String email, String name, {bool active = true}) =>
      AppUser(email: email, name: name, roles: const {UserRole.teacher}, active: active);

  test('levels: today, within 7 days, idle, never', () {
    expect(TeacherActivity.levelOf(null, now), ActivityLevel.never);
    expect(TeacherActivity.levelOf(DateTime(2026, 10, 10, 8), now), ActivityLevel.today);
    expect(TeacherActivity.levelOf(DateTime(2026, 10, 9, 23), now), ActivityLevel.recent);
    expect(TeacherActivity.levelOf(DateTime(2026, 10, 2), now), ActivityLevel.idle);
  });

  test('active teachers only, least active first', () {
    final rows = TeacherActivity.rows(
      [
        teacher('a@x.iq', 'أحمد'),
        teacher('b@x.iq', 'باسم'),
        teacher('c@x.iq', 'جاسم'),
        teacher('d@x.iq', 'دنيا', active: false),
        const AppUser(email: 'admin@x.iq', name: 'مدير', roles: {UserRole.superAdmin}),
        teacher('e@x.iq', 'عمر'),
      ],
      {
        'a@x.iq': Presence(email: 'a@x.iq', lastSeenAt: DateTime(2026, 10, 10, 9)),
        'b@x.iq': Presence(email: 'b@x.iq', lastSeenAt: DateTime(2026, 9, 20)),
        'e@x.iq': Presence(email: 'e@x.iq', lastSeenAt: DateTime(2026, 9, 1)),
      },
      now,
    );
    expect(rows.map((r) => r.user.email), ['c@x.iq', 'e@x.iq', 'b@x.iq', 'a@x.iq']);
    expect(rows.map((r) => r.level), [ActivityLevel.never, ActivityLevel.idle, ActivityLevel.idle, ActivityLevel.today]);
  });

  test('ago', () {
    expect(agoOf(now.subtract(const Duration(seconds: 20)), now).unit, AgoUnit.justNow);
    expect(agoOf(now.subtract(const Duration(minutes: 5)), now), (unit: AgoUnit.minutes, n: 5));
    expect(agoOf(now.subtract(const Duration(hours: 3)), now), (unit: AgoUnit.hours, n: 3));
    expect(agoOf(now.subtract(const Duration(days: 2, hours: 1)), now), (unit: AgoUnit.days, n: 2));
  });
}
