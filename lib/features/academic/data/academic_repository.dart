import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/domain/stage_ref.dart';
import '../../../core/firebase/collections.dart';
import '../domain/academic_year.dart';
import '../domain/stage.dart';

/// What is missing from the base configuration.
final class SetupStatus {
  const SetupStatus({required this.missingStages, required this.hasActiveYear});
  final List<StageRef> missingStages;
  final bool hasActiveYear;
  bool get isComplete => missingStages.isEmpty && hasActiveYear;
}

class AcademicRepository {
  AcademicRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _stages => _db.collection(Col.stages);
  CollectionReference<Map<String, dynamic>> get _years => _db.collection(Col.academicYears);

  Stream<List<Stage>> watchStages() => _stages.snapshots().map((snap) {
        final stages = [
          for (final d in snap.docs)
            if (StageRef.tryParse(d.id) != null) Stage.fromMap(d.id, d.data()),
        ];
        return stages..sort((a, b) => a.ref.compareTo(b.ref));
      });

  Stream<AcademicYear?> watchActiveYear() =>
      _years.where('active', isEqualTo: true).limit(1).snapshots().map((snap) =>
          snap.docs.isEmpty ? null : AcademicYear.fromMap(snap.docs.first.id, snap.docs.first.data()));

  Future<SetupStatus> setupStatus() async {
    final stages = await _stages.get();
    final existing = {for (final d in stages.docs) d.id};
    final active = await _years.where('active', isEqualTo: true).limit(1).get();
    return SetupStatus(
      missingStages: [for (final s in StageRef.all) if (!existing.contains(s.id)) s],
      hasActiveYear: active.docs.isNotEmpty,
    );
  }

  /// Creates the eight stages and an active academic year with the SPEC's
  /// example thresholds, without overwriting anything that exists.
  Future<void> initializeDefaults({required DateTime now, required String actor}) async {
    final status = await setupStatus();
    final batch = _db.batch();
    for (final ref in status.missingStages) {
      batch.set(_stages.doc(ref.id), {
        ...Stage(ref: ref).toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': actor,
      });
    }
    if (!status.hasActiveYear) {
      final year = AcademicYear(id: AcademicYear.idFor(now), semester: now.month >= 9 || now.month == 1 ? 1 : 2, active: true);
      batch.set(_years.doc(year.id), {
        ...year.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': actor,
      }, SetOptions(merge: true));
    }
    await batch.commit();
  }
}
