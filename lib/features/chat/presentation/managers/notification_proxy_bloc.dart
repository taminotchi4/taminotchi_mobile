import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../notifications/data/repositories/notification_repository_impl.dart';
import '../../../notifications/presentation/managers/notification_bloc.dart';

/// NotificationBloc requires a token, which is async. This proxy bloc
/// initializes the real NotificationBloc once the token is fetched,
/// and delegates all events/state access through it.
/// 
/// Usage: Access actual NotificationBloc via the app-level state or simply
/// provide it lazily when needed, initialized from the shell route.
class NotificationProxyBloc extends Cubit<NotificationState> {
  final NotificationRepositoryImpl repository;
  final AuthRepository authRepository;
  NotificationBloc? _notifBloc;
  NotificationBloc? get inner => _notifBloc;

  NotificationProxyBloc({
    required this.repository,
    required this.authRepository,
  }) : super(NotificationState()) {
    _init();
  }

  Future<void> _init() async {
    final token = await authRepository.getToken() ?? '';
    _notifBloc = NotificationBloc(repository: repository, token: token);
    _notifBloc!.stream.listen((s) => emit(s));
    _notifBloc!.add(NotificationStarted());
  }

  void markRead(String id) => _notifBloc?.add(NotificationMarkRead(id));
  void markAllRead() => _notifBloc?.add(NotificationMarkAllRead());

  @override
  Future<void> close() {
    _notifBloc?.close();
    return super.close();
  }
}
