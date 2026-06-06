class CreateChatRoomResponse {
  final String channelName;

  CreateChatRoomResponse({required this.channelName});

  factory CreateChatRoomResponse.fromJson(Map<String, dynamic> json) {
    return CreateChatRoomResponse(
      channelName: json['channelName']?.toString() ?? '',
    );
  }
}