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

  /// رسائل الإدارة (in-app notifications).
  static const messages = 'messages';

  /// `presence/{email}`: when each account last opened the app and last
  /// uploaded attendance (read by the super admin: «متابعة التدريسيين»).
  static const presence = 'presence';

  /// `inbox/{email}/items/{id}`: a message from the super admin to one person.
  static const inbox = 'inbox';
  static const inboxItems = 'items';

  /// App-wide settings (`config/app`: published versions + download links).
  static const config = 'config';
}
