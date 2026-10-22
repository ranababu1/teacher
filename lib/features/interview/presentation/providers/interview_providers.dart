import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../curriculum/domain/models/learning_path.dart';
import '../../../curriculum/presentation/curriculum_providers.dart';
import '../../domain/interview_service.dart';
import '../../domain/models/interview.dart';

final interviewServiceProvider = Provider<InterviewService>(
  (ref) => InterviewService(),
);

/// Courses that have interview questions, with their bank size.
final interviewTracksProvider =
    FutureProvider<List<({LearningPath path, int questionCount})>>((ref) async {
      final paths = await ref.watch(learningPathsProvider.future);
      final service = ref.read(interviewServiceProvider);
      return [
        for (final p in paths)
          if (service.questionBank(p).isNotEmpty)
            (path: p, questionCount: service.questionBank(p).length),
      ];
    });

/// A fresh random session for one course. Auto-disposed, so each visit
/// draws new questions.
final interviewSessionProvider = FutureProvider.autoDispose
    .family<({LearningPath path, List<InterviewQuestion> questions})?, String>((
      ref,
      pathId,
    ) async {
      final path = await ref.watch(learningPathProvider(pathId).future);
      if (path == null) return null;
      return (
        path: path,
        questions: ref.read(interviewServiceProvider).buildSession(path),
      );
    });
