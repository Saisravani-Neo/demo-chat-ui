import 'package:equatable/equatable.dart';

import '../model/conversation_model.dart';

abstract class ConversationsState extends Equatable {
  const ConversationsState();

  @override
  List<Object?> get props => [];
}

class ConversationsInitial extends ConversationsState {
  const ConversationsInitial();
}

class ConversationsLoading extends ConversationsState {
  const ConversationsLoading();
}

class ConversationsLoaded extends ConversationsState {
  const ConversationsLoaded({required this.conversations});

  final List<ConversationItem> conversations;

  @override
  List<Object?> get props => [conversations];
}

class ConversationsEmpty extends ConversationsState {
  const ConversationsEmpty();
}

class ConversationsFailure extends ConversationsState {
  const ConversationsFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
