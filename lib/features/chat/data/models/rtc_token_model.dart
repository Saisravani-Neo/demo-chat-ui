class RtcTokenModel {
  final String callId;
  final String channelName;
  final String token;
  final int uid;
  final String appId;
  final DateTime expiresAt;

  RtcTokenModel({
    required this.callId,
    required this.channelName,
    required this.token,
    required this.uid,
    required this.appId,
    required this.expiresAt,
  });

  factory RtcTokenModel.fromJson(Map<String, dynamic> json) {
    return RtcTokenModel(
      callId: json['callId'],
      channelName: json['channelName'],
      token: json['token'],
      uid: json['uid'],
      appId: json['appId'],
      expiresAt: DateTime.parse(json['expiresAt']),
    );
  }
}