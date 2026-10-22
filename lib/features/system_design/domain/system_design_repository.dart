import 'models/system_design_exercise.dart';

abstract class SystemDesignRepository {
  Future<List<SystemDesignExercise>> getExercises();

  Future<SystemDesignExercise?> getExercise(String id);
}

abstract class SystemDesignProgressRepository {
  Future<void> recordAttempt({
    required String exerciseId,
    required int score,
    required int maxScore,
  });

  /// exerciseId -> record, for exercises attempted at least once.
  Future<Map<String, SystemDesignRecord>> getRecords();
}
