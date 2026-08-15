import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/services/app_logger.dart';
import 'gemini_error_classifier.dart';

/// Thin, domain-agnostic wrapper around Gemini's `generateContent` REST
/// endpoint.
///
/// Knows nothing about [TeachingContext] or any of this app's response
/// models — it takes a system instruction, user content, and a Gemini
/// `responseSchema`, and hands back the decoded JSON object the model
/// produced. See `GeminiProvider` for the domain-aware layer built on top
/// of this.
class GeminiApiClient {
  GeminiApiClient({required String apiKey, required String baseUrl, Dio? dio})
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

  final String _apiKey;
  final String _baseUrl;
  final Dio _dio;

  /// Calls Gemini's `generateContent` endpoint for [model] and returns the
  /// *inner* structured JSON object the model produced.
  ///
  /// Gemini's HTTP envelope is
  /// `{"candidates": [{"content": {"parts": [{"text": "<json-as-a-string>"}]}}]}`
  /// — the actual structured payload constrained by [responseSchema] is a
  /// JSON string nested inside that envelope, so it has to be decoded a
  /// second time. Callers never need to know about that nesting; they get
  /// the final decoded `Map` back directly.
  Future<Map<String, dynamic>> generateContent({
    required String model,
    required String systemInstruction,
    required String userContent,
    required Map<String, dynamic> responseSchema,
  }) async {
    final Response<dynamic> response;
    try {
      response = await _dio.post<dynamic>(
        '$_baseUrl/v1beta/models/$model:generateContent',
        options: Options(
          headers: {
            'x-goog-api-key': _apiKey,
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'contents': [
            {
              'role': 'user',
              'parts': [
                {'text': userContent},
              ],
            },
          ],
          'systemInstruction': {
            'parts': [
              {'text': systemInstruction},
            ],
          },
          'generationConfig': {
            'responseMimeType': 'application/json',
            'responseSchema': responseSchema,
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
          'Could not reach Gemini (${e.type.name}): ${e.message ?? 'no further detail'}',
        );
      case DioExceptionType.badResponse:
        return AIUnavailableException(
          'Gemini API returned HTTP ${e.response?.statusCode}: '
          '${e.response?.data}',
          classifyGeminiError(
            statusCode: e.response?.statusCode,
            responseBody: e.response?.data,
          ),
        );
      case DioExceptionType.badCertificate:
      case DioExceptionType.cancel:
      case DioExceptionType.unknown:
        return InvalidAIResponseException(
          'Unexpected error calling Gemini (${e.type.name}): ${e.message}',
        );
    }
  }

  Map<String, dynamic> _unwrapEnvelope(dynamic rawBody) {
    try {
      final envelope = rawBody is String
          ? jsonDecode(rawBody) as Map<String, dynamic>
          : rawBody as Map<String, dynamic>;
      final candidates = envelope['candidates'] as List<dynamic>;
      final candidate = candidates.first as Map<String, dynamic>;
      final content = candidate['content'] as Map<String, dynamic>;
      final parts = content['parts'] as List<dynamic>;
      final text = (parts.first as Map<String, dynamic>)['text'] as String;
      final decoded = jsonDecode(text);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException(
          'Expected a JSON object inside the Gemini response text',
        );
      }
      return decoded;
    } on InvalidAIResponseException {
      rethrow;
    } catch (e) {
      throw InvalidAIResponseException('Could not parse Gemini response: $e');
    }
  }
}
