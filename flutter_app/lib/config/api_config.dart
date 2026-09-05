import 'package:flutter/services.dart';

class ApiConfig {
  static String _geminiApiKey = const String.fromEnvironment('GEMINI_API_KEY');

  static String get geminiApiKey => _geminiApiKey;

  static void setGeminiApiKey(String key) {
    if (key.isNotEmpty) _geminiApiKey = key;
  }

  /// Loads configuration from .env asset if not already provided via --dart-define
  static Future<void> init() async {
    if (_geminiApiKey.isNotEmpty) return;
    try {
      final envContent = await rootBundle.loadString('.env');
      for (final line in envContent.split('\n')) {
        final trimmed = line.trim();
        if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
        final eqIdx = trimmed.indexOf('=');
        if (eqIdx != -1) {
          final key = trimmed.substring(0, eqIdx).trim();
          final val = trimmed.substring(eqIdx + 1).trim();
          if (key == 'GEMINI_API_KEY' && val.isNotEmpty) {
            _geminiApiKey = val;
          }
        }
      }
    } catch (_) {}
  }

  static const String geminiModel = 'gemini-3.5-flash-lite';
  static const List<String> fallbackGeminiModels = [
    'gemini-3.5-flash-lite',
    'gemini-3.1-flash-lite',
    'gemini-3.6-flash',
    'gemini-flash-latest',
  ];

  static String getGeminiGenerateContentUrl([String? model]) =>
      'https://generativelanguage.googleapis.com/v1beta/models/${model ?? geminiModel}:generateContent';

  static String get geminiGenerateContentUrl => getGeminiGenerateContentUrl(geminiModel);

  // Local Asset Data Path for Curated Native Plants
  static const String localPlantsJsonPath = 'assets/data/plants.json';
}
