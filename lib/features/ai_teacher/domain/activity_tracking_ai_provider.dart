import '../../curriculum/domain/models/assessment.dart';
import '../../curriculum/domain/models/exercise.dart';
import 'ai_provider.dart';
import 'models/roadmap_generation.dart';
import 'models/study_coaching.dart';
import 'models/teacher_response.dart';

/// Wraps an [AIProvider] and reports when a request starts and finishes,
/// so other parts of the app (ads) can stay out of the way meanwhile.
class ActivityTrackingAiProvider implements AIProvider {
  const ActivityTrackingAiProvider({
    required this.inner,
    required this.onStart,
    required this.onFinish,
  });

  final AIProvider inner;
  final void Function() onStart;
  final void Function() onFinish;

  Future<T> _tracked<T>(Future<T> Function() request) async {
    onStart();
    try {
      return await request();
    } finally {
      onFinish();
    }
  }

  @override
  Future<TeacherResponse> teach(TeacherRequest request) =>
      _tracked(() => inner.teach(request));

  @override
  Future<AssessmentResult> assess(AssessmentRequest request) =>
      _tracked(() => inner.assess(request));

  @override
  Future<Exercise> generateExercise(ExerciseRequest request) =>
      _tracked(() => inner.generateExercise(request));

  @override
  Future<ExplanationEvaluation> evaluateExplanation(
    ExplanationRequest request,
  ) => _tracked(() => inner.evaluateExplanation(request));

  @override
  Future<List<Assessment>> generateModuleTest(ModuleTestRequest request) =>
      _tracked(() => inner.generateModuleTest(request));

  @override
  Future<void> testConnection() => _tracked(inner.testConnection);

  @override
  Future<StudyCoachingAdvice> coachStudyPlan(StudyCoachingRequest request) =>
      _tracked(() => inner.coachStudyPlan(request));

  @override
  Future<RoadmapDraft> generateRoadmap(RoadmapGenerationRequest request) =>
      _tracked(() => inner.generateRoadmap(request));
}
