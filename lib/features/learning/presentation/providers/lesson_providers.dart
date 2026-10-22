import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_provider.dart';
import '../../../../core/services/data_revision_provider.dart';
import '../../../ai_teacher/presentation/providers/misconception_providers.dart';
import '../../../curriculum/presentation/curriculum_providers.dart';
import '../../../progress/presentation/providers/progress_providers.dart';
import '../../data/lesson_resume_repository_impl.dart';
import '../../domain/complete_lesson_use_case.dart';
import '../../domain/lesson_flow.dart';
import '../../domain/lesson_resume_repository.dart';
import '../../domain/lesson_step_builder.dart';

final lessonResumeRepositoryProvider = Provider<LessonResumeRepository>(
  (ref) => LessonResumeRepositoryImpl(ref.watch(appDatabaseProvider)),
);

final completeLessonUseCaseProvider = Provider<CompleteLessonUseCase>(
  (ref) => CompleteLessonUseCase(
    progressRepository: ref.watch(studentProgressRepositoryProvider),
    resumeRepository: ref.watch(lessonResumeRepositoryProvider),
  ),
);

/// Step-by-step state for one lesson, keyed by concept id. Null data means
/// the concept does not exist.
final lessonFlowProvider = AsyncNotifierProvider.autoDispose
    .family<LessonFlowController, LessonFlow?, String>(
      LessonFlowController.new,
    );

class LessonFlowController
    extends AutoDisposeFamilyAsyncNotifier<LessonFlow?, String> {
  @override
  Future<LessonFlow?> build(String conceptId) async {
    // Reads, not watches: progress writes elsewhere bump data revisions,
    // and rebuilding would throw away the learner's place mid-lesson.
    final concept = await ref.read(conceptProvider(conceptId).future);
    if (concept == null) return null;
    var hasDetected = false;
    try {
      hasDetected = (await ref.read(
        unresolvedMisconceptionsProvider(conceptId).future,
      )).isNotEmpty;
    } on Object {
      hasDetected = false;
    }
    final steps = const LessonStepBuilder().build(
      concept,
      hasDetectedMisconceptions: hasDetected,
    );
    String? resumeId;
    try {
      resumeId = await ref
          .read(lessonResumeRepositoryProvider)
          .lastStepId(conceptId);
    } on Object {
      resumeId = null;
    }
    return LessonFlow.resume(steps, resumeId);
  }

  LessonFlow? get _flow => state.valueOrNull;

  void _set(LessonFlow next) {
    final previous = _flow;
    if (previous == null) return;
    state = AsyncData(next);
    if (next.index != previous.index && !next.isEmpty) {
      // Best effort: losing the resume point must not break the lesson.
      ref
          .read(lessonResumeRepositoryProvider)
          .saveStep(arg, next.current.id)
          .catchError((Object _) {});
    }
  }

  void next() {
    final flow = _flow;
    if (flow != null) _set(flow.next());
  }

  /// Returns false when already on the first step (the caller exits).
  bool back() {
    final flow = _flow;
    if (flow == null || flow.isFirst) return false;
    _set(flow.back());
    return true;
  }

  void jumpTo(int index) {
    final flow = _flow;
    if (flow != null) _set(flow.jumpTo(index));
  }

  void answer(int option) {
    final flow = _flow;
    if (flow != null) _set(flow.answer(option));
  }

  Future<void> complete() async {
    await ref.read(completeLessonUseCaseProvider)(arg);
    ref.read(dataRevisionProvider.notifier).bump();
  }
}
