import '../repositories/client_profile_repository.dart';

class DeleteAccountUseCase {
  final ClientProfileRepository repository;

  const DeleteAccountUseCase(this.repository);

  Future<void> call() async {
    await repository.deleteAccount();
  }
}
