import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/assess_use_case.dart';
import '../../domain/evaluate_explanation_use_case.dart';
import 'misconception_providers.dart';
import 'teach_providers.dart';

/// AI-graded feedback for free-text exercises (short answer, scenario,
/// debugging, coding) — see [ExercisePlayer]'s "Ask AI to check this"
/// action. Offline learners keep the existing self-rating flow; this is an
/// additional option, never a replacement, per instructions.md section 26.
final assessUseCaseProvider = Provider<AssessUseCase>((ref) {
  return AssessUseCase(
    contextBuilder: ref.watch(teachingContextBuilderProvider),
    misconceptionRepository: ref.watch(misconceptionRepositoryProvider),
    aiProvider: ref.watch(aiProviderProvider),
    requestLoggingEnabled: ref.watch(aiRequestLoggingEnabledProvider),
  );
});

/// AI-graded feedback for "explain in your own words" exercises.
final evaluateExplanationUseCaseProvider =
    Provider<EvaluateExplanationUseCase>((ref) {
      return EvaluateExplanationUseCase(
        contextBuilder: ref.watch(teachingContextBuilderProvider),
        misconceptionRepository: ref.watch(misconceptionRepositoryProvider),
        aiProvider: ref.watch(aiProviderProvider),
        requestLoggingEnabled: ref.watch(aiRequestLoggingEnabledProvider),
      );
    });
