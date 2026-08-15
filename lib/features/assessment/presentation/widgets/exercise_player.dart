import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../shared/widgets/code_block.dart';
import '../../../../shared/widgets/markdown_text.dart';
import '../../../ai_teacher/presentation/providers/api_key_providers.dart';
import '../../../ai_teacher/presentation/providers/grading_providers.dart';
import '../../../curriculum/domain/models/item_type.dart';
import '../../domain/models/attempt_outcome.dart';
import '../../domain/models/practice_item.dart';
import '../providers/assessment_providers.dart';

/// Normalized result of an AI grading call, whether it came from
/// `AIProvider.assess` or `.evaluateExplanation` — those return slightly
/// different shapes ([AssessmentResult] has no `isComplete`).
class _AiGradeResult {
  const _AiGradeResult({
    required this.isCorrect,
    this.isComplete,
    required this.feedback,
  });

  final bool isCorrect;
  final bool? isComplete;
  final String feedback;
}

/// Drives a single [PracticeItem] through hints → answer → reveal/grade →
/// feedback, and records the outcome via [RecordAttemptUseCase]. Used by
/// the Lesson, Practice, and Review screens alike — see instructions.md
/// section 22 (progressive hints) and section 16 (assessment types).
class ExercisePlayer extends ConsumerStatefulWidget {
  const ExercisePlayer({
    super.key,
    required this.conceptId,
    required this.language,
    required this.item,
    this.onCompleted,
  });

  final String conceptId;
  final String language;
  final PracticeItem item;
  final VoidCallback? onCompleted;

  @override
  ConsumerState<ExercisePlayer> createState() => _ExercisePlayerState();
}

class _ExercisePlayerState extends ConsumerState<ExercisePlayer> {
  final _answerController = TextEditingController();
  int _revealedHints = 0;
  int? _selectedOptionIndex;
  bool _revealed = false;
  bool _submitted = false;
  bool? _mcqCorrect;
  bool _aiChecking = false;
  String? _aiCheckError;
  _AiGradeResult? _aiGradeResult;

  bool get _isMultipleChoice => widget.item.options != null;

  @override
  void didUpdateWidget(ExercisePlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.id != widget.item.id) {
      _answerController.clear();
      _revealedHints = 0;
      _selectedOptionIndex = null;
      _revealed = false;
      _submitted = false;
      _mcqCorrect = null;
      _aiChecking = false;
      _aiCheckError = null;
      _aiGradeResult = null;
    }
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _submitMcq() async {
    if (_selectedOptionIndex == null || _submitted) return;
    final isCorrect = _selectedOptionIndex == widget.item.correctOptionIndex;
    setState(() {
      _mcqCorrect = isCorrect;
      _revealed = true;
      _submitted = true;
    });

    await ref
        .read(attemptRecorderProvider)
        .call(
          conceptId: widget.conceptId,
          itemId: widget.item.id,
          itemKind: widget.item.kind,
          itemType: widget.item.type,
          outcome: AttemptOutcome(
            isCorrect: isCorrect,
            selfRating: null,
            hintsUsed: 0,
          ),
        );

    widget.onCompleted?.call();
  }

  void _revealAnswer() {
    setState(() => _revealed = true);
  }

  Future<void> _submitSelfRating(SelfRating rating) async {
    if (_submitted) return;
    setState(() => _submitted = true);

    await ref
        .read(attemptRecorderProvider)
        .call(
          conceptId: widget.conceptId,
          itemId: widget.item.id,
          itemKind: widget.item.kind,
          itemType: widget.item.type,
          outcome: AttemptOutcome(
            isCorrect: null,
            selfRating: rating,
            hintsUsed: _revealedHints,
            userResponse: _answerController.text.trim().isEmpty
                ? null
                : _answerController.text.trim(),
          ),
        );

    widget.onCompleted?.call();
  }

