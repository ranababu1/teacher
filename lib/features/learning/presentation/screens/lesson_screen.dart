import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/navigation.dart';
import '../../../../core/constants/routes.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/services/data_revision_provider.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../../shared/widgets/glass_app_bar.dart';
import '../../../ai_teacher/presentation/widgets/ai_teacher_panel.dart';
import '../../../curriculum/domain/models/concept.dart';
import '../../../curriculum/presentation/curriculum_providers.dart';
import '../../../curriculum/presentation/widgets/course_locked_state.dart';
import '../../../progress/presentation/providers/progress_providers.dart';
import '../../domain/lesson_flow.dart';
import '../providers/lesson_providers.dart';
import '../widgets/lesson_step_views.dart';

/// A lesson as a sequence of one-screen steps: swipe or use Back and Next,
/// tap the progress bar to jump, and the last step finishes the lesson.
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
  String? _markedStartedForConceptId;

  void _maybeMarkStarted() {
    if (_markedStartedForConceptId == widget.conceptId) return;
    _markedStartedForConceptId = widget.conceptId;
    Future.microtask(() async {
      await ref
          .read(studentProgressRepositoryProvider)
          .markStarted(
            conceptId: widget.conceptId,
            learningPathId: widget.pathId,
            moduleId: widget.moduleId,
          );
      ref.read(dataRevisionProvider.notifier).bump();
    });
  }

  void _exit() => context.goBack(
    fallbackLocation: Routes.module(widget.pathId, widget.moduleId),
  );

  /// App-bar and system back: previous step first, then leave the lesson.
  void _back() {
    final moved = ref
        .read(lessonFlowProvider(widget.conceptId).notifier)
        .back();
    if (!moved) _exit();
  }

  @override
  Widget build(BuildContext context) {
    final isStarted =
        ref.watch(isLearningPathStartedProvider(widget.pathId)).valueOrNull ??
        false;

    if (!isStarted) {
      return Scaffold(
        appBar: GlassAppBar(title: const Text('Lesson')),
        body: SafeArea(child: CourseLockedState(pathId: widget.pathId)),
      );
    }

    _maybeMarkStarted();

    final flowValue = ref.watch(lessonFlowProvider(widget.conceptId));
    final concept = ref.watch(conceptProvider(widget.conceptId)).valueOrNull;
    final flow = flowValue.valueOrNull;
    final canPop = flow == null || flow.isFirst;

    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        appBar: GlassAppBar(
          leading: IconButton(
            key: const ValueKey('lesson-back'),
            tooltip: 'Back',
            icon: const Icon(Icons.arrow_back),
            onPressed: _back,
          ),
          title: Text(concept?.title ?? 'Lesson'),
          actions: [
            if (concept != null)
              IconButton(
                tooltip: 'Ask the AI teacher',
                icon: const Icon(Icons.psychology_alt_outlined),
                onPressed: () => _openAiTeacher(concept),
              ),
          ],
        ),
        body: SafeArea(
          child: AsyncValueView(
            value: flowValue,
            onRetry: () => ref.invalidate(lessonFlowProvider(widget.conceptId)),
            data: (flow) {
              if (flow == null || concept == null) {
                return _Message(
                  icon: Icons.search_off,
                  text: "We couldn't find this lesson.",
                  onBack: _exit,
                );
              }
              if (flow.isEmpty) {
                return _Message(
                  icon: Icons.inbox_outlined,
                  text: 'This lesson has no content yet.',
                  onBack: _exit,
                );
              }
              return _LessonFlowView(
                concept: concept,
                flow: flow,
                onFinished: _exit,
              );
            },
          ),
        ),
      ),
    );
  }

  void _openAiTeacher(Concept concept) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.8,
        maxChildSize: 0.95,
        builder: (_, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          children: [AiTeacherPanel(conceptId: concept.id)],
        ),
      ),
    );
  }
}

class _LessonFlowView extends ConsumerStatefulWidget {
  const _LessonFlowView({
    required this.concept,
    required this.flow,
    required this.onFinished,
  });

  final Concept concept;
  final LessonFlow flow;
  final VoidCallback onFinished;

  @override
  ConsumerState<_LessonFlowView> createState() => _LessonFlowViewState();
}

class _LessonFlowViewState extends ConsumerState<_LessonFlowView> {
  late final PageController _pages = PageController(
    initialPage: widget.flow.index,
  );
  bool _finishing = false;

