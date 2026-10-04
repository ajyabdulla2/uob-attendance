import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/firebase/collections.dart';
import '../../../core/firebase/doc_ids.dart';
import '../../auth/domain/app_user.dart';

/// `users` collection — account roles + teacher profiles.
class UsersRepository {
  UsersRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col => _db.collection(Col.users);

  /// The signed-in user's own profile (null when not provisioned).
  Stream<AppUser?> watch(String email) => _col.doc(DocIds.user(email)).snapshots().map(
        (snap) => snap.exists ? AppUser.fromMap(snap.id, snap.data()!) : null,
      );

  /// Every account (admins and stage managers only — see rules).
  Future<List<AppUser>> fetchAll() async {
    final snap = await _col.get();
    final users = [for (final d in snap.docs) AppUser.fromMap(d.id, d.data())];
    users.sort((a, b) => a.name.compareTo(b.name));
    return users;
  }

  Stream<List<AppUser>> watchAll() => _col.snapshots().map((snap) {
        final users = [for (final d in snap.docs) AppUser.fromMap(d.id, d.data())];
        users.sort((a, b) => a.name.compareTo(b.name));
        return users;
      });

  Future<void> updatePhone(String email, String phone) => _col.doc(DocIds.user(email)).update({
        'phone': phone.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
}
