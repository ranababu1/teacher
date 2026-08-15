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

    final conceptId = arg;
    final current = state.valueOrNull ?? const [];
    final withLearnerMessage = [
      ...current,
      ConversationMessage(isFromLearner: true, text: trimmed),
    ];
    state = AsyncData(withLearnerMessage);

    try {
      final response = await ref
          .read(teachUseCaseProvider)
          .call(conceptId: conceptId, learnerMessage: trimmed);
      state = AsyncData([
        ...withLearnerMessage,
        ConversationMessage(
          isFromLearner: false,
          text: response.explanation,
          followUpQuestion: response.followUpQuestion,
        ),
      ]);
    } catch (e) {
      final userMessage = e is AppException
          ? e.userMessage
          : 'Something went wrong asking the AI teacher. Please try again.';
      state = AsyncData([
        ...withLearnerMessage,
        ConversationMessage(
          isFromLearner: false,
          text: userMessage,
          isError: true,
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
