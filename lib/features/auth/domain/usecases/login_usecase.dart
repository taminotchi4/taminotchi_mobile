import '../repositories/auth_repository.dart';
import '../../data/models/login_model.dart';

class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<LoginResponse> call({
    required String phoneNumber,
    required String password,
  }) async {
    return await _repository.login(
      phoneNumber: phoneNumber,
      password: password,
    );
  }
}
