import '../../data/models/check_phone_model.dart';
import '../../data/models/request_otp_model.dart';
import '../../data/models/verify_otp_model.dart';
import '../../data/models/complete_register_model.dart';
import '../../data/models/login_model.dart';

abstract class AuthRepository {
  Future<CheckPhoneResponse> checkPhone(String phoneNumber);
  
  Future<RequestOtpResponse> requestOtp(String phoneNumber);
  
  Future<VerifyOtpResponse> verifyOtp({
    required String phoneNumber,
    required String code,
  });
  
  Future<CompleteRegisterResponse> completeRegister({
    required String phoneNumber,
    required String fullName,
    required String username,
    required String password,
    required String language,
  });
  
  Future<LoginResponse> login({
    required String phoneNumber,
    required String password,
  });
}
