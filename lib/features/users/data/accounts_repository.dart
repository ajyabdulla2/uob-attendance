import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/firebase/collections.dart';
import '../../../core/firebase/doc_ids.dart';
import '../../auth/domain/app_user.dart';
import '../domain/access_request.dart';

/// Adding an account whose e-mail already has one.
class AccountExistsException implements Exception {
  const AccountExistsException(this.email);
  final String email;

  @override
  String toString() => 'AccountExistsException($email)';
}

/// Account administration (admins) and join requests (any verified e-mail).
///
/// Every admin change writes its `auditLog` entry in the same batch or
/// transaction, so the trail cannot miss one.
class AccountsRepository {
  AccountsRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _users => _db.collection(Col.users);
  CollectionReference<Map<String, dynamic>> get _requests => _db.collection(Col.accessRequests);
  DocumentReference<Map<String, dynamic>> _newAuditDoc() => _db.collection(Col.auditLog).doc();

  // ------------------------------------------------------- join requests --

  /// The caller's own pending request (null when none).
  Stream<AccessRequest?> watchRequest(String email) => _requests.doc(DocIds.user(email)).snapshots().map(
        (snap) => snap.exists ? AccessRequest.fromMap(snap.id, snap.data()!) : null,
      );

  /// Pending requests, oldest first (admins only — see rules).
  Stream<List<AccessRequest>> watchRequests() => _requests.snapshots().map((snap) {
        final requests = [for (final d in snap.docs) AccessRequest.fromMap(d.id, d.data())];
        final never = DateTime.utc(9999);
        requests.sort((a, b) => (a.requestedAt ?? never).compareTo(b.requestedAt ?? never));
        return requests;
      });

  Future<void> submitRequest({required String email, required String name, String note = ''}) {
    final id = DocIds.user(email);
    return _requests.doc(id).set({
      'email': id,
      'name': name.trim(),
      'note': note.trim(),
      'requestedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> cancelRequest(String email) => _requests.doc(DocIds.user(email)).delete();

  /// Creates the account (unless one appeared meanwhile, e.g. by import) and
  /// removes the request.
  Future<void> approve(AppUser account, {required String actor}) => _db.runTransaction((tx) async {
        final ref = _users.doc(account.id);
        final existing = await tx.get(ref);
        if (!existing.exists) tx.set(ref, _newAccount(account, actor));
        tx.delete(_requests.doc(account.id));
        tx.set(_newAuditDoc(), _audit(actor, 'user.approve', account.id, after: _snapshot(account)));
      });

  Future<void> reject(AccessRequest request, {required String actor}) {
    final batch = _db.batch()
      ..delete(_requests.doc(request.email))
      ..set(_newAuditDoc(), _audit(actor, 'user.reject', request.email, before: {'name': request.name}));
    return batch.commit();
  }

  // ------------------------------------------------------------ accounts --

  /// Adds an account; throws [AccountExistsException] rather than overwrite.
  Future<void> create(AppUser account, {required String actor}) => _db.runTransaction((tx) async {
        final ref = _users.doc(account.id);
        if ((await tx.get(ref)).exists) throw AccountExistsException(account.id);
        tx.set(ref, _newAccount(account, actor));
        tx.set(_newAuditDoc(), _audit(actor, 'user.create', account.id, after: _snapshot(account)));
      });

  /// Saves what the account editor changes. `teachingStages` is left alone:
  /// it follows the teacher's assignments.
  Future<void> update(AppUser before, AppUser after, {required String actor}) {
    final batch = _db.batch()
      ..update(_users.doc(after.id), {
        'name': after.name.trim(),
        'title': after.title.trim(),
        'phone': after.phone.trim(),
        'roles': after.toMap()['roles'],
        'stageScopes': after.stageScopes,
        'active': after.active,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': actor,
      })
      ..set(_newAuditDoc(),
          _audit(actor, 'user.update', after.id, before: _snapshot(before), after: _snapshot(after)));
    return batch.commit();
  }

  Map<String, Object?> _newAccount(AppUser account, String actor) => {
        ...account.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': actor,
      };

  static Map<String, Object?> _snapshot(AppUser u) => {
        'name': u.name,
        'roles': u.toMap()['roles'],
        'stageScopes': u.stageScopes,
        'active': u.active,
      };

  static Map<String, Object?> _audit(String actor, String action, String email,
          {Map<String, Object?>? before, Map<String, Object?>? after}) =>
      {
        'actor': actor,
        'action': action,
        'targetPath': '${Col.users}/$email',
        'stageId': null,
        'before': before,
        'after': after,
        'at': FieldValue.serverTimestamp(),
      };
}
