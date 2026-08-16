import '../../settings/domain/settings_models.dart';
import '../domain/models/teaching_context.dart';
import 'shared_prompt_builder.dart' as shared;

/// A ready-to-send Claude prompt: a system instruction (persona, teaching
/// principles, output-format rule) and the user content (the assembled
/// teaching context plus the specific ask).
typedef AnthropicPrompt = ({String systemInstruction, String userContent});

/// Thin Claude-specific wrapper over the shared, provider-agnostic prompt
/// builders in `shared_prompt_builder.dart` — like Gemini, Claude enforces
/// its response shape via `output_config.format.json_schema`, so it uses
/// [shared.nativeSchemaOutputInstruction].
AnthropicPrompt buildTeachPrompt(
  TeachingContext context,
  String? learnerMessage, {
  required ExplanationDepth depth,
}) => shared.buildTeachPrompt(
  context,
  learnerMessage,
  depth: depth,
  outputInstruction: shared.nativeSchemaOutputInstruction,
);

AnthropicPrompt buildAssessPrompt(
  TeachingContext context,
  String learnerResponse, {
  required ExplanationDepth depth,
}) => shared.buildAssessPrompt(
  context,
  learnerResponse,
  depth: depth,
  outputInstruction: shared.nativeSchemaOutputInstruction,
);

AnthropicPrompt buildGenerateExercisePrompt(
  TeachingContext context, {
  required ExplanationDepth depth,
}) => shared.buildGenerateExercisePrompt(
  context,
  depth: depth,
  outputInstruction: shared.nativeSchemaOutputInstruction,
);

AnthropicPrompt buildEvaluateExplanationPrompt(
  TeachingContext context,
  String learnerExplanation, {
  required ExplanationDepth depth,
}) => shared.buildEvaluateExplanationPrompt(
  context,
  learnerExplanation,
  depth: depth,
  outputInstruction: shared.nativeSchemaOutputInstruction,
);
