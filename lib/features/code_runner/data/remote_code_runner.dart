import 'package:dio/dio.dart';

import '../../../core/errors/app_exception.dart';
import '../domain/code_runner.dart';
import '../domain/models/code_run.dart';

/// Talks to a learner-configured execution API.
///
/// Contract: `POST <endpoint>` with JSON
/// `{"language", "source", "stdin", "timeoutSeconds"}` and a JSON reply
/// `{"stdout", "stderr", "exitCode", "timedOut"}`. No credentials are
/// sent or stored by the app.
class RemoteCodeRunner implements CodeRunner {
  RemoteCodeRunner(this.endpoint, {Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 60),
              sendTimeout: const Duration(seconds: 15),
            ),
          );

  final Uri endpoint;
  final Dio _dio;

  @override
  Future<CodeRunResult> run(CodeRunRequest request) async {
    final Response<dynamic> response;
    try {
      response = await _dio.postUri<dynamic>(
        endpoint,
        data: request.toJson(),
        options: Options(contentType: Headers.jsonContentType),
      );
    } on DioException catch (e) {
      switch (e.type) {
        case DioExceptionType.connectionError:
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          throw NetworkUnavailableException(
            'Code runner unreachable: ${e.type}',
          );
        default:
          throw ConfigurationException(
            'Code runner request failed: HTTP ${e.response?.statusCode}',
          );
      }
    }
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw const ConfigurationException('Code runner returned non-JSON data');
    }
    try {
      return CodeRunResult.fromJson(data);
    } on FormatException catch (e) {
      throw ConfigurationException('Code runner reply invalid: ${e.message}');
    }
  }
}
