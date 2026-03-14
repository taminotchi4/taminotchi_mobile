import '../repositories/auth_repository.dart';
import '../../data/models/verify_otp_model.dart';

class VerifyOtpUseCase {
  final AuthRepository _repository;

  VerifyOtpUseCase(this._repository);

  Future<VerifyOtpResponse> call({
    required String phoneNumber,
    required String code,
  }) async {
    return await _repository.verifyOtp(
      phoneNumber: phoneNumber,
      code: code,
    );
  }
}
