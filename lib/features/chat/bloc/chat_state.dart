import 'package:equatable/equatable.dart';
import '../model/chat_message_model.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {
  const ChatInitial();
}

class ChatConnecting extends ChatState {
  const ChatConnecting();
}

class ChatReady extends ChatState {
  const ChatReady({
    required this.messages,
    this.isSending = false,
    this.isRecording = false,
    this.error,
  });

  final List<ChatMessageModel> messages;
  final bool isSending;
  final bool isRecording;
  final String? error;

  ChatReady copyWith({
    List<ChatMessageModel>? messages,
    bool? isSending,
    bool? isRecording,
    String? error,
    bool clearError = false,
  }) {
    return ChatReady(
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      isRecording: isRecording ?? this.isRecording,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [messages, isSending, isRecording, error];
}

class ChatFailure extends ChatState {
  const ChatFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
