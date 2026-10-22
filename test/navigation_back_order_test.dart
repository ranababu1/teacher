import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:teacher/app/navigation.dart';
import 'package:teacher/app/router.dart';
import 'package:teacher/core/constants/routes.dart';

/// Stand-in screen: shows [name] and a set of buttons that call the SAME
/// navigation helpers the real screens use, inside the REAL route tree.
Widget _screen(String name, [Map<String, void Function(BuildContext)>? acts]) {
  return Builder(
    builder: (context) => Scaffold(
      appBar: AppBar(title: Text('screen:$name')),
      body: Column(
        children: [
          for (final e in (acts ?? {}).entries)
            TextButton(onPressed: () => e.value(context), child: Text(e.key)),
        ],
      ),
    ),
  );
}

final _screens = AppScreens(
  dashboard: (_) => _screen('dashboard', {
    'interview': (c) => c.openInterviewPrep(),
    'continue': (c) => c.openLesson('py', 'm1', 'c1'),
    'practice': (c) => c.openPractice(),
  }),
  learn: (_) => _screen('learn', {'path': (c) => c.openLearningPath('py')}),
  progress: (_) => _screen('progress'),
  profile: (_) => _screen('profile', {'settings': (c) => c.openSettings()}),
  learningPath: (s) => _screen('path:${s.pathParameters['pathId']}', {
    'topic': (c) => c.openTopic('py', 'm1'),
  }),
  topic: (s) => _screen('topic:${s.pathParameters['moduleId']}', {
    'lesson': (c) => c.openLesson('py', s.pathParameters['moduleId']!, 'c1'),
    'test': (c) => c.openTopicTest('py', s.pathParameters['moduleId']!),
    'next': (c) => c.replaceWithNextTopic('py', 'm2'),
  }),
  lesson: (s) => _screen('lesson:${s.pathParameters['conceptId']}', {
    'settings': (c) => c.openSettings(),
    'prereq': (c) => c.openLesson('js', 'j1', 'c0'),
    'done': (c) => c.goBack(),
  }),
  topicTest: (s) => _screen('test:${s.pathParameters['moduleId']}', {
    'pass-next': (c) => c.continueFromTestToNextTopic('py', 'm2'),
    'fail-back': (c) => c.goBack(),
  }),
  practice: (_) =>
      _screen('practice', {'session': (c) => c.openPracticeSession('c1')}),
  practiceSession: (_) =>
      _screen('practice-session', {'done': (c) => c.goBack()}),
  settings: (_) => _screen('settings'),
  interviewPrep: (_) =>
      _screen('interview', {'session': (c) => c.openInterviewSession('py')}),
  interviewSession: (s) => _screen('interview:${s.pathParameters['pathId']}'),
  skillCheck: (s) => _screen('skill-check:${s.pathParameters['pathId']}'),
  shell: (shell) => Scaffold(body: shell),
);

Future<GoRouter> _pump(WidgetTester tester, {String initial = '/'}) async {
  final router = GoRouter(
    initialLocation: initial,
    routes: buildAppRoutes(screens: _screens),
  );
  await tester.pumpWidget(MaterialApp.router(routerConfig: router));
  await tester.pumpAndSettle();
  return router;
}

Future<void> _tap(WidgetTester tester, String label) async {
  await tester.tap(find.text(label).last);
  await tester.pumpAndSettle();
}

/// System back (Android back button / gesture).
Future<void> _back(WidgetTester tester) async {
  final handled = await tester.binding.handlePopRoute();
  expect(handled, isTrue, reason: 'back would have closed the app');
  await tester.pumpAndSettle();
}

void _on(String name) =>
    expect(find.text('screen:$name'), findsOneWidget, reason: 'on $name');

void main() {
  testWidgets('dashboard > continue lesson > back returns to dashboard', (
    t,
  ) async {
    await _pump(t);
    await _tap(t, 'continue');
    _on('lesson:c1');
    await _back(t);
    _on('dashboard');
  });

  testWidgets('learn > path > topic > lesson, back x3 retraces', (t) async {
    final router = await _pump(t, initial: Routes.learn);
    await _tap(t, 'path');
    await _tap(t, 'topic');
    await _tap(t, 'lesson');
    _on('lesson:c1');
    await _back(t);
    _on('topic:m1');
    await _back(t);
    _on('path:py');
    // In-app back behaves like system back.
    router.pop();
    await t.pumpAndSettle();
    _on('learn');
  });

  testWidgets('lesson > settings > back returns to the lesson', (t) async {
    await _pump(t);
    await _tap(t, 'continue');
    await _tap(t, 'settings');
    _on('settings');
    await _back(t);
    _on('lesson:c1');
  });

  testWidgets('prerequisite chip pushes; back returns to first lesson', (
    t,
  ) async {
    await _pump(t);
    await _tap(t, 'continue');
    await _tap(t, 'prereq');
    _on('lesson:c0');
    await _back(t);
    _on('lesson:c1');
  });

  testWidgets('failed test: back to topic pops to the topic', (t) async {
    await _pump(t, initial: Routes.learn);
    await _tap(t, 'path');
    await _tap(t, 'topic');
    await _tap(t, 'test');
    await _tap(t, 'fail-back');
    _on('topic:m1');
    await _back(t);
    _on('path:py');
  });

  testWidgets('passed test: next topic replaces; back goes to the path', (
    t,
  ) async {
    await _pump(t, initial: Routes.learn);
    await _tap(t, 'path');
    await _tap(t, 'topic');
    await _tap(t, 'test');
    await _tap(t, 'pass-next');
    _on('topic:m2');
    await _back(t);
    _on('path:py');
    await _back(t);
    _on('learn');
  });

  testWidgets('topic Continue replaces the finished topic', (t) async {
    await _pump(t, initial: Routes.learn);
    await _tap(t, 'path');
    await _tap(t, 'topic');
    await _tap(t, 'next');
    _on('topic:m2');
    await _back(t);
    _on('path:py');
  });

  testWidgets('practice from dashboard: done and back retrace', (t) async {
    await _pump(t);
    await _tap(t, 'practice');
    _on('practice');
    expect(find.byType(BackButton), findsOneWidget);
    await _tap(t, 'session');
    await _tap(t, 'done');
    _on('practice');
    await _back(t);
    _on('dashboard');
  });

  testWidgets('profile > settings > back returns to profile', (t) async {
    await _pump(t, initial: Routes.profile);
    await _tap(t, 'settings');
    await _back(t);
    _on('profile');
  });

  testWidgets('skill-check URL is not swallowed by the topic route', (t) async {
    await _pump(t, initial: Routes.skillCheck('py'));
    _on('skill-check:py');
  });

  testWidgets('dashboard > interview > session, back x2', (t) async {
    await _pump(t);
    await _tap(t, 'interview');
    await _tap(t, 'session');
    _on('interview:py');
    await _back(t);
    _on('interview');
    await _back(t);
    _on('dashboard');
  });

  testWidgets('old /profile/settings link still opens settings', (t) async {
    await _pump(t, initial: Routes.legacyProfileSettings);
    _on('settings');
  });

  testWidgets('cold-start deep link: back walks up, then to dashboard', (
    t,
  ) async {
    await _pump(t, initial: Routes.lesson('py', 'm1', 'c1'));
    _on('lesson:c1');
    await _back(t);
    _on('topic:m1');
    await _back(t);
    _on('path:py');
    await _back(t);
    _on('dashboard');
  });
}
