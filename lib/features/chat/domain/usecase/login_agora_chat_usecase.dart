import '../repositories/chat_repository.dart';

class LoginAgoraChatUseCase {
  final ChatRepository repository;

  LoginAgoraChatUseCase(this.repository);

  Future<void> call({
    required String agoraUserId,
    required String token,
  }) {
    return repository.loginAgoraChat(
      agoraUserId: agoraUserId,
      token: token,
    );
  }
}