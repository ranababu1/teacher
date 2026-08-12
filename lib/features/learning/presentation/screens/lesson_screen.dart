import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/routes.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../../shared/widgets/code_block.dart';
import '../../../../shared/widgets/difficulty_chip.dart';
import '../../../../shared/widgets/markdown_text.dart';
import '../../../assessment/domain/models/practice_item.dart';
import '../../../assessment/presentation/widgets/exercise_player.dart';
import '../../../curriculum/domain/models/concept.dart';
import '../../../curriculum/domain/models/learning_path.dart';
import '../../../curriculum/presentation/curriculum_providers.dart';
import '../../../progress/presentation/providers/progress_providers.dart';

class LessonScreen extends ConsumerStatefulWidget {
  const LessonScreen({
    super.key,
    required this.pathId,
    required this.moduleId,
    required this.conceptId,
  });

  final String pathId;
  final String moduleId;
  final String conceptId;

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(studentProgressRepositoryProvider)
          .markStarted(
            conceptId: widget.conceptId,
            learningPathId: widget.pathId,
            moduleId: widget.moduleId,
          );
    });
  }

  @override
  void didUpdateWidget(LessonScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.conceptId != widget.conceptId) {
      Future.microtask(() {
        ref
            .read(studentProgressRepositoryProvider)
            .markStarted(
              conceptId: widget.conceptId,
              learningPathId: widget.pathId,
              moduleId: widget.moduleId,
            );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final conceptValue = ref.watch(conceptProvider(widget.conceptId));

    return Scaffold(
      appBar: AppBar(title: const Text('Lesson')),
      body: SafeArea(
        child: AsyncValueView(
          value: conceptValue,
          onRetry: () => ref.invalidate(conceptProvider(widget.conceptId)),
          data: (concept) {
            if (concept == null) {
              return const Center(child: Text('Concept not found.'));
            }
            final language = languageForLearningPathId(concept.learningPathId);

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _Header(concept: concept),
                const SizedBox(height: 24),
                _ObjectivesSection(concept: concept),
                const SizedBox(height: 24),
                _PrerequisitesSection(conceptId: widget.conceptId),
                const SizedBox(height: 24),
                _ExplanationSection(concept: concept),
                if (concept.examples.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _ExamplesSection(concept: concept),
                ],
                if (concept.misconceptions.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _MisconceptionsSection(concept: concept),
                ],
                if (concept.exercises.isNotEmpty) ...[
                  const SizedBox(height: 28),
                  _SectionHeading(title: 'Try It'),
                  const SizedBox(height: 12),
                  for (final exercise in concept.exercises)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ExercisePlayer(
                        conceptId: concept.id,
                        language: language,
                        item: PracticeItem.fromExercise(exercise),
                      ),
                    ),
                ],
                if (concept.assessments.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _SectionHeading(title: 'Check Your Understanding'),
                  const SizedBox(height: 12),
                  for (final assessment in concept.assessments)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ExercisePlayer(
                        conceptId: concept.id,
                        language: language,
                        item: PracticeItem.fromAssessment(assessment),
                      ),
                    ),
                ],
                const SizedBox(height: 12),
                Center(
                  child: OutlinedButton.icon(
                    onPressed: () => context.go(
                      Routes.module(widget.pathId, widget.moduleId),
                    ),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Back to topic'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.concept});

  final Concept concept;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
      ],
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: Theme.of(context).textTheme.titleMedium);
  }
}

class _ObjectivesSection extends StatelessWidget {
  const _ObjectivesSection({required this.concept});

  final Concept concept;

  @override
  Widget build(BuildContext context) {
    if (concept.learningObjectives.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeading(title: 'Learning Objectives'),
        const SizedBox(height: 8),
        for (final objective in concept.learningObjectives)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.check, size: 16, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(objective, style: theme.textTheme.bodyMedium),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _PrerequisitesSection extends ConsumerWidget {
  const _PrerequisitesSection({required this.conceptId});

  final String conceptId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prereqsValue = ref.watch(prerequisiteConceptsProvider(conceptId));
    final prereqs = prereqsValue.valueOrNull ?? const [];
    if (prereqs.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeading(title: 'Prerequisites'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: prereqs
              .map(
                (p) => ActionChip(
                  label: Text(p.title),
                  avatar: const Icon(Icons.link, size: 16),
                  onPressed: () => context.go(
                    Routes.lesson(p.learningPathId, p.moduleId, p.id),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _ExplanationSection extends StatelessWidget {
  const _ExplanationSection({required this.concept});

  final Concept concept;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final section in concept.explanation.sections)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(section.heading, style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                MarkdownText(data: section.body),
              ],
            ),
          ),
      ],
    );
  }
}

class _ExamplesSection extends StatelessWidget {
  const _ExamplesSection({required this.concept});

  final Concept concept;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeading(title: 'Examples'),
        const SizedBox(height: 12),
        for (final example in concept.examples)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(example.title, style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                CodeBlock(
                  code: example.code,
                  language: example.language,
                  showLineNumbers: true,
                ),
                const SizedBox(height: 8),
                Text(example.explanation, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
      ],
    );
  }
}

class _MisconceptionsSection extends StatelessWidget {
  const _MisconceptionsSection({required this.concept});

  final Concept concept;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeading(title: 'Common Misconceptions'),
        const SizedBox(height: 12),
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
      ],
    );
  }
}
