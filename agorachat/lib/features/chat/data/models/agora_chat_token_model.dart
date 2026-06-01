class AgoraChatTokenModel {
  final String agoraUserId;
  final String token;
  final DateTime expiresAt;

  AgoraChatTokenModel({
    required this.agoraUserId,
    required this.token,
    required this.expiresAt,
  });

  factory AgoraChatTokenModel.fromJson(Map<String, dynamic> json) {
    return AgoraChatTokenModel(
      agoraUserId: json['agoraUserId'],
      token: json['token'],
      expiresAt: DateTime.parse(json['expiresAt']),
    );
  }
}