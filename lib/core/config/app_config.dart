import 'package:flutter_dotenv/flutter_dotenv.dart';

enum AppEnvironment { development, staging, production }

enum AIProviderType { gemini, openAI, local, none }

/// Optional capabilities that can be toggled without a full release.
///
/// These are read once at startup from environment configuration. They are
/// intentionally simple booleans — see instructions.md section 28.
class FeatureFlags {
  const FeatureFlags({
    this.aiTeacherEnabled = false,
    this.advancedAssessmentsEnabled = false,
    this.experimentalCurriculumEnabled = false,
    this.projectsEnabled = false,
    this.analyticsEnabled = false,
  });

  final bool aiTeacherEnabled;
  final bool advancedAssessmentsEnabled;
  final bool experimentalCurriculumEnabled;
  final bool projectsEnabled;
  final bool analyticsEnabled;
}

/// Central, environment-driven application configuration.
///
/// Never hard-code secrets here — values are sourced from `.env` via
/// flutter_dotenv, which is gitignored. See instructions.md section 27.
class AppConfig {
  const AppConfig({
    required this.environment,
    required this.aiProvider,
    required this.apiBaseUrl,
    required this.featureFlags,
    required this.geminiApiKey,
  });

  final AppEnvironment environment;
  final AIProviderType aiProvider;
  final String apiBaseUrl;
  final FeatureFlags featureFlags;
  final String? geminiApiKey;

  bool get isAIConfigured => geminiApiKey != null && geminiApiKey!.isNotEmpty;

  factory AppConfig.fromEnv() {
    final geminiKey = dotenv.env['GEMINI_API_KEY'];
    final hasGeminiKey = geminiKey != null && geminiKey.isNotEmpty;

    return AppConfig(
      environment: AppEnvironment.development,
      aiProvider: hasGeminiKey ? AIProviderType.gemini : AIProviderType.none,
      apiBaseUrl: dotenv.env['API_BASE_URL'] ?? '',
      featureFlags: FeatureFlags(aiTeacherEnabled: hasGeminiKey),
      geminiApiKey: geminiKey,
    );
  }
}
