class NotificationModel {
  final String id;
  final String? userId;
  final String type;
  final String? senderId;
  final String? senderType;
  final String? senderName;
  final String? senderAvatar;
  final String? referenceId;
  final String? referenceType;
  final String? preview;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const NotificationModel({
    required this.id,
    this.userId,
    required this.type,
    this.senderId,
    this.senderType,
    this.senderName,
    this.senderAvatar,
    this.referenceId,
    this.referenceType,
    this.preview,
    required this.isRead,
    required this.createdAt,
    this.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      userId: json['userId'] as String?,
      type: json['type'] as String,
      senderId: json['senderId'] as String?,
      senderType: json['senderType'] as String?,
      senderName: json['senderName'] as String?,
      senderAvatar: json['senderAvatar'] as String?,
      referenceId: json['referenceId'] as String?,
      referenceType: json['referenceType'] as String?,
      preview: json['preview'] as String?,
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? type,
    String? senderId,
    String? senderType,
    String? senderName,
    String? senderAvatar,
    String? referenceId,
    String? referenceType,
    String? preview,
    bool? isRead,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      senderId: senderId ?? this.senderId,
      senderType: senderType ?? this.senderType,
      senderName: senderName ?? this.senderName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
      referenceId: referenceId ?? this.referenceId,
      referenceType: referenceType ?? this.referenceType,
      preview: preview ?? this.preview,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
