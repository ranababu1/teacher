import '../../../core/errors/app_exception.dart';
import '../../curriculum/domain/models/exercise.dart';
import 'models/teacher_response.dart';

/// Provider-agnostic AI teaching contract — see instructions.md section 19.
///
/// No implementation exists yet (Gemini comes later, once the local
/// learning architecture and vertical slice are proven — see section 69).
/// The app must never call a concrete provider directly; callers go
/// through this interface via an AI Teacher Service / use case, never
/// straight from UI widgets.
abstract class AIProvider {
  Future<TeacherResponse> teach(TeacherRequest request);

  Future<AssessmentResult> assess(AssessmentRequest request);

  Future<Exercise> generateExercise(ExerciseRequest request);

  Future<ExplanationEvaluation> evaluateExplanation(ExplanationRequest request);

  /// A minimal round trip that succeeds only if the whole path — network,
  /// API key, and the AI service itself — is actually working. Used by
  /// Settings' "Test AI Connection" action; throws the same typed
  /// [AppException]s as every other method so callers get one consistent
  /// set of specific, plain-language failure reasons.
  Future<void> testConnection();
}
