import 'dart:convert';

import 'package:http/http.dart' as http;

/// What push-worker/ answered for one send.
final class PushResult {
  const PushResult({this.sent = 0, this.noDevice = 0, this.failed = 0});

  /// Phones that received it.
  final int sent;

  /// Recipients without a registered phone (never opened version 1.4+, or
  /// notifications turned off).
  final int noDevice;
  final int failed;
}

/// Asks push-worker/ to send a phone notification. The worker checks the
/// Firebase ID token: only an active super admin may send.
class PushClient {
  PushClient({required this.endpoint, required this.idToken, http.Client? client}) : _client = client ?? http.Client();

  final String endpoint;
  final Future<String?> Function() idToken;
  final http.Client _client;

  bool get configured => endpoint.isNotEmpty;

  Future<PushResult> send({required List<String> to, required String title, required String body}) async {
    if (!configured) throw StateError('push endpoint not configured');
    final token = await idToken();
    if (token == null) throw StateError('not signed in');
    final res = await _client
        .post(
          Uri.parse('${endpoint.replaceAll(RegExp(r'/+$'), '')}/send'),
          headers: {'authorization': 'Bearer $token', 'content-type': 'application/json'},
          body: jsonEncode({'to': to, 'title': title.trim(), 'body': body.trim()}),
        )
        .timeout(const Duration(seconds: 30));
    if (res.statusCode != 200) throw PushException(res.statusCode, res.body);
    final map = jsonDecode(res.body) as Map<String, dynamic>;
    int n(String k) => (map[k] as num?)?.toInt() ?? 0;
    return PushResult(sent: n('sent'), noDevice: n('noDevice'), failed: n('failed'));
  }
}

class PushException implements Exception {
  const PushException(this.status, this.body);

  final int status;
  final String body;

  @override
  String toString() => 'PushException($status): $body';
}
