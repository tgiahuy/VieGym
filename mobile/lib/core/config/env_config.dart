class EnvConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080',
  );

  static const String aiServiceBaseUrl = String.fromEnvironment(
    'AI_SERVICE_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );
}
