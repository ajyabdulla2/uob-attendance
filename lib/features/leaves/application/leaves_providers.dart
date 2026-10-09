import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../data/leaves_repository.dart';
import '../domain/leave.dart';

final leavesRepositoryProvider = Provider<LeavesRepository>(
  (ref) => LeavesRepository(ref.watch(firestoreProvider)),
);

final stageLeavesProvider = StreamProvider.autoDispose.family<List<Leave>, String>(
  (ref, stageId) => ref.watch(leavesRepositoryProvider).watchStage(stageId),
);
