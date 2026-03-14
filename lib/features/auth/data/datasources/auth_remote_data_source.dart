import '../../../../core/network/client.dart';
import '../../../../core/utils/result.dart';
import '../models/check_phone_model.dart';
import '../models/request_otp_model.dart';
import '../models/verify_otp_model.dart';
import '../models/complete_register_model.dart';
import '../models/login_model.dart';

class AuthRemoteDataSource {
  final ApiClient _client;

  AuthRemoteDataSource({required ApiClient client}) : _client = client;

  Future<Result<CheckPhoneResponse>> checkPhone(String phoneNumber) async {
    // URL encode the phone number for the path parameter
    final encodedPhone = Uri.encodeComponent(phoneNumber);
    
    final result = await _client.get<Map<String, dynamic>>(
      'client/check-phone/$encodedPhone',
    );

    return result.fold(
      (error) {
        print('❌ Error in checkPhone: $error');
        return Result.error(error);
      },
      (data) {
        print('🔍 Raw API response for checkPhone: $data');
        try {
          final response = CheckPhoneResponse.fromJson(data);
          print('📱 Parsed response: exists = ${response.exists}');
          return Result.ok(response);
        } catch (e) {
          print('❌ Error parsing checkPhone response: $e');
          return Result.error(Exception('Failed to parse response: $e'));
        }
      },
    );
  }

  Future<Result<RequestOtpResponse>> requestOtp(String phoneNumber) async {
    final result = await _client.post<Map<String, dynamic>>(
      'client/register/request-otp',
      data: RequestOtpRequest(phoneNumber: phoneNumber).toJson(),
    );

    return result.fold(
      (error) => Result.error(error),
      (data) {
        try {
          return Result.ok(RequestOtpResponse.fromJson(data));
        } catch (e) {
          return Result.error(Exception('Failed to parse response: $e'));
        }
      },
    );
  }

  Future<Result<VerifyOtpResponse>> verifyOtp({
    required String phoneNumber,
    required String code,
  }) async {
    final result = await _client.post<Map<String, dynamic>>(
      'client/register/verify-otp',
      data: VerifyOtpRequest(
        phoneNumber: phoneNumber,
        code: code,
      ).toJson(),
    );

    return result.fold(
      (error) => Result.error(error),
      (data) {
        try {
          return Result.ok(VerifyOtpResponse.fromJson(data));
        } catch (e) {
          return Result.error(Exception('Failed to parse response: $e'));
        }
      },
    );
  }

  Future<Result<CompleteRegisterResponse>> completeRegister({
    required String phoneNumber,
    required String fullName,
    required String username,
    required String password,
    required String language,
  }) async {
    final result = await _client.post<Map<String, dynamic>>(
      'client/register/complete',
      data: CompleteRegisterRequest(
        phoneNumber: phoneNumber,
        fullName: fullName,
        username: username,
        password: password,
        language: language,
      ).toJson(),
    );

    return result.fold(
      (error) => Result.error(error),
      (data) {
        try {
          return Result.ok(CompleteRegisterResponse.fromJson(data));
        } catch (e) {
          return Result.error(Exception('Failed to parse response: $e'));
        }
      },
    );
  }

  Future<Result<LoginResponse>> login({
    required String phoneNumber,
    required String password,
  }) async {
    final result = await _client.post<Map<String, dynamic>>(
      'client/login',
      data: LoginRequest(
        phoneNumber: phoneNumber,
        password: password,
      ).toJson(),
    );

    return result.fold(
      (error) => Result.error(error),
      (data) {
        try {
          return Result.ok(LoginResponse.fromJson(data));
        } catch (e) {
          return Result.error(Exception('Failed to parse response: $e'));
        }
      },
    );
  }
}
