import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../../assignments/domain/assignment.dart';
import '../../courses/data/course_panel.dart';
import '../data/server_register.dart';
import '../domain/attendance_session.dart';

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

final coursePanelRepositoryProvider = Provider<CoursePanelRepository>(
  (ref) => CoursePanelRepository(ref.watch(firestoreProvider)),
);

/// «لوحة المادة» from the server; null when the course is gone.
final coursePanelProvider = FutureProvider.autoDispose.family<CoursePanel?, String>(
  (ref, courseId) => ref.watch(coursePanelRepositoryProvider).load(courseId),
);

/// One lecture's marks, when it is opened in the panel.
final sessionMarksProvider = FutureProvider.autoDispose.family<Map<String, AttendanceStatus>, String>(
  (ref, sessionId) => ref.watch(coursePanelRepositoryProvider).marksOf(sessionId),
);
