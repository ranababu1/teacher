import '../../curriculum/domain/models/item_type.dart';
import 'models/attempt.dart';
import 'models/attempt_outcome.dart';

abstract class AttemptsRepository {
  Future<Attempt> saveAttempt({
    required String conceptId,
    required String itemId,
    required ItemKind itemKind,
    required ItemType itemType,
    required AttemptOutcome outcome,
  });

  Future<List<Attempt>> getAttemptsForConcept(String conceptId);

  Future<List<Attempt>> getRecentAttempts({int limit = 20});
}
