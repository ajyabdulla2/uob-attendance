/// Firestore collection names (SPEC: «قاعدة بيانات Firebase»).
abstract final class Col {
  static const users = 'users';
  static const academicYears = 'academicYears';
  static const stages = 'stages';
  static const students = 'students';
  static const courses = 'courses';
  static const groups = 'groups';
  static const assignments = 'assignments';
  static const sessions = 'sessions';
  static const records = 'records'; // sub-collection of sessions
  static const leaves = 'leaves';
  static const stats = 'stats';
  static const warningLists = 'warningLists';
  static const editRequests = 'editRequests';
  static const auditLog = 'auditLog';

  /// Join requests from verified but unprovisioned e-mails (doc ID = e-mail).
  static const accessRequests = 'accessRequests';

  /// App-wide settings (`config/app`: published versions + download links).
  static const config = 'config';
}
