import '../../../../core/utils/result.dart';
import '../entities/chat_entity.dart';
import '../entities/chat_message_entity.dart';
import '../../data/models/group_model.dart';
import '../../data/models/private_chat_model.dart';

abstract class ChatRepository {
  // --- Legacy (to be migrated) ---
  Future<Result<ChatEntity>> getOrCreateChat({
    required String sellerId,
    required String userId,
  });
  Future<Result<List<ChatMessageEntity>>> getMessages(String chatId);
  Future<Result<ChatMessageEntity>> sendMessage(ChatMessageEntity message);

  // --- Private Chat (New) ---
  Future<Result<PrivateChatModel>> openPrivateChat(String receiverId, String receiverRole);
  Future<Result<List<PrivateChatModel>>> getMyPrivateChats();
  
  // --- Group Chat (New) ---
  Future<Result<List<GroupModel>>> getGroups();
  Future<Result<GroupModel>> getGroupById(String id);
  Future<Result<List<GroupModel>>> getMyGroups();
  Future<Result<void>> joinGroup(String id);
  Future<Result<void>> leaveGroup(String id);

  // --- Common ---
  Future<Result<void>> markMessageSeen(String messageId);
  Future<Result<void>> editMessage(String messageId, String text);
  Future<Result<void>> deleteMessage(String messageId);
  Future<Result<String>> uploadMedia(String type, String filePath);
}
