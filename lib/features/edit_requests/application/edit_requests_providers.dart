import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../../auth/application/auth_providers.dart';
import '../data/edit_requests_repository.dart';
import '../domain/edit_request.dart';

final editRequestsRepositoryProvider = Provider<EditRequestsRepository>(
  (ref) => EditRequestsRepository(ref.watch(firestoreProvider)),
);

final pendingEditRequestsProvider = StreamProvider.autoDispose.family<List<EditRequest>, String>(
  (ref, stageId) => ref.watch(editRequestsRepositoryProvider).watchPending(stageId),
);

final myEditRequestsProvider = StreamProvider.autoDispose<List<EditRequest>>(
  (ref) => ref.watch(editRequestsRepositoryProvider).watchMine(ref.watch(signedInUserProvider).id),
);
