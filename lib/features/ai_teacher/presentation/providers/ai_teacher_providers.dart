import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/models/conversation_message.dart';
import 'teach_providers.dart';

/// Manages one ephemeral "Ask the AI Teacher" conversation thread per
/// concept (family-keyed by `conceptId`). Nothing is persisted — a fresh
/// visit to the lesson screen starts a fresh thread.
///
/// State is always `AsyncData` once the initial (empty) thread has loaded.
/// A failed [sendMessage] never wipes history and never puts the provider
/// into `AsyncError` — that would either lose the learner's just-sent
/// question or force awkward `copyWithPrevious` juggling in the UI. Instead
/// the failure is appended to the thread as an inline error turn
/// ([ConversationMessage.isError]), so the learner sees exactly what went
/// wrong right where they asked it, with their question still visible, and
/// can simply try again.
class AiConversationController
    extends FamilyAsyncNotifier<List<ConversationMessage>, String> {
  @override
  Future<List<ConversationMessage>> build(String conceptId) async => const [];

  /// Sends [message] as the learner's turn for this concept and appends
  /// the AI's reply (or an inline error turn on failure) once it resolves.
  ///
  /// The learner's message is added to the thread optimistically, before
  /// the AI call resolves, so it's visible immediately while the reply is
  /// pending.
  Future<void> sendMessage(String message) async {
    final trimmed = message.trim();
    if (trimmed.isEmpty) return;
    await _ask(learnerVisibleText: trimmed, promptText: trimmed);
  }

  /// Fetches the next chunk after a truncated or intentionally split reply.
  ///
  /// Shows a short "Continue" learner bubble; the prompt sent to the model
  /// includes prior AI text (when we have it) so the next part does not
  /// repeat. Uses the existing teach path — no new product surface.
  Future<void> continueAnswer() async {
    final current = state.valueOrNull ?? const [];
    if (current.isEmpty) return;
    if (!(current.last.canContinue)) return;

    String priorAi = '';
    String? lastLearnerQuestion;
    for (final m in current.reversed) {
      if (!m.isFromLearner && !m.isError && m.text.trim().isNotEmpty) {
        if (priorAi.isEmpty) priorAi = m.text.trim();
      }
      if (m.isFromLearner && lastLearnerQuestion == null) {
        // Skip the synthetic "Continue" bubbles themselves.
        if (m.text.trim().toLowerCase() != 'continue') {
          lastLearnerQuestion = m.text.trim();
        }
      }
    }

    final prompt = StringBuffer()
      ..writeln(
        'Continue from where you stopped. Do not repeat earlier content. '
        'Keep this next part under about 10000 tokens; if still incomplete, '
        'set needsContinuation to true again.',
      );
    if (priorAi.isNotEmpty) {
      prompt
        ..writeln()
        ..writeln('What you already said:')
        ..writeln('"""')
        ..writeln(priorAi)
        ..writeln('"""');
    } else if (lastLearnerQuestion != null && lastLearnerQuestion.isNotEmpty) {
      prompt
        ..writeln()
        ..writeln("The learner's question was:")
        ..writeln('"""')
        ..writeln(lastLearnerQuestion)
        ..writeln('"""');
    }

    await _ask(learnerVisibleText: 'Continue', promptText: prompt.toString());
  }

  Future<void> _ask({
    required String learnerVisibleText,
    required String promptText,
  }) async {
    final conceptId = arg;
    final current = state.valueOrNull ?? const [];
    final withLearnerMessage = [
      ...current,
      ConversationMessage(isFromLearner: true, text: learnerVisibleText),
    ];
    state = AsyncData(withLearnerMessage);

    try {
      final response = await ref
          .read(teachUseCaseProvider)
          .call(conceptId: conceptId, learnerMessage: promptText);
      state = AsyncData([
        ...withLearnerMessage,
        ConversationMessage(
          isFromLearner: false,
          text: response.explanation,
          followUpQuestion: response.followUpQuestion,
          canContinue: response.needsContinuation,
        ),
      ]);
    } catch (e) {
      final truncated =
          e is AIUnavailableException &&
          (e.message.contains('max_tokens') ||
              e.userMessage == aiTruncatedUserMessage);
      final userMessage = truncated
          ? aiTruncatedUserMessage
          : (e is AppException
                ? e.userMessage
                : 'Something went wrong asking the AI teacher. Please try again.');
      state = AsyncData([
        ...withLearnerMessage,
        ConversationMessage(
          isFromLearner: false,
          text: userMessage,
          isError: true,
          canContinue: truncated,
        ),
      ]);
    }
  }
}

final aiConversationControllerProvider =
    AsyncNotifierProvider.family<
      AiConversationController,
      List<ConversationMessage>,
      String
    >(AiConversationController.new);
