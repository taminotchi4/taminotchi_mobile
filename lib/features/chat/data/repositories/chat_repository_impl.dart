import '../../../../core/utils/result.dart';
import '../../domain/entities/chat_entity.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_local_data_source.dart';
import '../datasources/chat_remote_data_source.dart';
import '../datasources/group_remote_data_source.dart';
import '../models/group_model.dart';
import '../models/private_chat_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource chatRemoteDataSource;
  final GroupRemoteDataSource groupRemoteDataSource;
  final ChatLocalDataSource localDataSource;

  ChatRepositoryImpl({
    required this.chatRemoteDataSource,
    required this.groupRemoteDataSource,
    required this.localDataSource,
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
      return Result.ok(localDataSource.getMessages(chatId));
    } catch (e) {
      return Result.error(Exception('Failed to load messages'));
    }
  }

  @override
  Future<Result<ChatMessageEntity>> sendMessage(
    ChatMessageEntity message,
  ) async {
    try {
      return Result.ok(localDataSource.addMessage(message));
    } catch (e) {
      return Result.error(Exception('Failed to send message'));
    }
  }

  // --- New ---
  @override
  Future<Result<PrivateChatModel>> openPrivateChat(String receiverId, String receiverRole) async {
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
  Future<Result<void>> joinGroup(String id) async {
    return await groupRemoteDataSource.joinGroup(id);
  }

  @override
  Future<Result<void>> leaveGroup(String id) async {
    return await groupRemoteDataSource.leaveGroup(id);
  }

  @override
  Future<Result<void>> markMessageSeen(String messageId) async {
    return await chatRemoteDataSource.markMessageSeen(messageId);
  }

  @override
  Future<Result<void>> editMessage(String messageId, String text) async {
    return await chatRemoteDataSource.editMessage(messageId, text);
  }

  @override
  Future<Result<void>> deleteMessage(String messageId) async {
    return await chatRemoteDataSource.deleteMessage(messageId);
  }

  @override
  Future<Result<String>> uploadMedia(String type, String filePath) async {
    return await chatRemoteDataSource.uploadMedia(type, filePath);
  }
}
