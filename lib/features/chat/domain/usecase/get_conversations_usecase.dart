import '../../data/models/conversation_model.dart';
import '../repositories/chat_repository.dart';

class GetConversationsUseCase {
  final ChatRepository repository;

  GetConversationsUseCase(this.repository);

  Future<List<ConversationModel>> call() {
    return repository.getConversations();
  }
}