class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://stooge-shrink-whole.ngrok-free.dev';

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  static const String registerEndpoint = '/api/users/register';
  static const String verifyContactEndpoint = '/api/users/verify';
  static const String createChatRoomEndpoint = '/api/chat/create-room';

  static String agoraUserTokenEndpoint(String userId) =>
      '/api/agora/user-token/$userId';
}