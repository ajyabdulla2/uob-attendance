import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/firebase/collections.dart';
import '../domain/app_message.dart';

class MessagesRepository {
  MessagesRepository(this._fs);

  final FirebaseFirestore _fs;

  static const recent = 30;

  CollectionReference<Map<String, dynamic>> get _col => _fs.collection(Col.messages);

  /// The latest messages, newest first (the app keeps those meant for the user).
  Stream<List<AppMessage>> watchRecent() => _col
      .orderBy('createdAt', descending: true)
      .limit(recent)
      .snapshots()
      .map((s) => [for (final d in s.docs) AppMessage.fromMap(d.id, d.data())]);

  Future<void> send(AppMessage message) =>
      _col.doc().set({...message.toMap(), 'createdAt': FieldValue.serverTimestamp()});

  Future<void> delete(String id) => _col.doc(id).delete();
}
