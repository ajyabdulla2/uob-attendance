import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/domain/stage_ref.dart';
import '../../../core/firebase/collections.dart';

/// One stage's line on the department dashboard.
final class StageCounts {
  const StageCounts({
    required this.stageId,
    required this.students,
    required this.courses,
    required this.lecturesToday,
    required this.pendingRequests,
  });

  final String stageId;
  final int students;
  final int courses;
  final int lecturesToday;
  final int pendingRequests;
}

/// لوحة القسم (admins). Only count() aggregations — one read per 1000
/// documents counted — so opening it costs a few dozen reads, not the
/// thousands of documents behind it.
class DepartmentRepository {
  DepartmentRepository(this._fs);

  final FirebaseFirestore _fs;

  Future<int> _count(Query<Map<String, dynamic>> q) async => (await q.count().get()).count ?? 0;

  Future<List<StageCounts>> stageCounts(String todayKey) => Future.wait([
        for (final s in StageRef.all)
          Future.wait([
            _count(_fs.collection(Col.students).where('stageId', isEqualTo: s.id)),
            _count(_fs.collection(Col.courses).where('stageId', isEqualTo: s.id)),
            _count(_fs
                .collection(Col.sessions)
                .where('stageId', isEqualTo: s.id)
                .where('dateKey', isEqualTo: todayKey)),
            _count(_fs
                .collection(Col.editRequests)
                .where('stageId', isEqualTo: s.id)
                .where('status', isEqualTo: 'pending')),
          ]).then((c) => StageCounts(
                stageId: s.id,
                students: c[0],
                courses: c[1],
                lecturesToday: c[2],
                pendingRequests: c[3],
              )),
      ]);

  Future<int> pendingAccessRequests() => _count(_fs.collection(Col.accessRequests));

  Future<int> activeTeachers() => _count(_fs.collection(Col.users).where('active', isEqualTo: true));
}
