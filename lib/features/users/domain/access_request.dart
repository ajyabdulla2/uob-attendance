import '../../../core/firebase/firestore_converters.dart';

/// `accessRequests/{email}` — someone activated an e-mail the department has
/// not provisioned and asks to join. An admin approves (creates the account)
/// or rejects; both delete the request.
final class AccessRequest {
  const AccessRequest({required this.email, required this.name, this.note = '', this.requestedAt});

  /// Lower-cased e-mail; also the document ID.
  final String email;
  final String name;

  /// Free text for the admins (title, stage, …).
  final String note;
  final DateTime? requestedAt;

  static const maxName = 100;
  static const maxNote = 300;

  factory AccessRequest.fromMap(String id, Map<String, Object?> map) => AccessRequest(
        email: Fs.str(map['email'], id),
        name: Fs.str(map['name']),
        note: Fs.str(map['note']),
        requestedAt: Fs.date(map['requestedAt']),
      );
}
