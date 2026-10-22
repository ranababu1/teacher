import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teacher/core/database/app_database.dart';
import 'package:teacher/core/database/database_provider.dart';
import 'package:teacher/features/ai_teacher/presentation/providers/misconception_providers.dart';
import 'package:teacher/features/curriculum/presentation/curriculum_providers.dart';
import 'package:teacher/features/learning/data/lesson_resume_repository_impl.dart';
import 'package:teacher/features/learning/domain/lesson_step.dart';
import 'package:teacher/features/learning/presentation/providers/lesson_providers.dart';
import 'package:teacher/features/progress/presentation/providers/progress_providers.dart';

import 'support/lesson_fixtures.dart';

void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('repository saves, reads and clears the step per concept', () async {
    final repo = LessonResumeRepositoryImpl(db);
    expect(await repo.lastStepId('c1'), isNull);
    await repo.saveStep('c1', 'example-1');
    await repo.saveStep('c2', 'goals');
    await repo.saveStep('c1', 'try-it');
    expect(await repo.lastStepId('c1'), 'try-it');
    expect(await repo.lastStepId('c2'), 'goals');
    await repo.clear('c1');
    expect(await repo.lastStepId('c1'), isNull);
    expect(await repo.lastStepId('c2'), 'goals');
  });

  ProviderContainer container() {
    final c = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        conceptProvider.overrideWith((ref, id) async => lessonConcept(id: id)),
        unresolvedMisconceptionsProvider.overrideWith(
          (ref, id) async => const [],
        ),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  test('the controller remembers the step and reopens there', () async {
    var c = container();
    final sub = c.listen(lessonFlowProvider('c1'), (_, _) {});
    var flow = (await c.read(lessonFlowProvider('c1').future))!;
    expect(flow.index, 0);
    final controller = c.read(lessonFlowProvider('c1').notifier);
    controller.next();
    controller.next();
    await settle();
    final saved = c.read(lessonFlowProvider('c1')).value!.current.id;
    sub.close();

    c = container();
    c.listen(lessonFlowProvider('c1'), (_, _) {});
    flow = (await c.read(lessonFlowProvider('c1').future))!;
    expect(flow.current.id, saved);
    expect(flow.index, 2);
  });

  test('back returns false on the first step so the screen can exit', () async {
    final c = container();
    c.listen(lessonFlowProvider('c1'), (_, _) {});
    await c.read(lessonFlowProvider('c1').future);
    final controller = c.read(lessonFlowProvider('c1').notifier);
    expect(controller.back(), isFalse);
    controller.next();
    expect(controller.back(), isTrue);
    expect(c.read(lessonFlowProvider('c1')).value!.index, 0);
  });

  test('a quick check gates next until answered', () async {
    final c = container();
    c.listen(lessonFlowProvider('c1'), (_, _) {});
    final flow = (await c.read(lessonFlowProvider('c1').future))!;
    final gate = flow.steps.indexWhere((s) => s is QuickCheckStep);
    final controller = c.read(lessonFlowProvider('c1').notifier);
    for (var i = 0; i < gate + 3; i++) {
      controller.next();
    }
    expect(c.read(lessonFlowProvider('c1')).value!.index, gate);
    controller.answer(0);
    controller.next();
    expect(c.read(lessonFlowProvider('c1')).value!.index, gate + 1);
  });

  test('completing marks the concept completed and clears resume', () async {
    final c = container();
    c.listen(lessonFlowProvider('c1'), (_, _) {});
    await c
        .read(studentProgressRepositoryProvider)
        .markStarted(conceptId: 'c1', learningPathId: 'python', moduleId: 'm1');
    await c.read(lessonFlowProvider('c1').future);
    final controller = c.read(lessonFlowProvider('c1').notifier);
    controller.next();
    await settle();
    expect(await LessonResumeRepositoryImpl(db).lastStepId('c1'), isNotNull);
    await controller.complete();
    final progress = await c
        .read(studentProgressRepositoryProvider)
        .getProgress('c1');
    expect(progress!.isCompleted, isTrue);
    expect(await LessonResumeRepositoryImpl(db).lastStepId('c1'), isNull);
  });
}
