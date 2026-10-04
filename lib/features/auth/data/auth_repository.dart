import 'package:firebase_auth/firebase_auth.dart';

/// Why an auth action failed — mapped to localized messages in the UI.
enum AuthFailure {
  invalidCredentials,
  invalidEmail,
  emailAlreadyInUse,
  weakPassword,
  userDisabled,
  tooManyRequests,
  network,
  unknown,
}

class AuthException implements Exception {
  const AuthException(this.failure, [this.code]);

  final AuthFailure failure;
  final String? code;

  static AuthFailure mapCode(String code) => switch (code) {
        'invalid-credential' ||
        'wrong-password' ||
        'user-not-found' ||
        'INVALID_LOGIN_CREDENTIALS' =>
          AuthFailure.invalidCredentials,
        'invalid-email' => AuthFailure.invalidEmail,
        'email-already-in-use' => AuthFailure.emailAlreadyInUse,
        'weak-password' => AuthFailure.weakPassword,
        'user-disabled' => AuthFailure.userDisabled,
        'too-many-requests' => AuthFailure.tooManyRequests,
        'network-request-failed' => AuthFailure.network,
        _ => AuthFailure.unknown,
      };

  @override
  String toString() => 'AuthException($failure, $code)';
}

/// E-mail/password authentication (Firebase Auth, Spark plan).
///
/// Accounts are *activated*, not freely created: an admin first provisions
/// `users/{email}` (import or manual add); the teacher then signs up with the
/// same e-mail and verifies it. Firestore rules only honour verified e-mails,
/// so signing up with someone else's address grants nothing.
class AuthRepository {
  AuthRepository(this._auth);

  final FirebaseAuth _auth;

  /// Emits on sign-in/out *and* on profile changes such as e-mail verification
  /// after [reloadUser].
  Stream<User?> userChanges() => _auth.userChanges();

  User? get currentUser => _auth.currentUser;

  Future<void> signIn({required String email, required String password}) =>
      _guard(() => _auth.signInWithEmailAndPassword(email: email.trim(), password: password));

  /// Creates the Firebase Auth account for a pre-provisioned e-mail and sends
  /// the verification link.
  Future<void> activateAccount({required String email, required String password}) => _guard(() async {
        final cred = await _auth.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
        await cred.user?.sendEmailVerification();
      });

  Future<void> sendPasswordReset(String email) =>
      _guard(() => _auth.sendPasswordResetEmail(email: email.trim()));

  Future<void> resendVerification() => _guard(() async => _auth.currentUser?.sendEmailVerification());

  /// Reloads the user and refreshes the ID token so the `email_verified`
  /// claim seen by Firestore rules is up to date. Returns the new state.
  Future<bool> reloadUser() => _guard(() async {
        final user = _auth.currentUser;
        if (user == null) return false;
        await user.reload();
        final fresh = _auth.currentUser;
        if (fresh != null && fresh.emailVerified) await fresh.getIdToken(true);
        return fresh?.emailVerified ?? false;
      });

  Future<void> changePassword(String newPassword) =>
      _guard(() async => _auth.currentUser?.updatePassword(newPassword));

  Future<void> signOut() => _auth.signOut();

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on FirebaseAuthException catch (e) {
      throw AuthException(AuthException.mapCode(e.code), e.code);
    }
  }
}
