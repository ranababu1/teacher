import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/navigation.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../../shared/widgets/glass_app_bar.dart';
import '../../../../shared/widgets/gradient_card.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../../../ai_teacher/presentation/providers/api_key_providers.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../domain/models/roadmap.dart';
import '../../domain/roadmap_progress.dart';
import '../providers/roadmap_providers.dart';

IconData roadmapItemIcon(RoadmapItemKind kind) => switch (kind) {
  RoadmapItemKind.topic => Icons.menu_book_outlined,
  RoadmapItemKind.project => Icons.construction_outlined,
  RoadmapItemKind.systemDesign => Icons.account_tree_outlined,
  RoadmapItemKind.challenge => Icons.terminal_outlined,
};

/// Opens the screen a roadmap item points at (drill-down, so back returns
/// to the roadmap).
void openRoadmapItem(BuildContext context, RoadmapItem item) {
  switch (item.kind) {
    case RoadmapItemKind.topic:
      final slash = item.refId.indexOf('/');
      if (slash <= 0) return;
      context.openTopic(
        item.refId.substring(0, slash),
        item.refId.substring(slash + 1),
      );
    case RoadmapItemKind.project:
      context.openProject(item.refId);
    case RoadmapItemKind.systemDesign:
      context.openSystemDesignExercise(item.refId);
    case RoadmapItemKind.challenge:
      context.openCodingChallenge(item.refId);
  }
}

String _errorText(Object error) => error is AppException
    ? error.userMessage
    : 'Something went wrong while building your roadmap.';

/// A personal, multi-week roadmap toward a career goal, built by the AI
/// (or offline) from the app's own content and saved on the device.
class RoadmapScreen extends ConsumerStatefulWidget {
  const RoadmapScreen({super.key});

  @override
  ConsumerState<RoadmapScreen> createState() => _RoadmapScreenState();
}

class _RoadmapScreenState extends ConsumerState<RoadmapScreen> {
  bool _editing = false;
  bool _busy = false;
  Object? _error;
  RoadmapGoal? _pendingGoal;

  Future<void> _generate(RoadmapGoal goal, {required bool useAi}) async {
    setState(() {
      _busy = true;
      _error = null;
      _pendingGoal = goal;
    });
    try {
      final result = await ref
          .read(roadmapControllerProvider.notifier)
          .generate(goal, useAi: useAi);
      if (!mounted) return;
      setState(() {
        _busy = false;
        _editing = false;
      });
      final notes = [
        if (result.fellBackOffline)
          'No AI key or connection, so this plan was built offline.',
        if (result.droppedItems > 0)
          'Removed ${result.droppedItems} AI suggestions that did not '
              'match app content.',
      ];
      if (notes.isNotEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(notes.join(' '))));
      }
    } on Object catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = e;
      });
    }
  }

  Future<void> _confirmDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete roadmap?'),
        content: const Text(
          'Your course progress stays. Only this plan is removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(roadmapControllerProvider.notifier).clear();
      if (mounted) setState(() => _editing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final value = ref.watch(roadmapControllerProvider);
    final roadmap = value.valueOrNull;
    final aiReady = ref.watch(isAiConfiguredProvider);
    final careerGoal = ref
        .watch(learnerProfileControllerProvider)
        .valueOrNull
        ?.careerGoal;
    final showingPlan =
        roadmap != null && !_editing && !_busy && _error == null;
    return Scaffold(
      appBar: GlassAppBar(
        title: const Text('Career roadmap'),
        actions: [
          if (showingPlan) ...[
            IconButton(
              key: const ValueKey('roadmap-regenerate'),
              tooltip: 'Regenerate',
              icon: const Icon(Icons.refresh),
              onPressed: () => _generate(
                roadmap.goal,
                useAi: roadmap.source == RoadmapSource.ai,
              ),
            ),
            IconButton(
              key: const ValueKey('roadmap-edit-goal'),
              tooltip: 'Change goal',
              icon: const Icon(Icons.tune),
              onPressed: () => setState(() => _editing = true),
            ),
            IconButton(
              key: const ValueKey('roadmap-delete'),
              tooltip: 'Delete roadmap',
              icon: const Icon(Icons.delete_outline),
              onPressed: _confirmDelete,
            ),
          ],
        ],
      ),
      body: SafeArea(
        child: AsyncValueView<Roadmap?>(
          value: value,
          onRetry: () => ref.invalidate(roadmapControllerProvider),
          skeleton: () => const SkeletonCardList(),
          data: (saved) {
            if (_busy) return const _BuildingView();
            if (_error != null) {
              return _GenerateErrorView(
                message: _errorText(_error!),
                onRetry: () => _generate(_pendingGoal!, useAi: true),
                onOffline: () => _generate(_pendingGoal!, useAi: false),
                onBack: () => setState(() => _error = null),
              );
            }
            if (saved == null || _editing) {
              return _GoalForm(
                initial: _pendingGoal ?? saved?.goal,
                suggestedGoal: careerGoal,
                aiReady: aiReady,
                onCancel: saved == null
                    ? null
                    : () => setState(() => _editing = false),
                onSubmit: _generate,
              );
            }
            return _RoadmapView(roadmap: saved);
          },
        ),
      ),
    );
  }
}

