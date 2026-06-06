import 'package:equatable/equatable.dart';
import '../model/chat_message_model.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

/// Connect to Agora Chat and load history.
class ChatInitialized extends ChatEvent {
  const ChatInitialized({required this.receiverId});

  final String receiverId;

  @override
  List<Object?> get props => [receiverId];
}

/// Send a text message.
class ChatTextSent extends ChatEvent {
  const ChatTextSent({required this.text});

  final String text;

  @override
  List<Object?> get props => [text];
}

/// Start recording a voice message.
class ChatRecordingStarted extends ChatEvent {
  const ChatRecordingStarted();
}

/// Stop recording and send the voice message.
class ChatRecordingStopped extends ChatEvent {
  const ChatRecordingStopped();
}

/// A new message was received from the SDK listener.
class ChatMessageReceived extends ChatEvent {
  const ChatMessageReceived({required this.message});

  final ChatMessageModel message;

  @override
  List<Object?> get props => [message];
}

/// Toggle play/stop on a voice message bubble.
class ChatVoicePlayToggled extends ChatEvent {
  const ChatVoicePlayToggled({required this.messageId});

  final String messageId;

  @override
  List<Object?> get props => [messageId];
}

/// The peer has read the conversation (read receipts received).
class ChatReadReceiptReceived extends ChatEvent {
  const ChatReadReceiptReceived();
}
