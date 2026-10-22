import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/navigation.dart';
import '../../../../core/constants/routes.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../../shared/widgets/glass_app_bar.dart';
import '../../../../shared/widgets/gradient_card.dart';
import '../../../../shared/widgets/markdown_text.dart';
import '../../../interview/domain/models/interview.dart';
import '../../domain/models/system_design_exercise.dart';
import '../providers/system_design_providers.dart';

/// Stage-by-stage walkthrough: answer, reveal the model answer, self-rate.
class SystemDesignExerciseScreen extends ConsumerWidget {
  const SystemDesignExerciseScreen({super.key, required this.exerciseId});

  final String exerciseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(systemDesignExerciseProvider(exerciseId));
    return Scaffold(
      appBar: GlassAppBar(
        title: Text(value.valueOrNull?.title ?? 'System Design'),
      ),
      body: SafeArea(
        child: AsyncValueView(
          value: value,
          onRetry: () =>
              ref.invalidate(systemDesignExerciseProvider(exerciseId)),
          data: (exercise) {
            if (exercise == null || exercise.stages.isEmpty) {
              return const EmptyState(
                message: "We couldn't find that exercise.",
                icon: Icons.account_tree_outlined,
              );
            }
            return _DesignFlow(key: ObjectKey(exercise), exercise: exercise);
          },
        ),
      ),
    );
  }
}

class _DesignFlow extends ConsumerStatefulWidget {
  const _DesignFlow({super.key, required this.exercise});

  final SystemDesignExercise exercise;

  @override
  ConsumerState<_DesignFlow> createState() => _DesignFlowState();
}

class _DesignFlowState extends ConsumerState<_DesignFlow> {
  int _index = 0;
  int _hintsShown = 0;
  bool _revealed = false;
  bool _saved = false;
  final _notes = TextEditingController();
  final Map<String, InterviewRating> _ratings = {};

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  int get _score => _ratings.values.fold(0, (s, r) => s + r.points);

  Future<void> _rate(InterviewRating rating) async {
    setState(() {
      _ratings[widget.exercise.stages[_index].id] = rating;
      _index++;
      _revealed = false;
      _hintsShown = 0;
      _notes.clear();
    });
    if (_index >= widget.exercise.stages.length && !_saved) {
      _saved = true;
      try {
        await ref.read(systemDesignAttemptRecorderProvider)(
          exerciseId: widget.exercise.id,
          score: _score,
          maxScore: widget.exercise.maxScore,
        );
      } on AppException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(e.userMessage)));
        }
      }
    }
  }

  void _restart() => setState(() {
    _index = 0;
    _hintsShown = 0;
    _revealed = false;
    _saved = false;
    _ratings.clear();
    _notes.clear();
  });

  @override
  Widget build(BuildContext context) {
    final ex = widget.exercise;
    if (_index >= ex.stages.length) return _summary(context);
    final theme = Theme.of(context);
    final stage = ex.stages[_index];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        LinearProgressIndicator(value: _index / ex.stages.length),
        const SizedBox(height: 12),
        ExpansionTile(
          key: const ValueKey('scenario'),
          initiallyExpanded: _index == 0,
          tilePadding: EdgeInsets.zero,
          title: Text('Scenario', style: theme.textTheme.titleSmall),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: MarkdownText(data: ex.scenario),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Stage ${_index + 1} of ${ex.stages.length} · ${stage.title}',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        MarkdownText(data: stage.prompt),
        const SizedBox(height: 12),
        for (final h in stage.hints.take(_hintsShown))
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  size: 18,
                  color: theme.colorScheme.tertiary,
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(h)),
              ],
            ),
          ),
        if (!_revealed && _hintsShown < stage.hints.length)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => setState(() => _hintsShown++),
              icon: const Icon(Icons.lightbulb_outline),
              label: Text(_hintsShown == 0 ? 'Show a hint' : 'Another hint'),
            ),
          ),
        const SizedBox(height: 8),
        TextField(
          controller: _notes,
          minLines: 4,
          maxLines: 12,
          decoration: const InputDecoration(
            labelText: 'Your answer (notes, not saved)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        if (!_revealed)
          FilledButton(
            onPressed: () => setState(() => _revealed = true),
            child: const Text('Reveal Model Answer'),
          )
        else ...[
          GradientCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Model answer', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  MarkdownText(data: stage.modelAnswer),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('How close was your answer?', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final r in InterviewRating.values)
                r == InterviewRating.nailedIt
                    ? FilledButton(
                        onPressed: () => _rate(r),
                        child: Text(r.label),
                      )
                    : OutlinedButton(
                        onPressed: () => _rate(r),
                        child: Text(r.label),
                      ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _summary(BuildContext context) {
    final theme = Theme.of(context);
    final ex = widget.exercise;
    final percent = ex.maxScore == 0 ? 0 : (_score * 100 / ex.maxScore).round();
    final weak = [
      for (final s in ex.stages)
        if (_ratings[s.id] != InterviewRating.nailedIt) s,
    ];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Design score: $percent%', style: theme.textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text('${ex.stages.length} stages · ${ex.title}'),
        const SizedBox(height: 16),
        if (weak.isEmpty)
          const Text('Every stage matched the model answer. Nice work.')
        else ...[
          Text('Stages to revisit', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final s in weak)
            GradientCard(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(s.title),
                subtitle: Text(_ratings[s.id]?.label ?? ''),
              ),
            ),
        ],
        if (ex.commonPitfalls.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('Common pitfalls', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final p in ex.commonPitfalls)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber_outlined,
                    size: 18,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(p)),
                ],
              ),
            ),
        ],
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () =>
                    context.goBack(fallbackLocation: Routes.systemDesign),
                child: const Text('Done'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: _restart,
                child: const Text('Try Again'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