class _BuildingView extends StatelessWidget {
  const _BuildingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Building your roadmap from the app\'s courses...'),
        ],
      ),
    );
  }
}

class _GenerateErrorView extends StatelessWidget {
  const _GenerateErrorView({
    required this.message,
    required this.onRetry,
    required this.onOffline,
    required this.onBack,
  });

  final String message;
  final VoidCallback onRetry;
  final VoidCallback onOffline;
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
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                FilledButton(
                  key: const ValueKey('roadmap-retry'),
                  onPressed: onRetry,
                  child: const Text('Try again'),
                ),
                OutlinedButton(
                  key: const ValueKey('roadmap-use-offline'),
                  onPressed: onOffline,
                  child: const Text('Use offline plan'),
                ),
                TextButton(onPressed: onBack, child: const Text('Back')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalForm extends StatefulWidget {
  const _GoalForm({
    required this.initial,
    required this.aiReady,
    this.suggestedGoal,
    required this.onSubmit,
    this.onCancel,
  });

  final RoadmapGoal? initial;

  /// Prefill from the learner's profile when there is no previous goal.
  final String? suggestedGoal;
  final bool aiReady;
  final Future<void> Function(RoadmapGoal goal, {required bool useAi}) onSubmit;
  final VoidCallback? onCancel;

  @override
  State<_GoalForm> createState() => _GoalFormState();
}

class _GoalFormState extends State<_GoalForm> {
  late final TextEditingController _goal;
  late RoadmapLevel _level;
  late int _hours;
  late int _weeks;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _goal = TextEditingController(
      text: initial?.goal ?? widget.suggestedGoal ?? '',
    );
    _level = initial?.level ?? RoadmapLevel.beginner;
    _hours = initial?.hoursPerWeek ?? 6;
    _weeks = initial?.weeks ?? 12;
  }

  @override
  void dispose() {
    _goal.dispose();
    super.dispose();
  }

  RoadmapGoal get _value => RoadmapGoal(
    goal: _goal.text,
    level: _level,
    hoursPerWeek: _hours,
    weeks: _weeks,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasGoal = _goal.text.trim().isNotEmpty;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Tell me where you want to get to. Your roadmap uses only this '
          "app's courses, projects, design exercises and challenges, and "
          'tracks itself as you finish them.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          key: const ValueKey('roadmap-goal-field'),
          controller: _goal,
          maxLength: 200,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Your goal',
            hintText: 'e.g. Backend developer job in 3 months',
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        Text('Current level', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        SegmentedButton<RoadmapLevel>(
          segments: [
            for (final l in RoadmapLevel.values)
              ButtonSegment(value: l, label: Text(l.label)),
          ],
          selected: {_level},
          onSelectionChanged: (s) => setState(() => _level = s.first),
        ),
        const SizedBox(height: 16),
        Text('$_hours hours per week', style: theme.textTheme.titleSmall),
        Slider(
          value: _hours.toDouble(),
          min: RoadmapGoal.minHours.toDouble(),
          max: RoadmapGoal.maxHours.toDouble(),
          divisions: RoadmapGoal.maxHours - RoadmapGoal.minHours,
          label: '$_hours h',
          onChanged: (v) => setState(() => _hours = v.round()),
        ),
        Text(
          '$_weeks ${_weeks == 1 ? 'week' : 'weeks'}',
          style: theme.textTheme.titleSmall,
        ),
        Slider(
          value: _weeks.toDouble(),
          min: RoadmapGoal.minWeeks.toDouble(),
          max: RoadmapGoal.maxWeeks.toDouble(),
          divisions: RoadmapGoal.maxWeeks - RoadmapGoal.minWeeks,
          label: '$_weeks',
          onChanged: (v) => setState(() => _weeks = v.round()),
        ),
        const SizedBox(height: 16),
        if (widget.aiReady) ...[
          FilledButton.icon(
            key: const ValueKey('roadmap-generate-ai'),
            onPressed: hasGoal
                ? () => widget.onSubmit(_value, useAi: true)
                : null,
            icon: const Icon(Icons.auto_awesome_outlined),
            label: const Text('Generate with AI'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            key: const ValueKey('roadmap-generate-offline'),
            onPressed: hasGoal
                ? () => widget.onSubmit(_value, useAi: false)
                : null,
            child: const Text('Build offline plan'),
          ),
        ] else ...[
          FilledButton(
            key: const ValueKey('roadmap-generate-offline'),
            onPressed: hasGoal
                ? () => widget.onSubmit(_value, useAi: false)
                : null,
            child: const Text('Build my plan'),
          ),
          const SizedBox(height: 8),
          Text(
            'Built on your device from your goal. Add an AI key in '
            'Settings for a plan tailored by the AI.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        if (widget.onCancel != null) ...[
          const SizedBox(height: 8),
          TextButton(onPressed: widget.onCancel, child: const Text('Cancel')),
        ],
      ],
    );
  }
}

class _RoadmapView extends ConsumerWidget {
  const _RoadmapView({required this.roadmap});

  final Roadmap roadmap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final progress = ref.watch(roadmapProgressProvider).valueOrNull;
    final controller = ref.read(roadmapControllerProvider.notifier);
    if (roadmap.isEmpty) {
      return const EmptyState(
        message:
            'This roadmap has no items left. Regenerate it or change the '
            'goal from the top bar.',
        icon: Icons.map_outlined,
      );
    }
    final weekCount = roadmap.weeks.length;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _HeaderCard(roadmap: roadmap, progress: progress),
        const SizedBox(height: 12),
        for (final (w, week) in roadmap.weeks.indexed) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 12, 4, 6),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Week ${w + 1}: ${week.focus}',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                if (progress != null && week.items.isNotEmpty)
                  Text(
                    '${progress.doneInWeek(week)}/${week.items.length}',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          if (week.items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                'Catch-up week: review and practise what you have learned.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          for (final item in week.items)
            GradientCard(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                key: ValueKey('roadmap-item-${item.key}'),
                onTap: () => openRoadmapItem(context, item),
                leading: _ItemAvatar(
                  item: item,
                  done: progress?.isDone(item) ?? false,
                ),
                title: Text(item.title),
                subtitle: Text(
                  item.note.isEmpty
                      ? item.kind.label
                      : '${item.kind.label} · ${item.note}',
                ),
                trailing: PopupMenuButton<String>(
                  tooltip: 'Edit item',
                  onSelected: (action) => switch (action) {
                    'earlier' => controller.moveItem(item.key, -1),
                    'later' => controller.moveItem(item.key, 1),
                    _ => controller.removeItem(item.key),
                  },
                  itemBuilder: (context) => [
                    if (w > 0)
                      const PopupMenuItem(
                        value: 'earlier',
                        child: Text('Move to previous week'),
                      ),
                    if (w < weekCount - 1)
                      const PopupMenuItem(
                        value: 'later',
                        child: Text('Move to next week'),
                      ),
                    const PopupMenuItem(
                      value: 'remove',
                      child: Text('Remove from roadmap'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ],
    );
  }
}

class _ItemAvatar extends StatelessWidget {
  const _ItemAvatar({required this.item, required this.done});

  final RoadmapItem item;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return CircleAvatar(
      backgroundColor: done ? scheme.primary : scheme.primaryContainer,
      foregroundColor: done ? scheme.onPrimary : scheme.onPrimaryContainer,
      child: Icon(done ? Icons.check : roadmapItemIcon(item.kind)),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.roadmap, required this.progress});

  final Roadmap roadmap;
  final RoadmapProgress? progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = progress;
    final next = p?.next;
    final goal = roadmap.goal;
    return GradientCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(goal.goal, style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              '${goal.level.label} · ${goal.hoursPerWeek} h/week · '
              '${roadmap.weeks.length} weeks · '
              '${roadmap.source == RoadmapSource.ai ? 'AI plan' : 'Offline plan'}',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (roadmap.summary.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(roadmap.summary, style: theme.textTheme.bodyMedium),
            ],
            if (p != null) ...[
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: p.fraction,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 6),
              Text(
                '${p.done} of ${p.total} done',
                key: const ValueKey('roadmap-progress-label'),
                style: theme.textTheme.labelLarge,
              ),
            ],
            if (next != null) ...[
              const SizedBox(height: 12),
              FilledButton.tonalIcon(
                key: const ValueKey('roadmap-next'),
                onPressed: () => openRoadmapItem(context, next),
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text('Next: ${next.title}'),
              ),
            ] else if (p != null && p.total > 0) ...[
              const SizedBox(height: 12),
              Text(
                'Roadmap complete. Set a new goal from the top bar.',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
