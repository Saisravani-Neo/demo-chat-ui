import 'package:equatable/equatable.dart';

abstract class VoiceCallEvent extends Equatable {
  const VoiceCallEvent();

  @override
  List<Object?> get props => [];
}

class StartVoiceCallEvent extends VoiceCallEvent {
  final String receiverId;

  const StartVoiceCallEvent(this.receiverId);

  @override
  List<Object?> get props => [receiverId];
}

class EndVoiceCallEvent extends VoiceCallEvent {
  final String callId;
  final int durationSeconds;

  const EndVoiceCallEvent({
    required this.callId,
    required this.durationSeconds,
  });

  @override
  List<Object?> get props => [callId, durationSeconds];
}
