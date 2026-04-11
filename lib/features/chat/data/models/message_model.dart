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
  @HiveField(16)
  final String? senderRole;

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
    this.senderRole,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    final senderData = json['sender'] as Map<String, dynamic>?;
    
    // Robust sender name extraction
    final String sName = json['senderName']?.toString() ??
        senderData?['fullName']?.toString() ??
        senderData?['name']?.toString() ??
        senderData?['username']?.toString() ??
        json['user']?['username']?.toString() ??
        json['client']?['username']?.toString() ??
        'Noma\'lum';

    // Robust sender avatar extraction
    final String? sAvatar = json['senderAvatar']?.toString() ??
        senderData?['photoPath']?.toString() ??
        senderData?['avatar']?.toString() ??
        senderData?['photo']?.toString();

    // Robust senderId extraction
    final String sId = json['senderId']?.toString() ??
        json['userId']?.toString() ??
        senderData?['id']?.toString() ??
        json['user']?['id']?.toString() ??
        '';

    return MessageModel(
      id: json['id']?.toString() ?? '',
      privateChatId: json['privateChatId']?.toString(),
      groupId: json['groupId']?.toString(),
      commentId: json['commentId']?.toString(),
      senderId: sId,
      senderName: sName,
      senderAvatar: sAvatar,
      type: json['type']?.toString() ?? 'text',
      text: json['text']?.toString(),
      mediaPath: json['mediaPath']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      isRead: json['isRead'] as bool? ?? false,
      replyToId: json['replyToId']?.toString(),
      status: json['status']?.toString() ?? 
               (json['isRead'] == true ? 'SEEN' : 'SENT'),
      senderRole: json['senderRole']?.toString() ?? senderData?['role']?.toString(),
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
        'senderRole': senderRole,
      };

  MessageModel copyWith({
    String? status,
    bool? isSending,
    bool? isRead,
    String? text,
    String? localPath,
    String? mediaPath,
    String? senderRole,
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
      senderRole: senderRole ?? this.senderRole,
    );
  }

  ChatMessageEntity toEntity(String currentUserId) {
    return ChatMessageEntity(
      id: id,
      chatId: privateChatId ?? groupId ?? commentId ?? '',
      senderId: senderId,
      senderName: senderName,
      isSeller: senderId != currentUserId, // In client app, if sender is not me, it's typically the seller/other
      type: _parseType(type),
      content: text ?? mediaPath ?? '',
      createdAt: createdAt,
      status: _parseStatus(status ?? (isRead ? 'SEEN' : 'SENT')),
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

  static MessageStatus _parseStatus(String status) {
    switch (status) {
      case 'SENDING':
        return MessageStatus.sending;
      case 'SENT':
        return MessageStatus.sent;
      case 'DELIVERED':
        return MessageStatus.delivered;
      case 'SEEN':
      case 'READ':
        return MessageStatus.read;
      default:
        return MessageStatus.sent;
    }
  }
}
