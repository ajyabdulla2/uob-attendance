import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/firebase/collections.dart';
import '../domain/app_message.dart';

class MessagesRepository {
  MessagesRepository(this._fs);

  final FirebaseFirestore _fs;

  static const recent = 30;

  /// Firestore's limit per batch.
  static const _maxWrites = 500;

  CollectionReference<Map<String, dynamic>> get _col => _fs.collection(Col.messages);

  CollectionReference<Map<String, dynamic>> _inbox(String email) =>
      _fs.collection(Col.inbox).doc(email).collection(Col.inboxItems);

  /// The latest messages, newest first (the app keeps those meant for the user).
  Stream<List<AppMessage>> watchRecent() => _col
      .orderBy('createdAt', descending: true)
      .limit(recent)
      .snapshots()
      .map((s) => [for (final d in s.docs) AppMessage.fromMap(d.id, d.data())]);

  /// Messages sent to [email] alone, newest first.
  Stream<List<AppMessage>> watchInbox(String email) => _inbox(email)
      .orderBy('createdAt', descending: true)
      .limit(recent)
      .snapshots()
      .map((s) => [for (final d in s.docs) AppMessage.personal(d.id, email, d.data())]);

  Future<void> send(AppMessage message) =>
      _col.doc().set({...message.toMap(), 'createdAt': FieldValue.serverTimestamp()});

  /// One copy of [message] in each recipient's inbox, in batches.
  Future<void> sendPersonal(AppMessage message, Iterable<String> to) async {
    final emails = to.toSet().toList();
    for (var i = 0; i < emails.length; i += _maxWrites) {
      final batch = _fs.batch();
      for (final email in emails.skip(i).take(_maxWrites)) {
        batch.set(_inbox(email).doc(), {...message.toMap(), 'createdAt': FieldValue.serverTimestamp()});
      }
      await batch.commit();
    }
  }

  Future<void> delete(AppMessage message) => message.audience == MessageAudience.person
      ? _inbox(message.to!).doc(message.id).delete()
      : _col.doc(message.id).delete();
}
