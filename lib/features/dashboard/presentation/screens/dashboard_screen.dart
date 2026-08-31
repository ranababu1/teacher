import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/routes.dart';
import '../../../../shared/widgets/fade_slide_in.dart';
import '../../../../shared/widgets/glass_blob_field.dart';
import '../../../../shared/widgets/gradient_card.dart';
import '../../../../shared/widgets/section_label.dart';
import '../../../../shared/widgets/sparkline.dart';
import '../../../curriculum/presentation/curriculum_providers.dart';
import '../../../practice/presentation/providers/practice_providers.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../../progress/domain/models/path_progress_summary.dart';
import '../../../progress/presentation/providers/progress_providers.dart';
import '../../../review/presentation/providers/review_providers.dart';
import '../../domain/models/continue_learning_state.dart';
import '../providers/dashboard_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const sections = [
      _Greeting(),
      _ContinueLearningCard(),
      _StatRow(),
      _JourneySection(),
      _RecommendedNextStepCard(),
      _CurriculumSnapshotCard(),
      _ReviewQueueCard(),
      _WhyTeacherSection(),
      _RecentActivitySection(),
    ];

    return Scaffold(
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: sections.length,
          separatorBuilder: (_, _) => const SizedBox(height: 24),
          itemBuilder: (context, index) =>
              FadeSlideIn(index: index, child: sections[index]),
        ),
      ),
    );
  }
}

class _Greeting extends ConsumerWidget {
  const _Greeting();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(learnerProfileControllerProvider).valueOrNull;
    final name = profile?.name ?? '';

    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name.isEmpty ? 'Hi there 👋' : 'Hi $name 👋',
          style: theme.textTheme.headlineMedium,
        ),
        Text(
          'Ready to continue learning?',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _ContinueLearningCard extends ConsumerWidget {
  const _ContinueLearningCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateValue = ref.watch(continueLearningProvider);
    final state = stateValue.valueOrNull;

    if (stateValue.isLoading) {
      return const SizedBox.shrink();
    }

    return switch (state) {
      null || ContinueLearningEmpty() => const _EmptyContinueCard(),
      ContinueLearningConcept(concept: final concept) => _HeroGradientCard(
        eyebrow: 'Continue Learning',
        title: concept.title,
        onTap: () => context.go(
          Routes.lesson(concept.learningPathId, concept.moduleId, concept.id),
        ),
      ),
      ContinueLearningPathCompleted(pathTitle: final title) =>
        _PathCompletedCard(pathTitle: title),
    };
  }
}

class _EmptyContinueCard extends StatelessWidget {
  const _EmptyContinueCard();

  @override
  Widget build(BuildContext context) {
    return _HeroGradientCard(
      eyebrow: "Let's start",
      title: 'Learning.',
      onTap: () => context.go(Routes.learn),
    );
  }
}

class _PathCompletedCard extends StatelessWidget {
  const _PathCompletedCard({required this.pathTitle});

  final String pathTitle;

  @override
  Widget build(BuildContext context) {
    return _HeroGradientCard(
      eyebrow: 'Course Complete',
      title: "You've completed $pathTitle! 🎉",
      onTap: () => context.go(Routes.learn),
    );
  }
}

/// Shared visual treatment for the dashboard's single "hero" moment — a
/// glass card (matching every other card in the app, not a full-bleed
/// gradient wash — an earlier version used [AppGradients.primary] as the
/// whole card background with white text, which the user found "very
/// unreadable" once actually used) with the brand gradient applied
/// selectively to the last word of [title] (via [_GradientTailHeadline]).
/// Pared down to just the eyebrow, title, and visual — the whole card is
/// one tap target via [onTap], with no separate subtitle or CTA button.
class _HeroGradientCard extends StatelessWidget {
  const _HeroGradientCard({
    required this.eyebrow,
    required this.title,
    required this.onTap,
  });

  final String eyebrow;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GradientCard(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        eyebrow,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _GradientTailHeadline(
                      text: title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const _HeroVisual(),
            ],
          ),
        ),
      ),
    );
  }
}

/// The hero card's right-side image slot — a bundled study-themed photo,
/// clipped to a big rounded "swoop" on the top-left corner matching the
/// reference mockups' photo treatment.
class _HeroVisual extends StatelessWidget {
  const _HeroVisual();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(64),
        topRight: Radius.circular(16),
        bottomLeft: Radius.circular(16),
        bottomRight: Radius.circular(16),
      ),
      child: SizedBox(
        width: 110,
        height: 170,
        child: Image.asset(
          'assets/images/hero_photo.jpg',
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
      ),
    );
  }
}

