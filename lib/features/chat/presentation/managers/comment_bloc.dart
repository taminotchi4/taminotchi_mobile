import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/socket_manager.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../data/models/message_model.dart';
import '../../domain/repositories/chat_repository.dart';

// ══════════════════════════════════════════════════════════════
// EVENTS
// ══════════════════════════════════════════════════════════════

abstract class CommentEvent {
  const CommentEvent();
}

class CommentJoin extends CommentEvent {
  final String commentId;
  const CommentJoin(this.commentId);
}

class CommentSendMessage extends CommentEvent {
  final String commentId;
  final String text;
  final String? replyToId;
  const CommentSendMessage({
    required this.commentId,
    required this.text,
    this.replyToId,
  });
}

class CommentSendImage extends CommentEvent {
  final String commentId;
  final String filePath;
  final String? replyToId;
  const CommentSendImage({
    required this.commentId,
    required this.filePath,
    this.replyToId,
  });
}

class CommentSendAudio extends CommentEvent {
  final String commentId;
  final String filePath;
  const CommentSendAudio({required this.commentId, required this.filePath});
}

class CommentLeave extends CommentEvent {
  final String commentId;
  const CommentLeave(this.commentId);
}

class CommentLoadMore extends CommentEvent {
  final String commentId;
  const CommentLoadMore(this.commentId);
}

class CommentTyping extends CommentEvent {
  final String commentId;
  const CommentTyping(this.commentId);
}

class CommentStopTyping extends CommentEvent {
  final String commentId;
  const CommentStopTyping(this.commentId);
}

class CommentEditMessage extends CommentEvent {
  final String commentId;
  final String messageId;
  final String text;
  const CommentEditMessage({required this.commentId, required this.messageId, required this.text});
}

class CommentDeleteMessage extends CommentEvent {
  final String commentId;
  final String messageId;
  const CommentDeleteMessage({required this.commentId, required this.messageId});
}

class CommentStartEditing extends CommentEvent {
  final MessageModel message;
  const CommentStartEditing(this.message);
}

class CommentReplyToMessage extends CommentEvent {
  final MessageModel message;
  const CommentReplyToMessage(this.message);
}

class CommentCancelAction extends CommentEvent {
  const CommentCancelAction();
}

// Internal events
class _NewMessage extends CommentEvent {
  final MessageModel message;
  _NewMessage(this.message);
}

class _HistoryReceived extends CommentEvent {
  final List<MessageModel> messages;
  final bool prepend;
  _HistoryReceived(this.messages, {this.prepend = false});
}

class _LocalLoaded extends CommentEvent {
  final List<MessageModel> messages;
  _LocalLoaded(this.messages);
}

class _PeerTyping extends CommentEvent {
  final String userId;
  final bool isTyping;
  const _PeerTyping(this.userId, this.isTyping);
}

class _MediaResolved extends CommentEvent {
  final String messageId;
  final String localPath;
  _MediaResolved(this.messageId, this.localPath);
}

class _StatusUpdated extends CommentEvent {
  final String commentId;
  const _StatusUpdated(this.commentId);
}

// ══════════════════════════════════════════════════════════════
// STATE
class CommentState {
  final List<MessageModel> messages;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int currentPage;
  final String? error;
  final Set<String> typingUserIds;
  final String? currentUserId;
  final String? chatId;
  final MessageModel? editingMessage;
  final MessageModel? replyingToMessage;

