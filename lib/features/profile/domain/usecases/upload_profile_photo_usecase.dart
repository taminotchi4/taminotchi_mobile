import '../repositories/client_profile_repository.dart';

class UploadProfilePhotoUseCase {
  final ClientProfileRepository repository;

  UploadProfilePhotoUseCase(this.repository);

  Future<String?> call(String imagePath) {
    return repository.uploadPhoto(imagePath);
  }
}
