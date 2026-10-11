import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../data/announcements_repository.dart';
import '../domain/announcement.dart';

final announcementsRepositoryProvider = Provider<AnnouncementsRepository>(
  (ref) => AnnouncementsRepository(ref.watch(firestoreProvider)),
);

final announcementsProvider = StreamProvider.autoDispose<List<Announcement>>(
  (ref) => ref.watch(announcementsRepositoryProvider).watchRecent(),
);
