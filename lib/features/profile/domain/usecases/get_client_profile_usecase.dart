import '../entities/client_profile_entity.dart';
import '../repositories/client_profile_repository.dart';

class GetClientProfileUseCase {
  final ClientProfileRepository repository;

  GetClientProfileUseCase(this.repository);

  Future<ClientProfileEntity> call() {
    return repository.getProfile();
  }
}
