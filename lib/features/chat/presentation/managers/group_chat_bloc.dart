import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/socket_manager.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../data/models/message_model.dart';
import '../../data/models/group_model.dart';

// --- Events ---
abstract class GroupChatEvent {
  const GroupChatEvent();
}

class GroupChatStarted extends GroupChatEvent {
  final String groupId;
  const GroupChatStarted(this.groupId);
}

class GroupChatSendMessage extends GroupChatEvent {
  final String groupId;
  final String text;
  final String type;
  final String? mediaPath;
  final String? replyToId;
  const GroupChatSendMessage({
    required this.groupId,
    required this.text,
    this.type = 'text',
    this.mediaPath,
    this.replyToId,
  });
}

class GroupChatTyping extends GroupChatEvent {
  final String groupId;
  const GroupChatTyping(this.groupId);
}

// --- State ---
class GroupChatState {
  final List<MessageModel> messages;
  final bool isLoading;
  final GroupModel? group;
  final String? error;
  final List<String> typingUsers;

  GroupChatState({
    this.messages = const [],
    this.isLoading = false,
    this.group,
    this.error,
    this.typingUsers = const [],
  });

  GroupChatState copyWith({
    List<MessageModel>? messages,
    bool? isLoading,
    GroupModel? group,
    String? error,
    List<String>? typingUsers,
  }) {
    return GroupChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      group: group ?? this.group,
      error: error,
      typingUsers: typingUsers ?? this.typingUsers,
    );
  }
}

// --- Bloc ---
class GroupChatBloc extends Bloc<GroupChatEvent, GroupChatState> {
  final ChatRepository repository;
  final AuthRepository authRepository;
  dynamic _socket;
  bool _socketReady = false;

  GroupChatBloc({required this.repository, required this.authRepository})
      : super(GroupChatState()) {
    on<GroupChatStarted>(_onStarted);
    on<_NewGroupMessage>((event, emit) {
      emit(state.copyWith(messages: [...state.messages, event.message]));
    });
    on<GroupChatSendMessage>((event, emit) {
      if (!_socketReady) return;
      _socket.emit('send_message', {
        'groupId': event.groupId,
        'type': event.type,
        'text': event.text,
        if (event.mediaPath != null) 'mediaPath': event.mediaPath,
        if (event.replyToId != null) 'replyToId': event.replyToId,
      });
    });
    on<GroupChatTyping>((event, emit) {
      if (!_socketReady) return;
      _socket.emit('typing', {'groupId': event.groupId});
    });
    on<_UserTyping>((event, emit) {
      final updated = List<String>.from(state.typingUsers);
      if (event.isTyping) {
        if (!updated.contains(event.userName)) updated.add(event.userName);
      } else {
        updated.remove(event.userName);
      }
      emit(state.copyWith(typingUsers: updated));
    });
    on<_UpdateGroupHistory>((event, emit) {
      emit(state.copyWith(messages: event.messages, isLoading: false));
    });
  }

  Future<void> _onStarted(GroupChatStarted event, Emitter<GroupChatState> emit) async {
    emit(state.copyWith(isLoading: true));

    final token = await authRepository.getToken() ?? '';
    _socket = ChatSocketManager.connect('/group-chat', token);
    _socketReady = true;

    _socket.on('new_message', (data) {
      final msg = MessageModel.fromJson(data);
      if (msg.groupId == state.group?.id) add(_NewGroupMessage(msg));
    });
    _socket.on('typing', (data) {
      if (data['groupId'] == state.group?.id) {
        add(_UserTyping(data['userName'] ?? 'Kimdir', true));
      }
    });
    _socket.on('stop_typing', (data) {
      if (data['groupId'] == state.group?.id) {
        add(_UserTyping(data['userName'] ?? 'Kimdir', false));
      }
    });
    _socket.on('history', (data) {
      final List<dynamic> history = data['data'];
      final messages = history.map((e) => MessageModel.fromJson(e)).toList();
      add(_UpdateGroupHistory(messages));
    });

    final result = await repository.getGroupById(event.groupId);
    result.fold(
      (error) => emit(state.copyWith(isLoading: false, error: error.toString())),
      (group) {
        emit(state.copyWith(group: group, isLoading: true));
        _socket.emit('load_history', {'groupId': group.id, 'page': 1, 'limit': 30});
      },
    );
  }

  @override
  Future<void> close() {
    if (_socketReady) {
      _socket.off('new_message');
      _socket.off('typing');
      _socket.off('stop_typing');
      _socket.off('history');
    }
    return super.close();
  }
}

class _NewGroupMessage extends GroupChatEvent {
  final MessageModel message;
  _NewGroupMessage(this.message);
}

class _UserTyping extends GroupChatEvent {
  final String userName;
  final bool isTyping;
  _UserTyping(this.userName, this.isTyping);
}

class _UpdateGroupHistory extends GroupChatEvent {
  final List<MessageModel> messages;
  _UpdateGroupHistory(this.messages);
}
