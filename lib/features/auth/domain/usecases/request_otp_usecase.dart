import '../repositories/auth_repository.dart';
import '../../data/models/request_otp_model.dart';

class RequestOtpUseCase {
  final AuthRepository _repository;

  RequestOtpUseCase(this._repository);

  Future<RequestOtpResponse> call(String phoneNumber) async {
    return await _repository.requestOtp(phoneNumber);
  }
}
