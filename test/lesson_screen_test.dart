import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:teacher/core/database/app_database.dart';
import 'package:teacher/core/database/database_provider.dart';
import 'package:teacher/features/ai_teacher/presentation/providers/misconception_providers.dart';
import 'package:teacher/features/curriculum/domain/models/concept.dart';
import 'package:teacher/features/curriculum/presentation/curriculum_providers.dart';
import 'package:teacher/features/learning/data/lesson_resume_repository_impl.dart';
import 'package:teacher/features/learning/domain/lesson_step_builder.dart';
import 'package:teacher/features/learning/domain/lesson_step.dart';
import 'package:teacher/features/learning/presentation/screens/lesson_screen.dart';
import 'package:teacher/features/progress/presentation/providers/progress_providers.dart';

import 'support/lesson_fixtures.dart';

void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  final steps = const LessonStepBuilder().build(lessonConcept());
  final gate = steps.indexWhere((s) => s is QuickCheckStep);

  Future<void> pumpApp(WidgetTester tester) async {
    // Galaxy S25 Ultra: 1440 x 3120 physical pixels.
    tester.view.physicalSize = const Size(1440, 3120);
    tester.view.devicePixelRatio = 3.5;
    addTearDown(tester.view.reset);
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, _) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => context.push('/lesson'),
                child: const Text('open lesson'),
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/lesson',
          builder: (_, _) => const LessonScreen(
            pathId: 'python',
            moduleId: 'm1',
            conceptId: 'c1',
          ),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          isLearningPathStartedProvider.overrideWith((ref, id) async => true),
          conceptProvider.overrideWith(
            (ref, id) async => lessonConcept(id: id),
          ),
          prerequisiteConceptsProvider.overrideWith(
            (ref, id) async => const <Concept>[],
          ),
          unresolvedMisconceptionsProvider.overrideWith(
            (ref, id) async => const [],
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.tap(find.text('open lesson'));
    await tester.pumpAndSettle();
  }

  Finder stepLabel(int x) => find.text('Step $x of ${steps.length}');

  Future<void> tapNext(WidgetTester tester) async {
    await tester.tap(find.byKey(const ValueKey('lesson-next')));
    await tester.pumpAndSettle();
  }

  bool nextEnabled(WidgetTester tester) =>
      tester
          .widget<ButtonStyleButton>(find.byKey(const ValueKey('lesson-next')))
          .onPressed !=
      null;

  testWidgets('shows one step at a time with step X of N', (tester) async {
    await pumpApp(tester);
    expect(stepLabel(1), findsOneWidget);
    expect(find.text('You will learn to'), findsOneWidget);
    expect(find.byKey(const ValueKey('lesson-prev')), findsNothing);
    await tapNext(tester);
    expect(stepLabel(2), findsOneWidget);
    expect(find.text('Labels'), findsWidgets);
  });

  testWidgets('a quick check gates Next until answered, with feedback', (
    tester,
  ) async {
    await pumpApp(tester);
    for (var i = 0; i < gate; i++) {
      await tapNext(tester);
    }
    expect(stepLabel(gate + 1), findsOneWidget);
    expect(find.text('Answer to continue'), findsWidgets);
    expect(nextEnabled(tester), isFalse);
    // Swiping forward is blocked too.
    await tester.drag(
      find.byKey(const ValueKey('lesson-pages')),
      const Offset(-400, 0),
    );
    await tester.pumpAndSettle();
    expect(stepLabel(gate + 1), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('quick-option-0')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('quick-feedback')), findsOneWidget);
    expect(find.textContaining('Not quite'), findsOneWidget);
    expect(nextEnabled(tester), isTrue);
    await tapNext(tester);
    expect(stepLabel(gate + 2), findsOneWidget);
  });

  testWidgets('swiping moves between steps', (tester) async {
    await pumpApp(tester);
    await tester.drag(
      find.byKey(const ValueKey('lesson-pages')),
      const Offset(-400, 0),
    );
    await tester.pumpAndSettle();
    expect(stepLabel(2), findsOneWidget);
    await tester.drag(
      find.byKey(const ValueKey('lesson-pages')),
      const Offset(400, 0),
    );
    await tester.pumpAndSettle();
  });

  testWidgets('system back goes to the previous step, then exits', (
    tester,
  ) async {
    await pumpApp(tester);
    await tapNext(tester);
    await tapNext(tester);
    expect(stepLabel(3), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(stepLabel(2), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('lesson-back')));
    await tester.pumpAndSettle();
    expect(stepLabel(1), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('open lesson'), findsOneWidget);
  });

  testWidgets('reopens at the saved step', (tester) async {
    await LessonResumeRepositoryImpl(db).saveStep('c1', steps[gate + 1].id);
    await pumpApp(tester);
    expect(stepLabel(gate + 2), findsOneWidget);
  });

  testWidgets('the step list jumps, but not past an unanswered check', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.tap(find.byKey(const ValueKey('lesson-progress')));
    await tester.pumpAndSettle();
    final locked = tester.widget<ListTile>(
      find.byKey(ValueKey('step-tile-${gate + 1}')),
    );
    expect(locked.enabled, isFalse);
    await tester.tap(find.byKey(const ValueKey('step-tile-1')));
    await tester.pumpAndSettle();
    expect(stepLabel(2), findsOneWidget);
  });

  testWidgets('finishing the last step completes the lesson and exits', (
    tester,
  ) async {
    await LessonResumeRepositoryImpl(db).saveStep('c1', steps.last.id);
    await pumpApp(tester);
    expect(stepLabel(steps.length), findsOneWidget);
    expect(find.text('Finish lesson'), findsOneWidget);
    await tapNext(tester);
    expect(find.text('open lesson'), findsOneWidget);
    final container = ProviderScope.containerOf(
      tester.element(find.text('open lesson')),
    );
    final progress = await container
        .read(studentProgressRepositoryProvider)
        .getProgress('c1');
    expect(progress?.isCompleted, isTrue);
    expect(await LessonResumeRepositoryImpl(db).lastStepId('c1'), isNull);
  });
}
