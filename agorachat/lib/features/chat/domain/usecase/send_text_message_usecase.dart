import '../../data/models/message_record_model.dart';
import '../repositories/chat_repository.dart';

class SendTextMessageUseCase {
  final ChatRepository repository;

  SendTextMessageUseCase(this.repository);

  Future<MessageRecordModel> call({
    required String conversationId,
    required String receiverId,
    required String receiverAgoraUserId,
    required String text,
  }) {
    return repository.sendTextMessage(
      conversationId: conversationId,
      receiverId: receiverId,
      receiverAgoraUserId: receiverAgoraUserId,
      text: text,
    );
  }
}