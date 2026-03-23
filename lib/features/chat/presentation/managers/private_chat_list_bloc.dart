import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/socket_manager.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../data/models/message_model.dart';
import '../../data/models/private_chat_model.dart';
import '../../data/models/market_model.dart';
import '../../domain/repositories/chat_repository.dart';

// --- Events ---
abstract class PrivateChatListEvent {
  const PrivateChatListEvent();
}

class PrivateChatListLoad extends PrivateChatListEvent {}

class _NewMessageReceived extends PrivateChatListEvent {
  final MessageModel message;
  const _NewMessageReceived(this.message);
}

class PrivateChatListMarkRead extends PrivateChatListEvent {
  final String chatId;
  const PrivateChatListMarkRead(this.chatId);
}

class PrivateChatListSearch extends PrivateChatListEvent {
  final String query;
  const PrivateChatListSearch(this.query);
}

class PrivateChatListClearSearch extends PrivateChatListEvent {}

class PrivateChatListOpenChat extends PrivateChatListEvent {
  final String receiverId;
  final String receiverRole;
  final String receiverName;

  const PrivateChatListOpenChat({
    required this.receiverId,
    required this.receiverRole,
    required this.receiverName,
  });
}

// --- State ---
class PrivateChatListState {
  final List<PrivateChatModel> chats;
  final List<MarketModel> searchResults;
  final bool isLoading;
  final bool isSearching;
  final String? error;
  // Navigation trigger: set when a chat is opened successfully
  final ({String chatId, String name, String receiverId, String receiverRole})? navigateTo;

  const PrivateChatListState({
    this.chats = const [],
    this.searchResults = const [],
    this.isLoading = false,
    this.isSearching = false,
    this.error,
    this.navigateTo,
  });

  PrivateChatListState copyWith({
    List<PrivateChatModel>? chats,
    List<MarketModel>? searchResults,
    bool? isLoading,
    bool? isSearching,
    String? error,
    ({String chatId, String name, String receiverId, String receiverRole})? navigateTo,
    bool clearNavigateTo = false,
  }) {
    return PrivateChatListState(
      chats: chats ?? this.chats,
      searchResults: searchResults ?? this.searchResults,
      isLoading: isLoading ?? this.isLoading,
      isSearching: isSearching ?? this.isSearching,
      error: error,
      navigateTo: clearNavigateTo ? null : (navigateTo ?? this.navigateTo),
    );
  }
}

// --- Bloc ---
class PrivateChatListBloc extends Bloc<PrivateChatListEvent, PrivateChatListState> {
  final ChatRepository repository;
  final AuthRepository authRepository;
  dynamic _socket;
  bool _socketReady = false;

  PrivateChatListBloc({
    required this.repository,
    required this.authRepository,
  }) : super(const PrivateChatListState()) {
    on<PrivateChatListLoad>(_onLoad);
    on<_NewMessageReceived>(_onNewMessage);
    on<PrivateChatListMarkRead>(_onMarkRead);
    on<PrivateChatListSearch>(_onSearch);
    on<PrivateChatListClearSearch>(_onClearSearch);
    on<PrivateChatListOpenChat>(_onOpenChat);

    _initSocket();
  }

  Future<void> _initSocket() async {
    final token = await authRepository.getToken() ?? '';
    _socket = ChatSocketManager.connect('/private-chat', token);
    _socketReady = true;

    _socket.on('new_message', (data) {
      final msg = MessageModel.fromJson(data);
      add(_NewMessageReceived(msg));
    });
  }

  Future<void> _onLoad(PrivateChatListLoad event, Emitter<PrivateChatListState> emit) async {
    emit(state.copyWith(isLoading: true));
    final result = await repository.getMyPrivateChats();
    result.fold(
      (error) => emit(state.copyWith(isLoading: false, error: error.toString())),
      (chats) => emit(state.copyWith(chats: chats, isLoading: false)),
    );
  }

  void _onNewMessage(_NewMessageReceived event, Emitter<PrivateChatListState> emit) {
    final msg = event.message;
    final List<PrivateChatModel> currentChats = List.from(state.chats);
    
    final index = currentChats.indexWhere((c) => c.id == msg.privateChatId);
    
    if (index != -1) {
      // Chat topildi - oxirgi xabarni yangilaymiz va tepaga chiqaramiz
      final oldChat = currentChats.removeAt(index);
      final updatedChat = PrivateChatModel(
        id: oldChat.id,
        client: oldChat.client,
        market: oldChat.market,
        lastMessage: msg,
        messages: oldChat.messages, // Asosan list ko'rinishi uchun kerak emas, lekin saqlab qo'yamiz
        createdAt: oldChat.createdAt,
      );
      currentChats.insert(0, updatedChat);
      emit(state.copyWith(chats: currentChats));
    } else {
      // Yangi chat - ro'yxatni serverdan qayta yuklaymiz (metadatalarni olish uchun)
      add(PrivateChatListLoad());
    }
  }

  void _onMarkRead(PrivateChatListMarkRead event, Emitter<PrivateChatListState> emit) {
    final List<PrivateChatModel> currentChats = List.from(state.chats);
    final index = currentChats.indexWhere((c) => c.id == event.chatId);
    if (index != -1) {
      currentChats[index] = currentChats[index].copyWith(unreadCount: 0);
      emit(state.copyWith(chats: currentChats));
    }
  }

  Future<void> _onSearch(PrivateChatListSearch event, Emitter<PrivateChatListState> emit) async {
    if (event.query.isEmpty) {
      emit(state.copyWith(searchResults: [], isSearching: false));
      return;
    }
    emit(state.copyWith(isSearching: true));
    final result = await repository.searchMarkets(event.query);
    result.fold(
      (error) => emit(state.copyWith(isSearching: false, error: error.toString())),
      (markets) => emit(state.copyWith(searchResults: markets, isSearching: false)),
    );
  }

  void _onClearSearch(PrivateChatListClearSearch event, Emitter<PrivateChatListState> emit) {
    emit(state.copyWith(searchResults: [], isSearching: false));
  }

  Future<void> _onOpenChat(PrivateChatListOpenChat event, Emitter<PrivateChatListState> emit) async {
    emit(state.copyWith(isLoading: true));
    final result = await repository.openPrivateChat(event.receiverId, event.receiverRole);
    result.fold(
      (error) => emit(state.copyWith(isLoading: false, error: error.toString())),
      (chat) {
        emit(state.copyWith(
          isLoading: false,
          navigateTo: (
            chatId: chat.id,
            name: event.receiverName,
            receiverId: event.receiverId,
            receiverRole: event.receiverRole,
          ),
        ));
      },
    );
  }

  @override
  Future<void> close() {
    if (_socketReady) {
      _socket.off('new_message');
    }
    return super.close();
  }
}
