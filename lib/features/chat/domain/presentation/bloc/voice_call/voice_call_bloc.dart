import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../usecase/end_voice_call_usecase.dart';
import '../../../usecase/start_voice_call_usecase.dart';
import 'voice_call_event.dart';
import 'voice_call_state.dart';

class VoiceCallBloc extends Bloc<VoiceCallEvent, VoiceCallState> {
  final StartVoiceCallUseCase startVoiceCallUseCase;
  final EndVoiceCallUseCase endVoiceCallUseCase;

  VoiceCallBloc({
    required this.startVoiceCallUseCase,
    required this.endVoiceCallUseCase,
  }) : super(VoiceCallInitial()) {
    on<StartVoiceCallEvent>(_onStartCall);
    on<EndVoiceCallEvent>(_onEndCall);
  }

  Future<void> _onStartCall(
    StartVoiceCallEvent event,
    Emitter<VoiceCallState> emit,
  ) async {
    try {
      emit(VoiceCallLoading());

      final token = await startVoiceCallUseCase(
        receiverId: event.receiverId,
      );

      emit(VoiceCallStarted(token));
    } catch (e) {
      emit(VoiceCallFailure(e.toString()));
    }
  }

  Future<void> _onEndCall(
    EndVoiceCallEvent event,
    Emitter<VoiceCallState> emit,
  ) async {
    try {
      emit(VoiceCallLoading());

      await endVoiceCallUseCase(
        callId: event.callId,
        status: 'COMPLETED',
        durationSeconds: event.durationSeconds,
      );

      emit(VoiceCallEnded());
    } catch (e) {
      emit(VoiceCallFailure(e.toString()));
    }
  }
}