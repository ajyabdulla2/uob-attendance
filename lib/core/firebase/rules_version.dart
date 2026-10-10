import 'package:cloud_firestore/cloud_firestore.dart';

/// A canary for «are the deployed rules the ones this app expects?».
/// `firestore.rules` allows reading `rulesVersion/<current>` only; older
/// rules refuse it. Bump [current] here and in the rules together whenever
/// the rules change.
abstract final class RulesVersion {
  static const current = '2026-10-10b';
  static const path = 'rulesVersion/$current';

  /// true = deployed rules match, false = older rules are deployed, null =
  /// could not tell (offline…).
  static Future<bool?> isDeployed(FirebaseFirestore fs) async {
    try {
      await fs.doc(path).get(const GetOptions(source: Source.server));
      return true;
    } on FirebaseException catch (e) {
      return e.code == 'permission-denied' ? false : null;
    } on Object catch (e) {
      return '$e'.contains('PERMISSION_DENIED') ? false : null;
    }
  }

  static String describe(bool? deployed) => switch (deployed) {
        true => 'rules on server: current ($current)',
        false => 'rules on server: OUTDATED — deploy firestore.rules (app expects $current)',
        null => 'rules on server: unknown (offline?)',
      };
}
