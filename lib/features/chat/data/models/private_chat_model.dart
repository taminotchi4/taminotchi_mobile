import 'message_model.dart';

class PrivateChatModel {
  final String id;
  final dynamic client;
  final dynamic market;
  final MessageModel? lastMessage;
  final List<MessageModel> messages;
  final DateTime createdAt;
  final int unreadCount;

  PrivateChatModel({
    required this.id,
    this.client,
    this.market,
    this.lastMessage,
    this.messages = const [],
    required this.createdAt,
    this.unreadCount = 0,
  });

  factory PrivateChatModel.fromJson(Map<String, dynamic> json) {
    return PrivateChatModel(
      id: json['id'] as String,
      client: json['client'],
      market: json['market'],
      lastMessage: json['lastMessage'] != null
          ? MessageModel.fromJson(json['lastMessage'])
          : null,
      messages: (json['messages'] as List?)
              ?.map((m) => MessageModel.fromJson(m))
              .toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      unreadCount: json['unreadCount'] ?? 0,
    );
  }

  PrivateChatModel copyWith({
    String? id,
    dynamic client,
    dynamic market,
    MessageModel? lastMessage,
    List<MessageModel>? messages,
    DateTime? createdAt,
    int? unreadCount,
  }) {
    return PrivateChatModel(
      id: id ?? this.id,
      client: client ?? this.client,
      market: market ?? this.market,
      lastMessage: lastMessage ?? this.lastMessage,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}
