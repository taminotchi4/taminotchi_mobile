enum ChatMessageType { text, image, audio }

class ChatMessageEntity {
  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  final bool isSeller;
  final ChatMessageType type;
  final String content;
  final DateTime createdAt;

  const ChatMessageEntity({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    required this.isSeller,
    required this.type,
    required this.content,
    required this.createdAt,
  });
}
