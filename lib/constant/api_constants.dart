class ApiConstants {
  ApiConstants._();
  static const String baseUrl = String.fromEnvironment('BACKEND_API_URL', defaultValue: 'http://192.168.100.15:8000/api');

  /// SharedPreferences key the Sanctum bearer token is stored under.
  static const String tokenKey = 'auth_token';

  /// Requests give up after this long instead of hanging indefinitely —
  /// e.g. when the backend host is unreachable from the device.
  static const Duration requestTimeout = Duration(seconds: 15);
}