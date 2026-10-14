import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../../assignments/domain/assignment.dart';
import '../data/server_register.dart';

final serverRegisterRepositoryProvider = Provider<ServerRegisterRepository>(
  (ref) => ServerRegisterRepository(ref.watch(firestoreProvider)),
);

/// A teacher's classes (admins, «متابعة التدريسيين»).
final teacherClassesProvider = FutureProvider.autoDispose.family<List<Assignment>, String>(
  (ref, teacherId) => ref.watch(serverRegisterRepositoryProvider).classesOf(teacherId),
);

/// One class's register from the server; null when the class is gone.
final serverRegisterProvider = FutureProvider.autoDispose.family<ServerRegister?, String>(
  (ref, assignmentId) => ref.watch(serverRegisterRepositoryProvider).loadById(assignmentId),
);
