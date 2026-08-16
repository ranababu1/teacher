import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/services/app_logger.dart';
import 'anthropic_error_classifier.dart';

/// Thin, domain-agnostic wrapper around Anthropic's `/v1/messages`
/// endpoint.
///
/// Knows nothing about `TeachingContext` or any of this app's response
/// models — it takes a system instruction, user content, and a JSON
/// Schema, and hands back the decoded JSON object the model produced.
/// See `AnthropicProvider` for the domain-aware layer built on top of
/// this.
class AnthropicApiClient {
  AnthropicApiClient({required String apiKey, required String baseUrl, Dio? dio})
    : _apiKey = apiKey,
      _baseUrl = baseUrl,
      _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 30),
              sendTimeout: const Duration(seconds: 30),
            ),
          );

  static const _anthropicVersion = '2023-06-01';
  static const _maxTokens = 4096;

  final String _apiKey;
  final String _baseUrl;
  final Dio _dio;

  /// Calls Anthropic's `/v1/messages` endpoint for [model] and returns the
  /// *inner* structured JSON object the model produced.
  ///
  /// Unlike Gemini, the response JSON lands directly in
  /// `content[0].text` as a string with no extra envelope nesting — but a
  /// safety-classifier decline can return HTTP 200 with `stop_reason:
  /// "refusal"` and empty `content`, which is checked before attempting
  /// to read it.
  Future<Map<String, dynamic>> createMessage({
    required String model,
    required String systemInstruction,
    required String userContent,
    required Map<String, dynamic> jsonSchema,
  }) async {
    final Response<dynamic> response;
    try {
      response = await _dio.post<dynamic>(
        '$_baseUrl/v1/messages',
        options: Options(
          headers: {
            'x-api-key': _apiKey,
            'anthropic-version': _anthropicVersion,
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'model': model,
          'max_tokens': _maxTokens,
          'system': systemInstruction,
          'messages': [
            {'role': 'user', 'content': userContent},
          ],
          'output_config': {
            'format': {'type': 'json_schema', 'schema': jsonSchema},
          },
        },
      );
    } on DioException catch (e) {
      final mapped = _mapDioException(e);
      AppLogger.error(mapped.message, e);
      throw mapped;
    }

    return _unwrapEnvelope(response.data);
  }

  AppException _mapDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
      case DioExceptionType.connectionError:
        return NetworkUnavailableException(
          'Could not reach Claude (${e.type.name}): ${e.message ?? 'no further detail'}',
        );
      case DioExceptionType.badResponse:
        return AIUnavailableException(
          'Anthropic API returned HTTP ${e.response?.statusCode}: '
          '${e.response?.data}',
          classifyAnthropicError(
            statusCode: e.response?.statusCode,
            responseBody: e.response?.data,
          ),
        );
      case DioExceptionType.badCertificate:
      case DioExceptionType.cancel:
      case DioExceptionType.unknown:
        return InvalidAIResponseException(
          'Unexpected error calling Claude (${e.type.name}): ${e.message}',
        );
    }
  }

  Map<String, dynamic> _unwrapEnvelope(dynamic rawBody) {
    try {
      final envelope = rawBody is String
          ? jsonDecode(rawBody) as Map<String, dynamic>
          : rawBody as Map<String, dynamic>;

      if (envelope['stop_reason'] == 'refusal') {
        throw const AIUnavailableException(
          'Claude declined to respond to this request (stop_reason: refusal).',
          "The AI teacher declined to answer that. Try rephrasing your question.",
        );
      }

      final content = envelope['content'] as List<dynamic>;
      final text = (content.first as Map<String, dynamic>)['text'] as String;
      final decoded = jsonDecode(text);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException(
          'Expected a JSON object inside the Claude response text',
        );
      }
      return decoded;
    } on AIUnavailableException {
      rethrow;
    } on InvalidAIResponseException {
      rethrow;
    } catch (e) {
      throw InvalidAIResponseException('Could not parse Claude response: $e');
    }
  }
}
