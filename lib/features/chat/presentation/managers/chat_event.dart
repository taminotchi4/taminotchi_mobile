import '../../domain/entities/chat_message_entity.dart';

sealed class ChatEvent {
  const ChatEvent();
}

class ChatStarted extends ChatEvent {
  final String sellerId;
  final String userId;

  const ChatStarted({required this.sellerId, required this.userId});
}

class ChatSendMessage extends ChatEvent {
  final ChatMessageType type;
  final String content;

  const ChatSendMessage({required this.type, required this.content});
}
