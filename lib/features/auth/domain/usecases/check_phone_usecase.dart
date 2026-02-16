import '../repositories/auth_repository.dart';
import '../../data/models/check_phone_model.dart';

class CheckPhoneUseCase {
  final AuthRepository _repository;

  CheckPhoneUseCase(this._repository);

  Future<CheckPhoneResponse> call(String phoneNumber) async {
    return await _repository.checkPhone(phoneNumber);
  }
}
