import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/socket_manager.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../data/models/message_model.dart';

// ═══════════════════════════════════════════════════════════════
// EVENTS
// ═══════════════════════════════════════════════════════════════

abstract class PrivateChatEvent {
  const PrivateChatEvent();
}

/// Open chat via receiverId (REST → WS flow)
class PrivateChatStarted extends PrivateChatEvent {
  final String receiverId;
  final String receiverRole;
  const PrivateChatStarted(
      {required this.receiverId, required this.receiverRole});
}

/// Open chat with known chatId (WS only, used from chat list)
class PrivateChatStartedWithId extends PrivateChatEvent {
  final String chatId;
  const PrivateChatStartedWithId(this.chatId);
}

/// Infinite scroll — load next page
class PrivateChatLoadMore extends PrivateChatEvent {
  const PrivateChatLoadMore();
}

/// Send a text message
class PrivateChatSendMessage extends PrivateChatEvent {
  final String chatId;
  final String text;
  final String? type;
  final String? mediaPath;
  final String? replyToId;
  const PrivateChatSendMessage({
    required this.chatId,
    required this.text,
    this.type,
    this.mediaPath,
    this.replyToId,
  });
}

/// Send a media message (image or audio)
class PrivateChatSendMedia extends PrivateChatEvent {
  final String chatId;
  final String filePath;
  final String type; // 'image' | 'audio'
  const PrivateChatSendMedia(
      {required this.chatId, required this.filePath, required this.type});
}

/// Emit typing to server
class PrivateChatTyping extends PrivateChatEvent {
  final String chatId;
  const PrivateChatTyping(this.chatId);
}

// ─── Internal ────────────────────────────────────────────────
class _NewMessage extends PrivateChatEvent {
  final MessageModel message;
  _NewMessage(this.message);
}

class _HistoryReceived extends PrivateChatEvent {
  final List<MessageModel> messages;
  _HistoryReceived(this.messages);
}

class _LocalLoaded extends PrivateChatEvent {
  final List<MessageModel> messages;
  _LocalLoaded(this.messages);
}

class _StatusUpdated extends PrivateChatEvent {
  final String chatId;
  _StatusUpdated(this.chatId);
}

class _PeerTyping extends PrivateChatEvent {
  final bool isTyping;
  const _PeerTyping(this.isTyping);
}

class _MediaResolved extends PrivateChatEvent {
  final String messageId;
  final String localPath;
  _MediaResolved(this.messageId, this.localPath);
}

// ═══════════════════════════════════════════════════════════════
// STATE
// ═══════════════════════════════════════════════════════════════

class PrivateChatState {
  final List<MessageModel> messages;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasReachedEnd;
  final String? chatId;
  final String? error;
  final bool isPeerTyping;
  final String? currentUserId;
  final int currentPage;

  const PrivateChatState({
    this.messages = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasReachedEnd = false,
    this.chatId,
    this.error,
    this.isPeerTyping = false,
    this.currentUserId,
    this.currentPage = 1,
  });

