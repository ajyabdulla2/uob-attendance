import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../data/students_repository.dart';
import '../domain/student.dart';

final studentsRepositoryProvider = Provider<StudentsRepository>(
  (ref) => StudentsRepository(ref.watch(firestoreProvider)),
);

final stageStudentsProvider = StreamProvider.autoDispose.family<List<Student>, String>(
  (ref, stageId) => ref.watch(studentsRepositoryProvider).watchStage(stageId),
);
