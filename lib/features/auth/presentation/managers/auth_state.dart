import 'package:equatable/equatable.dart';

enum AuthStep {
  phoneInput,
  login,
  otpVerification,
  registration,
}

enum AuthStatus {
  initial,
  loading,
  success,
  error,
}

class AuthState extends Equatable {
  final AuthStep step;
  final AuthStatus status;
  final String phoneNumber;
  final String otpCode;
  final String password;
  final String fullName;
  final String username;
  final String? profilePhotoPath;
  final String language;
  final String? errorMessage;
  final String? usernameValidationError;
  final int otpTimer; // in seconds
  final String? serverOtpCode; // For development/debug only, not shown in UI
  final bool? isUsernameAvailable;
  final bool isCheckingUsername;

  const AuthState({
    this.step = AuthStep.phoneInput,
    this.status = AuthStatus.initial,
    this.phoneNumber = '',
    this.otpCode = '',
    this.password = '',
    this.fullName = '',
    this.username = '',
    this.profilePhotoPath,
    this.language = 'uz',
    this.errorMessage,
    this.usernameValidationError,
    this.otpTimer = 120,
    this.serverOtpCode,
    this.isUsernameAvailable,
    this.isCheckingUsername = false,
  });

  AuthState copyWith({
    AuthStep? step,
    AuthStatus? status,
    String? phoneNumber,
    String? otpCode,
    String? password,
    String? fullName,
    String? username,
    Object? profilePhotoPath = _undefined,
    String? language,
    Object? errorMessage = _undefined,
    Object? usernameValidationError = _undefined,
    int? otpTimer,
    Object? serverOtpCode = _undefined,
    Object? isUsernameAvailable = _undefined,
    bool? isCheckingUsername,
  }) {
    return AuthState(
      step: step ?? this.step,
      status: status ?? this.status,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      otpCode: otpCode ?? this.otpCode,
      password: password ?? this.password,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      profilePhotoPath: profilePhotoPath == _undefined
          ? this.profilePhotoPath
          : profilePhotoPath as String?,
      language: language ?? this.language,
      errorMessage:
          errorMessage == _undefined ? this.errorMessage : errorMessage as String?,
      usernameValidationError: usernameValidationError == _undefined
          ? this.usernameValidationError
          : usernameValidationError as String?,
      otpTimer: otpTimer ?? this.otpTimer,
      serverOtpCode: serverOtpCode == _undefined
          ? this.serverOtpCode
          : serverOtpCode as String?,
      isUsernameAvailable: isUsernameAvailable == _undefined
          ? this.isUsernameAvailable
          : isUsernameAvailable as bool?,
      isCheckingUsername: isCheckingUsername ?? this.isCheckingUsername,
    );
  }

  @override
  List<Object?> get props => [
        step,
        status,
        phoneNumber,
        otpCode,
        password,
        fullName,
        username,
        profilePhotoPath,
        language,
        errorMessage,
        usernameValidationError,
        otpTimer,
        serverOtpCode,
        isUsernameAvailable,
        isCheckingUsername,
      ];
}

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthPhoneNumberSubmitted extends AuthEvent {
  final String phoneNumber;
  const AuthPhoneNumberSubmitted(this.phoneNumber);
}

class AuthOtpSubmitted extends AuthEvent {
  final String otpCode;
  const AuthOtpSubmitted(this.otpCode);
}

class AuthPasswordSubmitted extends AuthEvent {
  final String password;
  const AuthPasswordSubmitted(this.password);
}

class AuthProfileSubmitted extends AuthEvent {
  final String fullName;
  final String? username;
  final String password;
  final String? profilePhotoPath;
  final String language;

  const AuthProfileSubmitted({
    required this.fullName,
    this.username,
    required this.password,
    this.profilePhotoPath,
    required this.language,
  });
}

class AuthOtpTimerTicked extends AuthEvent {
  final int duration;
  const AuthOtpTimerTicked(this.duration);
}

class AuthResendOtpRequested extends AuthEvent {}

class AuthStepChanged extends AuthEvent {
  final AuthStep step;
  const AuthStepChanged(this.step);
}

class AuthUsernameChanged extends AuthEvent {
  final String username;
  const AuthUsernameChanged(this.username);
}

const Object _undefined = Object();
