import '../../domain/entities/client_profile_entity.dart';
import '../../domain/repositories/client_profile_repository.dart';
import '../datasources/client_profile_local_data_source.dart';

class ClientProfileRepositoryImpl implements ClientProfileRepository {
  final ClientProfileLocalDataSource dataSource;

  ClientProfileRepositoryImpl(this.dataSource);

  @override
  Future<ClientProfileEntity> getProfile() {
    return dataSource.getProfile();
  }

  @override
  Future<ClientProfileEntity> updateProfile(ClientProfileEntity profile) {
    return dataSource.updateProfile(profile);
  }

  @override
  Future<String?> uploadPhoto(String imagePath) {
    return dataSource.uploadPhoto(imagePath);
  }

  @override
  Future<void> logout() {
    return dataSource.logout();
  }
}
