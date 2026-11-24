import 'package:dio/dio.dart';

import '../../settings/domain/settings_models.dart';

/// Finds the newest model of the family the app uses for each provider
/// (Claude Sonnet, GPT Terra, DeepSeek Flash) by asking the provider's
/// list-models endpoint with the learner's own API key.
///
/// Gemini needs no lookup: Google's `gemini-flash-latest` alias already
/// points at the newest Flash model, so it is the built-in default.
///
/// Every failure (offline, bad key, unexpected response, nothing matching)
/// returns null, and the caller falls back to the built-in default in
/// `AppConfig`. A lookup problem must never stop the AI Teacher working.
class LatestModelResolver {
  LatestModelResolver({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 15),
            ),
          );

  final Dio _dio;

  Future<String?> resolve({
    required AiProviderKind provider,
    required String apiKey,
    required String baseUrl,
  }) async {
    try {
      switch (provider) {
        case AiProviderKind.gemini:
          return null;
        case AiProviderKind.anthropic:
          final response = await _dio.get<dynamic>(
            '$baseUrl/v1/models',
            queryParameters: {'limit': 1000},
            options: Options(
              headers: {'x-api-key': apiKey, 'anthropic-version': '2023-06-01'},
            ),
          );
          return pickNewestClaudeSonnet(response.data);
        case AiProviderKind.openai:
          final response = await _dio.get<dynamic>(
            '$baseUrl/models',
            options: Options(headers: {'Authorization': 'Bearer $apiKey'}),
          );
          return pickNewestGptTerra(response.data);
        case AiProviderKind.deepseek:
          final response = await _dio.get<dynamic>(
            '$baseUrl/models',
            options: Options(headers: {'Authorization': 'Bearer $apiKey'}),
          );
          return pickNewestDeepSeekFlash(response.data);
      }
    } catch (_) {
      return null;
    }
  }
}

/// The `{id, created?/created_at?}` entries of a list-models response.
List<_ModelEntry> _entries(Object? body) {
  if (body is! Map) return const [];
  final data = body['data'];
  if (data is! List) return const [];
  final result = <_ModelEntry>[];
  for (var i = 0; i < data.length; i++) {
    final item = data[i];
    if (item is! Map) continue;
    final id = item['id'];
    if (id is! String || id.isEmpty) continue;
    result.add(_ModelEntry(id, _releaseTime(item), i));
  }
  return result;
}

/// Release time from OpenAI-style `created` (Unix seconds) or
/// Anthropic-style `created_at` (RFC 3339). Null when absent or unknown.
DateTime? _releaseTime(Map<dynamic, dynamic> item) {
  final created = item['created'];
  if (created is int && created > 0) {
    return DateTime.fromMillisecondsSinceEpoch(created * 1000, isUtc: true);
  }
  final createdAt = item['created_at'];
  if (createdAt is String) {
    final parsed = DateTime.tryParse(createdAt);
    // Anthropic uses the epoch when the release date is unknown.
    if (parsed != null && parsed.year > 1970) return parsed;
  }
  return null;
}

final _datedSnapshot = RegExp(r'-\d{4}-?\d{2}-?\d{2}$|-\d{8}$');

/// The version numbers in a model id, with any trailing date snapshot
/// removed: `gpt-6.1-terra` -> [6, 1], `claude-sonnet-5-5` -> [5, 5].
List<int> _version(String id) =>
    RegExp(r'\d+')
        .allMatches(id.replaceFirst(_datedSnapshot, ''))
        .map((m) => int.parse(m.group(0)!))
        .toList();

int _compareVersions(List<int> a, List<int> b) {
  for (var i = 0; i < a.length && i < b.length; i++) {
    if (a[i] != b[i]) return a[i].compareTo(b[i]);
  }
  return a.length.compareTo(b.length);
}

/// Newest first: release time when both entries have one, otherwise the
/// higher version number, then the provider's own order.
int _newestFirst(_ModelEntry a, _ModelEntry b) {
  if (a.released != null && b.released != null) {
    final byTime = b.released!.compareTo(a.released!);
    if (byTime != 0) return byTime;
  }
  final byVersion = _compareVersions(_version(b.id), _version(a.id));
  if (byVersion != 0) return byVersion;
  return a.order.compareTo(b.order);
}

/// Prefers a plain id over its dated snapshots (`gpt-6.1-terra` over
/// `gpt-6.1-terra-2026-10-01`), since the plain id tracks fixes.
String? _pick(List<_ModelEntry> candidates) {
  if (candidates.isEmpty) return null;
  final plain = candidates
      .where((e) => !_datedSnapshot.hasMatch(e.id))
      .toList();
  final pool = plain.isNotEmpty ? plain : candidates;
  pool.sort(_newestFirst);
  return pool.first.id;
}

/// Newest `claude-sonnet-*` model in an Anthropic `/v1/models` response.
String? pickNewestClaudeSonnet(Object? body) => _pick(
  _entries(body).where((e) => e.id.startsWith('claude-sonnet-')).toList(),
);

const _excludedOpenAiVariants = [
  'pro',
  'mini',
  'nano',
  'batch',
  'preview',
  'audio',
  'realtime',
  'search',
  'transcribe',
  'tts',
];

/// Newest GPT Terra model in an OpenAI `/models` response. Uses a
/// `*-terra-latest` alias if OpenAI lists one; skips variants such as
/// Terra Pro or batch-only models.
String? pickNewestGptTerra(Object? body) {
  final terra = _entries(body).where((e) {
    final parts = e.id.toLowerCase().split(RegExp(r'[-.]'));
    return e.id.startsWith('gpt-') &&
        parts.contains('terra') &&
        !parts.any(_excludedOpenAiVariants.contains);
  }).toList();
  for (final e in terra) {
    if (e.id.endsWith('-latest')) return e.id;
  }
  return _pick(terra);
}

/// Newest DeepSeek Flash model in a DeepSeek `/models` response. Uses
/// the unversioned `deepseek-flash` id if listed, since it follows the
/// newest Flash release.
String? pickNewestDeepSeekFlash(Object? body) {
  final flash = _entries(body).where((e) {
    final id = e.id.toLowerCase();
    return id.startsWith('deepseek-') &&
        id.contains('flash') &&
        !id.contains('preview');
  }).toList();
  for (final e in flash) {
    if (e.id == 'deepseek-flash') return e.id;
  }
  return _pick(flash);
}

class _ModelEntry {
  const _ModelEntry(this.id, this.released, this.order);

  final String id;
  final DateTime? released;
  final int order;
}