  LessonFlowController get _controller =>
      ref.read(lessonFlowProvider(widget.concept.id).notifier);

  @override
  void didUpdateWidget(covariant _LessonFlowView old) {
    super.didUpdateWidget(old);
    final target = widget.flow.index;
    if (!_pages.hasClients) return;
    final shown = _pages.page?.round() ?? target;
    if (shown == target) return;
    if (MediaQuery.of(context).disableAnimations) {
      _pages.jumpToPage(target);
    } else {
      _pages.animateToPage(
        target,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    final flow = widget.flow;
    if (page > flow.index) {
      _controller.next();
    } else if (page < flow.index) {
      _controller.back();
    }
  }

  Future<void> _finish() async {
    setState(() => _finishing = true);
    try {
      await _controller.complete();
      if (mounted) widget.onFinished();
    } on AppException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.userMessage)));
      }
    } finally {
      if (mounted) setState(() => _finishing = false);
    }
  }

  void _openStepList() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => _StepListSheet(
        flow: widget.flow,
        onSelect: (i) {
          Navigator.of(sheetContext).pop();
          _controller.jumpTo(i);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final flow = widget.flow;
    final theme = Theme.of(context);
    return Column(
      children: [
        Semantics(
          button: true,
          label:
              'Step ${flow.index + 1} of ${flow.steps.length}. Show all steps',
          child: InkWell(
            key: const ValueKey('lesson-progress'),
            onTap: _openStepList,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LinearProgressIndicator(
                    value: flow.progress,
                    minHeight: 4,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        'Step ${flow.index + 1} of ${flow.steps.length}',
                        style: theme.textTheme.labelMedium,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          flow.current.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.list,
                        size: 18,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: PageView.builder(
            key: const ValueKey('lesson-pages'),
            controller: _pages,
            // Forward swipes stop at an unanswered quick check; back
            // swipes are always allowed via the button and system back.
            physics: flow.canGoNext
                ? const PageScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            itemCount: flow.steps.length,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, i) {
              final step = flow.steps[i];
              return _StepCard(
                child: LessonStepView(
                  concept: widget.concept,
                  step: step,
                  answer: flow.answers[step.id],
                  onAnswer: _controller.answer,
                ),
              );
            },
          ),
        ),
        _BottomBar(
          flow: flow,
          finishing: _finishing,
          onBack: () => _controller.back(),
          onNext: flow.isLast ? _finish : _controller.next,
        ),
      ],
    );
  }
}

/// One step's card: fills the space between the header and the bottom
/// bar, centred and width-capped on tablets, scrolling inside itself when
/// the content is taller than the screen.
class _StepCard extends StatelessWidget {
  const _StepCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Scrollbar(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(width: double.infinity, child: child),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.flow,
    required this.finishing,
    required this.onBack,
    required this.onNext,
  });

  final LessonFlow flow;
  final bool finishing;
  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Row(
            children: [
              if (!flow.isFirst)
                OutlinedButton.icon(
                  key: const ValueKey('lesson-prev'),
                  onPressed: onBack,
                  icon: const Icon(Icons.chevron_left),
                  label: const Text('Back'),
                ),
              const Spacer(),
              Flexible(
                child: FilledButton.icon(
                  key: const ValueKey('lesson-next'),
                  onPressed: flow.canGoNext && !finishing ? onNext : null,
                  iconAlignment: IconAlignment.end,
                  icon: finishing
                      ? const SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(flow.isLast ? Icons.check : Icons.chevron_right),
                  label: Text(
                    !flow.canGoNext
                        ? 'Answer to continue'
                        : flow.isLast
                        ? 'Finish lesson'
                        : 'Next',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepListSheet extends StatelessWidget {
  const _StepListSheet({required this.flow, required this.onSelect});

  final LessonFlow flow;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      builder: (_, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.only(bottom: 16),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text('Steps', style: theme.textTheme.titleMedium),
          ),
          for (final (i, step) in flow.steps.indexed)
            ListTile(
              key: ValueKey('step-tile-$i'),
              enabled: flow.canJumpTo(i),
              selected: i == flow.index,
              leading: CircleAvatar(
                radius: 14,
                child: Text('${i + 1}', style: theme.textTheme.labelSmall),
              ),
              title: Text(step.title),
              trailing: flow.canJumpTo(i)
                  ? null
                  : const Icon(Icons.lock_outline),
              onTap: () => onSelect(i),
            ),
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.text,
    required this.onBack,
  });

  final IconData icon;
  final String text;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(text, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}
