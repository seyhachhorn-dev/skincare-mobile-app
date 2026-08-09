class ApiConstants {
  ApiConstants._();
  static const String baseUrl = String.fromEnvironment('BACKEND_API_URL', defaultValue: 'http://192.168.100.15:8000/api');
}