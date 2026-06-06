import 'package:equatable/equatable.dart';

import '../../../../data/models/message_record_model.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatSending extends ChatState {}

class ChatMessageSent extends ChatState {
  final MessageRecordModel message;

  const ChatMessageSent(this.message);

  @override
  List<Object?> get props => [message];
}

class ChatFailure extends ChatState {
  final String message;

  const ChatFailure(this.message);

  @override
  List<Object?> get props => [message];
}