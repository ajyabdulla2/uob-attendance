import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../../users/data/users_repository.dart';
import '../data/auth_repository.dart';
import '../domain/app_user.dart';
import '../domain/permissions.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(firebaseAuthProvider)),
);

final usersRepositoryProvider = Provider<UsersRepository>(
  (ref) => UsersRepository(ref.watch(firestoreProvider)),
);

final authUserProvider = StreamProvider<User?>(
  (ref) => ref.watch(authRepositoryProvider).userChanges(),
);

/// `users/{email}` of the signed-in, verified user (null when missing).
final currentProfileProvider = StreamProvider<AppUser?>((ref) {
  final user = ref.watch(authUserProvider).value;
  final email = user?.email;
  if (user == null || email == null || !user.emailVerified) return Stream.value(null);
  return ref.watch(usersRepositoryProvider).watch(email);
});

/// Where the signed-in person stands; drives routing.
sealed class AuthStatus {
  const AuthStatus();
}

final class AuthLoading extends AuthStatus {
  const AuthLoading();
}

final class SignedOut extends AuthStatus {
  const SignedOut();
}

/// Signed in, but the e-mail is not verified yet.
final class NeedsVerification extends AuthStatus {
  const NeedsVerification(this.email);
  final String email;
}

/// Verified, but no `users/{email}` doc: the account was not provisioned.
final class NotProvisioned extends AuthStatus {
  const NotProvisioned(this.email);
  final String email;
}

final class Suspended extends AuthStatus {
  const Suspended(this.user);
  final AppUser user;
}

final class ProfileLoadFailed extends AuthStatus {
  const ProfileLoadFailed(this.error);
  final Object error;
}

final class SignedIn extends AuthStatus {
  const SignedIn(this.user);
  final AppUser user;
  Permissions get permissions => Permissions(user);
}

final authStatusProvider = Provider<AuthStatus>((ref) {
  final auth = ref.watch(authUserProvider);
  if (auth.isLoading && !auth.hasValue) return const AuthLoading();
  final user = auth.value;
  if (user == null) return const SignedOut();
  final email = user.email ?? '';
  if (!user.emailVerified) return NeedsVerification(email);

  final profile = ref.watch(currentProfileProvider);
  if (profile.hasError) return ProfileLoadFailed(profile.error!);
  if (!profile.hasValue) return const AuthLoading();
  final appUser = profile.value;
  if (appUser == null) return NotProvisioned(email);
  if (!appUser.active) return Suspended(appUser);
  return SignedIn(appUser);
});

/// The active signed-in user. Only read it below the signed-in shell.
final signedInUserProvider = Provider<AppUser>((ref) {
  final status = ref.watch(authStatusProvider);
  if (status is SignedIn) return status.user;
  throw StateError('No signed-in user (status: $status)');
});

final permissionsProvider = Provider<Permissions>(
  (ref) => Permissions(ref.watch(signedInUserProvider)),
);
