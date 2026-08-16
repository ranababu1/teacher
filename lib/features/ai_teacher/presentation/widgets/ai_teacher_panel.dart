import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/routes.dart';
import '../../../../shared/widgets/fade_slide_in.dart';
import '../../../../shared/widgets/markdown_text.dart';
import '../../../settings/domain/settings_models.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../../domain/models/conversation_message.dart';
import '../providers/ai_teacher_providers.dart';
import '../providers/api_key_providers.dart';

/// "Ask the AI Teacher" — lets the learner ask free-form questions about
/// the concept they're currently viewing and get a context-aware answer.
///
/// Meant to sit inline among the Lesson screen's other sections (see
/// instructions.md sections 19-21); the caller wires it into that screen's
/// section list.
class AiTeacherPanel extends ConsumerStatefulWidget {
  const AiTeacherPanel({super.key, required this.conceptId});

  final String conceptId;

  @override
  ConsumerState<AiTeacherPanel> createState() => _AiTeacherPanelState();
}

class _AiTeacherPanelState extends ConsumerState<AiTeacherPanel> {
  final _inputController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  Future<void> _send([String? overrideText]) async {
    final text = (overrideText ?? _inputController.text).trim();
    if (text.isEmpty || _isSending) return;

    _inputController.clear();
    setState(() => _isSending = true);
    await ref
        .read(aiConversationControllerProvider(widget.conceptId).notifier)
        .sendMessage(text);
    if (!mounted) return;
    setState(() => _isSending = false);
  }

  @override
  Widget build(BuildContext context) {
    if (!ref.watch(isAiConfiguredProvider)) {
      final providerLabel =
          ref.watch(settingsControllerProvider).valueOrNull?.aiProviderKind.displayName ??
          AiProviderKind.gemini.displayName;
      return _NotConfiguredCard(providerLabel: providerLabel);
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final messages =
        ref
            .watch(aiConversationControllerProvider(widget.conceptId))
            .valueOrNull ??
        const [];

    // If the thread's last turn is an error, the turn right before it is
    // always the learner message that triggered it (see
    // AiConversationController.sendMessage) — retrying just resends it.
    String? retryText;
    if (messages.length > 1 && messages.last.isError) {
      final previous = messages[messages.length - 2];
      if (previous.isFromLearner) retryText = previous.text;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.smart_toy_outlined,
              size: 20,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text('Ask the AI Teacher', style: theme.textTheme.titleMedium),
          ],
        ),
        const SizedBox(height: 12),
        if (messages.isEmpty)
          Text(
            'Ask about anything on this page.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          )
        else
          for (var i = 0; i < messages.length; i++)
            FadeSlideIn(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _MessageBubble(
                  message: messages[i],
                  onRetry: (i == messages.length - 1 && retryText != null)
                      ? () => _send(retryText)
                      : null,
                ),
              ),
            ),
        if (_isSending)
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: _ThinkingIndicator(),
          ),
        const SizedBox(height: 4),
        _InputRow(
          controller: _inputController,
          enabled: !_isSending,
          onSend: _send,
        ),
      ],
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, this.onRetry});

  final ConversationMessage message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (message.isFromLearner) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            message.text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onPrimaryContainer,
            ),
          ),
        ),
      );
    }

    if (message.isError) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.errorContainer.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.error_outline, size: 18, color: colorScheme.error),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(message.text, style: theme.textTheme.bodyMedium),
                ),
              ],
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: onRetry,
                  child: const Text('Try again'),
                ),
              ),
            ],
          ],
        ),
      );
    }

    // A successful AI reply.
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MarkdownText(data: message.text),
            if (message.followUpQuestion != null) ...[
              const SizedBox(height: 10),
              Divider(
                height: 1,
                color: colorScheme.outlineVariant.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.forum_outlined,
                    size: 16,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      message.followUpQuestion!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ThinkingIndicator extends StatelessWidget {
  const _ThinkingIndicator();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        const SizedBox(width: 10),
        Text(
          'The AI teacher is thinking...',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _InputRow extends StatelessWidget {
  const _InputRow({
    required this.controller,
    required this.enabled,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool enabled;
  final Future<void> Function() onSend;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            enabled: enabled,
            minLines: 1,
            maxLines: 4,
            textInputAction: TextInputAction.send,
            onSubmitted: enabled ? (_) => onSend() : null,
            decoration: const InputDecoration(
              hintText: 'Ask a question about this concept...',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton.filled(
          onPressed: enabled ? onSend : null,
          icon: const Icon(Icons.arrow_upward),
        ),
      ],
    );
  }
}

class _NotConfiguredCard extends StatelessWidget {
  const _NotConfiguredCard({required this.providerLabel});

  final String providerLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.smart_toy_outlined,
                size: 20,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text('AI Teacher', style: theme.textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Ask free-form questions about this concept and get a '
            'context-aware answer. This needs your own $providerLabel API '
            'key — add one in Settings to turn it on.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.tonalIcon(
              onPressed: () => context.go(Routes.profileSettings),
              icon: const Icon(Icons.settings_outlined, size: 18),
              label: const Text('Go to Settings'),
            ),
          ),
        ],
      ),
    );
  }
}
