import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../data/data_fix_repository.dart';

final dataFixRepositoryProvider = Provider<DataFixRepository>(
  (ref) => DataFixRepository(ref.watch(firestoreProvider)),
);
