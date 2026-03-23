class NotificationModel {
  final String id;
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

  NotificationModel({
    required this.id,
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
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
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
    );
  }
}
