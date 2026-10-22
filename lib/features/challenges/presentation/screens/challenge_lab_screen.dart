import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/navigation.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../../shared/widgets/glass_app_bar.dart';
import '../../../../shared/widgets/gradient_card.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../../domain/challenge_service.dart';
import '../providers/challenge_providers.dart';

/// Hub for debugging sessions, coding challenges and real-world scenarios.
class ChallengeLabScreen extends ConsumerWidget {
  const ChallengeLabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(challengeCoursesProvider);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: GlassAppBar(title: const Text('Challenge Lab')),
      body: SafeArea(
        child: AsyncValueView(
          value: value,
          onRetry: () => ref.invalidate(challengeCoursesProvider),
          skeleton: () => const SkeletonCardList(),
          data: (courses) {
            if (courses.isEmpty) {
              return const EmptyState(
                message: 'No challenges are available yet.',
                icon: Icons.bug_report_outlined,
              );
            }
            final stored = ref.watch(selectedChallengeCourseProvider);
            final selected = courses.firstWhere(
              (c) => c.path.id == stored,
              orElse: () => courses.first,
            );
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    Text('Course', style: theme.textTheme.titleMedium),
                    const Spacer(),
                    DropdownButton<String>(
                      value: selected.path.id,
                      onChanged: (v) =>
                          ref
                                  .read(
                                    selectedChallengeCourseProvider.notifier,
                                  )
                                  .state =
                              v,
                      items: [
                        for (final c in courses)
                          DropdownMenuItem(
                            value: c.path.id,
                            child: Text(c.path.title),
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                GradientCard(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Icon(
                      Icons.terminal_outlined,
                      color: theme.colorScheme.primary,
                    ),
                    title: const Text('Long-form Challenges'),
                    subtitle: const Text(
                      'Multi-part problems across courses, with reference '
                      'solutions.',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.openCodingChallenges(),
                  ),
                ),
                for (final kind in ChallengeKind.values)
                  GradientCard(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      enabled: selected.counts[kind]! > 0,
                      leading: Icon(switch (kind) {
                        ChallengeKind.debugging => Icons.bug_report_outlined,
                        ChallengeKind.coding => Icons.code,
                        ChallengeKind.scenario =>
                          Icons.business_center_outlined,
                      }, color: theme.colorScheme.primary),
                      title: Text(kind.title),
                      subtitle: Text(
                        selected.counts[kind]! > 0
                            ? '${kind.description} '
                                  '${selected.counts[kind]} available.'
                            : 'None in this course yet.',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () =>
                          context.openChallengeSet(selected.path.id, kind.name),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
