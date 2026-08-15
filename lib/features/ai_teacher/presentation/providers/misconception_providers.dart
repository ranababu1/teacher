import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_provider.dart';
import '../../../../core/services/data_revision_provider.dart';
import '../../data/misconception_repository_impl.dart';
import '../../domain/misconception_repository.dart';
import '../../domain/models/detected_misconception.dart';

final misconceptionRepositoryProvider = Provider<MisconceptionRepository>((
  ref,
) {
  return MisconceptionRepositoryImpl(ref.watch(appDatabaseProvider));
});

final unresolvedMisconceptionsProvider =
    FutureProvider.family<List<DetectedMisconception>, String>((
      ref,
      conceptId,
    ) {
      ref.watch(dataRevisionProvider);
      return ref
          .watch(misconceptionRepositoryProvider)
          .getUnresolvedForConcept(conceptId);
    });
