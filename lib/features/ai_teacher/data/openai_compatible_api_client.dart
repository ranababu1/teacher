import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/services/app_logger.dart';
import 'openai_compatible_error_classifier.dart';

/// Thin, domain-agnostic wrapper around the OpenAI Chat Completions API
/// shape — used for both OpenAI itself and DeepSeek, which documents
/// wire-compatibility with this same endpoint/request/response format.
///
/// Knows nothing about `TeachingContext` or any of this app's response
/// models — it takes a system instruction and user content, and hands
/// back the decoded JSON object the model produced. See
/// `OpenAiCompatibleProvider` for the domain-aware layer built on top of
/// this.
class OpenAiCompatibleApiClient {
  OpenAiCompatibleApiClient({
    required String apiKey,
    required String baseUrl,
    required this.providerLabel,
    Dio? dio,
  }) : _apiKey = apiKey,
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

  final String _apiKey;
  final String _baseUrl;
  final String providerLabel;
  final Dio _dio;

  /// Calls the `/chat/completions` endpoint for [model] and returns the
  /// *inner* structured JSON object the model produced.
  ///
  /// The response envelope is
  /// `{"choices": [{"message": {"content": "<json-as-a-string>"}}]}` — the
  /// structured payload requested via `response_format: json_object` is a
  /// JSON string nested inside that envelope, so it has to be decoded a
  /// second time. Callers never need to know about that nesting; they get
  /// the final decoded `Map` back directly.
  Future<Map<String, dynamic>> chatCompletion({
    required String model,
    required String systemInstruction,
    required String userContent,
  }) async {
    final Response<dynamic> response;
    try {
      response = await _dio.post<dynamic>(
        '$_baseUrl/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer $_apiKey',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'model': model,
          'messages': [
            {'role': 'system', 'content': systemInstruction},
            {'role': 'user', 'content': userContent},
          ],
          'response_format': {'type': 'json_object'},
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
          'Could not reach $providerLabel (${e.type.name}): ${e.message ?? 'no further detail'}',
        );
      case DioExceptionType.badResponse:
        return AIUnavailableException(
          '$providerLabel API returned HTTP ${e.response?.statusCode}: '
          '${e.response?.data}',
          classifyOpenAiCompatibleError(
            statusCode: e.response?.statusCode,
            responseBody: e.response?.data,
            providerLabel: providerLabel,
          ),
        );
      case DioExceptionType.badCertificate:
      case DioExceptionType.cancel:
      case DioExceptionType.unknown:
        return InvalidAIResponseException(
          'Unexpected error calling $providerLabel (${e.type.name}): ${e.message}',
        );
    }
  }

  Map<String, dynamic> _unwrapEnvelope(dynamic rawBody) {
    try {
      final envelope = rawBody is String
          ? jsonDecode(rawBody) as Map<String, dynamic>
          : rawBody as Map<String, dynamic>;
      final choices = envelope['choices'] as List<dynamic>;
      final choice = choices.first as Map<String, dynamic>;
      final message = choice['message'] as Map<String, dynamic>;
      final text = message['content'] as String;
      final decoded = jsonDecode(text);
      if (decoded is! Map<String, dynamic>) {
        throw FormatException(
          'Expected a JSON object inside the $providerLabel response text',
        );
      }
      return decoded;
    } on InvalidAIResponseException {
      rethrow;
    } catch (e) {
      throw InvalidAIResponseException(
        'Could not parse $providerLabel response: $e',
      );
    }
  }
}
