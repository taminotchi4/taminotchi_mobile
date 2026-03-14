import '../../../../core/utils/result.dart';
import '../entities/chat_entity.dart';
import '../repositories/chat_repository.dart';

class GetOrCreateChatUseCase {
  final ChatRepository repository;

  const GetOrCreateChatUseCase(this.repository);

  Future<Result<ChatEntity>> call({
    required String sellerId,
    required String userId,
  }) {
    return repository.getOrCreateChat(sellerId: sellerId, userId: userId);
  }
}
