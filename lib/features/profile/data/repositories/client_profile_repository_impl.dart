import '../../domain/entities/client_profile_entity.dart';
import '../../domain/repositories/client_profile_repository.dart';
import '../datasources/client_profile_local_data_source.dart';
import '../datasources/client_profile_remote_data_source.dart';

class ClientProfileRepositoryImpl implements ClientProfileRepository {
  final ClientProfileLocalDataSource localDataSource;
  final ClientProfileRemoteDataSource remoteDataSource;

  ClientProfileRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<ClientProfileEntity> getProfile() async {
    try {
      final profile = await remoteDataSource.getProfile();
      await localDataSource.updateProfile(profile);
      return profile;
    } catch (_) {
      return localDataSource.getProfile();
    }
  }

  @override
  Future<ClientProfileEntity> updateProfile(ClientProfileEntity profile) async {
    final updatedProfile = await remoteDataSource.updateProfile(profile);
    await localDataSource.updateProfile(updatedProfile);
    return updatedProfile;
  }

  @override
  Future<String?> uploadPhoto(String imagePath) {
    return remoteDataSource.uploadPhoto(imagePath);
  }

  @override
  Future<void> logout() async {
    await localDataSource.logout();
  }

  @override
  Future<void> deleteAccount() async {
    await remoteDataSource.deleteAccount();
    await localDataSource.logout();
  }
}
