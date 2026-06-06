import '../../data/models/rtc_token_model.dart';
import '../repositories/chat_repository.dart';

class StartVoiceCallUseCase {
  final ChatRepository repository;

  StartVoiceCallUseCase(this.repository);

  Future<RtcTokenModel> call({
    required String receiverId,
  }) {
    return repository.getRtcToken(receiverId: receiverId);
  }
}