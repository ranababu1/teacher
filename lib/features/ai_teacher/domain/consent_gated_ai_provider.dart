import '../../../core/errors/app_exception.dart';
import '../../../core/services/ai_activity.dart';
import '../../curriculum/domain/models/assessment.dart';
import '../../curriculum/domain/models/exercise.dart';
import 'ai_provider.dart';
import 'models/roadmap_generation.dart';
import 'models/study_coaching.dart';
import 'models/teacher_response.dart';

/// Wraps a real [AIProvider] so no request leaves the device until the
/// learner has agreed to share data with that provider. Every AI feature
/// goes through `aiProviderProvider`, so this one gate covers them all.
class ConsentGatedAiProvider implements AIProvider {
  const ConsentGatedAiProvider({
    required this.inner,
    required this.ensureConsent,
    required this.providerName,
  });

  final AIProvider inner;

  /// True once the learner has agreed, asking them first if needed.
  final Future<bool> Function() ensureConsent;
  final String providerName;

  Future<T> _gated<T>(Future<T> Function() request) =>
      AiActivity.track(() async {
        if (!await ensureConsent()) {
          throw AiConsentDeclinedException(providerName);
        }
        return request();
      });

  @override
  Future<TeacherResponse> teach(TeacherRequest request) =>
      _gated(() => inner.teach(request));

  @override
  Future<AssessmentResult> assess(AssessmentRequest request) =>
      _gated(() => inner.assess(request));

  @override
  Future<Exercise> generateExercise(ExerciseRequest request) =>
      _gated(() => inner.generateExercise(request));

  @override
  Future<ExplanationEvaluation> evaluateExplanation(
    ExplanationRequest request,
  ) => _gated(() => inner.evaluateExplanation(request));

  @override
  Future<List<Assessment>> generateModuleTest(ModuleTestRequest request) =>
      _gated(() => inner.generateModuleTest(request));

  @override
  Future<void> testConnection() => _gated(inner.testConnection);

  @override
  Future<StudyCoachingAdvice> coachStudyPlan(StudyCoachingRequest request) =>
      _gated(() => inner.coachStudyPlan(request));

  @override
  Future<RoadmapDraft> generateRoadmap(RoadmapGenerationRequest request) =>
      _gated(() => inner.generateRoadmap(request));
}
