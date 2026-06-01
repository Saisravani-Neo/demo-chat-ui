import '../../data/models/agora_chat_token_model.dart';
import '../repositories/chat_repository.dart';

class GetAgoraChatTokenUseCase {
  final ChatRepository repository;

  GetAgoraChatTokenUseCase(this.repository);

  Future<AgoraChatTokenModel> call() {
    return repository.getAgoraChatToken();
  }
}