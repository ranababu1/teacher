import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/navigation.dart';
import '../../../../shared/widgets/code_block.dart';
import '../../../../shared/widgets/difficulty_chip.dart';
import '../../../../shared/widgets/markdown_text.dart';
import '../../../ai_teacher/presentation/providers/misconception_providers.dart';
import '../../../assessment/domain/models/practice_item.dart';
import '../../../assessment/presentation/widgets/exercise_player.dart';
import '../../../curriculum/domain/models/concept.dart';
import '../../../curriculum/domain/models/learning_path.dart';
import '../../../curriculum/presentation/curriculum_providers.dart';
import '../../domain/lesson_step.dart';

/// The body of one lesson step. Pure presentation: all state lives in
/// `LessonFlowController`.
class LessonStepView extends StatelessWidget {
  const LessonStepView({
    super.key,
    required this.concept,
    required this.step,
    required this.answer,
    required this.onAnswer,
  });

  final Concept concept;
  final LessonStep step;

  /// The picked option for a quick check step, if answered.
  final int? answer;
  final ValueChanged<int> onAnswer;

  @override
  Widget build(BuildContext context) {
    final language = languageForLearningPathId(concept.learningPathId);
    return switch (step) {
      GoalsStep s => _GoalsView(concept: concept, step: s),
      ExplanationStep s => _ExplanationView(step: s),
      QuickCheckStep s => _QuickCheckView(
        check: s.check,
        answer: answer,
        onAnswer: onAnswer,
      ),
      ExampleStep s => _ExampleView(step: s),
      MisconceptionsStep _ => _Titled(
        title: 'Common misconceptions',
        child: LessonMisconceptions(concept: concept),
      ),
      TryItStep s => _Titled(
        title: 'Try it',
        child: Column(
          children: [
            for (final exercise in s.exercises)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ExercisePlayer(
                  conceptId: concept.id,
                  language: language,
                  item: PracticeItem.fromExercise(exercise),
                ),
              ),
          ],
        ),
      ),
      CheckUnderstandingStep s => _Titled(
        title: 'Check your understanding',
        child: Column(
          children: [
            for (final assessment in s.assessments)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ExercisePlayer(
                  conceptId: concept.id,
                  language: language,
                  item: PracticeItem.fromAssessment(assessment),
                ),
              ),
          ],
        ),
      ),
    };
  }
}

class _Titled extends StatelessWidget {
  const _Titled({required this.title, required this.child, this.subtitle});

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.titleLarge),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

class _GoalsView extends ConsumerWidget {
  const _GoalsView({required this.concept, required this.step});

  final Concept concept;
  final GoalsStep step;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final prereqs = step.hasPrerequisites
        ? ref.watch(prerequisiteConceptsProvider(concept.id)).valueOrNull ??
              const <Concept>[]
        : const <Concept>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(concept.title, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(concept.description, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 10),
        Row(
          children: [
            DifficultyChip(difficulty: concept.difficulty),
            const SizedBox(width: 8),
            Icon(
              Icons.schedule,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              '${concept.estimatedMinutes} min',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        if (step.objectives.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text('You will learn to', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final objective in step.objectives)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check, size: 18, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(child: Text(objective)),
                ],
              ),
            ),
        ],
        if (prereqs.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text('Helps to know first', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final p in prereqs)
                ActionChip(
                  label: Text(p.title),
                  avatar: const Icon(Icons.link, size: 16),
                  onPressed: () =>
                      context.openLesson(p.learningPathId, p.moduleId, p.id),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _ExplanationView extends StatelessWidget {
  const _ExplanationView({required this.step});

  final ExplanationStep step;

  @override
  Widget build(BuildContext context) {
    return _Titled(
      title: step.heading,
      subtitle: step.partCount > 1
          ? 'Part ${step.part} of ${step.partCount}'
          : null,
      child: MarkdownText(data: step.body, selectable: false),
    );
  }
}

class _QuickCheckView extends StatelessWidget {
  const _QuickCheckView({
    required this.check,
    required this.answer,
    required this.onAnswer,
  });

  final QuickCheck check;
  final int? answer;
  final ValueChanged<int> onAnswer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final picked = answer;
    return _Titled(
      title: 'Quick check',
      subtitle: picked == null ? 'Answer to continue' : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MarkdownText(data: check.prompt, selectable: false),
          const SizedBox(height: 12),
          for (final (i, option) in check.options.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: OutlinedButton(
                key: ValueKey('quick-option-$i'),
                style: OutlinedButton.styleFrom(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  backgroundColor: picked == null
                      ? null
                      : i == check.correctIndex
                      ? scheme.primaryContainer
                      : i == picked
                      ? scheme.errorContainer
                      : null,
                  foregroundColor: picked == null
                      ? null
                      : i == check.correctIndex
                      ? scheme.onPrimaryContainer
                      : i == picked
                      ? scheme.onErrorContainer
                      : null,
                ),
                onPressed: picked == null ? () => onAnswer(i) : null,
                child: Text(option),
              ),
            ),
          if (picked != null) ...[
            const SizedBox(height: 8),
            Container(
              key: const ValueKey('quick-feedback'),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: check.isCorrect(picked)
                    ? scheme.primaryContainer
                    : scheme.errorContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    check.isCorrect(picked)
                        ? 'Correct!'
                        : 'Not quite. The answer is '
                              '"${check.options[check.correctIndex]}".',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: check.isCorrect(picked)
                          ? scheme.onPrimaryContainer
                          : scheme.onErrorContainer,
                    ),
                  ),
                  if (check.feedback.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      check.feedback,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: check.isCorrect(picked)
                            ? scheme.onPrimaryContainer
                            : scheme.onErrorContainer,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ExampleView extends StatelessWidget {
  const _ExampleView({required this.step});

  final ExampleStep step;

  @override
  Widget build(BuildContext context) {
    final example = step.example;
    return _Titled(
      title: example.title.isEmpty ? 'Example' : example.title,
      subtitle: step.count > 1
          ? 'Example ${step.index + 1} of ${step.count}'
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CodeBlock(
            code: example.code,
            language: example.language,
            showLineNumbers: true,
          ),
          const SizedBox(height: 12),
          Text(example.explanation),
        ],
      ),
    );
  }
}

class LessonMisconceptions extends ConsumerWidget {
  const LessonMisconceptions({super.key, required this.concept});

  final Concept concept;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final detected =
        ref.watch(unresolvedMisconceptionsProvider(concept.id)).valueOrNull ??
        const [];

    if (concept.misconceptions.isEmpty && detected.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final misconception in concept.misconceptions)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.close, size: 16, color: theme.colorScheme.error),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        misconception.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(misconception.clarification)),
                  ],
                ),
              ],
            ),
          ),
        for (final misconception in detected)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.psychology_alt_outlined,
                  size: 16,
                  color: theme.colorScheme.tertiary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        misconception.description,
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Flagged by the AI teacher during a recent conversation',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
