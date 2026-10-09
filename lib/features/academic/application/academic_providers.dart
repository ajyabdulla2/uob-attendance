import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../data/academic_repository.dart';
import '../domain/academic_year.dart';
import '../domain/stage.dart';

final academicRepositoryProvider = Provider<AcademicRepository>(
  (ref) => AcademicRepository(ref.watch(firestoreProvider)),
);

final activeYearProvider = StreamProvider<AcademicYear?>(
  (ref) => ref.watch(academicRepositoryProvider).watchActiveYear(),
);

final stagesProvider = StreamProvider<List<Stage>>(
  (ref) => ref.watch(academicRepositoryProvider).watchStages(),
);

/// Admins only (reads every stage + the active year).
final setupStatusProvider = FutureProvider.autoDispose<SetupStatus>(
  (ref) => ref.watch(academicRepositoryProvider).setupStatus(),
);
