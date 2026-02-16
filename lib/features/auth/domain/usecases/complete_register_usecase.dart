import '../repositories/auth_repository.dart';
import '../../data/models/complete_register_model.dart';

class CompleteRegisterUseCase {
  final AuthRepository _repository;

  CompleteRegisterUseCase(this._repository);

  Future<CompleteRegisterResponse> call({
    required String phoneNumber,
    required String fullName,
    required String username,
    required String password,
    required String language,
  }) async {
    return await _repository.completeRegister(
      phoneNumber: phoneNumber,
      fullName: fullName,
      username: username,
      password: password,
      language: language,
    );
  }
}
