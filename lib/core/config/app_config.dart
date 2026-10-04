/// Compile-time configuration (pass with `--dart-define=KEY=value`).
abstract final class AppConfig {
  /// Every document carries this so other departments can be added later
  /// without a rebuild (SPEC: «إضافة حقل departmentId من البداية»).
  static const departmentId = 'cs';

  /// Connect to the local Firebase Emulator Suite instead of production.
  static const useEmulator = bool.fromEnvironment('USE_FIREBASE_EMULATOR');

  /// Host of the emulators (use 10.0.2.2 from the Android emulator).
  static const emulatorHost = String.fromEnvironment(
    'FIREBASE_EMULATOR_HOST',
    defaultValue: 'localhost',
  );

  static const authEmulatorPort = 9099;
  static const firestoreEmulatorPort = 8080;

  /// University e-mail domain. Not enforced yet (pending department decision
  /// «هل الدخول بالبريد الجامعي متاح لكل التدريسيين»); used for hints only.
  static const universityEmailDomain = 'uobasrah.edu.iq';
}
