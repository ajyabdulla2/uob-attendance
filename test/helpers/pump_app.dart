import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uob_attendance/app.dart';
import 'package:uob_attendance/core/database/database_provider.dart';
import 'package:uob_attendance/core/firebase/firebase_providers.dart';
import 'package:uob_attendance/core/theme/app_settings.dart';
import 'package:uob_attendance/features/app_update/application/app_update_providers.dart';
import 'package:uob_attendance/features/app_update/domain/app_update_policy.dart';
import 'package:uob_attendance/features/auth/domain/app_user.dart';

/// Pumps the whole app on fakes (Firestore, Auth, preferences), signed in as
/// [user] with [profile] in `users/`. Shared by the widget tests.
const adminEmail = 'admin@uobasrah.edu.iq';

Future<({FakeFirebaseFirestore db, MockFirebaseAuth auth})> pumpApp(
  WidgetTester tester, {
  MockUser? user,
  AppUser? profile,
  Map<String, Object> prefs = const {},
  Map<String, Object>? appPolicy,
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final sharedPrefs = await SharedPreferences.getInstance();
  final db = FakeFirebaseFirestore();
  if (profile != null) await db.doc('users/${profile.id}').set(profile.toMap());
  if (appPolicy != null) await db.doc('config/app').set(appPolicy);
  final auth = MockFirebaseAuth(signedIn: user != null, mockUser: user);

  tester.view.physicalSize = const Size(1200, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(sharedPrefs),
      firebaseAuthProvider.overrideWithValue(auth),
      firestoreProvider.overrideWithValue(db),
      // Drift's stream cleanup leaves a zero-length timer that flutter_test
      // flags after disposal; the local DB has its own tests.
      pendingUploadsProvider.overrideWith((ref) => Stream.value(0)),
      installedVersionProvider.overrideWith((ref) async => const AppVersion(1, 0, 0)),
    ],
    child: const AttendanceApp(),
  ));
  await tester.pumpAndSettle();
  return (db: db, auth: auth);
}
