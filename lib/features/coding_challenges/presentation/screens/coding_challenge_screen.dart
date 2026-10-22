import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/navigation.dart';
import '../../../../core/constants/routes.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../../shared/widgets/code_block.dart';
import '../../../../shared/widgets/glass_app_bar.dart';
import '../../../../shared/widgets/gradient_card.dart';
import '../../../../shared/widgets/markdown_text.dart';
import '../../../code_runner/presentation/widgets/run_code_panel.dart';
import '../../../interview/domain/models/interview.dart';
import '../../domain/models/coding_challenge.dart';
import '../providers/coding_challenge_providers.dart';

/// Part-by-part long-form challenge: write code, check behaviours, compare
/// with the reference solution, self-rate.
class CodingChallengeScreen extends ConsumerWidget {
  const CodingChallengeScreen({super.key, required this.challengeId});

  final String challengeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(codingChallengeProvider(challengeId));
    return Scaffold(
      appBar: GlassAppBar(title: Text(value.valueOrNull?.title ?? 'Challenge')),
      body: SafeArea(
        child: AsyncValueView(
          value: value,
          onRetry: () => ref.invalidate(codingChallengeProvider(challengeId)),
          data: (challenge) {
            if (challenge == null || challenge.parts.isEmpty) {
              return const EmptyState(
                message: "We couldn't find that challenge.",
                icon: Icons.terminal_outlined,
              );
            }
            return _ChallengeFlow(
              key: ObjectKey(challenge),
              challenge: challenge,
            );
          },
        ),
      ),
    );
  }
}

class _ChallengeFlow extends ConsumerStatefulWidget {
  const _ChallengeFlow({super.key, required this.challenge});

  final LongFormChallenge challenge;

  @override
  ConsumerState<_ChallengeFlow> createState() => _ChallengeFlowState();
}

class _ChallengeFlowState extends ConsumerState<_ChallengeFlow> {
  int _index = 0;
  int _hintsShown = 0;
  bool _revealed = false;
  bool _saved = false;
  final Set<int> _checked = {};
  final Map<String, InterviewRating> _ratings = {};

  /// One editor for the whole challenge: later parts extend earlier code.
  late final TextEditingController _code = TextEditingController(
    text: widget.challenge.starterCode,
  );

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  int get _score => _ratings.values.fold(0, (s, r) => s + r.points);

  Future<void> _rate(InterviewRating rating) async {
    setState(() {
      _ratings[widget.challenge.parts[_index].id] = rating;
      _index++;
      _revealed = false;
      _hintsShown = 0;
      _checked.clear();
    });
    if (_index >= widget.challenge.parts.length && !_saved) {
      _saved = true;
      try {
        await ref.read(codingChallengeAttemptRecorderProvider)(
          challengeId: widget.challenge.id,
          score: _score,
          maxScore: widget.challenge.maxScore,
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
    _checked.clear();
    _ratings.clear();
    _code.text = widget.challenge.starterCode;
  });

  @override
  Widget build(BuildContext context) {
    final c = widget.challenge;
    if (_index >= c.parts.length) return _summary(context);
    final theme = Theme.of(context);
    final part = c.parts[_index];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        LinearProgressIndicator(value: _index / c.parts.length),
        const SizedBox(height: 12),
        ExpansionTile(
          key: const ValueKey('statement'),
          initiallyExpanded: _index == 0,
          tilePadding: EdgeInsets.zero,
          title: Text('Problem', style: theme.textTheme.titleSmall),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: MarkdownText(data: c.statement),
            ),
          ],
        ),
        Text(
          'Part ${_index + 1} of ${c.parts.length} · ${part.title}',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        MarkdownText(data: part.task),
        const SizedBox(height: 8),
        for (final h in part.hints.take(_hintsShown))
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
        if (!_revealed && _hintsShown < part.hints.length)
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
          key: const ValueKey('code-editor'),
          controller: _code,
          minLines: 8,
          maxLines: 24,
          keyboardType: TextInputType.multiline,
          style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
          decoration: InputDecoration(
            labelText: 'Your code (${c.language}, kept across parts)',
            alignLabelWithHint: true,
            border: const OutlineInputBorder(),
          ),
        ),
        RunCodePanel(language: c.language, source: () => _code.text),
        const SizedBox(height: 12),
        Text('Check your work', style: theme.textTheme.titleSmall),
        for (final (i, check) in part.checks.indexed)
          CheckboxListTile(
            value: _checked.contains(i),
            onChanged: (v) => setState(
              () => v == true ? _checked.add(i) : _checked.remove(i),
            ),
            title: Text(check),
            dense: true,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
          ),
        const SizedBox(height: 12),
        if (!_revealed)
          FilledButton(
            onPressed: () => setState(() => _revealed = true),
            child: const Text('Reveal Reference Solution'),
          )
        else ...[
          Text('Reference solution', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          CodeBlock(code: part.solution, language: c.language),
          const SizedBox(height: 8),
          MarkdownText(data: part.explanation),
          const SizedBox(height: 16),
          Text('How close was yours?', style: theme.textTheme.titleSmall),
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
    final c = widget.challenge;
    final percent = c.maxScore == 0 ? 0 : (_score * 100 / c.maxScore).round();
    final weak = [
      for (final p in c.parts)
        if (_ratings[p.id] != InterviewRating.nailedIt) p,
    ];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Challenge score: $percent%',
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 4),
        Text('${c.parts.length} parts · ${c.title}'),
        const SizedBox(height: 16),
        if (weak.isEmpty)
          const Text('Every part matched the reference. Well done.')
        else ...[
          Text('Parts to revisit', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final p in weak)
            GradientCard(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(p.title),
                subtitle: Text(_ratings[p.id]?.label ?? ''),
              ),
            ),
        ],
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () =>
                    context.goBack(fallbackLocation: Routes.codingChallenges),
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
