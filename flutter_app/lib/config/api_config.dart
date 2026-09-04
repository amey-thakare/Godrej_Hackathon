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

  static const String geminiModel = 'gemini-1.5-flash';
  static String get geminiGenerateContentUrl =>
      'https://generativelanguage.googleapis.com/v1beta/models/$geminiModel:generateContent';

  // Local Asset Data Path for Curated Native Plants
  static const String localPlantsJsonPath = 'assets/data/plants.json';
}
