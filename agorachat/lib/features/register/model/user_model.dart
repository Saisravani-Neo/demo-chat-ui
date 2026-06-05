class RegisterUserResponse {
  final String userId;
  final String mobileNumber;
  final String message;

  RegisterUserResponse({
    required this.userId,
    required this.mobileNumber,
    required this.message,
  });

  factory RegisterUserResponse.fromJson(Map<String, dynamic> json) {
    return RegisterUserResponse(
      userId: json['userId']?.toString() ?? '',
      mobileNumber: json['mobileNumber']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
    );
  }
}