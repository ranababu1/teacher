import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teacher/core/database/app_database.dart';
import 'package:teacher/core/errors/app_exception.dart';
import 'package:teacher/features/code_runner/data/code_runner_repository_impl.dart';
import 'package:teacher/features/code_runner/data/remote_code_runner.dart';
import 'package:teacher/features/code_runner/domain/code_runner.dart';
import 'package:teacher/features/code_runner/domain/models/code_run.dart';

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.respond);

  final ResponseBody Function(RequestOptions options) respond;
  RequestOptions? last;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    last = options;
    return respond(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(Object body, [int status = 200]) => ResponseBody.fromString(
  jsonEncode(body),
  status,
  headers: {
    Headers.contentTypeHeader: [Headers.jsonContentType],
  },
);

RemoteCodeRunner _runner(_FakeAdapter adapter) {
  final dio = Dio()..httpClientAdapter = adapter;
  return RemoteCodeRunner(Uri.parse('https://runner.example/run'), dio: dio);
}

class _RecordingRunner implements CodeRunner {
  final requests = <CodeRunRequest>[];

  @override
  Future<CodeRunResult> run(CodeRunRequest request) async {
    requests.add(request);
    return const CodeRunResult(stdout: 'hi\n', stderr: '', exitCode: 0);
  }
}

const _request = CodeRunRequest(language: 'python', source: 'print("hi")');

void main() {
  group('parseCodeRunnerUrl', () {
    test('accepts https URLs and rejects everything else', () {
      expect(parseCodeRunnerUrl(' https://run.example/api '), isNotNull);
      expect(parseCodeRunnerUrl('http://run.example/api'), isNull);
      expect(parseCodeRunnerUrl('run.example'), isNull);
      expect(parseCodeRunnerUrl(''), isNull);
      expect(parseCodeRunnerUrl('https://'), isNull);
    });
  });

  group('CodeRunnerRepositoryImpl', () {
    late AppDatabase db;
    late _RecordingRunner runner;
    late CodeRunnerRepositoryImpl repo;
    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      runner = _RecordingRunner();
      repo = CodeRunnerRepositoryImpl(db, runnerFactory: (_) => runner);
    });
    tearDown(() => db.close());

    test('is disabled by default and refuses to run', () async {
      expect(await repo.endpoint(), isNull);
      await expectLater(
        repo.run(_request),
        throwsA(isA<ConfigurationException>()),
      );
      expect(runner.requests, isEmpty);
    });

    test('saves, uses and clears the endpoint', () async {
      await repo.setEndpoint('https://run.example/api');
      expect(await repo.endpoint(), Uri.parse('https://run.example/api'));
      final result = await repo.run(_request);
      expect(result.stdout, 'hi\n');
      expect(runner.requests.single.source, 'print("hi")');
      await repo.setEndpoint('  ');
      expect(await repo.endpoint(), isNull);
    });

    test('rejects an invalid URL without changing the setting', () async {
      await repo.setEndpoint('https://run.example/api');
      expect(
        () => repo.setEndpoint('ftp://nope'),
        throwsA(isA<ArgumentError>()),
      );
      expect(await repo.endpoint(), Uri.parse('https://run.example/api'));
    });
  });

  group('RemoteCodeRunner', () {
    test('posts the documented JSON and parses the reply', () async {
      final adapter = _FakeAdapter(
        (_) => _json({
          'stdout': '3\n',
          'stderr': '',
          'exitCode': 0,
          'timedOut': false,
        }),
      );
      final result = await _runner(adapter).run(_request);
      expect(result.succeeded, isTrue);
      expect(result.stdout, '3\n');
      expect(adapter.last!.method, 'POST');
      expect(adapter.last!.uri.toString(), 'https://runner.example/run');
      final body = adapter.last!.data as Map<String, dynamic>;
      expect(body['language'], 'python');
      expect(body['timeoutSeconds'], 10);
    });

    test('reports timeouts and non-zero exits', () async {
      final adapter = _FakeAdapter(
        (_) => _json({'stdout': '', 'exitCode': 137, 'timedOut': true}),
      );
      final result = await _runner(adapter).run(_request);
      expect(result.timedOut, isTrue);
      expect(result.succeeded, isFalse);
    });

    test('maps a malformed reply and HTTP errors to app exceptions', () async {
      await expectLater(
        _runner(_FakeAdapter((_) => _json({'stdout': 'x'}))).run(_request),
        throwsA(isA<ConfigurationException>()),
      );
      await expectLater(
        _runner(_FakeAdapter((_) => _json({'error': 'boom'}, 500)))
            .run(_request),
        throwsA(isA<ConfigurationException>()),
      );
    });

    test('maps connection failures to NetworkUnavailableException', () async {
      final adapter = _FakeAdapter(
        (options) => throw DioException.connectionError(
          requestOptions: options,
          reason: 'refused',
        ),
      );
      await expectLater(
        _runner(adapter).run(_request),
        throwsA(isA<NetworkUnavailableException>()),
      );
    });
  });
}
