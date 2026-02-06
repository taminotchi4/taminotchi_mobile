import '../entities/client_profile_entity.dart';
import '../repositories/client_profile_repository.dart';

class UpdateClientProfileUseCase {
  final ClientProfileRepository repository;

  UpdateClientProfileUseCase(this.repository);

  Future<ClientProfileEntity> call(ClientProfileEntity profile) {
    return repository.updateProfile(profile);
  }
}
