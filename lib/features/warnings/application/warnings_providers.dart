import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../data/warnings_repository.dart';
import '../domain/warning_list.dart';

final warningsRepositoryProvider = Provider<WarningsRepository>(
  (ref) => WarningsRepository(ref.watch(firestoreProvider)),
);

final stageDecisionsProvider = StreamProvider.autoDispose.family<List<WarningList>, String>(
  (ref, stageId) => ref.watch(warningsRepositoryProvider).watchStage(stageId),
);
