import '../../../../core/utils/result.dart';
import '../entities/chat_message_entity.dart';
import '../repositories/chat_repository.dart';

class SendMessageUseCase {
  final ChatRepository repository;

  const SendMessageUseCase(this.repository);

  Future<Result<ChatMessageEntity>> call(ChatMessageEntity message) {
    return repository.sendMessage(message);
  }
}
