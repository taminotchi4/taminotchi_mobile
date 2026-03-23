import 'package:hive_flutter/hive_flutter.dart';
import '../models/message_model.dart';

abstract class ChatLocalDataSource {
  Future<void> saveMessages(String chatId, List<MessageModel> messages);
  Future<List<MessageModel>> getMessages(String chatId, {int page = 1, int limit = 50});
  Future<void> saveMessage(String chatId, MessageModel message);
  Future<void> upsertMessage(String chatId, MessageModel message);
  Future<void> updateMessageStatus(String chatId, String messageId, String status);
  Future<void> replaceTempMessage(String chatId, String tempId, MessageModel realMessage);
  Future<void> clearChat(String chatId);

  // --- Legacy Stubs ---
  dynamic getOrCreateChat({required String sellerId, required String userId});
  dynamic getLegacyMessages(String chatId);
  dynamic addMessage(dynamic message);
}

class ChatLocalDataSourceImpl implements ChatLocalDataSource {
  static const String _boxNamePrefix = 'chat_messages_';
  static const int _maxPerChat = 100;

  Future<Box<MessageModel>> _getBox(String chatId) async {
    final boxName = '$_boxNamePrefix${chatId.replaceAll('-', '_')}';
    if (Hive.isBoxOpen(boxName)) return Hive.box<MessageModel>(boxName);
    return await Hive.openBox<MessageModel>(boxName);
  }

  @override
  Future<void> saveMessages(String chatId, List<MessageModel> messages) async {
    final box = await _getBox(chatId);
    // Upsert all (id as key to prevent duplicates naturally)
    final map = <String, MessageModel>{
      for (final m in messages) m.id: m,
    };
    await box.putAll(map);

    // Enforce limit: keep only the newest _maxPerChat messages
    if (box.length > _maxPerChat) {
      final all = box.values.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final toDelete = all.skip(_maxPerChat).map((m) => m.id).toList();
      await box.deleteAll(toDelete);
    }
  }

  @override
  Future<List<MessageModel>> getMessages(
    String chatId, {
    int page = 1,
    int limit = 50,
  }) async {
    final box = await _getBox(chatId);
    final all = box.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final start = (page - 1) * limit;
    if (start >= all.length) return [];
    return all.skip(start).take(limit).toList();
  }

  @override
  Future<void> saveMessage(String chatId, MessageModel message) async {
    final box = await _getBox(chatId);
    // Skip duplicates
    if (!box.containsKey(message.id)) {
      await box.put(message.id, message);
    }
  }

  @override
  Future<void> upsertMessage(String chatId, MessageModel message) async {
    final box = await _getBox(chatId);
    await box.put(message.id, message);
  }

  @override
  Future<void> updateMessageStatus(
    String chatId,
    String messageId,
    String status,
  ) async {
    final box = await _getBox(chatId);
    final msg = box.get(messageId);
    if (msg != null) {
      await box.put(messageId, msg.copyWith(status: status));
    }
  }

  @override
  Future<void> replaceTempMessage(
    String chatId,
    String tempId,
    MessageModel realMessage,
  ) async {
    final box = await _getBox(chatId);
    // Remove old temp entry
    if (box.containsKey(tempId)) await box.delete(tempId);
    // Upsert real message
    await box.put(realMessage.id, realMessage);
  }

  @override
  Future<void> clearChat(String chatId) async {
    final box = await _getBox(chatId);
    await box.clear();
  }

  // --- Legacy Stubs ---
  @override
  dynamic getOrCreateChat({required String sellerId, required String userId}) => null;

  @override
  dynamic getLegacyMessages(String chatId) => [];

  @override
  dynamic addMessage(dynamic message) => message;
}
