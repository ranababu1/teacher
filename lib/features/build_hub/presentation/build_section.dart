import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/navigation.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/gradient_card.dart';
import '../../../shared/widgets/section_label.dart';
import '../domain/build_progress.dart';
import 'build_progress_provider.dart';

/// Projects, system design and long-form challenges, each with progress.
class BuildSection extends ConsumerWidget {
  const BuildSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Loading or error: show the tiles with their plain descriptions so the
    // entry points never disappear.
    final progress = ref.watch(buildProgressProvider).valueOrNull;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel('Build and design'),
        const SizedBox(height: 8),
        _TrackCard(
          key: const ValueKey('build-projects'),
          icon: Icons.construction_outlined,
          title: 'Projects',
          description: 'Guided builds with milestones and a rubric',
          progress: progress?.projects,
          onTap: () => context.openProjects(),
        ),
        const SizedBox(height: 8),
        _TrackCard(
          key: const ValueKey('build-system-design'),
          icon: Icons.account_tree_outlined,
          title: 'System Design',
          description: 'Staged design walkthroughs with model answers',
          progress: progress?.systemDesign,
          onTap: () => context.openSystemDesign(),
        ),
        const SizedBox(height: 8),
        _TrackCard(
          key: const ValueKey('build-coding-challenges'),
          icon: Icons.code_outlined,
          title: 'Long-form challenges',
          description: 'Multi-part coding problems that build on each other',
          progress: progress?.codingChallenges,
          onTap: () => context.openCodingChallenges(),
        ),
      ],
    );
  }
}

class _TrackCard extends StatelessWidget {
  const _TrackCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.progress,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final TrackProgress? progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final track = progress;
    final hasProgress =
        track != null && (track.done > 0 || track.inProgress > 0);
    return GradientCard(
      elevation: AppElevation.flat,
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon),
        title: Text(title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(hasProgress ? track.summary : description),
            if (hasProgress) ...[
              const SizedBox(height: 6),
              LinearProgressIndicator(value: track.fraction),
            ],
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
