import 'package:equatable/equatable.dart';

abstract class ChatAuthState extends Equatable {
  const ChatAuthState();

  @override
  List<Object?> get props => [];
}

class ChatAuthInitial extends ChatAuthState {}

class ChatAuthLoading extends ChatAuthState {}

class ChatAuthSuccess extends ChatAuthState {}

class ChatAuthFailure extends ChatAuthState {
  final String message;

  const ChatAuthFailure(this.message);

  @override
  List<Object?> get props => [message];
}