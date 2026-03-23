import '../../../../core/utils/result.dart';
import '../entities/chat_entity.dart';
import '../entities/chat_message_entity.dart';
import '../../data/models/group_model.dart';
import '../../data/models/private_chat_model.dart';
import '../../data/models/market_model.dart';
import '../../data/models/message_model.dart';

abstract class ChatRepository {
  // --- Legacy (to be migrated) ---
  Future<Result<ChatEntity>> getOrCreateChat({
    required String sellerId,
    required String userId,
  });
  Future<Result<List<ChatMessageEntity>>> getMessages(String chatId);
  Future<Result<ChatMessageEntity>> sendMessage(ChatMessageEntity message);

  // --- Private Chat ---
  Future<Result<PrivateChatModel>> openPrivateChat(
      String receiverId, String receiverRole);
  Future<Result<List<PrivateChatModel>>> getMyPrivateChats();
  Future<Result<List<MarketModel>>> searchMarkets(String query);

  // --- Group Chat ---
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

  // --- Offline Support (Hive) ---
  Future<List<MessageModel>> getLocalMessages(String chatId, {int page, int limit});
  Future<void> saveLocalMessages(String chatId, List<MessageModel> messages);
  Future<void> saveLocalMessage(String chatId, MessageModel message);
  Future<void> upsertLocalMessage(String chatId, MessageModel message);
  Future<void> replaceTempMessage(String chatId, String tempId, MessageModel real);
  Future<void> updateLocalMessageStatus(String chatId, String messageId, String status);

  // --- Media Cache ---
  Future<String?> getLocalMediaPath(String serverUrl, String type);
  Future<bool> isMediaCached(String serverUrl, String type);
}
