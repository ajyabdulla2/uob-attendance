import 'package:flutter_test/flutter_test.dart';
import 'package:uob_attendance/features/app_update/domain/app_update_policy.dart';

void main() {
  group('«إصدار التطبيق» form', () {
    test('accepts a version, an optional lower minimum and https links', () {
      expect(AppUpdatePolicy.check(latest: '1.4.0', androidUrl: 'https://drive.google.com/uc?id=x'), isEmpty);
      expect(AppUpdatePolicy.check(latest: '1.4.0', minimum: '1.3.0'), isEmpty);
      expect(AppUpdatePolicy.check(latest: '1.4.0', minimum: '1.4.0'), isEmpty);
      expect(AppUpdatePolicy.check(latest: '1.4'), isEmpty, reason: 'the patch part is optional');
    });

    test('refuses what would break the banner or lock everyone out', () {
      expect(AppUpdatePolicy.check(latest: ''), [ReleaseIssue.latestMissing]);
      expect(AppUpdatePolicy.check(latest: 'جديد'), [ReleaseIssue.latestInvalid]);
      expect(AppUpdatePolicy.check(latest: '1.4.0', minimum: 'x'), [ReleaseIssue.minimumInvalid]);
      expect(AppUpdatePolicy.check(latest: '1.4.0', minimum: '1.5.0'), [ReleaseIssue.minimumAboveLatest]);
      expect(AppUpdatePolicy.check(latest: '1.4.0', androidUrl: 'http://example.com/a.apk'), [ReleaseIssue.urlInvalid]);
      expect(AppUpdatePolicy.check(latest: '1.4.0', iosUrl: 'drive.google.com/x'), [ReleaseIssue.urlInvalid]);
    });

    test('empty fields become null, text is trimmed', () {
      final p = AppUpdatePolicy.fromForm(latest: ' 1.4.0 ', androidUrl: ' https://x.y/a ', notes: ' جديد ');
      expect(p.toMap(), {
        'latestVersion': '1.4.0',
        'minVersion': null,
        'androidUrl': 'https://x.y/a',
        'iosUrl': null,
        'notes': 'جديد',
      });
    });
  });
}
