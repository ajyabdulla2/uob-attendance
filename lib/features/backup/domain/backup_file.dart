import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cryptography/cryptography.dart';

/// The department's data at one moment: `collection → docId → fields`, and
/// attendance records as `sessionId → studentId → fields`.
final class BackupData {
  const BackupData({
    required this.createdAt,
    required this.createdBy,
    required this.collections,
    required this.records,
  });

  final DateTime createdAt;
  final String createdBy;
  final Map<String, Map<String, Map<String, Object?>>> collections;
  final Map<String, Map<String, Map<String, Object?>>> records;

  int get documentCount =>
      collections.values.fold<int>(0, (n, c) => n + c.length) + records.values.fold<int>(0, (n, r) => n + r.length);
}

class BackupPasswordException implements Exception {
  const BackupPasswordException();
}

class BackupFormatException implements Exception {
  const BackupFormatException(this.message);
  final String message;
  @override
  String toString() => 'BackupFormatException: $message';
}

/// `.uobk` files: «UOBK1» + salt(16) + nonce(12) + AES-256-GCM(gzip(JSON))
/// + MAC(16). The key comes from the password by PBKDF2-HMAC-SHA256. A wrong
/// password (or a damaged file) fails the MAC check.
abstract final class BackupFile {
  static const extension = 'uobk';
  static final _magic = ascii.encode('UOBK1');
  static const iterations = 60000;
  static const formatVersion = 1;

  static Future<SecretKey> _key(String password, List<int> salt) => Pbkdf2(
        macAlgorithm: Hmac.sha256(),
        iterations: iterations,
        bits: 256,
      ).deriveKeyFromPassword(password: password, nonce: salt);

  static Future<Uint8List> encrypt(BackupData data, String password, {Random? random}) async {
    final rnd = random ?? Random.secure();
    final salt = List<int>.generate(16, (_) => rnd.nextInt(256));
    final nonce = List<int>.generate(12, (_) => rnd.nextInt(256));
    final plain = GZipEncoder().encode(utf8.encode(jsonEncode(toJson(data))))!;
    final box = await AesGcm.with256bits().encrypt(plain, secretKey: await _key(password, salt), nonce: nonce);
    return Uint8List.fromList([..._magic, ...salt, ...nonce, ...box.cipherText, ...box.mac.bytes]);
  }

  static Future<BackupData> decrypt(Uint8List bytes, String password) async {
    final head = _magic.length;
    if (bytes.length < head + 16 + 12 + 16 || !_startsWithMagic(bytes)) {
      throw const BackupFormatException('not a .uobk backup');
    }
    final salt = bytes.sublist(head, head + 16);
    final nonce = bytes.sublist(head + 16, head + 28);
    final cipher = bytes.sublist(head + 28, bytes.length - 16);
    final mac = Mac(bytes.sublist(bytes.length - 16));
    final List<int> plain;
    try {
      plain = await AesGcm.with256bits().decrypt(
        SecretBox(cipher, nonce: nonce, mac: mac),
        secretKey: await _key(password, salt),
      );
    } on SecretBoxAuthenticationError {
      throw const BackupPasswordException();
    }
    return fromJson((jsonDecode(utf8.decode(GZipDecoder().decodeBytes(plain))) as Map).cast<String, Object?>());
  }

  static bool _startsWithMagic(Uint8List b) {
    for (var i = 0; i < _magic.length; i++) {
      if (b[i] != _magic[i]) return false;
    }
    return true;
  }

  // ------------------------------------------------------------ JSON --

  static Map<String, Object?> toJson(BackupData d) => {
        'format': formatVersion,
        'createdAt': d.createdAt.toUtc().toIso8601String(),
        'createdBy': d.createdBy,
        'collections': {
          for (final c in d.collections.entries)
            c.key: {for (final doc in c.value.entries) doc.key: encodeValue(doc.value)},
        },
        'records': {
          for (final s in d.records.entries)
            s.key: {for (final r in s.value.entries) r.key: encodeValue(r.value)},
        },
      };

  static BackupData fromJson(Map<String, Object?> j) {
    if (j['format'] != formatVersion) throw BackupFormatException('format ${j['format']}');
    Map<String, Map<String, Map<String, Object?>>> nested(Object? v) => {
          for (final a in (v as Map).cast<String, Object?>().entries)
            a.key: {
              for (final b in (a.value as Map).cast<String, Object?>().entries)
                b.key: (decodeValue(b.value) as Map).cast<String, Object?>(),
            },
        };
    return BackupData(
      createdAt: DateTime.parse(j['createdAt'] as String),
      createdBy: j['createdBy'] as String,
      collections: nested(j['collections']),
      records: nested(j['records']),
    );
  }

  /// Firestore values → JSON (timestamps become `{"__ts": micros}`).
  static Object? encodeValue(Object? v) => switch (v) {
        Timestamp t => {'__ts': t.microsecondsSinceEpoch},
        DateTime d => {'__ts': d.microsecondsSinceEpoch},
        Map m => {for (final e in m.entries) '${e.key}': encodeValue(e.value)},
        List l => [for (final x in l) encodeValue(x)],
        _ => v,
      };

  static Object? decodeValue(Object? v) => switch (v) {
        Map m when m.length == 1 && m['__ts'] is int => Timestamp.fromMicrosecondsSinceEpoch(m['__ts'] as int),
        Map m => {for (final e in m.entries) '${e.key}': decodeValue(e.value)},
        List l => [for (final x in l) decodeValue(x)],
        _ => v,
      };
}
