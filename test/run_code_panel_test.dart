import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teacher/features/code_runner/domain/code_runner.dart';
import 'package:teacher/features/code_runner/domain/code_runner_repository.dart';
import 'package:teacher/features/code_runner/domain/models/code_run.dart';
import 'package:teacher/features/code_runner/presentation/providers/code_runner_providers.dart';
import 'package:teacher/features/code_runner/presentation/widgets/run_code_panel.dart';

class _RecordingRunner implements CodeRunner {
  final requests = <CodeRunRequest>[];

  @override
  Future<CodeRunResult> run(CodeRunRequest request) async {
    requests.add(request);
    return const CodeRunResult(stdout: 'hi\n', stderr: '', exitCode: 0);
  }
}

class _FakeRepo implements CodeRunnerRepository {
  _FakeRepo(this.url);

  Uri? url;
  final runner = _RecordingRunner();

  @override
  Future<Uri?> endpoint() async => url;

  @override
  Future<void> setEndpoint(String? value) async =>
      url = value == null ? null : Uri.parse(value);

  @override
  Future<CodeRunResult> run(CodeRunRequest request) => runner.run(request);
}

void main() {
  group('RunCodePanel', () {
    Widget app(_FakeRepo repo) => ProviderScope(
      overrides: [codeRunnerRepositoryProvider.overrideWithValue(repo)],
      child: MaterialApp(
        home: Scaffold(
          body: RunCodePanel(language: 'python', source: () => 'print(1)'),
        ),
      ),
    );

    testWidgets('stays hidden when no runner is configured', (tester) async {
      await tester.pumpWidget(app(_FakeRepo(null)));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('run-code')), findsNothing);
    });

    testWidgets('runs code and shows the output when configured', (
      tester,
    ) async {
      final repo = _FakeRepo(Uri.parse('https://run.example/api'));
      await tester.pumpWidget(app(repo));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('run-code')));
      await tester.pumpAndSettle();
      expect(repo.runner.requests.single.source, 'print(1)');
      expect(find.byKey(const ValueKey('run-output')), findsOneWidget);
      expect(find.textContaining('Exited with code 0'), findsOneWidget);
    });
  });
}
