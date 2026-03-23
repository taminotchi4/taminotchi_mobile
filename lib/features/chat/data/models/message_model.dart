import 'package:hive/hive.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../../../home/domain/entities/comment_entity.dart';

part 'message_model.g.dart';

@HiveType(typeId: 0)
class MessageModel {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String? privateChatId;
  @HiveField(2)
  final String? groupId;
  @HiveField(3)
  final String? commentId;
  @HiveField(4)
  final String senderId;
  @HiveField(5)
  final String senderName;
  @HiveField(6)
  final String? senderAvatar;
  @HiveField(7)
  final String type;
  @HiveField(8)
  final String? text;
  @HiveField(9)
  final String? mediaPath; // Server URL or original local path when sending
  @HiveField(10)
  final DateTime createdAt;
  @HiveField(11)
  final bool isRead;
  @HiveField(12)
  final String? replyToId;
  @HiveField(13)
  final String? status; // SENT, DELIVERED, SEEN
  @HiveField(14)
  final bool isSending; // true only for optimistic messages
  @HiveField(15)
  final String? localPath; // Locally cached media file path

  MessageModel({
    required this.id,
    this.privateChatId,
    this.groupId,
    this.commentId,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.type,
    this.text,
    this.mediaPath,
    required this.createdAt,
    this.isRead = false,
    this.replyToId,
    this.status,
    this.isSending = false,
    this.localPath,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    final senderData = json['sender'] as Map<String, dynamic>?;
    return MessageModel(
      id: json['id'] as String,
      privateChatId: json['privateChatId'] as String?,
      groupId: json['groupId'] as String?,
      commentId: json['commentId'] as String?,
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String? ??
          senderData?['fullName'] as String? ??
          senderData?['name'] as String? ??
          'Noma\'lum',
      senderAvatar: json['senderAvatar'] as String? ??
          senderData?['photoPath'] as String?,
      type: json['type'] as String,
      text: json['text'] as String?,
      mediaPath: json['mediaPath'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      isRead: json['isRead'] ?? false,
      replyToId: json['replyToId'] as String?,
      status: (json['status'] as String?) ??
          (json['isRead'] == true ? 'SEEN' : 'SENT'),
      // localPath not in server response; populated later by cache service
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'privateChatId': privateChatId,
        'groupId': groupId,
        'commentId': commentId,
        'senderId': senderId,
        'senderName': senderName,
        'senderAvatar': senderAvatar,
        'type': type,
        'text': text,
        'mediaPath': mediaPath,
        'createdAt': createdAt.toIso8601String(),
        'isRead': isRead,
        'replyToId': replyToId,
        'status': status,
      };

  MessageModel copyWith({
    String? status,
    bool? isSending,
    bool? isRead,
    String? text,
    String? localPath,
    String? mediaPath,
  }) {
    return MessageModel(
      id: id,
      privateChatId: privateChatId,
      groupId: groupId,
      commentId: commentId,
      senderId: senderId,
      senderName: senderName,
      senderAvatar: senderAvatar,
      type: type,
      text: text ?? this.text,
      mediaPath: mediaPath ?? this.mediaPath,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
      replyToId: replyToId,
      status: status ?? this.status,
      isSending: isSending ?? this.isSending,
      localPath: localPath ?? this.localPath,
    );
  }

  ChatMessageEntity toEntity(String currentUserId) {
    return ChatMessageEntity(
      id: id,
      chatId: privateChatId ?? groupId ?? commentId ?? '',
      senderId: senderId,
      senderName: senderName,
      isSeller: false,
      type: _parseType(type),
      content: text ?? mediaPath ?? '',
      createdAt: createdAt,
      status:
          (status == 'SEEN' || isRead) ? MessageStatus.read : MessageStatus.sent,
      replyToId: replyToId,
    );
  }

  CommentEntity toCommentEntity(String postId) {
    return CommentEntity(
      id: id,
      postId: postId,
      userName: senderName,
      userAvatarPath: senderAvatar ?? 'assets/icons/ic_user.svg',
      content: text ?? '[Media]',
      createdAt: createdAt,
      userRole: null,
    );
  }

  static ChatMessageType _parseType(String type) {
    switch (type) {
      case 'image':
        return ChatMessageType.image;
      case 'audio':
        return ChatMessageType.audio;
      default:
        return ChatMessageType.text;
    }
  }
}
