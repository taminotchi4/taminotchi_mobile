enum ChatMessageType { text, image, audio, album }

enum MessageStatus {
  sending,    // Yuborilmoqda
  sent,       // Yuborildi
  delivered,  // Yetkazildi (serverga)
  read,       // O'qildi
  failed,     // Yuborilmadi
}

class ChatMessageEntity {
  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  final bool isSeller;
  final ChatMessageType type;
  final String content;
  final DateTime createdAt;
  final MessageStatus status;
  final String? caption;
  final List<String> images;

  final String? replyToId;
  final ChatMessageEntity? replyToMessage;

  const ChatMessageEntity({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    required this.isSeller,
    required this.type,
    required this.content,
    required this.createdAt,
    this.status = MessageStatus.sent,
    this.caption,
    this.images = const [],
    this.replyToId,
    this.replyToMessage,
  });

  ChatMessageEntity copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? senderName,
    bool? isSeller,
    ChatMessageType? type,
    String? content,
    DateTime? createdAt,
    MessageStatus? status,
    String? caption,
    List<String>? images,
    String? replyToId,
    ChatMessageEntity? replyToMessage,
    bool clearReply = false,
  }) {
    return ChatMessageEntity(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      isSeller: isSeller ?? this.isSeller,
      type: type ?? this.type,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      caption: caption ?? this.caption,
      images: images ?? this.images,
      replyToId: clearReply ? null : (replyToId ?? this.replyToId),
      replyToMessage: clearReply ? null : (replyToMessage ?? this.replyToMessage),
    );
  }
}
