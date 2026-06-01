import '../../data/models/message_record_model.dart';
import '../repositories/chat_repository.dart';

class SendVoiceMessageUseCase {
  final ChatRepository repository;

  SendVoiceMessageUseCase(this.repository);

  Future<MessageRecordModel> call({
    required String conversationId,
    required String receiverId,
    required String receiverAgoraUserId,
    required String filePath,
    required int duration,
  }) {
    return repository.sendVoiceMessage(
      conversationId: conversationId,
      receiverId: receiverId,
      receiverAgoraUserId: receiverAgoraUserId,
      filePath: filePath,
      duration: duration,
    );
  }
}