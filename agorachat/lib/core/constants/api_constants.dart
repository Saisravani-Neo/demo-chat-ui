class ApiConstants {
  ApiConstants._();

  // Replace with your actual backend base URL
  static const String baseUrl = 'https://your-backend-api.com';

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Endpoints
  static const String registerEndpoint = '/api/users/register';
  static const String checkAndCreateEndpoint = '/api/chat/check-and-create';
}
