class ApiConstants {
  ApiConstants._();
  static const String baseUrl = String.fromEnvironment('BACKEND_API_URL', defaultValue: 'http://127.0.0.1:8000/api');
}