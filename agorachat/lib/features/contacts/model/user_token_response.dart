class UserTokenResponse {
  final String userId;
  final String token;

  UserTokenResponse({
    required this.userId,
    required this.token,
  });

  factory UserTokenResponse.fromJson(Map<String, dynamic> json) {
    return UserTokenResponse(
      userId: json['userId']?.toString() ?? '',
      token: json['token']?.toString() ?? '',
    );
  }
}