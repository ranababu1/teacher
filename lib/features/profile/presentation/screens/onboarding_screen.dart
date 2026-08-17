import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/routes.dart';
import '../../../../shared/utils/subject_style.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../../shared/widgets/difficulty_chip.dart';
import '../../../../shared/widgets/gradient_card.dart';
import '../../../curriculum/domain/models/learning_path.dart';
import '../../../curriculum/presentation/curriculum_providers.dart';
import '../../../progress/presentation/providers/progress_providers.dart';
import '../providers/profile_providers.dart';

/// Shown exactly once, on first launch, before the learner ever sees the
/// Dashboard. Two internal steps — name/goal, then a subject picker — kept
/// as one screen/route so the router's onboarding gate only has to care
/// about `hasCompletedOnboarding`, not an intermediate step. See
/// instructions.md section 45.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _nameController = TextEditingController();
  final _goalController = TextEditingController();
  final _selectedPathIds = <String>{};
  int _step = 0;
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  bool get _canContinueFromStep0 => _nameController.text.trim().isNotEmpty;

  void _goToStep1() {
    if (!_canContinueFromStep0) return;
    setState(() => _step = 1);
  }

  void _goBackToStep0() {
    if (_submitting) return;
    setState(() => _step = 0);
  }

  void _togglePath(String pathId) {
    setState(() {
      if (!_selectedPathIds.remove(pathId)) _selectedPathIds.add(pathId);
    });
  }

  /// Starts every selected path first, then completes onboarding last.
  /// Order matters: completing onboarding flips `hasCompletedOnboarding`,
  /// which synchronously fires the router's refreshListenable and
  /// schedules navigation away from this screen — starting paths
  /// afterward would risk some silently not finishing before that happens.
  Future<void> _submit() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    for (final pathId in _selectedPathIds) {
      await ref.read(learningPathStarterProvider).call(pathId);
    }
    final goal = _goalController.text.trim();
    await ref
        .read(learnerProfileControllerProvider.notifier)
        .completeOnboarding(
          name: _nameController.text.trim(),
          careerGoal: goal.isEmpty ? null : goal,
        );
    if (mounted) context.go(Routes.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _step == 0
                    ? KeyedSubtree(
                        key: const ValueKey('step0'),
                        child: _buildStep0(theme),
                      )
                    : KeyedSubtree(
                        key: const ValueKey('step1'),
                        child: _buildStep1(theme),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep0(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Welcome to Teacher', style: theme.textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(
          "Let's set up your profile before you get started.",
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 32),
        TextField(
          controller: _nameController,
          autofocus: true,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            labelText: 'Your name',
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _goalController,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(
            labelText: "What's your goal? (optional)",
            hintText: 'e.g. Become a Full Stack AI Developer',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (_) => _goToStep1(),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _canContinueFromStep0 ? _goToStep1 : null,
            child: const Text('Continue'),
          ),
        ),
      ],
    );
  }

  Widget _buildStep1(ThemeData theme) {
    final pathsValue = ref.watch(learningPathsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _submitting ? null : _goBackToStep0,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          visualDensity: VisualDensity.compact,
        ),
        const SizedBox(height: 12),
        Text(
          'What do you want to learn?',
          style: theme.textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Pick any courses you want to start now — you can add more '
          'later from Learn.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        AsyncValueView(
          value: pathsValue,
          onRetry: () => ref.invalidate(learningPathsProvider),
          data: (paths) => Column(
            children: [
              for (final path in paths)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _LearningInterestTile(
                    path: path,
                    selected: _selectedPathIds.contains(path.id),
                    enabled: !_submitting,
                    onTap: () => _togglePath(path.id),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _submitting ? null : _submit,
            child: _submitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    _selectedPathIds.isEmpty ? 'Skip for now' : 'Get Started',
                  ),
          ),
        ),
      ],
    );
  }
}

/// A selectable subject row for the onboarding picker — mirrors
/// `_LearningPathCard`'s icon/color treatment from the Learn tab
/// (`learning_paths_screen.dart`) so a subject's visual identity is
/// consistent everywhere it appears.
class _LearningInterestTile extends StatelessWidget {
  const _LearningInterestTile({
    required this.path,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final LearningPath path;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  bool get _comingSoon => path.modules.isEmpty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = subjectColor(path.id, theme.brightness);
    final interactive = enabled && !_comingSoon;

    return Opacity(
      opacity: _comingSoon ? 0.6 : 1,
      child: GradientCard(
        clipBehavior: Clip.antiAlias,
        child: CheckboxListTile(
          value: selected,
          onChanged: interactive ? (_) => onTap() : null,
          controlAffinity: ListTileControlAffinity.trailing,
          secondary: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(subjectIcon(path.iconName), color: color),
          ),
          title: Text(path.title),
          subtitle: _comingSoon
              ? const Text('Coming Soon')
              : Align(
                  alignment: Alignment.centerLeft,
                  child: DifficultyChip(difficulty: path.difficulty),
                ),
        ),
      ),
    );
  }
}
