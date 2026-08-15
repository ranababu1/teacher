import 'package:equatable/equatable.dart';

/// One turn in an ephemeral "Ask the AI Teacher" conversation thread.
///
/// Conversations are scoped to a single lesson-screen visit and are kept
/// in memory only — see [AiConversationController] in
/// `presentation/providers/ai_teacher_providers.dart`.
class ConversationMessage extends Equatable {
  const ConversationMessage({
    required this.isFromLearner,
    required this.text,
    this.followUpQuestion,
    this.isError = false,
  });

  /// True if this turn was typed by the learner; false if it's the AI's
  /// reply (or an inline error bubble standing in for a failed reply).
  final bool isFromLearner;

  /// The learner's question, the AI's explanation, or a human-readable
  /// error message when [isError] is true.
  final String text;

  /// A suggested follow-up question from the AI. Only ever set on a
  /// successful AI message.
  final String? followUpQuestion;

  /// True if this turn represents a failed request rather than a real AI
  /// reply. Lets the thread surface an inline, recoverable error bubble
  /// instead of losing the conversation or the learner's question.
  final bool isError;

  @override
  List<Object?> get props => [isFromLearner, text, followUpQuestion, isError];
}
