import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/navigation.dart';
import '../../../../core/constants/routes.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../../shared/widgets/glass_app_bar.dart';
import '../../../../shared/widgets/gradient_card.dart';
import '../../../../shared/widgets/markdown_text.dart';
import '../../domain/models/interview.dart';
import '../providers/interview_providers.dart';

/// One mock-interview session for a course.
class InterviewSessionScreen extends ConsumerWidget {
  const InterviewSessionScreen({super.key, required this.pathId});

  final String pathId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(interviewSessionProvider(pathId));
    return Scaffold(
      appBar: GlassAppBar(title: const Text('Mock Interview')),
      body: SafeArea(
        child: AsyncValueView(
          value: value,
          onRetry: () => ref.invalidate(interviewSessionProvider(pathId)),
          data: (session) {
            if (session == null || session.questions.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'No interview questions for this course yet.',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            return _InterviewFlow(
              key: ObjectKey(session.questions),
              title: session.path.title,
              questions: session.questions,
              onNewSession: () =>
                  ref.invalidate(interviewSessionProvider(pathId)),
            );
          },
        ),
      ),
    );
  }
}

class _InterviewFlow extends StatefulWidget {
  const _InterviewFlow({
    super.key,
    required this.title,
    required this.questions,
    required this.onNewSession,
  });

  final String title;
  final List<InterviewQuestion> questions;
  final VoidCallback onNewSession;

  @override
  State<_InterviewFlow> createState() => _InterviewFlowState();
}

class _InterviewFlowState extends State<_InterviewFlow> {
  int _index = 0;
  bool _revealed = false;
  final _notes = TextEditingController();
  final Map<String, InterviewRating> _ratings = {};

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  void _rate(InterviewRating rating) {
    setState(() {
      _ratings[widget.questions[_index].id] = rating;
      _index++;
      _revealed = false;
      _notes.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_index >= widget.questions.length) {
      return _summary(
        context,
        InterviewSummary(ratings: _ratings, questions: widget.questions),
      );
    }
    final theme = Theme.of(context);
    final q = widget.questions[_index];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        LinearProgressIndicator(value: _index / widget.questions.length),
        const SizedBox(height: 12),
        Text(
          'Question ${_index + 1} of ${widget.questions.length} · '
          '${q.isScenario ? 'Scenario' : 'Concept'} · ${q.moduleTitle}',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        MarkdownText(data: q.prompt),
        const SizedBox(height: 16),
        TextField(
          controller: _notes,
          minLines: 3,
          maxLines: 8,
          decoration: const InputDecoration(
            labelText: 'Your answer (optional notes, not saved)',
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
                  MarkdownText(data: q.modelAnswer),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('How did you do?', style: theme.textTheme.titleSmall),
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

  Widget _summary(BuildContext context, InterviewSummary summary) {
    final theme = Theme.of(context);
    final revisit = summary.toRevisit;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Interview score: ${summary.scorePercent}%',
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 4),
        Text('${summary.answered} questions · ${widget.title}'),
        const SizedBox(height: 16),
        if (revisit.isEmpty)
          const Text('You nailed every question. Try another session.')
        else ...[
          Text('Worth revisiting', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final q in revisit)
            GradientCard(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(q.conceptTitle),
                subtitle: Text(
                  '${q.moduleTitle} · ${summary.ratings[q.id]!.label}',
                ),
                trailing: const Icon(Icons.menu_book_outlined),
                onTap: () => context.openLesson(
                  q.learningPathId,
                  q.moduleId,
                  q.conceptId,
                ),
              ),
            ),
        ],
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () =>
                    context.goBack(fallbackLocation: Routes.interviewPrep),
                child: const Text('Done'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: widget.onNewSession,
                child: const Text('New Session'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
