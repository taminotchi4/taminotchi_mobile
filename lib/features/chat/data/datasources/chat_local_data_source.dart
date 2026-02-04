import 'dart:math';

import '../../domain/entities/chat_entity.dart';
import '../../domain/entities/chat_message_entity.dart';

class ChatLocalDataSource {
  final Random _random = Random();
  final Map<String, ChatEntity> _chats = {};
  final Map<String, List<ChatMessageEntity>> _messages = {};

  ChatEntity getOrCreateChat({
    required String sellerId,
    required String userId,
  }) {
    final key = '$sellerId-$userId';
    return _chats.putIfAbsent(
      key,
      () => ChatEntity(id: 'chat_$key', sellerId: sellerId, userId: userId),
    );
  }

  List<ChatMessageEntity> getMessages(String chatId) {
    return List.unmodifiable(_messages[chatId] ?? []);
  }

  ChatMessageEntity addMessage(ChatMessageEntity message) {
    final list = _messages.putIfAbsent(message.chatId, () => []);
    list.add(message);
    return message;
  }

  ChatMessageEntity mockIncomingMessage(String chatId) {
    final message = ChatMessageEntity(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      chatId: chatId,
      senderId: 'seller',
      senderName: 'Market',
      isSeller: true,
      type: ChatMessageType.text,
      content: _randomMessage(),
      createdAt: DateTime.now(),
    );
    return addMessage(message);
  }

  String _randomMessage() {
    const messages = [
      'Salom! Qanday yordam bera olaman?',
      'Buyurtma bo\'yicha savolingiz bormi?',
      'Mahsulotlar bo\'yicha ma\'lumot beraman.',
    ];
    return messages[_random.nextInt(messages.length)];
  }
}
