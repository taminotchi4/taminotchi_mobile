import '../../../../core/utils/result.dart';
import '../entities/chat_message_entity.dart';
import '../repositories/chat_repository.dart';

class GetMessagesUseCase {
  final ChatRepository repository;

  const GetMessagesUseCase(this.repository);

  Future<Result<List<ChatMessageEntity>>> call(String chatId) {
    return repository.getMessages(chatId);
  }
}
