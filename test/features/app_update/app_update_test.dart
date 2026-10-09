import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uob_attendance/features/app_update/data/config_repository.dart';
import 'package:uob_attendance/features/app_update/domain/app_update_policy.dart';

void main() {
  group('AppVersion', () {
    test('parses common forms and ignores the build number', () {
      expect(AppVersion.tryParse('1.2.3'), const AppVersion(1, 2, 3));
      expect(AppVersion.tryParse('1.2.3+45'), const AppVersion(1, 2, 3));
      expect(AppVersion.tryParse('v1.2'), const AppVersion(1, 2, 0));
      expect(AppVersion.tryParse(' 2.0.10 '), const AppVersion(2, 0, 10));
      for (final bad in [null, '', '1', 'a.b.c', '1.2.3.4']) {
        expect(AppVersion.tryParse(bad), isNull, reason: '$bad');
      }
    });

    test('compares numerically, not as text', () {
      expect(const AppVersion(1, 10, 0) > const AppVersion(1, 9, 9), isTrue);
      expect(const AppVersion(1, 2, 3) < const AppVersion(1, 2, 4), isTrue);
      expect(const AppVersion(2, 0) < const AppVersion(1, 99, 99), isFalse);
      expect(const AppVersion(1, 0).toString(), '1.0.0');
    });
  });

  group('AppUpdatePolicy.evaluate', () {
    const policy = AppUpdatePolicy(
      latest: AppVersion(1, 3, 0),
      minimum: AppVersion(1, 1, 0),
      androidUrl: 'https://example.org/a.apk',
      iosUrl: 'https://testflight.apple.com/x',
    );

    test('below minimum → required; below latest → optional; else none', () {
      expect(policy.evaluate(const AppVersion(1, 0, 9)), UpdateUrgency.required);
      expect(policy.evaluate(const AppVersion(1, 2, 0)), UpdateUrgency.optional);
      expect(policy.evaluate(const AppVersion(1, 3, 0)), UpdateUrgency.none);
      expect(policy.evaluate(const AppVersion(1, 4, 0)), UpdateUrgency.none);
      expect(const AppUpdatePolicy().evaluate(const AppVersion(0, 1)), UpdateUrgency.none);
    });

    test('platform links and Firestore round-trip', () {
      expect(policy.downloadUrl(ios: false), 'https://example.org/a.apk');
      expect(policy.downloadUrl(ios: true), 'https://testflight.apple.com/x');
      final back = AppUpdatePolicy.fromMap(policy.toMap());
      expect(back.latest, policy.latest);
      expect(back.minimum, policy.minimum);
      expect(AppUpdatePolicy.fromMap(const {'latestVersion': 'garbage'}).latest, isNull);
    });
  });

  test('ConfigRepository watches config/app', () async {
    final db = FakeFirebaseFirestore();
    final repo = ConfigRepository(db);
    expect(await repo.watchAppPolicy().first, isNull);
    await db.doc('config/app').set({'latestVersion': '1.5.0'});
    expect((await repo.watchAppPolicy().first)!.latest, const AppVersion(1, 5, 0));
  });
}

extension on AppVersion {
  bool operator >(AppVersion other) => compareTo(other) > 0;
}
