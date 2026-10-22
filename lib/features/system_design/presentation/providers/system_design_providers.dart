import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_provider.dart';
import '../../../../core/services/data_revision_provider.dart';
import '../../data/system_design_repository_impl.dart';
import '../../domain/models/system_design_exercise.dart';
import '../../domain/system_design_repository.dart';

final systemDesignRepositoryProvider = Provider<SystemDesignRepository>(
  (ref) => SystemDesignRepositoryImpl(rootBundle),
);

final systemDesignProgressRepositoryProvider =
    Provider<SystemDesignProgressRepository>(
      (ref) =>
          SystemDesignProgressRepositoryImpl(ref.watch(appDatabaseProvider)),
    );

final systemDesignListProvider =
    FutureProvider<
      List<({SystemDesignExercise exercise, SystemDesignRecord? record})>
    >((ref) async {
      ref.watch(dataRevisionProvider);
      final exercises = await ref
          .watch(systemDesignRepositoryProvider)
          .getExercises();
      final records = await ref
          .watch(systemDesignProgressRepositoryProvider)
          .getRecords();
      return [for (final e in exercises) (exercise: e, record: records[e.id])];
    });

final systemDesignExerciseProvider =
    FutureProvider.family<SystemDesignExercise?, String>(
      (ref, id) => ref.watch(systemDesignRepositoryProvider).getExercise(id),
    );

/// Saves a finished walkthrough and refreshes readers.
class SystemDesignAttemptRecorder {
  SystemDesignAttemptRecorder(this._ref);

  final Ref _ref;

  Future<void> call({
    required String exerciseId,
    required int score,
    required int maxScore,
  }) async {
    await _ref
        .read(systemDesignProgressRepositoryProvider)
        .recordAttempt(
          exerciseId: exerciseId,
          score: score,
          maxScore: maxScore,
        );
    _ref.read(dataRevisionProvider.notifier).bump();
  }
}

final systemDesignAttemptRecorderProvider =
    Provider<SystemDesignAttemptRecorder>(SystemDesignAttemptRecorder.new);
