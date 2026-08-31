import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/routes.dart';
import '../../../../shared/utils/subject_style.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../../shared/widgets/glass_app_bar.dart';
import '../../../../shared/widgets/gradient_card.dart';
import '../../../../shared/widgets/labeled_progress_bar.dart';
import '../../../../shared/widgets/section_label.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../../../progress/domain/models/course_status.dart';
import '../../../progress/domain/models/path_progress_summary.dart';
import '../../../progress/presentation/providers/progress_providers.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../../domain/models/badge.dart' as profile_badge;
import '../../domain/models/learner_profile.dart';
import '../../domain/models/learner_stats.dart';
import '../providers/profile_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileValue = ref.watch(learnerProfileControllerProvider);

    return Scaffold(
      appBar: GlassAppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(Routes.profileSettings),
          ),
        ],
      ),
      body: SafeArea(
        child: AsyncValueView(
          value: profileValue,
          onRetry: () => ref.invalidate(learnerProfileControllerProvider),
          skeleton: () => const SkeletonCardList(itemCount: 4),
          data: (profile) => _ProfileBody(profile: profile),
        ),
      ),
    );
  }
}

class _ProfileBody extends ConsumerWidget {
  const _ProfileBody({required this.profile});

  final LearnerProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(learnerStatsProvider).valueOrNull ?? LearnerStats.empty;
    final allStarted =
        ref.watch(startedPathProgressSummariesProvider).valueOrNull ??
        const <PathProgressSummary>[];
    // "My Skills" only shows courses substantial enough to call a skill —
    // a course just started at 5% isn't one yet.
    final skills = allStarted.where((s) => s.overallPercent >= 0.5).toList();
    final dailyTargetMinutes = ref
        .watch(settingsControllerProvider)
        .valueOrNull
        ?.dailyTargetMinutes;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _ProfileHeader(profile: profile, stats: stats),
        const SizedBox(height: 24),
        const SectionLabel('Learning Progress'),
        const SizedBox(height: 12),
        _LearningProgressCard(stats: stats),
        if (stats.badges.isNotEmpty) ...[
          const SizedBox(height: 24),
          const SectionLabel('Achievements'),
          const SizedBox(height: 12),
          _AchievementsWrap(badges: stats.badges),
        ],
        const SizedBox(height: 24),
        const SectionLabel('My Learning Goals'),
        const SizedBox(height: 12),
        _LearningGoalsCard(
          profile: profile,
          dailyTargetMinutes: dailyTargetMinutes,
        ),
        if (skills.isNotEmpty) ...[
          const SizedBox(height: 24),
          const SectionLabel('My Skills'),
          const SizedBox(height: 12),
          _SkillsCard(skills: skills),
        ],
        const SizedBox(height: 24),
        const SectionLabel('Settings'),
        const SizedBox(height: 12),
        const _SettingsLinksCard(),
      ],
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.profile, required this.stats});

  final LearnerProfile profile;
  final LearnerStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(
            Icons.person,
            size: 40,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          profile.name.isEmpty ? 'Learner' : profile.name,
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 2),
        Text(
          stats.experienceLevel.label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _StatBadge(emoji: '🔥', label: '${stats.currentStreak} day streak'),
            const SizedBox(width: 24),
            _StatBadge(emoji: '⭐', label: '${stats.totalXp} XP'),
          ],
        ),
      ],
    );
  }
}

class _StatBadge extends StatelessWidget {
  const _StatBadge({required this.emoji, required this.label});

