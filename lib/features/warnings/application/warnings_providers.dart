import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../data/external_notices_repository.dart';
import '../data/warnings_repository.dart';
import '../domain/external_notice.dart';
import '../domain/warning_list.dart';

final warningsRepositoryProvider = Provider<WarningsRepository>(
  (ref) => WarningsRepository(ref.watch(firestoreProvider)),
);

final stageDecisionsProvider = StreamProvider.autoDispose.family<List<WarningList>, String>(
  (ref, stageId) => ref.watch(warningsRepositoryProvider).watchStage(stageId),
);

final externalNoticesRepositoryProvider = Provider<ExternalNoticesRepository>(
  (ref) => ExternalNoticesRepository(ref.watch(firestoreProvider)),
);

/// «كتب خارجية» of one stage, newest first.
final stageNoticesProvider = StreamProvider.autoDispose.family<List<ExternalNotice>, String>(
  (ref, stageId) => ref.watch(externalNoticesRepositoryProvider).watchStage(stageId),
);
