import '../../../../core/network/client.dart';
import '../models/client_profile_model.dart';
import '../../domain/entities/client_profile_entity.dart';

abstract class ClientProfileRemoteDataSource {
  Future<ClientProfileEntity> getProfile();
  Future<ClientProfileEntity> updateProfile(ClientProfileEntity profile);
  Future<String?> uploadPhoto(String imagePath);
}

class ClientProfileRemoteDataSourceImpl implements ClientProfileRemoteDataSource {
  final ApiClient client;

  ClientProfileRemoteDataSourceImpl({required this.client});

  @override
  Future<ClientProfileEntity> getProfile() async {
    final result = await client.get<Map<String, dynamic>>('client/me/profile');
    return result.fold(
      (error) => throw error,
      (data) {
        final profileData = data['data'] as Map<String, dynamic>;
        return ClientProfileModel.fromJson(profileData);
      },
    );
  }

  @override
  Future<ClientProfileEntity> updateProfile(ClientProfileEntity profile) async {
    final result = await client.patch<Map<String, dynamic>>(
      'client/me/profile',
      data: {
        'fullName': profile.name,
        'username': profile.username,
        'language': profile.language,
      },
    );
    return result.fold(
      (error) => throw error,
      (data) {
        final profileData = data['data'] as Map<String, dynamic>;
        return ClientProfileModel.fromJson(profileData);
      },
    );
  }

  @override
  Future<String?> uploadPhoto(String imagePath) async {
    // This might need FormData, but for now let's keep it simple or implement if needed
    // The previous local version just returned imagePath
    return imagePath;
  }
}
