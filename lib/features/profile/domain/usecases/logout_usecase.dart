import '../repositories/client_profile_repository.dart';

class LogoutUseCase {
  final ClientProfileRepository repository;

  LogoutUseCase(this.repository);

  Future<void> call() {
    return repository.logout();
  }
}
