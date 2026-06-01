import 'package:equatable/equatable.dart';

import '../../../../data/models/rtc_token_model.dart';

abstract class VoiceCallState extends Equatable {
  const VoiceCallState();

  @override
  List<Object?> get props => [];
}

class VoiceCallInitial extends VoiceCallState {}

class VoiceCallLoading extends VoiceCallState {}

class VoiceCallStarted extends VoiceCallState {
  final RtcTokenModel token;

  const VoiceCallStarted(this.token);

  @override
  List<Object?> get props => [token];
}

class VoiceCallEnded extends VoiceCallState {}

class VoiceCallFailure extends VoiceCallState {
  final String message;

  const VoiceCallFailure(this.message);

  @override
  List<Object?> get props => [message];
}
