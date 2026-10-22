import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/navigation.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../../shared/widgets/glass_app_bar.dart';
import '../../../../shared/widgets/gradient_card.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../providers/interview_providers.dart';

/// Pick a course to practise interview questions for.
class InterviewPrepScreen extends ConsumerWidget {
  const InterviewPrepScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracks = ref.watch(interviewTracksProvider);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: GlassAppBar(title: const Text('Interview Prep')),
      body: SafeArea(
        child: AsyncValueView(
          value: tracks,
          onRetry: () => ref.invalidate(interviewTracksProvider),
          skeleton: () => const SkeletonCardList(),
          data: (list) {
            if (list.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'No interview questions are available yet.',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Answer out loud or in notes, then compare with a model '
                  'answer and rate yourself honestly. Five questions per '
                  'session, mixing real-world scenarios and concepts.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                for (final t in list)
                  GradientCard(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Icon(
                        Icons.record_voice_over_outlined,
                        color: theme.colorScheme.primary,
                      ),
                      title: Text(t.path.title),
                      subtitle: Text('${t.questionCount} questions'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.openInterviewSession(t.path.id),
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
