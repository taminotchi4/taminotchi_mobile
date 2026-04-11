import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/socket_manager.dart';
import '../../data/models/notification_model.dart';
import '../../data/repositories/notification_repository_impl.dart';

// ─── Events ───────────────────────────────────────────────────────────────────
abstract class NotificationEvent {
  const NotificationEvent();
}

class NotificationStarted extends NotificationEvent {}

class NotificationMarkRead extends NotificationEvent {
  final String id;
  const NotificationMarkRead(this.id);
}

class NotificationMarkAllRead extends NotificationEvent {}

class NotificationLoadMore extends NotificationEvent {}

class _NewNotification extends NotificationEvent {
  final NotificationModel notification;
  const _NewNotification(this.notification);
}

class _UnreadCountUpdated extends NotificationEvent {
  final int count;
  const _UnreadCountUpdated(this.count);
}

// ─── State ────────────────────────────────────────────────────────────────────
class NotificationState {
  final List<NotificationModel> notifications;
  final int unreadCount;
  final bool isLoading;
  final bool hasMore;
  final int currentPage;

  const NotificationState({
    this.notifications = const [],
    this.unreadCount = 0,
    this.isLoading = false,
    this.hasMore = true,
    this.currentPage = 1,
  });

  NotificationState copyWith({
    List<NotificationModel>? notifications,
    int? unreadCount,
    bool? isLoading,
    bool? hasMore,
    int? currentPage,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

// ─── Bloc ─────────────────────────────────────────────────────────────────────
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepositoryImpl repository;
  final String token;
  late final dynamic _socket;

  NotificationBloc({required this.repository, required this.token})
      : super(const NotificationState()) {
    // WebSocket ulanish — /notification namespace
    _socket = ChatSocketManager.connect('/notification', 'Bearer $token');

    // ── WebSocket: yangi notification ──────────────────────────────────────
    _socket.on('notification', (data) {
      try {
        final map = data is Map<String, dynamic>
            ? data
            : Map<String, dynamic>.from(data as Map);
        add(_NewNotification(NotificationModel.fromJson(map)));
      } catch (e) {
        debugPrint('❌ Notification parse xatosi: $e');
      }
    });

    // ── WebSocket: o'qilmagan soni yangilandi ──────────────────────────────
    _socket.on('unread_count', (data) {
      try {
        final map = data is Map ? data : {};
        final count = (map['count'] as num?)?.toInt() ?? 0;
        add(_UnreadCountUpdated(count));
      } catch (e) {
        debugPrint('❌ unread_count parse xatosi: $e');
      }
    });

    // ── Event handlers ─────────────────────────────────────────────────────
    on<NotificationStarted>(_onStarted);
    on<_NewNotification>(_onNewNotification);
    on<_UnreadCountUpdated>(_onUnreadCountUpdated);
    on<NotificationMarkRead>(_onMarkRead);
    on<NotificationMarkAllRead>(_onMarkAllRead);
    on<NotificationLoadMore>(_onLoadMore);
  }

  // Ishga tushganda: unread count + birinchi sahifa
  Future<void> _onStarted(
    NotificationStarted event,
    Emitter<NotificationState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    final results = await Future.wait([
      repository.getUnreadCount(),
      repository.getNotifications(page: 1),
    ]);

    int unread = state.unreadCount;
    results[0].fold((e) {}, (count) => unread = count as int);

    results[1].fold(
      (error) => emit(state.copyWith(isLoading: false)),
      (list) {
        final notifications = list as List<NotificationModel>;
        emit(state.copyWith(
          notifications: notifications,
          unreadCount: unread,
          isLoading: false,
          hasMore: notifications.length >= 20,
          currentPage: 1,
        ));
      },
    );
  }

  // Yangi notification WebSocket dan keldi
  void _onNewNotification(
    _NewNotification event,
    Emitter<NotificationState> emit,
  ) {
    emit(state.copyWith(
      notifications: [event.notification, ...state.notifications],
      unreadCount: state.unreadCount + 1,
    ));
  }

  // Server o'qilmagan sonini yangiladi
  void _onUnreadCountUpdated(
    _UnreadCountUpdated event,
    Emitter<NotificationState> emit,
  ) {
    emit(state.copyWith(unreadCount: event.count));
  }

  // Bitta notification o'qildi
  Future<void> _onMarkRead(
    NotificationMarkRead event,
    Emitter<NotificationState> emit,
  ) async {
    await repository.markRead(event.id);
    final updated = state.notifications.map((n) {
      return n.id == event.id ? n.copyWith(isRead: true) : n;
    }).toList();
    emit(state.copyWith(
      notifications: updated,
      unreadCount: (state.unreadCount - 1).clamp(0, 9999),
    ));
  }

  // Barchasini o'qildi
  Future<void> _onMarkAllRead(
    NotificationMarkAllRead event,
    Emitter<NotificationState> emit,
  ) async {
    await repository.markAllRead();
    final updated = state.notifications.map((n) => n.copyWith(isRead: true)).toList();
    emit(state.copyWith(notifications: updated, unreadCount: 0));
  }

  // Ko'proq yuklash (pagination)
  Future<void> _onLoadMore(
    NotificationLoadMore event,
    Emitter<NotificationState> emit,
  ) async {
    if (!state.hasMore || state.isLoading) return;
    final nextPage = state.currentPage + 1;
    emit(state.copyWith(isLoading: true));
    final result = await repository.getNotifications(page: nextPage);
    result.fold(
      (error) => emit(state.copyWith(isLoading: false)),
      (list) => emit(state.copyWith(
        notifications: [...state.notifications, ...list],
        isLoading: false,
        hasMore: list.length >= 20,
        currentPage: nextPage,
      )),
    );
  }

  @override
  Future<void> close() {
    _socket.off('notification');
    _socket.off('unread_count');
    return super.close();
  }
}