/// Renders [text] with its trailing word gradient-filled (the brand
/// [AppGradients.primary] hues) and the rest in [style]'s plain color —
/// matching the reference mockups' "Learning." / "learning." treatment.
/// Trailing non-ASCII characters (e.g. a `🎉` on the path-completed
/// card) are excluded from the gradient and rendered plain immediately
/// after it, since [ShaderMask] would otherwise flatten an emoji glyph's
/// own colors to the gradient too.
class _GradientTailHeadline extends StatelessWidget {
  const _GradientTailHeadline({required this.text, this.style});

  final String text;
  final TextStyle? style;

  static final _trailingNonAscii = RegExp(r'\s*([^\x00-\x7F]+)\s*$');

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final match = _trailingNonAscii.firstMatch(text);
    final trailing = match?.group(1);
    final core = match == null ? text : text.substring(0, match.start);

    final words = core.trimRight().split(' ');
    final tail = words.isEmpty ? '' : words.removeLast();
    final rest = words.isEmpty ? '' : '${words.join(' ')} ';

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (rest.isNotEmpty) Text(rest, style: style),
        if (tail.isNotEmpty)
          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) => AppGradients.primary(
              colorScheme,
            ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
            child: Text(tail, style: style),
          ),
        if (trailing != null) Text(' $trailing', style: style),
      ],
    );
  }
}

/// A big-number snapshot of the whole curriculum, shown only before any
/// course is started — fills otherwise-empty space with something
/// low-text/high-impact rather than nothing, using real, live-computed
/// numbers (never hardcoded) so it stays correct as the curriculum grows.
class _CurriculumSnapshotCard extends ConsumerWidget {
  const _CurriculumSnapshotCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final started = ref.watch(startedLearningPathIdsProvider).valueOrNull;
    if (started == null || started.isNotEmpty) return const SizedBox.shrink();

    final paths = ref.watch(learningPathsProvider).valueOrNull;
    if (paths == null || paths.isEmpty) return const SizedBox.shrink();

    final courseCount = paths.length;
    final conceptCount = paths.fold(0, (sum, p) => sum + p.conceptCount);
    final hours = paths.fold(0, (sum, p) => sum + p.estimatedHours);

    return GradientCard(
      child: InkWell(
        onTap: () => context.go(Routes.learn),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _BigStat(value: '$courseCount', label: 'Courses'),
              _BigStat(value: '$conceptCount', label: 'Concepts'),
              _BigStat(value: '${hours}h', label: 'Content'),
            ],
          ),
        ),
      ),
    );
  }
}

class _BigStat extends StatelessWidget {
  const _BigStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Text(value, style: theme.textTheme.displaySmall),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// A short, icon-led list of what the app actually offers — shown only
/// before any course is started, alongside [_CurriculumSnapshotCard], but
/// in a deliberately different visual register (icon+caption rather than
/// big numbers) so the two empty-state slots don't feel repetitive.
class _WhyTeacherSection extends ConsumerWidget {
  const _WhyTeacherSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final started = ref.watch(startedLearningPathIdsProvider).valueOrNull;
    if (started == null || started.isNotEmpty) return const SizedBox.shrink();

    return GradientCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: const [
            _BenefitTile(
              icon: Icons.smart_toy_outlined,
              text: 'An AI teacher on demand',
            ),
            SizedBox(height: 16),
            _BenefitTile(
              icon: Icons.replay_circle_filled_outlined,
              text: 'Spaced review that sticks',
            ),
            SizedBox(height: 16),
            _BenefitTile(
              icon: Icons.edit_note_outlined,
              text: 'Practice by writing real code',
            ),
          ],
        ),
      ),
    );
  }
}

class _BenefitTile extends StatelessWidget {
  const _BenefitTile({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: theme.textTheme.titleSmall)),
      ],
    );
  }
}

