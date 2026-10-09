import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/firebase/collections.dart';
import '../domain/student.dart';

class StudentsRepository {
  StudentsRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col => _db.collection(Col.students);

  /// Students keyed by ID. [stageIds] null = every stage (admins only);
  /// stage managers must pass their scopes (rules require the filter).
  Future<Map<String, Student>> fetchByStages(Iterable<String>? stageIds) async {
    final snaps = stageIds == null
        ? [await _col.get()]
        : await Future.wait([for (final id in stageIds) _col.where('stageId', isEqualTo: id).get()]);
    return {
      for (final snap in snaps)
        for (final d in snap.docs) d.id: Student.fromMap(d.id, d.data()),
    };
  }

  /// Students of one stage in register order.
  Stream<List<Student>> watchStage(String stageId) =>
      _col.where('stageId', isEqualTo: stageId).snapshots().map((snap) {
        final list = [for (final d in snap.docs) Student.fromMap(d.id, d.data())];
        return list..sort(Student.compare);
      });
}
