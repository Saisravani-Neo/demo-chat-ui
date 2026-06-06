import 'package:equatable/equatable.dart';

abstract class ChatAuthEvent extends Equatable {
  const ChatAuthEvent();

  @override
  List<Object?> get props => [];
}

class ChatAuthStarted extends ChatAuthEvent {}