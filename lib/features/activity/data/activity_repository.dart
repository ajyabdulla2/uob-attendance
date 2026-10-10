import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/firebase/collections.dart';
import '../../attendance/domain/attendance_session.dart';
import '../domain/teacher_activity.dart';

class ActivityRepository {
  ActivityRepository(this._fs);

  final FirebaseFirestore _fs;

  CollectionReference<Map<String, dynamic>> get _col => _fs.collection(Col.presence);

  /// Every account's presence (super admin only), by e-mail.
  Stream<Map<String, Presence>> watchAll() => _col.snapshots().map(
        (s) => {for (final d in s.docs) d.id: Presence.fromMap(d.id, d.data())},
      );

  /// The app was opened by [email].
  Future<void> reportSeen(String email, {required String platform, required String appVersion}) => _col.doc(email).set({
        ...Presence.seenFields(platform: platform, appVersion: appVersion),
        'email': email,
        'lastSeenAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

  /// [email]'s phone uploaded attendance (a lecture recorded or edited).
  Future<void> reportUpload(String email) => _col.doc(email).set({
        'email': email,
        'lastSeenAt': FieldValue.serverTimestamp(),
        'lastUploadAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

  /// This phone's FCM token for [email] (null: stop sending to it).
  Future<void> reportPushToken(String email, String? token) => _col.doc(email).set({
        'email': email,
        'lastSeenAt': FieldValue.serverTimestamp(),
        'pushToken': token,
      }, SetOptions(merge: true));

  /// The lectures [email] opened, latest first, and how many in all.
  Future<({List<AttendanceSession> latest, int total})> lecturesBy(String email, {int limit = 5}) async {
    final q = _fs.collection(Col.sessions).where('openedBy', isEqualTo: email);
    final latest = await q.orderBy('date', descending: true).limit(limit).get();
    final total = await q.count().get();
    return (
      latest: [for (final d in latest.docs) AttendanceSession.fromMap(d.id, d.data())],
      total: total.count ?? latest.docs.length,
    );
  }
}
