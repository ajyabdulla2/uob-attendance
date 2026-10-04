import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../../auth/application/auth_providers.dart';
import '../data/assignments_repository.dart';
import '../domain/assignment.dart';

final assignmentsRepositoryProvider = Provider<AssignmentsRepository>(
  (ref) => AssignmentsRepository(ref.watch(firestoreProvider)),
);

/// «موادي» — the signed-in user's own assignments.
final myAssignmentsProvider = StreamProvider.autoDispose<List<Assignment>>((ref) {
  final me = ref.watch(signedInUserProvider);
  return ref.watch(assignmentsRepositoryProvider).watchTeacher(me.id);
});

final stageAssignmentsProvider = StreamProvider.autoDispose.family<List<Assignment>, String>(
  (ref, stageId) => ref.watch(assignmentsRepositoryProvider).watchStage(stageId),
);
