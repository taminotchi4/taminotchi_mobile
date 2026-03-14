import '../../../../core/utils/result.dart';
import '../entities/chat_entity.dart';
import '../entities/chat_message_entity.dart';

abstract class ChatRepository {
  Future<Result<ChatEntity>> getOrCreateChat({
    required String sellerId,
    required String userId,
  });

  Future<Result<List<ChatMessageEntity>>> getMessages(String chatId);

  Future<Result<ChatMessageEntity>> sendMessage(ChatMessageEntity message);
}
