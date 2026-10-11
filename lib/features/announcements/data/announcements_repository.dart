import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/config/app_config.dart';
import '../../../core/firebase/collections.dart';
import '../domain/announcement.dart';

class AnnouncementsRepository {
  AnnouncementsRepository(this._fs);

  final FirebaseFirestore _fs;

  /// The public page shows the same number (each one is a read on Spark).
  static const recent = 30;

  CollectionReference<Map<String, dynamic>> get _col => _fs.collection(Col.announcements);

  /// Newest first.
  Stream<List<Announcement>> watchRecent() => _col
      .orderBy('createdAt', descending: true)
      .limit(recent)
      .snapshots()
      .map((s) => [for (final d in s.docs) Announcement.fromMap(d.id, d.data())]);

  Future<void> create({required String title, required String body, required String by}) => _col.doc().set({
        'title': title.trim(),
        'body': body.trim(),
        'createdBy': by,
        'createdAt': FieldValue.serverTimestamp(),
        'departmentId': AppConfig.departmentId,
      });

  /// Keeps the original author and date; records who edited it and when.
  Future<void> update(String id, {required String title, required String body, required String by}) =>
      _col.doc(id).update({
        'title': title.trim(),
        'body': body.trim(),
        'updatedBy': by,
        'updatedAt': FieldValue.serverTimestamp(),
      });

  Future<void> delete(String id) => _col.doc(id).delete();
}
