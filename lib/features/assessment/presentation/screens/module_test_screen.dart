import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/routes.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../../shared/widgets/markdown_text.dart';
import '../../../ai_teacher/presentation/providers/api_key_providers.dart';
import '../../../ai_teacher/presentation/providers/module_test_providers.dart';
import '../../../curriculum/domain/models/assessment.dart';
import '../../../curriculum/domain/models/curriculum_module.dart';
import '../../../curriculum/domain/models/item_type.dart';
import '../../../curriculum/domain/models/learning_path.dart';
import '../../../curriculum/presentation/curriculum_providers.dart';
import '../../../progress/domain/models/module_test_result.dart';
import '../../../progress/domain/module_unlock.dart';
import '../../../progress/presentation/providers/progress_providers.dart';

/// A gating test covering an entire module ("topic"), always built from
/// the module's own curated static assessments (curriculum content, not
/// AI-generated) so passing is deterministic and doesn't depend on AI
/// availability or output quality. All questions are multiple-choice,
/// graded locally and instantly. Passing at ≥70% unlocks the next module
/// in the path. Once passed, a learner with an AI provider configured
/// can optionally generate a fresh 20-question AI practice round — purely
/// extra practice, never persisted, and never re-gates anything.
class ModuleTestScreen extends ConsumerStatefulWidget {
  const ModuleTestScreen({
    super.key,
    required this.pathId,
    required this.moduleId,
  });

  final String pathId;
  final String moduleId;

  @override
  ConsumerState<ModuleTestScreen> createState() => _ModuleTestScreenState();
}

enum _Phase { intro, inProgress, result }

class _ModuleTestScreenState extends ConsumerState<ModuleTestScreen> {
  _Phase _phase = _Phase.intro;
  String? _startError;
  List<Assessment> _questions = const [];
  int _currentIndex = 0;
  int _correctCount = 0;
  int? _selectedOptionIndex;
  bool _questionSubmitted = false;
  bool _isPracticeRound = false;
  bool _practiceLoading = false;
  String? _practiceError;

  void _start(CurriculumModule module) {
    final questions =
        module.concepts
            .expand((c) => c.assessments)
            .where((a) => a.type == ItemType.multipleChoice)
            .toList()
          ..shuffle();

    if (questions.isEmpty) {
      setState(() {
        _startError = "This topic doesn't have any test questions yet.";
      });
      return;
    }

    setState(() {
      _questions = questions;
      _currentIndex = 0;
      _correctCount = 0;
      _selectedOptionIndex = null;
      _questionSubmitted = false;
      _isPracticeRound = false;
      _startError = null;
      _phase = _Phase.inProgress;
    });
  }

  Future<void> _startPracticeRound() async {
    setState(() {
      _practiceLoading = true;
      _practiceError = null;
    });
    try {
      final questions = await ref
          .read(generateModuleTestUseCaseProvider)
          .call(
            learningPathId: widget.pathId,
            moduleId: widget.moduleId,
            questionCount: 20,
          );

      if (questions.isEmpty) {
        throw const InvalidAIResponseException(
          'No practice questions were generated for this topic',
        );
      }

      if (!mounted) return;
      setState(() {
        _questions = questions;
        _currentIndex = 0;
        _correctCount = 0;
        _selectedOptionIndex = null;
        _questionSubmitted = false;
        _isPracticeRound = true;
        _practiceLoading = false;
        _phase = _Phase.inProgress;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _practiceLoading = false;
        _practiceError = e is AppException
            ? e.userMessage
            : "Couldn't generate practice questions. Please try again.";
      });
    }
  }

  void _submitAnswer() {
    if (_selectedOptionIndex == null || _questionSubmitted) return;
    final question = _questions[_currentIndex];
    final isCorrect = _selectedOptionIndex == question.correctOptionIndex;
    setState(() {
      _questionSubmitted = true;
      if (isCorrect) _correctCount++;
    });
  }

