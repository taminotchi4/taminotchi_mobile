import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/socket_manager.dart';
import '../../data/models/message_model.dart';

// --- Events ---
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
  final String mediaPath;
  final String? replyToId;
  const CommentSendImage({
    required this.commentId,
    required this.mediaPath,
    this.replyToId,
  });
}

class CommentLeave extends CommentEvent {
  final String commentId;
  const CommentLeave(this.commentId);
}

class CommentLoadMoreHistory extends CommentEvent {
  final String commentId;
  const CommentLoadMoreHistory(this.commentId);
}

class CommentTyping extends CommentEvent {
  final String commentId;
  const CommentTyping(this.commentId);
}

class CommentStopTyping extends CommentEvent {
  final String commentId;
  const CommentStopTyping(this.commentId);
}

// Internal
class _NewComment extends CommentEvent {
  final MessageModel comment;
  _NewComment(this.comment);
}

class _UpdateHistory extends CommentEvent {
  final List<MessageModel> comments;
  final bool prepend;
  _UpdateHistory(this.comments, {this.prepend = false});
}

class _OtherUserTyping extends CommentEvent {
  final String userId;
  final bool isTyping;
  _OtherUserTyping(this.userId, this.isTyping);
}

// --- State ---
class CommentState {
  final List<MessageModel> comments;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int currentPage;
  final String? error;
  final Set<String> typingUserIds;

  const CommentState({
    this.comments = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.currentPage = 1,
    this.error,
    this.typingUserIds = const {},
  });

  CommentState copyWith({
    List<MessageModel>? comments,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? currentPage,
    String? error,
    Set<String>? typingUserIds,
  }) {
    return CommentState(
      comments: comments ?? this.comments,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      error: error,
      typingUserIds: typingUserIds ?? this.typingUserIds,
    );
  }
}

// --- Bloc ---
class CommentBloc extends Bloc<CommentEvent, CommentState> {
  static const int _pageLimit = 30;

  final String token;
  late final dynamic _socket;
  Timer? _typingTimer;

  CommentBloc({required this.token}) : super(const CommentState()) {
    _socket = ChatSocketManager.connect('/comment-chat', token);

    // Listen for new messages
    _socket.on('new_message', (data) {
      try {
        final msg = MessageModel.fromJson(data as Map<String, dynamic>);
        add(_NewComment(msg));
      } catch (_) {}
    });

    // Listen for history
    _socket.on('history', (data) {
      try {
        final List<dynamic> history = (data as Map<String, dynamic>)['data'] ?? [];
        final messages = history.map((e) => MessageModel.fromJson(e as Map<String, dynamic>)).toList();
        add(_UpdateHistory(messages, prepend: state.currentPage > 1));
      } catch (_) {}
    });

    // Typing indicators
    _socket.on('typing', (data) {
      try {
        final userId = (data as Map<String, dynamic>)['userId'] as String? ?? '';
        if (userId.isNotEmpty) add(_OtherUserTyping(userId, true));
      } catch (_) {}
    });

    _socket.on('stop_typing', (data) {
      try {
        final userId = (data as Map<String, dynamic>)['userId'] as String? ?? '';
        if (userId.isNotEmpty) add(_OtherUserTyping(userId, false));
      } catch (_) {}
    });

    on<CommentJoin>(_onJoin);
    on<CommentSendMessage>(_onSendMessage);
    on<CommentSendImage>(_onSendImage);
    on<CommentLeave>(_onLeave);
    on<CommentLoadMoreHistory>(_onLoadMore);
    on<CommentTyping>(_onTyping);
    on<CommentStopTyping>(_onStopTyping);
    on<_NewComment>(_onNewComment);
    on<_UpdateHistory>(_onUpdateHistory);
    on<_OtherUserTyping>(_onOtherUserTyping);
  }

  void _onJoin(CommentJoin event, Emitter<CommentState> emit) {
    emit(state.copyWith(isLoading: true, comments: [], currentPage: 1, hasMore: true));
    _socket.emit('join_comment', {'commentId': event.commentId});

    _socket.once('joined', (data) {
      _socket.emit('load_history', {
        'commentId': event.commentId,
        'page': 1,
        'limit': _pageLimit,
      });
    });
  }

  void _onSendMessage(CommentSendMessage event, Emitter<CommentState> emit) {
    _socket.emit('send_message', {
      'commentId': event.commentId,
      'type': 'text',
      'text': event.text,
      if (event.replyToId != null) 'replyToId': event.replyToId,
    });
  }

  void _onSendImage(CommentSendImage event, Emitter<CommentState> emit) {
    _socket.emit('send_message', {
      'commentId': event.commentId,
      'type': 'image',
      'mediaPath': event.mediaPath,
      if (event.replyToId != null) 'replyToId': event.replyToId,
    });
  }

  void _onLeave(CommentLeave event, Emitter<CommentState> emit) {
    _socket.emit('leave_comment', {'commentId': event.commentId});
    _typingTimer?.cancel();
    emit(const CommentState());
  }

  void _onLoadMore(CommentLoadMoreHistory event, Emitter<CommentState> emit) {
    if (state.isLoadingMore || !state.hasMore) return;
    final nextPage = state.currentPage + 1;
    emit(state.copyWith(isLoadingMore: true, currentPage: nextPage));
    _socket.emit('load_history', {
      'commentId': event.commentId,
      'page': nextPage,
      'limit': _pageLimit,
    });
  }

  void _onTyping(CommentTyping event, Emitter<CommentState> emit) {
    _socket.emit('typing', {'commentId': event.commentId});
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), () {
      _socket.emit('stop_typing', {'commentId': event.commentId});
    });
  }

  void _onStopTyping(CommentStopTyping event, Emitter<CommentState> emit) {
    _typingTimer?.cancel();
    _socket.emit('stop_typing', {'commentId': event.commentId});
  }

  void _onNewComment(_NewComment event, Emitter<CommentState> emit) {
    emit(state.copyWith(comments: [...state.comments, event.comment]));
  }

  void _onUpdateHistory(_UpdateHistory event, Emitter<CommentState> emit) {
    final hasMore = event.comments.length >= _pageLimit;
    if (event.prepend) {
      emit(state.copyWith(
        comments: [...event.comments, ...state.comments],
        isLoadingMore: false,
        hasMore: hasMore,
      ));
    } else {
      emit(state.copyWith(
        comments: event.comments,
        isLoading: false,
        hasMore: hasMore,
      ));
    }
  }

  void _onOtherUserTyping(_OtherUserTyping event, Emitter<CommentState> emit) {
    final typingIds = Set<String>.from(state.typingUserIds);
    if (event.isTyping) {
      typingIds.add(event.userId);
    } else {
      typingIds.remove(event.userId);
    }
    emit(state.copyWith(typingUserIds: typingIds));
  }

  @override
  Future<void> close() {
    _typingTimer?.cancel();
    _socket.off('new_message');
    _socket.off('history');
    _socket.off('typing');
    _socket.off('stop_typing');
    _socket.off('joined');
    return super.close();
  }
}
