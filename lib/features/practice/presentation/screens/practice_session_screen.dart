import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/routes.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../ai_teacher/presentation/providers/api_key_providers.dart';
import '../../../ai_teacher/presentation/providers/generate_exercise_providers.dart';
import '../../../assessment/domain/models/practice_item.dart';
import '../../../assessment/presentation/widgets/exercise_player.dart';
import '../../../curriculum/domain/models/exercise.dart';
import '../../../curriculum/domain/models/learning_path.dart';
import '../../../curriculum/presentation/curriculum_providers.dart';

/// A focused, exercises-only view for repeat practice on a concept a
/// learner has already been taught — no lesson prose, just "Try It" again,
/// plus an option to generate fresh AI-authored exercises for more
/// practice. See instructions.md sections 55-56: AI-generated exercises
/// augment the curriculum for this session only — never persisted back
/// into it.
class PracticeSessionScreen extends ConsumerStatefulWidget {
  const PracticeSessionScreen({super.key, required this.conceptId});

  final String conceptId;

  @override
  ConsumerState<PracticeSessionScreen> createState() =>
      _PracticeSessionScreenState();
}

class _PracticeSessionScreenState
    extends ConsumerState<PracticeSessionScreen> {
  final List<Exercise> _generatedExercises = [];
  bool _generating = false;
  String? _generateError;

  Future<void> _generateExercise() async {
    setState(() {
      _generating = true;
      _generateError = null;
    });

    try {
      final exercise = await ref
          .read(generateExerciseUseCaseProvider)
          .call(conceptId: widget.conceptId);
      if (!mounted) return;
      setState(() {
        _generatedExercises.add(exercise);
        _generating = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _generating = false;
        _generateError = e is AppException
            ? e.userMessage
            : 'Something went wrong generating an exercise. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final conceptValue = ref.watch(conceptProvider(widget.conceptId));
    final isAiConfigured = ref.watch(isAiConfiguredProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Practice')),
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
                Text(
                  concept.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  '${concept.exercises.length} exercises',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                for (final exercise in concept.exercises)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ExercisePlayer(
                      conceptId: concept.id,
                      language: language,
                      item: PracticeItem.fromExercise(exercise),
                    ),
                  ),
                for (final exercise in _generatedExercises)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _AiGeneratedLabel(),
                        const SizedBox(height: 6),
                        ExercisePlayer(
                          conceptId: concept.id,
                          language: language,
                          item: PracticeItem.fromExercise(exercise),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
                if (!isAiConfigured)
                  _NotConfiguredHint(theme: Theme.of(context))
                else ...[
                  if (_generateError != null) ...[
                    _GenerateErrorBanner(
                      message: _generateError!,
                      onRetry: _generateExercise,
                    ),
                    const SizedBox(height: 12),
                  ],
                  Center(
                    child: OutlinedButton.icon(
                      onPressed: _generating ? null : _generateExercise,
                      icon: _generating
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.auto_awesome_outlined, size: 18),
                      label: Text(
                        _generating
                            ? 'Generating exercise...'
                            : 'Generate a fresh exercise',
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AiGeneratedLabel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.auto_awesome_outlined, size: 14, color: theme.colorScheme.tertiary),
        const SizedBox(width: 4),
        Text(
          'AI-generated',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.tertiary,
          ),
        ),
      ],
    );
  }
}

class _NotConfiguredHint extends StatelessWidget {
  const _NotConfiguredHint({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.auto_awesome_outlined,
            size: 18,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Add a Gemini API key in Settings to generate fresh practice exercises.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          TextButton(
            onPressed: () => context.go(Routes.settings),
            child: const Text('Settings'),
          ),
        ],
      ),
    );
  }
}

class _GenerateErrorBanner extends StatelessWidget {
  const _GenerateErrorBanner({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
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
