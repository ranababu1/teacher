import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_provider.dart';
import '../../../../core/services/data_revision_provider.dart';
import '../../../curriculum/presentation/curriculum_providers.dart';
import '../../data/coding_challenge_repository_impl.dart';
import '../../domain/coding_challenge_repository.dart';
import '../../domain/models/coding_challenge.dart';

final codingChallengeRepositoryProvider = Provider<CodingChallengeRepository>(
  (ref) => CodingChallengeRepositoryImpl(rootBundle),
);

final codingChallengeProgressRepositoryProvider =
    Provider<CodingChallengeProgressRepository>(
      (ref) =>
          CodingChallengeProgressRepositoryImpl(ref.watch(appDatabaseProvider)),
    );

typedef ChallengeListItem = ({
  LongFormChallenge challenge,
  String courseTitle,
  ChallengeRecord? record,
});

final codingChallengeListProvider = FutureProvider<List<ChallengeListItem>>((
  ref,
) async {
  ref.watch(dataRevisionProvider);
  final challenges = await ref
      .watch(codingChallengeRepositoryProvider)
      .getChallenges();
  final records = await ref
      .watch(codingChallengeProgressRepositoryProvider)
      .getRecords();
  final paths = await ref.watch(learningPathsProvider.future);
  final titles = {for (final p in paths) p.id: p.title};
  return [
    for (final c in challenges)
      (
        challenge: c,
        courseTitle: titles[c.learningPathId] ?? c.learningPathId,
        record: records[c.id],
      ),
  ];
});

final codingChallengeProvider =
    FutureProvider.family<LongFormChallenge?, String>(
      (ref, id) =>
          ref.watch(codingChallengeRepositoryProvider).getChallenge(id),
    );

/// Saves a finished challenge and refreshes readers.
class CodingChallengeAttemptRecorder {
  CodingChallengeAttemptRecorder(this._ref);

  final Ref _ref;

  Future<void> call({
    required String challengeId,
    required int score,
    required int maxScore,
  }) async {
    await _ref
        .read(codingChallengeProgressRepositoryProvider)
        .recordAttempt(
          challengeId: challengeId,
          score: score,
          maxScore: maxScore,
        );
    _ref.read(dataRevisionProvider.notifier).bump();
  }
}

final codingChallengeAttemptRecorderProvider =
    Provider<CodingChallengeAttemptRecorder>(
      CodingChallengeAttemptRecorder.new,
    );
