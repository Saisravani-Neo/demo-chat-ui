import 'package:equatable/equatable.dart';

abstract class ConversationsEvent extends Equatable {
  const ConversationsEvent();

  @override
  List<Object?> get props => [];
}

class LoadConversations extends ConversationsEvent {
  const LoadConversations();
}

class RefreshConversations extends ConversationsEvent {
  const RefreshConversations();
}
