import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/navigation.dart';
import '../../../../core/constants/routes.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../../shared/widgets/glass_app_bar.dart';
import '../../../../shared/widgets/gradient_card.dart';
import '../../../curriculum/domain/models/learning_path.dart';
import '../../domain/models/skill_check.dart';
import '../providers/skill_check_providers.dart';

/// A short multiple-choice check across a course's topics. The result
/// suggests where to start, and can unlock the topics the learner already
/// knows (see [SkillCheckService] for the placement rule).
class SkillCheckScreen extends ConsumerWidget {
  const SkillCheckScreen({super.key, required this.pathId});

  final String pathId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(skillCheckProvider(pathId));
    return Scaffold(
      appBar: GlassAppBar(title: const Text('Skill Check')),
      body: SafeArea(
        child: AsyncValueView(
          value: value,
          onRetry: () => ref.invalidate(skillCheckProvider(pathId)),
          data: (check) {
            if (check == null) {
              return const _Message('Course not found.');
            }
            if (check.questions.isEmpty) {
              return const _Message(
                'This course has no skill-check questions yet.',
              );
            }
            return _SkillCheckFlow(
              path: check.path,
              questions: check.questions,
            );
          },
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Text(text, textAlign: TextAlign.center),
    ),
  );
}

class _SkillCheckFlow extends ConsumerStatefulWidget {
  const _SkillCheckFlow({required this.path, required this.questions});

  final LearningPath path;
  final List<SkillCheckQuestion> questions;

  @override
  ConsumerState<_SkillCheckFlow> createState() => _SkillCheckFlowState();
}

class _SkillCheckFlowState extends ConsumerState<_SkillCheckFlow> {
  bool _started = false;
  int _index = 0;
  int? _selected;
  final Map<String, int> _answers = {};
  SkillCheckResult? _result;
  bool _applying = false;
  bool _applied = false;
  String? _applyError;

  void _next() {
    final question = widget.questions[_index];
    if (_selected != null) _answers[question.id] = _selected!;
    if (_index + 1 < widget.questions.length) {
      setState(() {
        _index++;
        _selected = null;
      });
      return;
    }
    setState(() {
      _result = ref
          .read(skillCheckServiceProvider)
          .score(
            path: widget.path,
            questions: widget.questions,
            answers: _answers,
          );
    });
  }

  Future<void> _applyPlacement() async {
    setState(() {
      _applying = true;
      _applyError = null;
    });
    try {
      await ref.read(applySkillCheckPlacementProvider)(_result!);
      if (mounted) setState(() => _applied = true);
    } catch (_) {
      if (mounted) {
        setState(
          () => _applyError = 'Could not save your placement. Try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _applying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_started) return _intro(context);
    if (_result != null) return _resultView(context, _result!);
    return _questionView(context);
  }

  Widget _intro(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(widget.path.title, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 12),
        Text(
          '${widget.questions.length} quick questions across the course. '
          'Answer what you know and skip what you do not. Topics you get '
          'fully right at the start of the course can be unlocked, so you '
          'begin where it gets new for you.',
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: () => setState(() => _started = true),
          child: const Text('Start Skill Check'),
        ),
      ],
    );
  }

  Widget _questionView(BuildContext context) {
    final theme = Theme.of(context);
    final question = widget.questions[_index];
    final options = question.assessment.options!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        LinearProgressIndicator(value: _index / widget.questions.length),
        const SizedBox(height: 12),
        Text(
          'Question ${_index + 1} of ${widget.questions.length} · '
          '${question.moduleTitle}',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        Text(question.assessment.prompt, style: theme.textTheme.titleMedium),
        const SizedBox(height: 16),
        RadioGroup<int>(
          groupValue: _selected,
          onChanged: (v) => setState(() => _selected = v),
          child: Column(
            children: [
              for (var i = 0; i < options.length; i++)
                RadioListTile<int>(value: i, title: Text(options[i])),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {
                _selected = null;
                _next();
              },
              child: const Text("I don't know"),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: _selected == null ? null : _next,
              child: Text(
                _index + 1 < widget.questions.length ? 'Next' : 'See Results',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _resultView(BuildContext context, SkillCheckResult result) {
    final theme = Theme.of(context);
    final start = result.recommendedStartModule;
    final skipCount = result.testedOutModuleIds.length;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'You scored ${result.scorePercent}%',
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 4),
        Text('${result.correct} of ${result.total} correct'),
        const SizedBox(height: 16),
        GradientCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Where to start', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  start == null
                      ? 'You answered every topic correctly. You can unlock '
                            'the whole course and dip into any topic.'
                      : skipCount == 0
                      ? 'Start from the beginning: "${start.title}".'
                      : 'You can skip $skipCount '
                            '${skipCount == 1 ? 'topic' : 'topics'} and '
                            'start at "${start.title}".',
                ),
                if (_applyError != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _applyError!,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ],
                const SizedBox(height: 12),
                if (skipCount > 0 && !_applied)
                  FilledButton(
                    onPressed: _applying ? null : _applyPlacement,
                    child: Text(
                      _applying
                          ? 'Unlocking...'
                          : 'Unlock $skipCount '
                                '${skipCount == 1 ? 'topic' : 'topics'}',
                    ),
                  ),
                if (_applied && start != null)
                  FilledButton(
                    onPressed: () =>
                        context.replaceWithNextTopic(widget.path.id, start.id),
                    child: Text('Go to "${start.title}"'),
                  ),
                if (_applied && start == null)
                  const Text('Every topic is unlocked.'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text('By topic', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        for (final t in result.topicScores)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              t.isAllCorrect
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color: t.isAllCorrect
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            title: Text(t.module.title),
            trailing: Text('${t.correct}/${t.total}'),
          ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () => context.goBack(
            fallbackLocation: Routes.learningPath(widget.path.id),
          ),
          child: const Text('Done'),
        ),
      ],
    );
  }
}
