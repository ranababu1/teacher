import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/generate_exercise_use_case.dart';
import 'teach_providers.dart';

/// AI-authored practice exercises — see [GenerateExerciseUseCase] for why
/// these are never persisted back into curriculum content.
final generateExerciseUseCaseProvider = Provider<GenerateExerciseUseCase>((
  ref,
) {
  return GenerateExerciseUseCase(
    contextBuilder: ref.watch(teachingContextBuilderProvider),
    aiProvider: ref.watch(aiProviderProvider),
    requestLoggingEnabled: ref.watch(aiRequestLoggingEnabledProvider),
  );
});