/// A glanceable row of three stat tiles: the learner's most-recently
/// active course (if any), how many concepts are ready to practice, and
/// the current day streak. Tile 1 is the app's one other real-blur
/// surface per screen alongside the hero card (see [GradientCard]'s
/// [GlassTint] doc comment); tiles 2/3 fake the glass look and always
/// show (even at 0), matching the reference mockup's own always-visible
/// stat row.
class _StatRow extends ConsumerWidget {
  const _StatRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summariesValue = ref.watch(startedPathProgressSummariesProvider);
    final summaries =
        summariesValue.valueOrNull ?? const <PathProgressSummary>[];
    final practiceCount =
        ref.watch(practiceQueueProvider).valueOrNull?.length ?? 0;
    final streak =
        ref.watch(learnerStatsProvider).valueOrNull?.currentStreak ?? 0;

    final tiles = <Widget>[
      if (summaries.isNotEmpty)
        _StatTile(
          tint: GlassTint.dark,
          icon: Icons.menu_book_outlined,
          iconColor: Colors.white,
          value: '${(summaries.first.overallPercent * 100).round()}%',
          label: summaries.first.title,
          sparklineValue: summaries.first.overallPercent,
          sparklineSeed: 0,
          onTap: () =>
              context.go(Routes.learningPath(summaries.first.learningPathId)),
        ),
      _StatTile(
        icon: Icons.checklist_outlined,
        iconColor: AppColors.success,
        value: '$practiceCount',
        label: practiceCount == 1 ? 'concept ready' : 'concepts ready',
        sparklineValue: (practiceCount / 10).clamp(0.0, 1.0),
        sparklineSeed: 1,
        onTap: () => context.go(Routes.practice),
      ),
      _StatTile(
        icon: Icons.local_fire_department_outlined,
        iconColor: AppColors.danger,
        value: '$streak',
        label: 'day streak',
        sparklineValue: (streak / 30).clamp(0.0, 1.0),
        sparklineSeed: 2,
      ),
    ];