  const CommentState({
    this.messages = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.currentPage = 1,
    this.error,
    this.typingUserIds = const {},
    this.currentUserId,
    this.chatId,
    this.editingMessage,
    this.replyingToMessage,
  });
  CommentState copyWith({
    List<MessageModel>? messages,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? currentPage,
    String? error,
    Set<String>? typingUserIds,
    String? currentUserId,
    String? chatId,
    MessageModel? editingMessage,
    MessageModel? replyingToMessage,
    bool clearEditing = false,
    bool clearReplying = false,
  }) {
    return CommentState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      error: error,
      typingUserIds: typingUserIds ?? this.typingUserIds,
      currentUserId: currentUserId ?? this.currentUserId,
      chatId: chatId ?? this.chatId,
      editingMessage: clearEditing ? null : (editingMessage ?? this.editingMessage),
      replyingToMessage: clearReplying ? null : (replyingToMessage ?? this.replyingToMessage),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// BLOC
// ══════════════════════════════════════════════════════════════

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  static const int _pageLimit = 30;

  final AuthRepository authRepository;
  final ChatRepository chatRepository;

  dynamic _socket;
  bool _socketReady = false;
  Timer? _typingTimer;

  CommentBloc({
    required this.authRepository,
    required this.chatRepository,
  }) : super(const CommentState()) {
    on<CommentJoin>(_onJoin);
    on<CommentSendMessage>(_onSendMessage);
    on<CommentSendImage>(_onSendImage);
    on<CommentSendAudio>(_onSendAudio);
    on<CommentLeave>(_onLeave);
    on<CommentLoadMore>(_onLoadMore);
    on<CommentTyping>(_onTyping);
    on<CommentStopTyping>(_onStopTyping);
    on<CommentEditMessage>(_onEditMessage);
    on<CommentDeleteMessage>(_onDeleteMessage);
    on<CommentStartEditing>((e, emit) => emit(state.copyWith(editingMessage: e.message, clearReplying: true)));
    on<CommentReplyToMessage>((e, emit) => emit(state.copyWith(replyingToMessage: e.message, clearEditing: true)));
    on<CommentCancelAction>((e, emit) => emit(state.copyWith(clearEditing: true, clearReplying: true)));
    on<_NewMessage>(_onNewMessage);
    on<_HistoryReceived>(_onHistoryReceived);
    on<_LocalLoaded>(_onLocalLoaded);
    on<_PeerTyping>(_onPeerTyping);
    on<_MediaResolved>(_onMediaResolved);
    on<_StatusUpdated>(_onStatusUpdated);
  }

  // ── Join ──────────────────────────────────────────────────────

  Future<void> _onJoin(CommentJoin event, Emitter<CommentState> emit) async {
    emit(state.copyWith(
      isLoading: true,
      messages: [],
      currentPage: 1,
      hasMore: true,
      chatId: event.commentId,
    ));

    // 1. Load local cache immediately
    final local = await chatRepository.getLocalMessages(event.commentId);
    if (local.isNotEmpty) {
      emit(state.copyWith(messages: local, isLoading: false));
    }

    // 2. Get token & connect socket
    final token = await authRepository.getToken() ?? '';
    final userId = await authRepository.getUserId();
    emit(state.copyWith(currentUserId: userId));

    await _connectSocket(event.commentId, token);
  }

  // ── Socket setup ─────────────────────────────────────────────

  Future<void> _connectSocket(String commentId, String token) async {
    _socket = ChatSocketManager.connect('/comment-chat', token);
    _socketReady = true;

    _socket.on('new_message', (data) {
      try {
        final msg = MessageModel.fromJson(data as Map<String, dynamic>);
        if (!isClosed) add(_NewMessage(msg));
      } catch (_) {}
    });

    _socket.on('history', (data) {
      try {
        final List<dynamic> list =
            (data as Map<String, dynamic>)['data'] as List<dynamic>? ?? [];
        final messages =
            list.map((e) => MessageModel.fromJson(e as Map<String, dynamic>)).toList();
        if (!isClosed) {
          add(_HistoryReceived(messages, prepend: state.currentPage > 1));
        }
      } catch (_) {}
    });

    _socket.on('messages_seen', (data) {
      try {
        final cid = (data as Map<String, dynamic>)['commentId'] as String?;
        if (cid == state.chatId && !isClosed) add(_StatusUpdated(cid!));
      } catch (_) {}
    });

    _socket.on('typing', (data) {
      try {
        final userId = (data as Map<String, dynamic>)['userId'] as String? ?? '';
        if (userId.isNotEmpty && !isClosed) add(_PeerTyping(userId, true));
      } catch (_) {}
    });

    _socket.on('stop_typing', (data) {
      try {
        final userId = (data as Map<String, dynamic>)['userId'] as String? ?? '';
        if (userId.isNotEmpty && !isClosed) add(_PeerTyping(userId, false));
      } catch (_) {}
    });

    void joinAndLoad() {
      _socket.emit('join_comment', {'commentId': commentId});
      _socket.emit('load_history', {
        'commentId': commentId,
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

  // ── Send text ────────────────────────────────────────────────

  Future<void> _onSendMessage(
      CommentSendMessage event, Emitter<CommentState> emit) async {
    if (!_socketReady) return;

    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final optimistic = MessageModel(
      id: tempId,
      commentId: event.commentId,
      senderId: state.currentUserId ?? 'me',
      senderName: 'Siz',
      type: 'text',
      text: event.text,
      createdAt: DateTime.now(),
      status: 'SENT',
      isSending: true,
    );

    emit(state.copyWith(messages: [optimistic, ...state.messages]));
    await chatRepository.saveLocalMessage(event.commentId, optimistic);

    _socket.emit('send_message', {
      'commentId': event.commentId,
      'type': 'text',
      'text': event.text,
      if (event.replyToId != null) 'replyToId': event.replyToId,
    });
  }

  // ── Send image ───────────────────────────────────────────────

  Future<void> _onSendImage(
      CommentSendImage event, Emitter<CommentState> emit) async {
    if (!_socketReady) return;

    // Show optimistic
    final tempId = 'temp_img_${DateTime.now().millisecondsSinceEpoch}';
    final optimistic = MessageModel(
      id: tempId,
      commentId: event.commentId,
      senderId: state.currentUserId ?? 'me',
      senderName: 'Siz',
      type: 'image',
      mediaPath: event.filePath,
      localPath: event.filePath,
      createdAt: DateTime.now(),
      status: 'SENT',
      isSending: true,
    );
    emit(state.copyWith(messages: [optimistic, ...state.messages]));
    await chatRepository.saveLocalMessage(event.commentId, optimistic);

    // Upload
    final result = await chatRepository.uploadMedia('image', event.filePath);
    if (result.isError) {
      emit(state.copyWith(error: 'Rasm yuborishda xatolik'));
      return;
    }
    final serverPath = result.data!;

    _socket.emit('send_message', {
      'commentId': event.commentId,
      'type': 'image',
      'mediaPath': serverPath,
      if (state.replyingToMessage != null) 'replyToId': state.replyingToMessage!.id,
    });
    if (state.replyingToMessage != null) {
      emit(state.copyWith(clearReplying: true));
    }
  }

  Future<void> _onEditMessage(CommentEditMessage event, Emitter<CommentState> emit) async {
    final result = await chatRepository.editMessage(event.messageId, event.text);
    if (result.isSuccess) {
      final list = state.messages.map((m) {
        if (m.id == event.messageId) {
          return m.copyWith(text: event.text);
        }
        return m;
      }).toList();
      emit(state.copyWith(messages: list, clearEditing: true));
    } else {
      emit(state.copyWith(error: 'Tahrirlashda xatolik'));
    }
  }

  Future<void> _onDeleteMessage(CommentDeleteMessage event, Emitter<CommentState> emit) async {
    final result = await chatRepository.deleteMessage(event.messageId);
    if (result.isSuccess) {
      final list = state.messages.where((m) => m.id != event.messageId).toList();
      emit(state.copyWith(messages: list));
    } else {
      emit(state.copyWith(error: 'O\'chirishda xatolik'));
    }
  }

  // ── Send audio ───────────────────────────────────────────────

  Future<void> _onSendAudio(
      CommentSendAudio event, Emitter<CommentState> emit) async {
    if (!_socketReady) return;

    final tempId = 'temp_aud_${DateTime.now().millisecondsSinceEpoch}';
    final optimistic = MessageModel(
      id: tempId,
      commentId: event.commentId,
      senderId: state.currentUserId ?? 'me',
      senderName: 'Siz',
      type: 'audio',
      mediaPath: event.filePath,
      localPath: event.filePath,
      createdAt: DateTime.now(),
      status: 'SENT',
      isSending: true,
    );
    emit(state.copyWith(messages: [optimistic, ...state.messages]));
    await chatRepository.saveLocalMessage(event.commentId, optimistic);

    final result = await chatRepository.uploadMedia('audio', event.filePath);
    if (result.isError) {
      emit(state.copyWith(error: 'Audio yuborishda xatolik'));
      return;
    }
    final serverPath = result.data!;

    _socket.emit('send_message', {
      'commentId': event.commentId,
      'type': 'audio',
      'mediaPath': serverPath,
    });
  }

  // ── Leave ─────────────────────────────────────────────────────

  void _onLeave(CommentLeave event, Emitter<CommentState> emit) {
    _socket?.emit('leave_comment', {'commentId': event.commentId});
    _typingTimer?.cancel();
    emit(const CommentState());
  }

  // ── Load more ────────────────────────────────────────────────

  Future<void> _onLoadMore(CommentLoadMore event, Emitter<CommentState> emit) async {
    if (state.isLoadingMore || !state.hasMore || !_socketReady) return;
    final nextPage = state.currentPage + 1;
    emit(state.copyWith(isLoadingMore: true, currentPage: nextPage));

    // Try local first
    final local = await chatRepository.getLocalMessages(
      event.commentId,
      page: nextPage,
      limit: _pageLimit,
    );
    if (local.isNotEmpty) {
      emit(state.copyWith(
        messages: [...state.messages, ...local],
        isLoadingMore: false,
        hasMore: local.length >= _pageLimit,
      ));
      return;
    }

    _socket.emit('load_history', {
      'commentId': event.commentId,
      'page': nextPage,
      'limit': _pageLimit,
    });
  }

  // ── Typing ────────────────────────────────────────────────────

  void _onTyping(CommentTyping event, Emitter<CommentState> emit) {
    if (!_socketReady) return;
    _socket.emit('typing', {'commentId': event.commentId});
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 3), () {
      _socket.emit('stop_typing', {'commentId': event.commentId});
    });
  }

  void _onStopTyping(CommentStopTyping event, Emitter<CommentState> emit) {
    _typingTimer?.cancel();
    if (_socketReady) _socket.emit('stop_typing', {'commentId': event.commentId});
  }

  // ── Incoming message ─────────────────────────────────────────

  Future<void> _onNewMessage(_NewMessage event, Emitter<CommentState> emit) async {
    final msg = event.message;
    final commentId = state.chatId;
    if (commentId == null) return;

    final list = List<MessageModel>.from(state.messages);

    // Replace optimistic
    final tempIdx = list.indexWhere((m) =>
        m.isSending &&
        m.type == msg.type &&
        (m.text == msg.text || m.mediaPath == msg.mediaPath));

    if (tempIdx != -1) {
      final tempId = list[tempIdx].id;
      await chatRepository.replaceTempMessage(commentId, tempId, msg);
      list[tempIdx] = msg;
    } else if (list.any((m) => m.id == msg.id)) {
      // Duplicate guard
      final idx = list.indexWhere((m) => m.id == msg.id);
      list[idx] = msg;
      await chatRepository.upsertLocalMessage(commentId, msg);
    } else {
      list.insert(0, msg);
      await chatRepository.saveLocalMessage(commentId, msg);
    }

    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    emit(state.copyWith(messages: list));

    // Lazy media download
    if ((msg.type == 'image' || msg.type == 'audio') &&
        msg.mediaPath != null &&
        (msg.localPath == null || msg.localPath!.isEmpty)) {
      _resolveMedia(msg, commentId);
    }
  }

  // ── History ───────────────────────────────────────────────────

  Future<void> _onHistoryReceived(
      _HistoryReceived event, Emitter<CommentState> emit) async {
    final commentId = state.chatId;
    if (commentId == null) return;

    final incoming = List<MessageModel>.from(event.messages)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final existing = List<MessageModel>.from(state.messages);
    final merged = _mergeMessages(existing, incoming);

    emit(state.copyWith(
      messages: merged,
      isLoading: false,
      isLoadingMore: false,
      hasMore: incoming.length >= _pageLimit,
    ));

    await chatRepository.saveLocalMessages(commentId, incoming);

    // Pre-fetch media
    for (final msg in merged.take(10)) {
      if ((msg.type == 'image' || msg.type == 'audio') &&
          msg.mediaPath != null &&
          (msg.localPath == null || msg.localPath!.isEmpty)) {
        _resolveMedia(msg, commentId);
      }
    }
  }

  void _onLocalLoaded(_LocalLoaded event, Emitter<CommentState> emit) {
    if (state.messages.isEmpty) {
      emit(state.copyWith(messages: event.messages));
    }
  }

  void _onPeerTyping(_PeerTyping event, Emitter<CommentState> emit) {
    final ids = Set<String>.from(state.typingUserIds);
    if (event.isTyping) {
      ids.add(event.userId);
    } else {
      ids.remove(event.userId);
    }
    emit(state.copyWith(typingUserIds: ids));
  }

  Future<void> _onMediaResolved(
      _MediaResolved event, Emitter<CommentState> emit) async {
    final list = List<MessageModel>.from(state.messages);
    final idx = list.indexWhere((m) => m.id == event.messageId);
    if (idx == -1) return;

    final updated = list[idx].copyWith(localPath: event.localPath);
    list[idx] = updated;
    emit(state.copyWith(messages: list));

    if (state.chatId != null) {
      await chatRepository.upsertLocalMessage(state.chatId!, updated);
    }
  }

  Future<void> _onStatusUpdated(
      _StatusUpdated event, Emitter<CommentState> emit) async {
    final commentId = state.chatId;
    if (commentId == null) return;

    final updated = state.messages.map((m) {
      if (m.commentId == event.commentId && m.status != 'SEEN') {
        return m.copyWith(status: 'SEEN');
      }
      return m;
    }).toList();

    emit(state.copyWith(messages: updated));

    for (final m in updated.where((m) => m.status == 'SEEN')) {
      await chatRepository.updateLocalMessageStatus(commentId, m.id, 'SEEN');
    }
  }

  // ── Helpers ───────────────────────────────────────────────────

  List<MessageModel> _mergeMessages(
    List<MessageModel> existing,
    List<MessageModel> incoming,
  ) {
    final map = <String, MessageModel>{for (final m in incoming) m.id: m};
    final merged = <MessageModel>[];

    for (final m in existing) {
      if (map.containsKey(m.id)) {
        merged.add(map.remove(m.id)!);
      } else {
        merged.add(m);
      }
    }
    merged.insertAll(0, map.values);
    merged.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return merged;
  }

  void _resolveMedia(MessageModel msg, String commentId) {
    final url = msg.mediaPath;
    if (url == null) return;
    chatRepository.getLocalMediaPath(url, msg.type).then((localPath) {
      if (localPath != null && !isClosed) {
        add(_MediaResolved(msg.id, localPath));
      }
    });
  }

  @override
  Future<void> close() {
    _typingTimer?.cancel();
    if (_socketReady) {
      _socket
        ..off('new_message')
        ..off('history')
        ..off('messages_seen')
        ..off('typing')
        ..off('stop_typing')
        ..off('connect');
      if (state.chatId != null) {
        _socket.emit('leave_comment', {'commentId': state.chatId});
      }
    }
    return super.close();
  }
}
