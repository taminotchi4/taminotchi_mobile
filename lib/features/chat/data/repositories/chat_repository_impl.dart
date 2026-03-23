import '../../../../core/utils/result.dart';
import '../../domain/entities/chat_entity.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_local_data_source.dart';
import '../datasources/chat_remote_data_source.dart';
import '../datasources/group_remote_data_source.dart';
import '../models/group_model.dart';
import '../models/message_model.dart';
import '../models/private_chat_model.dart';
import '../models/market_model.dart';
import '../services/chat_media_service.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource chatRemoteDataSource;
  final GroupRemoteDataSource groupRemoteDataSource;
  final ChatLocalDataSource localDataSource;
  final ChatMediaService mediaService;

  ChatRepositoryImpl({
    required this.chatRemoteDataSource,
    required this.groupRemoteDataSource,
    required this.localDataSource,
    required this.mediaService,
  });

  // --- Legacy ---
  @override
  Future<Result<ChatEntity>> getOrCreateChat({
    required String sellerId,
    required String userId,
  }) async {
    try {
      return Result.ok(localDataSource.getOrCreateChat(
        sellerId: sellerId,
        userId: userId,
      ));
    } catch (e) {
      return Result.error(Exception('Failed to load chat'));
    }
  }

  @override
  Future<Result<List<ChatMessageEntity>>> getMessages(String chatId) async {
    try {
      return Result.ok(localDataSource.getLegacyMessages(chatId));
    } catch (e) {
      return Result.error(Exception('Failed to load messages'));
    }
  }

  @override
  Future<Result<ChatMessageEntity>> sendMessage(ChatMessageEntity message) async {
    try {
      return Result.ok(localDataSource.addMessage(message));
    } catch (e) {
      return Result.error(Exception('Failed to send message'));
    }
  }

  // --- Private Chat ---
  @override
  Future<Result<PrivateChatModel>> openPrivateChat(
      String receiverId, String receiverRole) async {
    final result = await chatRemoteDataSource.openPrivateChat(receiverId, receiverRole);
    return result.fold(
      (error) => Result.error(error),
      (data) => Result.ok(PrivateChatModel.fromJson(data)),
    );
  }

  @override
  Future<Result<List<PrivateChatModel>>> getMyPrivateChats() async {
    final result = await chatRemoteDataSource.getMyPrivateChats();
    return result.fold(
      (error) => Result.error(error),
      (list) => Result.ok(list.map((e) => PrivateChatModel.fromJson(e)).toList()),
    );
  }

  @override
  Future<Result<List<MarketModel>>> searchMarkets(String query) async {
    final result = await chatRemoteDataSource.searchMarkets(query);
    return result.fold(
      (error) => Result.error(error),
      (list) => Result.ok(list.map((e) => MarketModel.fromJson(e)).toList()),
    );
  }

  // --- Group Chat ---
  @override
  Future<Result<List<GroupModel>>> getGroups() async {
    final result = await groupRemoteDataSource.getGroups();
    return result.fold(
      (error) => Result.error(error),
      (list) => Result.ok(list.map((e) => GroupModel.fromJson(e)).toList()),
    );
  }

  @override
  Future<Result<GroupModel>> getGroupById(String id) async {
    final result = await groupRemoteDataSource.getGroupById(id);
    return result.fold(
      (error) => Result.error(error),
      (data) => Result.ok(GroupModel.fromJson(data)),
    );
  }

  @override
  Future<Result<List<GroupModel>>> getMyGroups() async {
    final result = await groupRemoteDataSource.getMyGroups();
    return result.fold(
      (error) => Result.error(error),
      (list) => Result.ok(list.map((e) => GroupModel.fromJson(e)).toList()),
    );
  }

  @override
  Future<Result<void>> joinGroup(String id) async =>
      groupRemoteDataSource.joinGroup(id);

  @override
  Future<Result<void>> leaveGroup(String id) async =>
      groupRemoteDataSource.leaveGroup(id);

  // --- Common ---
  @override
  Future<Result<void>> markMessageSeen(String messageId) async =>
      chatRemoteDataSource.markMessageSeen(messageId);

  @override
  Future<Result<void>> editMessage(String messageId, String text) async =>
      chatRemoteDataSource.editMessage(messageId, text);

  @override
  Future<Result<void>> deleteMessage(String messageId) async =>
      chatRemoteDataSource.deleteMessage(messageId);

  @override
  Future<Result<String>> uploadMedia(String type, String filePath) async =>
      chatRemoteDataSource.uploadMedia(type, filePath);

  // --- Offline Support (Hive) ---
  @override
  Future<List<MessageModel>> getLocalMessages(
    String chatId, {
    int page = 1,
    int limit = 50,
  }) =>
      localDataSource.getMessages(chatId, page: page, limit: limit);

  @override
  Future<void> saveLocalMessages(
      String chatId, List<MessageModel> messages) async {
    await localDataSource.saveMessages(chatId, messages);
  }

  @override
  Future<void> saveLocalMessage(String chatId, MessageModel message) async {
    await localDataSource.saveMessage(chatId, message);
  }

  @override
  Future<void> upsertLocalMessage(String chatId, MessageModel message) async {
    await localDataSource.upsertMessage(chatId, message);
  }

  @override
  Future<void> replaceTempMessage(
    String chatId,
    String tempId,
    MessageModel real,
  ) async {
    await localDataSource.replaceTempMessage(chatId, tempId, real);
  }

  @override
  Future<void> updateLocalMessageStatus(
    String chatId,
    String messageId,
    String status,
  ) async {
    await localDataSource.updateMessageStatus(chatId, messageId, status);
  }

  // --- Media Cache ---
  @override
  Future<String?> getLocalMediaPath(String serverUrl, String type) =>
      mediaService.getLocalPath(serverUrl, type);

  @override
  Future<bool> isMediaCached(String serverUrl, String type) =>
      mediaService.isCached(serverUrl, type);
}
