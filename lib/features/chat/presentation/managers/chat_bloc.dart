import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/chat_message_entity.dart';
import '../../domain/usecases/get_messages_usecase.dart';
import '../../domain/usecases/get_or_create_chat_usecase.dart';
import '../../domain/usecases/send_message_usecase.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GetOrCreateChatUseCase getOrCreateChatUseCase;
  final GetMessagesUseCase getMessagesUseCase;
  final SendMessageUseCase sendMessageUseCase;

  ChatBloc({
    required this.getOrCreateChatUseCase,
    required this.getMessagesUseCase,
    required this.sendMessageUseCase,
  }) : super(ChatState.initial()) {
    on<ChatStarted>(_onStarted);
    on<ChatSendMessage>(_onSendMessage);
  }

  Future<void> _onStarted(ChatStarted event, Emitter<ChatState> emit) async {
    emit(state.copyWith(isLoading: true));
    final chatResult = await getOrCreateChatUseCase(
      sellerId: event.sellerId,
      userId: event.userId,
    );
    if (emit.isDone) return;
    await chatResult.fold(
      (error) async => emit(state.copyWith(isLoading: false)),
      (chat) async {
        final messagesResult = await getMessagesUseCase(chat.id);
        if (emit.isDone) return;
        messagesResult.fold(
          (_) => emit(state.copyWith(isLoading: false, chat: chat)),
          (messages) => emit(state.copyWith(
            isLoading: false,
            chat: chat,
            messages: messages,
          )),
        );
      },
    );
  }

  Future<void> _onSendMessage(
    ChatSendMessage event,
    Emitter<ChatState> emit,
  ) async {
    final chat = state.chat;
    if (chat == null) return;
    if (event.content.trim().isEmpty) return;
    final message = ChatMessageEntity(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      chatId: chat.id,
      senderId: chat.userId,
      senderName: 'Mening akkauntim',
      isSeller: false,
      type: event.type,
      content: event.content,
      createdAt: DateTime.now(),
    );
    final result = await sendMessageUseCase(message);
    result.fold(
      (_) {},
      (sent) => emit(state.copyWith(
        messages: [...state.messages, sent],
      )),
    );
  }
}
