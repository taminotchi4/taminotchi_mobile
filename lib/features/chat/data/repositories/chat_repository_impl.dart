import '../../../../core/utils/result.dart';
import '../../domain/entities/chat_entity.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_local_data_source.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatLocalDataSource localDataSource;

  const ChatRepositoryImpl(this.localDataSource);

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
}
