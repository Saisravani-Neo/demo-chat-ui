class VerifyContactResponse {
  final bool registered;
  final String? userId;
  final String? mobileNumber;

  VerifyContactResponse({
    required this.registered,
    this.userId,
    this.mobileNumber,
  });

  factory VerifyContactResponse.fromJson(Map<String, dynamic> json) {
    return VerifyContactResponse(
      registered: json['registered'] == true,
      userId: json['userId']?.toString(),
      mobileNumber: json['mobileNumber']?.toString(),
    );
  }
}