  PrivateChatState copyWith({
    List<MessageModel>? messages,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasReachedEnd,
    String? chatId,
    String? error,
    bool? isPeerTyping,
    String? currentUserId,
    int? currentPage,
  }) {
    return PrivateChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      chatId: chatId ?? this.chatId,
      error: error,
      isPeerTyping: isPeerTyping ?? this.isPeerTyping,
      currentUserId: currentUserId ?? this.currentUserId,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// BLOC
// ═══════════════════════════════════════════════════════════════

class PrivateChatBloc extends Bloc<PrivateChatEvent, PrivateChatState> {
  final ChatRepository repository;
  final AuthRepository authRepository;

  dynamic _socket;
  bool _socketReady = false;
  static const int _pageLimit = 50;

  PrivateChatBloc({
    required this.repository,
    required this.authRepository,
  }) : super(const PrivateChatState()) {
    on<PrivateChatStarted>(_onStarted);
    on<PrivateChatStartedWithId>(_onStartedWithId);
    on<PrivateChatLoadMore>(_onLoadMore);
    on<PrivateChatSendMessage>(_onSendMessage);
    on<PrivateChatSendMedia>(_onSendMedia);
    on<PrivateChatTyping>(_onTyping);
    on<_NewMessage>(_onNewMessage);
    on<_HistoryReceived>(_onHistoryReceived);
    on<_LocalLoaded>(_onLocalLoaded);
    on<_StatusUpdated>(_onStatusUpdated);
    on<_PeerTyping>((e, emit) => emit(state.copyWith(isPeerTyping: e.isTyping)));
    on<_MediaResolved>(_onMediaResolved);
  }

  // ─── Main entry points ───────────────────────────────────────

  Future<void> _onStarted(
      PrivateChatStarted event, Emitter<PrivateChatState> emit) async {
    emit(state.copyWith(isLoading: true));

    final currentUserId = await authRepository.getUserId();

    final result =
        await repository.openPrivateChat(event.receiverId, event.receiverRole);

    if (result.isError) {
      emit(state.copyWith(isLoading: false, error: result.error.toString()));
      return;
    }

    final chat = result.data;
    if (chat == null) {
      emit(state.copyWith(isLoading: false));
      return;
    }

    emit(state.copyWith(chatId: chat.id, currentUserId: currentUserId));

    // 1. Show local cache instantly
    final local = await repository.getLocalMessages(chat.id);
    if (local.isNotEmpty) {
      emit(state.copyWith(messages: local, isLoading: false));
    } else {
      emit(state.copyWith(isLoading: false));
    }

    // 2. Connect socket (will trigger load_history)
    await _connectSocket(chat.id);
  }

  Future<void> _onStartedWithId(
      PrivateChatStartedWithId event, Emitter<PrivateChatState> emit) async {
    emit(state.copyWith(isLoading: true));

    final currentUserId = await authRepository.getUserId();
    emit(state.copyWith(chatId: event.chatId, currentUserId: currentUserId));

    // 1. Show local cache instantly
    final local = await repository.getLocalMessages(event.chatId);
    if (local.isNotEmpty) {
      emit(state.copyWith(messages: local, isLoading: false));
    } else {
      emit(state.copyWith(isLoading: false));
    }

    // 2. Connect socket
    await _connectSocket(event.chatId);
  }

  // ─── Infinite scroll ─────────────────────────────────────────

  Future<void> _onLoadMore(
      PrivateChatLoadMore event, Emitter<PrivateChatState> emit) async {
    if (state.isLoadingMore || state.hasReachedEnd || state.chatId == null) {
      return;
    }

    emit(state.copyWith(isLoadingMore: true));

    // Try local first
    final nextPage = state.currentPage + 1;
    final local = await repository.getLocalMessages(
      state.chatId!,
      page: nextPage,
      limit: _pageLimit,
    );

    if (local.isNotEmpty) {
      final combined = [...state.messages, ...local];
      emit(state.copyWith(
        messages: combined,
        isLoadingMore: false,
        currentPage: nextPage,
        hasReachedEnd: local.length < _pageLimit,
      ));
      return;
    }

    // Request from server via socket
    _socket?.emit('load_history', {
      'privateChatId': state.chatId,
      'page': nextPage,
      'limit': _pageLimit,
    });

    // State will be updated via _onHistoryReceived
    emit(state.copyWith(isLoadingMore: false, currentPage: nextPage));
  }

  // ─── Send text ───────────────────────────────────────────────

  Future<void> _onSendMessage(
      PrivateChatSendMessage event, Emitter<PrivateChatState> emit) async {
    if (!_socketReady) return;

    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final optimistic = MessageModel(
      id: tempId,
      privateChatId: event.chatId,
      senderId: state.currentUserId ?? 'me',
      senderName: 'Siz',
      type: event.type ?? 'text',
      text: event.text,
      mediaPath: event.mediaPath,
      createdAt: DateTime.now(),
      status: 'SENT',
      isSending: true,
    );

    emit(state.copyWith(messages: [optimistic, ...state.messages]));
    // Save optimistic msg locally (will be replaced when confirmed)
    await repository.saveLocalMessage(event.chatId, optimistic);

    _socket.emit('send_message', {
      'privateChatId': event.chatId,
      'type': event.type ?? 'text',
      'text': event.text,
      if (event.mediaPath != null) 'mediaPath': event.mediaPath,
      if (event.replyToId != null) 'replyToId': event.replyToId,
    });
  }

  // ─── Send media ───────────────────────────────────────────────

  Future<void> _onSendMedia(
      PrivateChatSendMedia event, Emitter<PrivateChatState> emit) async {
    if (!_socketReady) return;

    final tempId = 'temp_media_${DateTime.now().millisecondsSinceEpoch}';
    final optimistic = MessageModel(
      id: tempId,
      privateChatId: event.chatId,
      senderId: state.currentUserId ?? 'me',
      senderName: 'Siz',
      type: event.type,
      // Show local file immediately while upload is in progress
      mediaPath: event.filePath,
      localPath: event.filePath,
      createdAt: DateTime.now(),
      status: 'SENT',
      isSending: true,
    );

    emit(state.copyWith(messages: [optimistic, ...state.messages]));
    await repository.saveLocalMessage(event.chatId, optimistic);

    // Upload to server
    final result = await repository.uploadMedia(event.type, event.filePath);

    if (result.isError) {
      emit(state.copyWith(error: result.error.toString()));
      return;
    }

    final serverPath = result.data!;

    // Emit to socket; server will respond with new_message
    _socket.emit('send_message', {
      'privateChatId': event.chatId,
      'type': event.type,
      'mediaPath': serverPath,
    });
    // The _onNewMessage handler will replace the temp entry
  }

  // ─── Typing ───────────────────────────────────────────────────

  void _onTyping(PrivateChatTyping event, Emitter<PrivateChatState> emit) {
    if (!_socketReady) return;
    _socket.emit('typing', {'privateChatId': event.chatId});
  }

  // ─── Incoming message ─────────────────────────────────────────

  Future<void> _onNewMessage(
      _NewMessage event, Emitter<PrivateChatState> emit) async {
    final msg = event.message;
    final chatId = state.chatId;
    if (chatId == null) return;

    final list = List<MessageModel>.from(state.messages);

    // 1. Replace optimistic (temp) if content matches
    final tempIdx = list.indexWhere((m) =>
        m.isSending &&
        m.type == msg.type &&
        (m.text == msg.text || m.mediaPath == msg.mediaPath));

    if (tempIdx != -1) {
      final tempId = list[tempIdx].id;
      // Replace in local store
      await repository.replaceTempMessage(chatId, tempId, msg);
      list[tempIdx] = msg;
    } else if (list.any((m) => m.id == msg.id)) {
      // Update existing (duplicate guard)
      final idx = list.indexWhere((m) => m.id == msg.id);
      list[idx] = msg;
      await repository.upsertLocalMessage(chatId, msg);
    } else {
      // Brand-new incoming message
      list.insert(0, msg);
      await repository.saveLocalMessage(chatId, msg);
    }

    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    emit(state.copyWith(messages: list));

    // Lazy-load media if message has a server URL but no local file
    if ((msg.type == 'image' || msg.type == 'audio') &&
        msg.mediaPath != null &&
        (msg.localPath == null || msg.localPath!.isEmpty)) {
      _resolveMedia(msg);
    }
  }

  // ─── History received from server ─────────────────────────────

  Future<void> _onHistoryReceived(
      _HistoryReceived event, Emitter<PrivateChatState> emit) async {
    final chatId = state.chatId;
    if (chatId == null) return;

    final incoming = List<MessageModel>.from(event.messages);
    incoming.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // Merge with existing to avoid total replacement of temp messages
    final existing = List<MessageModel>.from(state.messages);
    final merged = _mergeMessages(existing, incoming);

    emit(state.copyWith(
      messages: merged,
      isLoadingMore: false,
      hasReachedEnd: incoming.length < _pageLimit,
    ));

    // Persist to Hive
    await repository.saveLocalMessages(chatId, incoming);

    // Kick off media pre-fetch for first visible batch
    for (final msg in merged.take(20)) {
      if ((msg.type == 'image' || msg.type == 'audio') &&
          msg.mediaPath != null &&
          (msg.localPath == null || msg.localPath!.isEmpty)) {
        _resolveMedia(msg);
      }
    }
  }

  // ─── Local history (instant display) ─────────────────────────

  void _onLocalLoaded(_LocalLoaded event, Emitter<PrivateChatState> emit) {
    if (state.messages.isEmpty) {
      emit(state.copyWith(messages: event.messages));
    }
  }

  // ─── Status update ────────────────────────────────────────────

  Future<void> _onStatusUpdated(
      _StatusUpdated event, Emitter<PrivateChatState> emit) async {
    final chatId = state.chatId;
    if (chatId == null) return;

    final updated = state.messages.map((m) {
      if (m.privateChatId == event.chatId && m.status != 'SEEN') {
        return m.copyWith(status: 'SEEN');
      }
      return m;
    }).toList();

    emit(state.copyWith(messages: updated));

    // Persist status changes
    for (final m in updated.where((m) => m.status == 'SEEN')) {
      await repository.updateLocalMessageStatus(chatId, m.id, 'SEEN');
    }
  }

  // ─── Media resolved (lazy download complete) ──────────────────

  Future<void> _onMediaResolved(
      _MediaResolved event, Emitter<PrivateChatState> emit) async {
    final list = List<MessageModel>.from(state.messages);
    final idx = list.indexWhere((m) => m.id == event.messageId);
    if (idx == -1) return;

    final updated = list[idx].copyWith(localPath: event.localPath);
    list[idx] = updated;
    emit(state.copyWith(messages: list));

    if (state.chatId != null) {
      await repository.upsertLocalMessage(state.chatId!, updated);
    }
  }

  // ─── Socket ───────────────────────────────────────────────────

  Future<void> _connectSocket(String chatId) async {
    final token = await authRepository.getToken() ?? '';
    _socket = ChatSocketManager.connect('/private-chat', token);
    _socketReady = true;

    _socket.on('new_message', (data) {
      final msg = MessageModel.fromJson(data as Map<String, dynamic>);
      if (msg.privateChatId == state.chatId) add(_NewMessage(msg));
    });

    _socket.on('messages_seen', (data) {
      if (data['privateChatId'] == state.chatId) {
        add(_StatusUpdated(state.chatId!));
      }
    });

    _socket.on('history', (data) {
      final raw = data['data'] as List<dynamic>;
      final msgs = raw.map((e) => MessageModel.fromJson(e as Map<String, dynamic>)).toList();
      add(_HistoryReceived(msgs));
    });

    _socket.on('typing', (data) {
      if (data['privateChatId'] == state.chatId) add(const _PeerTyping(true));
    });

    _socket.on('stop_typing', (data) {
      if (data['privateChatId'] == state.chatId) add(const _PeerTyping(false));
    });

    void joinAndLoad() {
      _socket.emit('join_chat', {'privateChatId': chatId});
      _socket.emit('load_history', {
        'privateChatId': chatId,
        'page': 1,
        'limit': _pageLimit,
      });
    }

    if (_socket.connected == true) {
      joinAndLoad();
    } else {
      _socket.on('connect', (_) => joinAndLoad());
    }
  }

  // ─── Helpers ─────────────────────────────────────────────────

  /// Merge server messages into existing list without losing temp messages.
  List<MessageModel> _mergeMessages(
    List<MessageModel> existing,
    List<MessageModel> incoming,
  ) {
    final map = <String, MessageModel>{
      for (final m in incoming) m.id: m,
    };

    final merged = <MessageModel>[];

    for (final m in existing) {
      if (map.containsKey(m.id)) {
        merged.add(map.remove(m.id)!); // use server version
      } else {
        merged.add(m); // keep local (temp or older)
      }
    }

    // Add any new server messages not in existing
    merged.insertAll(0, map.values);
    merged.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return merged;
  }

  /// Fire-and-forget: download media in background, then dispatch event.
  void _resolveMedia(MessageModel msg) {
    final type = msg.type;
    final url = msg.mediaPath;
    if (url == null) return;

    repository.getLocalMediaPath(url, type).then((localPath) {
      if (localPath != null && !isClosed) {
        add(_MediaResolved(msg.id, localPath));
      }
    });
  }

  @override
  Future<void> close() {
    if (_socketReady) {
      _socket
        ..off('new_message')
        ..off('messages_seen')
        ..off('history')
        ..off('typing')
        ..off('stop_typing')
        ..off('connect');
      if (state.chatId != null) {
        _socket.emit('leave_chat', {'privateChatId': state.chatId});
      }
    }
    return super.close();
  }
}
