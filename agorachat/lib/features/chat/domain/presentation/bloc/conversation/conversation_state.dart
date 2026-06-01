import 'package:equatable/equatable.dart';

import '../../../../data/models/conversation_model.dart';

abstract class ConversationState extends Equatable {
  const ConversationState();

  @override
  List<Object?> get props => [];
}

class ConversationInitial extends ConversationState {}

class ConversationLoading extends ConversationState {}

class ConversationLoaded extends ConversationState {
  final List<ConversationModel> conversations;

  const ConversationLoaded(this.conversations);

  @override
  List<Object?> get props => [conversations];
}

class ConversationFailure extends ConversationState {
  final String message;

  const ConversationFailure(this.message);

  @override
  List<Object?> get props => [message];
}