  void _nextQuestion() {
    if (_currentIndex + 1 < _questions.length) {
      setState(() {
        _currentIndex++;
        _selectedOptionIndex = null;
        _questionSubmitted = false;
      });
    } else {
      setState(() => _phase = _Phase.result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pathValue = ref.watch(learningPathProvider(widget.pathId));

    return Scaffold(
      appBar: AppBar(title: const Text('Topic Test')),
      body: SafeArea(
        child: AsyncValueView(
          value: pathValue,
          onRetry: () =>
              ref.invalidate(learningPathProvider(widget.pathId)),
          data: (path) {
            final module = path?.findModule(widget.moduleId);
            if (path == null || module == null) {
              return const Center(child: Text('Topic not found.'));
            }

            return switch (_phase) {
              _Phase.intro => _buildIntro(module),
              _Phase.inProgress => _buildInProgress(),
              _Phase.result => _buildResult(path, module),
            };
          },
        ),
      ),
    );
  }

  Widget _buildIntro(CurriculumModule module) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.quiz_outlined, size: 40, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              module.title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'At least 10 questions, need 70% to pass and unlock the next '
              'topic.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            if (_startError != null) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  _startError!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
            ],
            FilledButton(
              onPressed: () => _start(module),
              child: const Text('Start'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInProgress() {
    final theme = Theme.of(context);
    final question = _questions[_currentIndex];
    final options = question.options ?? const [];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Question ${_currentIndex + 1} of ${_questions.length}',
          style: theme.textTheme.labelLarge,
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MarkdownText(data: question.prompt),
                const SizedBox(height: 16),
                RadioGroup<int>(
                  groupValue: _selectedOptionIndex,
                  onChanged: _questionSubmitted
                      ? (_) {}
                      : (value) => setState(() => _selectedOptionIndex = value),
                  child: Column(
                    children: [
                      for (var i = 0; i < options.length; i++)
                        RadioListTile<int>(
                          value: i,
                          enabled: !_questionSubmitted,
                          title: Text(options[i]),
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          activeColor: theme.colorScheme.primary,
                          tileColor: _questionSubmitted
                              ? _optionColor(i, question, theme)
                              : null,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                if (!_questionSubmitted)
                  FilledButton(
                    onPressed: _selectedOptionIndex == null
                        ? null
                        : _submitAnswer,
                    child: const Text('Check Answer'),
                  )
                else ...[
                  _FeedbackRow(
                    isCorrect: _selectedOptionIndex == question.correctOptionIndex,
                    explanation: question.explanation,
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton(
                      onPressed: _nextQuestion,
                      child: Text(
                        _currentIndex + 1 < _questions.length
                            ? 'Next'
                            : 'See Result',
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color? _optionColor(int index, Assessment question, ThemeData theme) {
    if (index == question.correctOptionIndex) {
      return theme.colorScheme.primaryContainer.withValues(alpha: 0.5);
    }
    if (index == _selectedOptionIndex) {
      return theme.colorScheme.errorContainer.withValues(alpha: 0.5);
    }
    return null;
  }

  Widget _buildResult(LearningPath path, CurriculumModule module) {
    final theme = Theme.of(context);
    final result = ModuleTestResult(
      correctCount: _correctCount,
      totalQuestions: _questions.length,
    );

    if (!_isPracticeRound && result.isPassed) {
      // Fire-and-forget: the result screen doesn't need to await this to
      // render, and RecordAttemptUseCase-style recorders elsewhere in this
      // app are written the same way (see LearningPathStarter). Practice
      // rounds are ephemeral and never recorded — the module is already
      // unlocked by this point.
      ref
          .read(moduleTestRecorderProvider)
          .call(
            learningPathId: widget.pathId,
            moduleId: widget.moduleId,
            scorePercent: result.scorePercent,
            questionCount: result.totalQuestions,
          );
    }

    final next = nextModule(path: path, module: module);
    final canOfferPractice =
        !_isPracticeRound &&
        result.isPassed &&
        ref.watch(isAiConfiguredProvider);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              result.isPassed ? Icons.check_circle_outline : Icons.cancel_outlined,
              size: 48,
              color: result.isPassed
                  ? theme.colorScheme.primary
                  : theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              _isPracticeRound
                  ? 'Practice round complete'
                  : (result.isPassed ? 'Passed!' : 'Not quite'),
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _isPracticeRound
                  ? '${result.correctCount} of ${result.totalQuestions} '
                        'correct (${result.scorePercent}%).'
                  : '${result.correctCount} of ${result.totalQuestions} '
                        'correct (${result.scorePercent}%) — need 70% to '
                        'pass.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (_practiceError != null) ...[
              const SizedBox(height: 8),
              Text(
                _practiceError!,
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ],
            const SizedBox(height: 24),
            if (_isPracticeRound)
              Wrap(
                spacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: () => context.go(
                      Routes.module(widget.pathId, widget.moduleId),
                    ),
                    child: const Text('Back to Topic'),
                  ),
                  FilledButton(
                    onPressed: _practiceLoading ? null : _startPracticeRound,
                    child: _practiceLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Practice Again'),
                  ),
                ],
              )
            else if (result.isPassed)
              Column(
                children: [
                  FilledButton(
                    onPressed: () => context.go(
                      next != null
                          ? Routes.module(widget.pathId, next.id)
                          : Routes.learningPath(widget.pathId),
                    ),
                    child: Text(
                      next != null ? 'Continue to Next Topic' : 'Back to Course',
                    ),
                  ),
                  if (canOfferPractice) ...[
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: _practiceLoading ? null : _startPracticeRound,
                      child: _practiceLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Practice More (20 AI Questions)'),
                    ),
                  ],
                ],
              )
            else
              Wrap(
                spacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: () => context.go(
                      Routes.module(widget.pathId, widget.moduleId),
                    ),
                    child: const Text('Back to Topic'),
                  ),
                  FilledButton(
                    onPressed: () => setState(() => _phase = _Phase.intro),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _FeedbackRow extends StatelessWidget {
  const _FeedbackRow({required this.isCorrect, this.explanation});

  final bool isCorrect;
  final String? explanation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isCorrect ? theme.colorScheme.primary : theme.colorScheme.error;
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