  final String emoji;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _LearningProgressCard extends StatelessWidget {
  const _LearningProgressCard({required this.stats});

  final LearnerStats stats;

  @override
  Widget build(BuildContext context) {
    return GradientCard(
      elevation: AppElevation.prominent,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _StatRow(
              label: 'Courses completed',
              value: stats.coursesCompleted,
            ),
            _StatRow(
              label: 'Lessons completed',
              value: stats.lessonsCompleted,
            ),
            _StatRow(
              label: 'Practice questions',
              value: stats.practiceQuestionsAttempted,
            ),
            _StatRow(
              label: 'Coding challenges',
              value: stats.codingChallengesAttempted,
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final String label;
  final int value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        children: [
          Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
          Text(
            '$value',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementsWrap extends StatelessWidget {
  const _AchievementsWrap({required this.badges});

  final List<profile_badge.Badge> badges;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [for (final badge in badges) _BadgeTile(badge: badge)],
    );
  }
}

/// One collectible in the Achievements grid — an emoji medallion, its
/// flavorful name, and the concrete criterion it was earned for.
class _BadgeTile extends StatelessWidget {
  const _BadgeTile({required this.badge});

  final profile_badge.Badge badge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 126,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.primary.withValues(alpha: 0.15),
            ),
            child: Text(badge.emoji, style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(height: 8),
          Text(
            badge.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            badge.description,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _LearningGoalsCard extends ConsumerWidget {
  const _LearningGoalsCard({
    required this.profile,
    required this.dailyTargetMinutes,
  });

  final LearnerProfile profile;
  final int? dailyTargetMinutes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasGoal = (profile.careerGoal ?? '').isNotEmpty;

    return GradientCard(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.flag_outlined),
            title: Text(hasGoal ? profile.careerGoal! : 'Add a goal'),
            subtitle: const Text('Career goal'),
            trailing: const Icon(Icons.edit_outlined, size: 18),
            onTap: () => _editGoal(context, ref, profile.careerGoal),
          ),
          if (dailyTargetMinutes != null) ...[
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.timer_outlined),
              title: Text('Daily target: $dailyTargetMinutes minutes'),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _editGoal(
    BuildContext context,
    WidgetRef ref,
    String? current,
  ) async {
    final controller = TextEditingController(text: current ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Your goal'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'e.g. Become a Full Stack AI Developer',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null) {
      await ref
          .read(learnerProfileControllerProvider.notifier)
          .setCareerGoal(result.isEmpty ? null : result);
    }
  }
}

class _SkillsCard extends StatelessWidget {
  const _SkillsCard({required this.skills});

  final List<PathProgressSummary> skills;

  @override
  Widget build(BuildContext context) {
    return GradientCard(
      elevation: AppElevation.prominent,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            for (var i = 0; i < skills.length; i++) ...[
              _SkillRow(skill: skills[i]),
              if (i != skills.length - 1) const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }
}

/// One "My Skills" row — a course's progress bar plus its performance
/// tier ("In Progress" while under 100%, then "Passed"/"Expert"/"Legend"
/// once complete, graded off its average topic-quiz score).
class _SkillRow extends ConsumerWidget {
  const _SkillRow({required this.skill});

  final PathProgressSummary skill;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brightness = Theme.of(context).brightness;
    final status = ref
        .watch(
          courseStatusProvider((
            pathId: skill.learningPathId,
            overallPercent: skill.overallPercent,
          )),
        )
        .valueOrNull;

    return LabeledProgressBar(
      label: skill.title,
      progress: skill.overallPercent,
      color: subjectColor(skill.learningPathId, brightness),
      labelBadge: status == null ? null : _CourseStatusChip(status: status),
    );
  }
}

class _CourseStatusChip extends StatelessWidget {
  const _CourseStatusChip({required this.status});

  final CourseStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = switch (status) {
      CourseStatus.inProgress => theme.colorScheme.onSurfaceVariant,
      CourseStatus.passed => AppColors.success,
      CourseStatus.expert => theme.colorScheme.primary,
      CourseStatus.legend => AppColors.warning,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SettingsLinksCard extends StatelessWidget {
  const _SettingsLinksCard();

  @override
  Widget build(BuildContext context) {
    return GradientCard(
      elevation: AppElevation.flat,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Notifications'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(Routes.profileSettings),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.dark_mode_outlined),
            title: const Text('Appearance'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(Routes.profileSettings),
          ),
        ],
      ),
    );
  }
}
