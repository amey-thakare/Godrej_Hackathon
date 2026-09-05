class ApiConfig {
  // Backend server URL (FastAPI running locally)
  static const String backendBaseUrl = 'http://localhost:8000';

  static String get backendIdentifyUrl =>
      '$backendBaseUrl/api/v1/identify';

  // Direct Gemini API configuration
  static const String geminiModel = 'gemini-3.6-flash';

  static const List<String> fallbackGeminiModels = [
    'gemini-3.6-flash',
    'gemini-3.5-flash-lite',
    'gemini-3.1-flash-lite',
    'gemini-flash-latest',
  ];

  static String getGeminiGenerateContentUrl([String? model]) =>
      'https://generativelanguage.googleapis.com/v1beta/models/${model ?? geminiModel}:generateContent';

  static String get geminiGenerateContentUrl =>
      getGeminiGenerateContentUrl(geminiModel);
}
