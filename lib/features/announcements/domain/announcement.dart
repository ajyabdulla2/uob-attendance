import '../../../core/config/app_config.dart';
import '../../../core/firebase/firestore_converters.dart';

/// `announcements/{id}`: إعلانات القسم. Public: the page the department's
/// QR poster opens (`web/announcements.html`) reads them without signing in.
/// Admins write them from the app.
final class Announcement {
  const Announcement({
    required this.id,
    required this.title,
    this.body = '',
    this.createdBy = '',
    this.createdAt,
    this.updatedAt,
  });

  factory Announcement.fromMap(String id, Map<String, dynamic> m) => Announcement(
        id: id,
        title: Fs.str(m['title']),
        body: Fs.str(m['body']),
        createdBy: Fs.str(m['createdBy']),
        createdAt: Fs.date(m['createdAt']),
        updatedAt: Fs.date(m['updatedAt']),
      );

  final String id;
  final String title;
  final String body;
  final String createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  static const maxTitle = 200;
  static const maxBody = 5000;

  /// The public page for these announcements.
  static String pageUrl([String site = AppConfig.siteUrl]) => '$site/announcements.html';
}
