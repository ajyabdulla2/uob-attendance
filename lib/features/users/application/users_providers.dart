import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_providers.dart';
import '../../auth/domain/app_user.dart';

/// Every account (admins and stage managers may list users — see rules).
final allUsersProvider = StreamProvider.autoDispose<List<AppUser>>(
  (ref) => ref.watch(usersRepositoryProvider).watchAll(),
);
