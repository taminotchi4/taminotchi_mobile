import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/socket_manager.dart';
import '../../data/models/notification_model.dart';
import '../../data/repositories/notification_repository_impl.dart';

// --- Events ---
abstract class NotificationEvent {
  const NotificationEvent();
}

class NotificationStarted extends NotificationEvent {}

class NotificationMarkRead extends NotificationEvent {
  final String id;
  const NotificationMarkRead(this.id);
}

class NotificationMarkAllRead extends NotificationEvent {}

class _NewNotification extends NotificationEvent {
  final NotificationModel notification;
  const _NewNotification(this.notification);
}

// --- State ---
class NotificationState {
  final List<NotificationModel> notifications;
  final int unreadCount;
  final bool isLoading;

  NotificationState({
    this.notifications = const [],
    this.unreadCount = 0,
    this.isLoading = false,
  });

  NotificationState copyWith({
    List<NotificationModel>? notifications,
    int? unreadCount,
    bool? isLoading,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// --- Bloc ---
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepositoryImpl repository;
  final String token;
  late final dynamic _socket;

  NotificationBloc({required this.repository, required this.token}) : super(NotificationState()) {
    _socket = ChatSocketManager.connect('/notification', token);

    _socket.on('notification', (data) {
      final notif = NotificationModel.fromJson(data);
      add(_NewNotification(notif));
    });

    on<NotificationStarted>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      final unreadResult = await repository.getUnreadCount();
      final listResult = await repository.getNotifications();

      int unread = state.unreadCount;
      unreadResult.fold((_) {}, (count) => unread = count);

      listResult.fold(
        (error) => emit(state.copyWith(isLoading: false)),
        (list) => emit(state.copyWith(
          notifications: list,
          unreadCount: unread,
          isLoading: false,
        )),
      );
    });

    on<_NewNotification>((event, emit) {
      emit(state.copyWith(
        notifications: [event.notification, ...state.notifications],
        unreadCount: state.unreadCount + 1,
      ));
    });

    on<NotificationMarkRead>((event, emit) async {
      await repository.markRead(event.id);
      final updated = state.notifications.map((n) {
        if (n.id == event.id) {
          // Note: NotificationModel is immutable, in real app we'd have copyWith
          // For now, reload or just decrement count
        }
        return n;
      }).toList();
      emit(state.copyWith(unreadCount: (state.unreadCount - 1).clamp(0, 999)));
    });

    on<NotificationMarkAllRead>((event, emit) async {
      await repository.markAllRead();
      emit(state.copyWith(unreadCount: 0));
    });
  }

  @override
  Future<void> close() {
    _socket.off('notification');
    return super.close();
  }
}
