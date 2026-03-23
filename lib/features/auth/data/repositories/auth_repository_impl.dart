import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/check_phone_model.dart';
import '../models/request_otp_model.dart';
import '../models/verify_otp_model.dart';
import '../models/complete_register_model.dart';
import '../models/login_model.dart';
import '../models/check_username_model.dart';
import '../datasources/auth_local_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<CheckPhoneResponse> checkPhone(String phoneNumber) async {
    final result = await _remoteDataSource.checkPhone(phoneNumber);
    return result.fold(
      (error) => throw error,
      (response) => response,
    );
  }
  
  @override
  Future<CheckUsernameResponse> checkUsername(String username) async {
    final result = await _remoteDataSource.checkUsername(username);
    return result.fold(
      (error) => throw error,
      (response) => response,
    );
  }

  @override
  Future<RequestOtpResponse> requestOtp(String phoneNumber) async {
    final result = await _remoteDataSource.requestOtp(phoneNumber);
    return result.fold(
      (error) => throw error,
      (response) => response,
    );
  }

  @override
  Future<VerifyOtpResponse> verifyOtp({
    required String phoneNumber,
    required String code,
  }) async {
    final result = await _remoteDataSource.verifyOtp(
      phoneNumber: phoneNumber,
      code: code,
    );
    return result.fold(
      (error) => throw error,
      (response) => response,
    );
  }

  @override
  Future<CompleteRegisterResponse> completeRegister({
    required String phoneNumber,
    required String fullName,
    required String username,
    required String password,
    required String language,
  }) async {
    final result = await _remoteDataSource.completeRegister(
      phoneNumber: phoneNumber,
      fullName: fullName,
      username: username,
      password: password,
      language: language,
    );
    return result.fold(
      (error) => throw error,
      (response) async {
        if (response.accessToken != null) {
          await _localDataSource.saveToken(response.accessToken!);
          await _localDataSource.saveUserId(response.user.id);
          // Save for AuthInterceptor
          await _localDataSource.saveUserData(
            username: response.user.username,
            password: password,
          );
        }
        return response;
      },
    );
  }

  @override
  Future<LoginResponse> login({
    required String phoneNumber,
    required String password,
  }) async {
    final result = await _remoteDataSource.login(
      phoneNumber: phoneNumber,
      password: password,
    );
    return result.fold(
      (error) => throw error,
      (response) async {
        await _localDataSource.saveToken(response.accessToken);
        await _localDataSource.saveUserId(response.user.id);
        // Save these for AuthInterceptor's auto-refresh logic
        await _localDataSource.saveUserData(
          username: response.username,
          password: password,
        );
        return response;
      },
    );
  }

  @override
  Future<String?> getToken() async {
    return await _localDataSource.getToken();
  }

  @override
  Future<String?> getUserId() async {
    return await _localDataSource.getUserId();
  }
}
