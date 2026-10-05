import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:mock_exceptions/mock_exceptions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uob_attendance/core/firebase/firebase_providers.dart';
import 'package:uob_attendance/core/router/app_router.dart';
import 'package:uob_attendance/features/auth/application/auth_providers.dart';
import 'package:uob_attendance/features/auth/data/auth_repository.dart';
import 'package:uob_attendance/features/auth/domain/app_user.dart';

AppUser user(Set<UserRole> roles, {bool active = true, List<String> scopes = const []}) =>
    AppUser(email: 't@uob.iq', name: 'ت', roles: roles, active: active, stageScopes: scopes);

/// Waits until [authStatusProvider] settles on something other than loading.
Future<AuthStatus> settle(ProviderContainer c) async {
  for (var i = 0; i < 50; i++) {
    final s = c.read(authStatusProvider);
    if (s is! AuthLoading) return s;
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  return c.read(authStatusProvider);
}

ProviderContainer container({MockUser? signedIn, FakeFirebaseFirestore? db}) {
  final c = ProviderContainer(overrides: [
    firebaseAuthProvider.overrideWithValue(MockFirebaseAuth(signedIn: signedIn != null, mockUser: signedIn)),
    firestoreProvider.overrideWithValue(db ?? FakeFirebaseFirestore()),
  ]);
  c.listen(authStatusProvider, (_, _) {});
  addTearDown(c.dispose);
  return c;
}

void main() {
  group('authStatusProvider', () {
    test('signed out', () async {
      expect(await settle(container()), isA<SignedOut>());
    });

    test('unverified e-mail must verify first', () async {
      final status = await settle(container(signedIn: MockUser(email: 't@uob.iq', isEmailVerified: false)));
      expect(status, isA<NeedsVerification>().having((s) => s.email, 'email', 't@uob.iq'));
    });

    test('verified but not provisioned', () async {
      final status = await settle(container(signedIn: MockUser(email: 't@uob.iq', isEmailVerified: true)));
      expect(status, isA<NotProvisioned>());
    });

    test('suspended', () async {
      final db = FakeFirebaseFirestore();
      await db.doc('users/t@uob.iq').set(user({UserRole.teacher}, active: false).toMap());
      final status = await settle(container(signedIn: MockUser(email: 'T@uob.iq', isEmailVerified: true), db: db));
      expect(status, isA<Suspended>());
    });

    test('signed in with roles, live-updated from Firestore', () async {
      final db = FakeFirebaseFirestore();
      await db.doc('users/t@uob.iq').set(user({UserRole.teacher}).toMap());
      final c = container(signedIn: MockUser(email: 't@uob.iq', isEmailVerified: true), db: db);
      final status = await settle(c);
      expect(status, isA<SignedIn>());
      expect((status as SignedIn).permissions.canManageAssignments, isFalse);

      await db.doc('users/t@uob.iq').update({'roles': ['teacher', 'stageManager'], 'stageScopes': ['2-morning']});
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(c.read(permissionsProvider).canManageAssignments, isTrue);
    });
  });

  group('AuthRepository', () {
    test('signs in and out', () async {
      final auth = MockFirebaseAuth(mockUser: MockUser(email: 't@uob.iq', isEmailVerified: true));
      final repo = AuthRepository(auth);
      await repo.signIn(email: ' t@uob.iq ', password: 'secret123');
      expect(repo.currentUser?.email, 't@uob.iq');
      expect(await repo.reloadUser(), isTrue);
      await repo.signOut();
      expect(repo.currentUser, isNull);
    });

    test('maps Firebase error codes to AuthFailure', () async {
      final auth = MockFirebaseAuth();
      whenCalling(Invocation.method(#signInWithEmailAndPassword, null))
          .on(auth)
          .thenThrow(FirebaseAuthException(code: 'invalid-credential'));
      await expectLater(
        AuthRepository(auth).signIn(email: 'a@b.iq', password: 'x'),
        throwsA(isA<AuthException>().having((e) => e.failure, 'failure', AuthFailure.invalidCredentials)),
      );
      expect(AuthException.mapCode('email-already-in-use'), AuthFailure.emailAlreadyInUse);
      expect(AuthException.mapCode('network-request-failed'), AuthFailure.network);
      expect(AuthException.mapCode('something-new'), AuthFailure.unknown);
    });
  });

  group('redirectFor', () {
    final teacher = SignedIn(user({UserRole.teacher}));
    final manager = SignedIn(user({UserRole.stageManager, UserRole.teacher}, scopes: ['3-morning']));

    test('gates by auth status', () {
      expect(redirectFor(const AuthLoading(), Routes.home), Routes.splash);
      expect(redirectFor(const SignedOut(), Routes.import), Routes.login);
      expect(redirectFor(const SignedOut(), Routes.login), isNull);
      expect(redirectFor(const NeedsVerification('x'), Routes.home), Routes.verifyEmail);
      expect(redirectFor(const NotProvisioned('x'), Routes.home), Routes.noAccess);
      expect(redirectFor(Suspended(user({UserRole.teacher}, active: false)), Routes.home), Routes.noAccess);
      expect(redirectFor(ProfileLoadFailed(Exception()), Routes.profile), Routes.noAccess);
    });

    test('signed-in users leave the gate screens', () {
      expect(redirectFor(teacher, Routes.login), Routes.home);
      expect(redirectFor(teacher, Routes.splash), Routes.home);
      expect(redirectFor(teacher, Routes.home), isNull);
      expect(redirectFor(teacher, Routes.profile), isNull);
    });

    test('role-guarded screens', () {
      expect(redirectFor(teacher, Routes.import), Routes.home);
      expect(redirectFor(teacher, Routes.assignments), Routes.home);
      expect(redirectFor(manager, Routes.import), isNull);
      expect(redirectFor(manager, Routes.assignments), isNull);
      // Accounts: admins only (stage managers neither).
      expect(redirectFor(teacher, Routes.accounts), Routes.home);
      expect(redirectFor(manager, Routes.accounts), Routes.home);
      expect(redirectFor(SignedIn(user({UserRole.deputyAdmin})), Routes.accounts), isNull);
    });
  });
}
