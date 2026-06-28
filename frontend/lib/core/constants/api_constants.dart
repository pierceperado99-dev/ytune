class ApiConstants {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://ytune-ajm9.onrender.com/api',
  );
  static const String search = '/search';
  static const String stream = '/stream';
  static const Duration timeout = Duration(seconds: 120);

  ApiConstants._();
}
