import 'package:equatable/equatable.dart';

enum AuthStep {
  phoneInput,
  otpVerification,
  passwordCreation,
  profileSetup,
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
  final int otpTimer; // in seconds

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
    this.otpTimer = 120,
  });

  AuthState copyWith({
    AuthStep? step,
    AuthStatus? status,
    String? phoneNumber,
    String? otpCode,
    String? password,
    String? fullName,
    String? username,
    String? profilePhotoPath,
    String? language,
    String? errorMessage,
    int? otpTimer,
  }) {
    return AuthState(
      step: step ?? this.step,
      status: status ?? this.status,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      otpCode: otpCode ?? this.otpCode,
      password: password ?? this.password,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      profilePhotoPath: profilePhotoPath ?? this.profilePhotoPath,
      language: language ?? this.language,
      errorMessage: errorMessage ?? this.errorMessage,
      otpTimer: otpTimer ?? this.otpTimer,
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
        otpTimer,
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
  final String? profilePhotoPath;
  final String language;

  const AuthProfileSubmitted({
    required this.fullName,
    this.username,
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
