import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_provider.dart';
import '../../../progress/presentation/providers/progress_providers.dart';
import '../../../review/presentation/providers/review_providers.dart';
import '../../data/attempts_repository_impl.dart';
import '../../domain/attempts_repository.dart';
import '../../domain/record_attempt_use_case.dart';

final attemptsRepositoryProvider = Provider<AttemptsRepository>((ref) {
  return AttemptsRepositoryImpl(ref.watch(appDatabaseProvider));
});

final recordAttemptUseCaseProvider = Provider<RecordAttemptUseCase>((ref) {
  return RecordAttemptUseCase(
    attemptsRepository: ref.watch(attemptsRepositoryProvider),
    masteryRepository: ref.watch(conceptMasteryRepositoryProvider),
    reviewScheduleRepository: ref.watch(reviewScheduleRepositoryProvider),
    studentProgressRepository: ref.watch(studentProgressRepositoryProvider),
  );
});
