import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_provider.dart';
import '../../../../core/services/data_revision_provider.dart';
import '../../../curriculum/domain/models/item_type.dart';
import '../../../progress/presentation/providers/progress_providers.dart';
import '../../../review/presentation/providers/review_providers.dart';
import '../../data/attempts_repository_impl.dart';
import '../../domain/attempts_repository.dart';
import '../../domain/models/attempt.dart';
import '../../domain/models/attempt_outcome.dart';
import '../../domain/record_attempt_use_case.dart';

final attemptsRepositoryProvider = Provider<AttemptsRepository>((ref) {
  return AttemptsRepositoryImpl(ref.watch(appDatabaseProvider));
});

/// Every attempt ever recorded — shared by the profile stats provider and
/// the pending-tests provider so the unbounded query runs once per data
/// revision, not twice.
final allAttemptsProvider = FutureProvider<List<Attempt>>((ref) {
  ref.watch(dataRevisionProvider);
  return ref.watch(attemptsRepositoryProvider).getAllAttempts();
});

final recordAttemptUseCaseProvider = Provider<RecordAttemptUseCase>((ref) {
  return RecordAttemptUseCase(
    attemptsRepository: ref.watch(attemptsRepositoryProvider),
    masteryRepository: ref.watch(conceptMasteryRepositoryProvider),
    reviewScheduleRepository: ref.watch(reviewScheduleRepositoryProvider),
    studentProgressRepository: ref.watch(studentProgressRepositoryProvider),
  );
});

/// The entry point UI should actually call to record an attempt.
///
/// Wraps [RecordAttemptUseCase] (which stays plain Dart, no Riverpod, so
/// it's trivially unit-testable) with the one thing a Riverpod-aware
/// caller needs to add: telling dependent read providers to refetch.
final attemptRecorderProvider = Provider<AttemptRecorder>((ref) {
  return AttemptRecorder(ref);
});

class AttemptRecorder {
  AttemptRecorder(this._ref);

  final Ref _ref;

  Future<Attempt> call({
    required String conceptId,
    required String itemId,
    required ItemKind itemKind,
    required ItemType itemType,
    required AttemptOutcome outcome,
  }) async {
    final attempt = await _ref
        .read(recordAttemptUseCaseProvider)
        .call(
          conceptId: conceptId,
          itemId: itemId,
          itemKind: itemKind,
          itemType: itemType,
          outcome: outcome,
        );
    _ref.read(dataRevisionProvider.notifier).bump();
    return attempt;
  }
}
