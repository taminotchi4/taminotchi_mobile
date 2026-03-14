import '../../domain/entities/client_profile_entity.dart';

class ClientProfileLocalDataSource {
  ClientProfileEntity? _profile;

  ClientProfileLocalDataSource() {
    _profile = const ClientProfileEntity(
      id: 'user_1',
      name: 'Alisher Karimov',
      username: '@alisher_k',
      phone: '+998 90 123 45 67',
      language: 'uz',
    );
  }

  Future<ClientProfileEntity> getProfile() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _profile!;
  }

  Future<ClientProfileEntity> updateProfile(ClientProfileEntity profile) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _profile = profile;
    return _profile!;
  }

  Future<String?> uploadPhoto(String imagePath) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return imagePath;
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
  }
}
