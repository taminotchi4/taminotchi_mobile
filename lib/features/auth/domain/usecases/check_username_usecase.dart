import '../repositories/auth_repository.dart';
import '../../data/models/check_username_model.dart';

class CheckUsernameUseCase {
  final AuthRepository _repository;

  CheckUsernameUseCase(this._repository);

  Future<CheckUsernameResponse> call(String username) async {
    return await _repository.checkUsername(username);
  }
}
