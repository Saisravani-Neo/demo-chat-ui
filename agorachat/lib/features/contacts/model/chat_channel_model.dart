import 'package:equatable/equatable.dart';

class ChatChannelModel extends Equatable {
  const ChatChannelModel({
    required this.registered,
    this.currentUserId,
    this.receiverUserId,
    this.channelName,
    this.chatToken,
    this.voiceCallToken,
    this.contactName,
  });

  final bool registered;
  final String? currentUserId;
  final String? receiverUserId;
  final String? channelName;
  final String? chatToken;
  final String? voiceCallToken;
  final String? contactName;

  factory ChatChannelModel.fromJson(Map<String, dynamic> json) {
    return ChatChannelModel(
      registered: json['registered'] as bool,
      currentUserId: json['currentUserId'] as String?,
      receiverUserId: json['receiverUserId'] as String?,
      channelName: json['channelName'] as String?,
      chatToken: json['chatToken'] as String?,
      voiceCallToken: json['voiceCallToken'] as String?,
    );
  }

  ChatChannelModel copyWith({String? contactName}) {
    return ChatChannelModel(
      registered: registered,
      currentUserId: currentUserId,
      receiverUserId: receiverUserId,
      channelName: channelName,
      chatToken: chatToken,
      voiceCallToken: voiceCallToken,
      contactName: contactName ?? this.contactName,
    );
  }

  @override
  List<Object?> get props => [
        registered,
        currentUserId,
        receiverUserId,
        channelName,
        chatToken,
        voiceCallToken,
        contactName,
      ];
}