    // IntrinsicHeight so the Row's own height is determinate — this Row
    // sits directly inside the Dashboard's ListView with no bounded-height
    // ancestor, and crossAxisAlignment.stretch demands infinite height
    // without it (a real layout crash caught live, not a hypothetical).
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < tiles.length; i++) ...[
            Expanded(child: tiles[i]),
            if (i != tiles.length - 1) const SizedBox(width: 12),
          ],
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.sparklineValue,
    required this.sparklineSeed,
    this.onTap,
    this.tint = GlassTint.adaptive,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final double sparklineValue;
  final int sparklineSeed;
  final VoidCallback? onTap;
  final GlassTint tint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onDark = tint == GlassTint.dark;
    final valueColor = onDark ? Colors.white : theme.colorScheme.onSurface;
    final labelColor = onDark
        ? Colors.white70
        : theme.colorScheme.onSurfaceVariant;

    return GradientCard(
      tint: tint,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(height: 10),
              Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: valueColor,
                ),
              ),
              Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(color: labelColor),
              ),
              const SizedBox(height: 8),
              Sparkline(
                value: sparklineValue,
                seed: sparklineSeed,
                color: iconColor,
                height: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One restyled card per started course, replacing the old plain
/// progress-bar list with a step-dot visualization (fill proportional to
/// [PathProgressSummary.overallPercent] — no literal "module N of M"
/// concept exists in the domain layer, so this is deliberately a
/// percent-driven decoration, not a real module count) and a short
/// next-step caption.
class _JourneySection extends ConsumerWidget {
  const _JourneySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summariesValue = ref.watch(startedPathProgressSummariesProvider);
    final summaries =
        summariesValue.valueOrNull ?? const <PathProgressSummary>[];
    if (summaries.isEmpty) return const SizedBox.shrink();

    final continueState = ref.watch(continueLearningProvider).valueOrNull;
    final continueConcept = continueState is ContinueLearningConcept
        ? continueState.concept
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Continue your journey',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            TextButton(
              onPressed: () => context.go(Routes.progress),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('View all'),
                  Icon(Icons.chevron_right, size: 16),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        for (var i = 0; i < summaries.length; i++) ...[
          _JourneyCard(
            summary: summaries[i],
            caption:
                continueConcept != null &&
                    continueConcept.learningPathId ==
                        summaries[i].learningPathId
                ? continueConcept.title
                : (summaries[i].overallPercent > 0
                      ? 'Keep going'
                      : 'Start your first concept'),
          ),
          if (i != summaries.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _JourneyCard extends StatelessWidget {
  const _JourneyCard({required this.summary, required this.caption});

  final PathProgressSummary summary;
  final String caption;

  static const _dotCount = 5;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final filledDots = (summary.overallPercent * _dotCount).round().clamp(
      0,
      _dotCount,
    );

    return GradientCard(
      child: InkWell(
        onTap: () => context.go(Routes.learningPath(summary.learningPathId)),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              GlassMedallion(
                icon: Icons.menu_book_outlined,
                size: 40,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(summary.title, style: theme.textTheme.titleSmall),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        for (var i = 0; i < _dotCount; i++) ...[
                          Container(
                            width: 9,
                            height: 9,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: i < filledDots
                                  ? colorScheme.primary
                                  : colorScheme.outlineVariant,
                            ),
                          ),
                          if (i != _dotCount - 1)
                            Expanded(
                              child: Container(
                                height: 2,
                                color: i < filledDots - 1
                                    ? colorScheme.primary.withValues(
                                        alpha: 0.5,
                                      )
                                    : colorScheme.outlineVariant.withValues(
                                        alpha: 0.5,
                                      ),
                              ),
                            ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      caption,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(summary.overallPercent * 100).round()}%',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewQueueCard extends ConsumerWidget {
  const _ReviewQueueCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dueValue = ref.watch(dueSchedulesProvider);
    final count = dueValue.valueOrNull?.length ?? 0;
    if (count == 0) return const SizedBox.shrink();

    return GradientCard(
      elevation: AppElevation.flat,
      child: ListTile(
        onTap: () => context.go(Routes.review),
        leading: const Icon(Icons.replay_circle_filled_outlined),
        title: Text('$count concept${count == 1 ? '' : 's'} due for review'),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

/// Reskinned as a dark-glass "featured" card (like the hero card) since
/// it's the Dashboard's other spotlight moment — an abstract
/// [GlassMedallion] icon stands in for the reference mockup's 3D
/// illustration. Copy/data (`{path} → {module} → {concept}`, the reason
/// text) is unchanged from before.
class _RecommendedNextStepCard extends ConsumerWidget {
  const _RecommendedNextStepCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommendationValue = ref.watch(dashboardRecommendationProvider);
    final recommendation = recommendationValue.valueOrNull;
    if (recommendation == null) return const SizedBox.shrink();

    // Right after onboarding (a started path, zero progress, no mastery
    // rows yet), Continue Learning's fallback and this recommendation can
    // independently resolve to the exact same concept — don't show it
    // twice. Once real progress/mastery exists the two naturally diverge
    // and both stay useful.
    final continueValue = ref.watch(continueLearningProvider);
    if (continueValue.isLoading) return const SizedBox.shrink();
    final continueState = continueValue.valueOrNull;
    final continueConceptId = continueState is ContinueLearningConcept
        ? continueState.concept.id
        : null;
    if (recommendation.concept.id == continueConceptId) {
      return const SizedBox.shrink();
    }

    void goToRecommendation() => context.go(
      Routes.lesson(
        recommendation.concept.learningPathId,
        recommendation.concept.moduleId,
        recommendation.concept.id,
      ),
    );

    return GradientCard(
      tint: GlassTint.dark,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: goToRecommendation,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const GlassMedallion(icon: Icons.code),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RECOMMENDED NEXT',
                      style: Theme.of(context).textTheme.labelMedium
                          ?.copyWith(color: Colors.white70, letterSpacing: 1),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${recommendation.learningPathTitle} → ${recommendation.moduleTitle} → '
                      '${recommendation.concept.title}',
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      recommendation.reason,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white54),
                        ),
                        onPressed: goToRecommendation,
                        child: const Text('Start Learning →'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentActivitySection extends ConsumerWidget {
  const _RecentActivitySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completedValue = ref.watch(recentlyCompletedProvider);
    final completed = completedValue.valueOrNull ?? const [];
    if (completed.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel('Recent Activity'),
        const SizedBox(height: 12),
        GradientCard(
          child: Column(
            children: [
              for (final progress in completed)
                _RecentActivityTile(
                  conceptId: progress.conceptId,
                  completedAt: progress.completedAt!,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RecentActivityTile extends ConsumerWidget {
  const _RecentActivityTile({
    required this.conceptId,
    required this.completedAt,
  });

  final String conceptId;
  final DateTime completedAt;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conceptValue = ref.watch(conceptProvider(conceptId));
    final title = conceptValue.valueOrNull?.title ?? conceptId;

    return ListTile(
      leading: const Icon(Icons.task_alt, size: 20),
      title: Text(title),
      subtitle: Text(_relativeTime(completedAt)),
    );
  }

  String _relativeTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