  Future<void> _checkWithAi() async {
    final answer = _answerController.text.trim();
    if (answer.isEmpty || _aiChecking || _submitted) return;

    setState(() {
      _aiChecking = true;
      _aiCheckError = null;
    });

    try {
      final _AiGradeResult result;
      if (widget.item.type == ItemType.explanation) {
        final evaluation = await ref
            .read(evaluateExplanationUseCaseProvider)
            .call(conceptId: widget.conceptId, learnerExplanation: answer);
        result = _AiGradeResult(
          isCorrect: evaluation.isCorrect,
          isComplete: evaluation.isComplete,
          feedback: evaluation.feedback,
        );
      } else {
        final assessment = await ref
            .read(assessUseCaseProvider)
            .call(conceptId: widget.conceptId, learnerResponse: answer);
        result = _AiGradeResult(
          isCorrect: assessment.isCorrect,
          feedback: assessment.feedback,
        );
      }

      if (!mounted) return;
      setState(() {
        _aiChecking = false;
        _aiGradeResult = result;
        _submitted = true;
      });

      await ref
          .read(attemptRecorderProvider)
          .call(
            conceptId: widget.conceptId,
            itemId: widget.item.id,
            itemKind: widget.item.kind,
            itemType: widget.item.type,
            outcome: AttemptOutcome(
              isCorrect: result.isCorrect,
              selfRating: null,
              hintsUsed: _revealedHints,
              userResponse: answer,
            ),
          );
      widget.onCompleted?.call();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _aiChecking = false;
        _aiCheckError = e is AppException
            ? e.userMessage
            : 'Something went wrong asking the AI teacher. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final item = widget.item;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _iconFor(item),
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(item.type.label, style: theme.textTheme.labelLarge),
              ],
            ),
            const SizedBox(height: 10),
            MarkdownText(data: item.prompt),
            if (item.code != null) ...[
              const SizedBox(height: 12),
              CodeBlock(
                code: item.code!,
                language: widget.language,
                showLineNumbers: true,
              ),
            ],
            const SizedBox(height: 16),
            if (_isMultipleChoice)
              _buildMultipleChoice(theme)
            else
              _buildSelfAssessed(theme),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(PracticeItem item) {
    if (item.options != null) return Icons.checklist_outlined;
    if (item.code != null) return Icons.terminal_outlined;
    return Icons.edit_note_outlined;
  }

