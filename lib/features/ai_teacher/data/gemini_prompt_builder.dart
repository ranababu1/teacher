import '../../settings/domain/settings_models.dart';
import '../domain/models/module_test_context.dart';
import '../domain/models/teaching_context.dart';
import 'shared_prompt_builder.dart' as shared;

/// A ready-to-send Gemini prompt: a system instruction (persona, teaching
/// principles, output-format rule) and the user content (the assembled
/// teaching context plus the specific ask).
typedef GeminiPrompt = ({String systemInstruction, String userContent});

/// Thin Gemini-specific wrapper over the shared, provider-agnostic prompt
/// builders in `shared_prompt_builder.dart` — Gemini enforces its response
/// shape via `responseSchema`, so it uses [shared.nativeSchemaOutputInstruction].
GeminiPrompt buildTeachPrompt(
  TeachingContext context,
  String? learnerMessage, {
  required ExplanationDepth depth,
}) => shared.buildTeachPrompt(
  context,
  learnerMessage,
  depth: depth,
  outputInstruction: shared.nativeSchemaOutputInstruction,
);

GeminiPrompt buildAssessPrompt(
  TeachingContext context,
  String learnerResponse, {
  required ExplanationDepth depth,
}) => shared.buildAssessPrompt(
  context,
  learnerResponse,
  depth: depth,
  outputInstruction: shared.nativeSchemaOutputInstruction,
);

GeminiPrompt buildGenerateExercisePrompt(
  TeachingContext context, {
  required ExplanationDepth depth,
}) => shared.buildGenerateExercisePrompt(
  context,
  depth: depth,
  outputInstruction: shared.nativeSchemaOutputInstruction,
);

GeminiPrompt buildEvaluateExplanationPrompt(
  TeachingContext context,
  String learnerExplanation, {
  required ExplanationDepth depth,
}) => shared.buildEvaluateExplanationPrompt(
  context,
  learnerExplanation,
  depth: depth,
  outputInstruction: shared.nativeSchemaOutputInstruction,
);

GeminiPrompt buildModuleTestPrompt(
  ModuleTestContext context, {
  required int questionCount,
  required ExplanationDepth depth,
}) => shared.buildModuleTestPrompt(
  context,
  questionCount: questionCount,
  depth: depth,
  outputInstruction: shared.nativeSchemaOutputInstruction,
);
