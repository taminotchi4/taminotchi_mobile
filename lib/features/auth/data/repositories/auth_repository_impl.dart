import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/check_phone_model.dart';
import '../models/request_otp_model.dart';
import '../models/verify_otp_model.dart';
import '../models/complete_register_model.dart';
import '../models/login_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<CheckPhoneResponse> checkPhone(String phoneNumber) async {
    final result = await _remoteDataSource.checkPhone(phoneNumber);
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
      (response) => response,
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
      (response) => response,
    );
  }
}