  Widget _buildMultipleChoice(ThemeData theme) {
    final options = widget.item.options!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RadioGroup<int>(
          groupValue: _selectedOptionIndex,
          onChanged: _submitted
              ? (_) {}
              : (value) => setState(() => _selectedOptionIndex = value),
          child: Column(
            children: [
              for (var i = 0; i < options.length; i++)
                RadioListTile<int>(
                  value: i,
                  enabled: !_submitted,
                  title: Text(options[i]),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  activeColor: theme.colorScheme.primary,
                  tileColor: _submitted ? _mcqOptionColor(i, theme) : null,
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (!_submitted)
          FilledButton(
            onPressed: _selectedOptionIndex == null ? null : _submitMcq,
            child: const Text('Check Answer'),
          )
        else
          _FeedbackBanner(
            isCorrect: _mcqCorrect!,
            explanation: widget.item.mcqExplanation,
          ),
      ],
    );
  }

  Color? _mcqOptionColor(int index, ThemeData theme) {
    if (index == widget.item.correctOptionIndex) {
      return theme.colorScheme.primaryContainer.withValues(alpha: 0.5);
    }
    if (index == _selectedOptionIndex && !_mcqCorrect!) {
      return theme.colorScheme.errorContainer.withValues(alpha: 0.5);
    }
    return null;
  }

  Widget _buildSelfAssessed(ThemeData theme) {
    final item = widget.item;

    if (_submitted && _aiGradeResult != null) {
      // Graded by the AI teacher — this stands in for the reveal +
      // self-rating flow entirely, since the AI already judged correctness.
      return _AiGradeBanner(result: _aiGradeResult!);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!_revealed) ...[
          TextField(
            controller: _answerController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Type your answer here (optional — this just helps you think it through)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          if (item.hints.isNotEmpty) _buildHints(theme),
          const SizedBox(height: 12),
          if (_aiCheckError != null) ...[
            _AiCheckErrorBanner(
              message: _aiCheckError!,
              onRetry: _checkWithAi,
            ),
            const SizedBox(height: 12),
          ],
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton(
                onPressed: _revealAnswer,
                child: const Text('Reveal Answer'),
              ),
              if (ref.watch(isAiConfiguredProvider))
                FilledButton.tonalIcon(
                  onPressed: _aiChecking ? null : _checkWithAi,
                  icon: _aiChecking
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.smart_toy_outlined, size: 18),
                  label: Text(
                    _aiChecking ? 'Asking AI teacher...' : 'Ask AI to check this',
                  ),
                ),
            ],
          ),
        ] else ...[
          _buildSolution(theme),
          const SizedBox(height: 16),
          if (!_submitted) _buildSelfRating(theme) else _RecordedBanner(),
        ],
      ],
    );
  }

  Widget _buildHints(ThemeData theme) {
    final item = widget.item;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < _revealedHints; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              'Hint ${i + 1}: ${item.hints[i]}',
              style: theme.textTheme.bodyMedium,
            ),
          ),
        if (_revealedHints < item.hints.length)
          TextButton.icon(
            onPressed: () => setState(() => _revealedHints++),
            icon: const Icon(Icons.lightbulb_outline, size: 18),
            label: Text(
              _revealedHints == 0 ? 'Show a hint' : 'Show another hint',
            ),
          ),
      ],
    );
  }

  Widget _buildSolution(ThemeData theme) {
    final item = widget.item;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Model Answer', style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          if (item.expectedAnswer != null)
            MarkdownText(data: item.expectedAnswer!),
          if (item.solutionCode != null) ...[
            const SizedBox(height: 8),
            CodeBlock(code: item.solutionCode!, language: widget.language),
          ],
          if (item.revealExplanation != null) ...[
            const SizedBox(height: 8),
            MarkdownText(data: item.revealExplanation!),
          ],
        ],
      ),
    );
  }

  Widget _buildSelfRating(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('How did you do?', style: theme.textTheme.labelLarge),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: SelfRating.values
              .map(
                (rating) => OutlinedButton(
                  onPressed: () => _submitSelfRating(rating),
                  child: Text(rating.label),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _FeedbackBanner extends StatelessWidget {
  const _FeedbackBanner({required this.isCorrect, this.explanation});

  final bool isCorrect;
  final String? explanation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isCorrect
        ? theme.colorScheme.primary
        : theme.colorScheme.error;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                isCorrect ? 'Correct' : 'Not quite',
                style: theme.textTheme.titleSmall?.copyWith(color: color),
              ),
            ],
          ),
          if (explanation != null) ...[
            const SizedBox(height: 8),
            MarkdownText(data: explanation!),
          ],
        ],
      ),
    );
  }
}

/// Feedback from an AI-graded self-assessed exercise (see
/// [_ExercisePlayerState._checkWithAi]) — a stand-in for the reveal +
/// self-rating flow, since the AI already judged correctness.
class _AiGradeBanner extends StatelessWidget {
  const _AiGradeBanner({required this.result});

  final _AiGradeResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = result.isCorrect
        ? theme.colorScheme.primary
        : theme.colorScheme.error;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                result.isCorrect ? Icons.check_circle : Icons.cancel,
                color: color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                result.isCorrect ? 'Correct' : 'Not quite',
                style: theme.textTheme.titleSmall?.copyWith(color: color),
              ),
              if (result.isComplete == false) ...[
                const SizedBox(width: 8),
                Text(
                  '· Incomplete',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const Spacer(),
              Icon(
                Icons.smart_toy_outlined,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
          const SizedBox(height: 8),
          MarkdownText(data: result.feedback),
        ],
      ),
    );
  }
}

class _AiCheckErrorBanner extends StatelessWidget {
  const _AiCheckErrorBanner({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, size: 18, color: theme.colorScheme.error),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: theme.textTheme.bodyMedium)),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _RecordedBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(
          Icons.check_circle_outline,
          size: 18,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text('Recorded', style: theme.textTheme.bodyMedium),
      ],
    );
  }
}
