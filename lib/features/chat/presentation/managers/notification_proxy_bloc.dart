import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../notifications/data/repositories/notification_repository_impl.dart';
import '../../../notifications/presentation/managers/notification_bloc.dart';
import '../../../../core/services/notification_service.dart';

/// NotificationBloc requires an async token. This proxy fetches the token,
/// initializes the real NotificationBloc, and delegates all events/state.
/// Also handles FCM token registration with the backend after login.
class NotificationProxyBloc extends Cubit<NotificationState> {
  final NotificationRepositoryImpl repository;
  final AuthRepository authRepository;
  NotificationBloc? _notifBloc;
  NotificationBloc? get inner => _notifBloc;

  NotificationProxyBloc({
    required this.repository,
    required this.authRepository,
  }) : super(const NotificationState()) {
    _init();
  }

  Future<void> _init() async {
    final token = await authRepository.getToken() ?? '';
    if (token.isEmpty) return;

    // 1. WebSocket notification bilan NotificationBloc
    _notifBloc = NotificationBloc(repository: repository, token: token);
    _notifBloc!.stream.listen((s) => emit(s));
    _notifBloc!.add(NotificationStarted());

    // 2. FCM tokenni backendga yuborish
    // Hozircha 'client' role bilan (keyin profile'dan olish mumkin)
    await NotificationService().onUserLoggedIn(
      repository: repository,
      userRole: 'client',
    );
  }

  void markRead(String id) => _notifBloc?.add(NotificationMarkRead(id));
  void markAllRead() => _notifBloc?.add(NotificationMarkAllRead());
  void loadMore() => _notifBloc?.add(NotificationLoadMore());

  @override
  Future<void> close() {
    _notifBloc?.close();
    return super.close();
  }
}
