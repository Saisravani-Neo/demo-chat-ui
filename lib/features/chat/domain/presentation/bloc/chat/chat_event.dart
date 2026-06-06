import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class SendTextMessageEvent extends ChatEvent {
  final String conversationId;
  final String receiverId;
  final String receiverAgoraUserId;
  final String text;

  const SendTextMessageEvent({
    required this.conversationId,
    required this.receiverId,
    required this.receiverAgoraUserId,
    required this.text,
  });

  @override
  List<Object?> get props => [
        conversationId,
        receiverId,
        receiverAgoraUserId,
        text,
      ];
}

class SendVoiceMessageEvent extends ChatEvent {
  final String conversationId;
  final String receiverId;
  final String receiverAgoraUserId;
  final String filePath;
  final int duration;

  const SendVoiceMessageEvent({
    required this.conversationId,
    required this.receiverId,
    required this.receiverAgoraUserId,
    required this.filePath,
    required this.duration,
  });

  @override
  List<Object?> get props => [
        conversationId,
        receiverId,
        receiverAgoraUserId,
        filePath,
        duration,
      ];
}