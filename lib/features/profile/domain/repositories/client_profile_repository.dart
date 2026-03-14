import '../entities/client_profile_entity.dart';

abstract class ClientProfileRepository {
  Future<ClientProfileEntity> getProfile();
  Future<ClientProfileEntity> updateProfile(ClientProfileEntity profile);
  Future<String?> uploadPhoto(String imagePath);
  Future<void> logout();
}
