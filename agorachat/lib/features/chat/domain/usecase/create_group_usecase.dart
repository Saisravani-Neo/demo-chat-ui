import '../repositories/chat_repository.dart';

class CreateGroupUseCase {
  final ChatRepository repository;

  CreateGroupUseCase(this.repository);

  Future<void> call({
    required String name,
    required List<String> memberIds,
  }) {
    return repository.createGroup(
      name: name,
      memberIds: memberIds,
    );
  }
}
