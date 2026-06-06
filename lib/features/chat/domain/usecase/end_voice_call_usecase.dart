import '../repositories/chat_repository.dart';

class EndVoiceCallUseCase {
  final ChatRepository repository;

  EndVoiceCallUseCase(this.repository);

  Future<void> call({
    required String callId,
    required String status,
    required int durationSeconds,
  }) {
    return repository.endCall(
      callId: callId,
      status: status,
      durationSeconds: durationSeconds,
    );
  }
}