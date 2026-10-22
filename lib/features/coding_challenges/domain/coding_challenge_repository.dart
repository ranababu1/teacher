import 'models/coding_challenge.dart';

abstract class CodingChallengeRepository {
  Future<List<LongFormChallenge>> getChallenges();

  Future<LongFormChallenge?> getChallenge(String id);
}

abstract class CodingChallengeProgressRepository {
  Future<void> recordAttempt({
    required String challengeId,
    required int score,
    required int maxScore,
  });

  /// challengeId -> record, for challenges finished at least once.
  Future<Map<String, ChallengeRecord>> getRecords();
}
