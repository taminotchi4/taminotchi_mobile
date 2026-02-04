import '../../domain/entities/chat_entity.dart';
import '../../domain/entities/chat_message_entity.dart';

class ChatState {
  final ChatEntity? chat;
  final List<ChatMessageEntity> messages;
  final bool isLoading;

  const ChatState({
    required this.chat,
    required this.messages,
    required this.isLoading,
  });

  factory ChatState.initial() => const ChatState(
    chat: null,
    messages: [],
    isLoading: false,
  );

  ChatState copyWith({
    ChatEntity? chat,
    List<ChatMessageEntity>? messages,
    bool? isLoading,
  }) {
    return ChatState(
      chat: chat ?? this.chat,
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
