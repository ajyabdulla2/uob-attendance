import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../../auth/application/auth_providers.dart';
import '../../auth/domain/app_user.dart';
import '../data/accounts_repository.dart';
import '../domain/access_request.dart';

/// Every account (admins and stage managers may list users — see rules).
final allUsersProvider = StreamProvider.autoDispose<List<AppUser>>(
  (ref) => ref.watch(usersRepositoryProvider).watchAll(),
);

final accountsRepositoryProvider = Provider<AccountsRepository>(
  (ref) => AccountsRepository(ref.watch(firestoreProvider)),
);

/// Pending join requests. Watch only where `canManageAccounts` holds.
final accessRequestsProvider = StreamProvider.autoDispose<List<AccessRequest>>(
  (ref) => ref.watch(accountsRepositoryProvider).watchRequests(),
);

/// The signed-in person's own join request (null when none).
final myAccessRequestProvider = StreamProvider.autoDispose<AccessRequest?>((ref) {
  final email = ref.watch(authUserProvider).value?.email;
  if (email == null) return Stream.value(null);
  return ref.watch(accountsRepositoryProvider).watchRequest(email);
});
