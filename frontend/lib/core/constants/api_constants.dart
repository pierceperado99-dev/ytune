class ApiConstants {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080/api',
  );
  static const String search = '/search';
  static const String stream = '/stream';
  static const Duration timeout = Duration(seconds: 120);

  ApiConstants._();
}
