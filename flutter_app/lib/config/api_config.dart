class ApiConfig {
  // Configured for USB cable connection via `adb reverse tcp:8000 tcp:8000`:
  static String baseUrl = 'http://localhost:8000/api/v1';

  static String get healthUrl => '$baseUrl/health';
  static String get plantsUrl => '$baseUrl/plants';
  static String get identifyUrl => '$baseUrl/identify';
  static String get chatUrl => '$baseUrl/chat';

  static String plantDetailUrl(int id) => '$baseUrl/plants/$id';
}
