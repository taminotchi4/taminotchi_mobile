import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  Timer? _timer;

  AuthBloc() : super(const AuthState()) {
    on<AuthPhoneNumberSubmitted>(_onPhoneNumberSubmitted);
    on<AuthOtpSubmitted>(_onOtpSubmitted);
    on<AuthPasswordSubmitted>(_onPasswordSubmitted);
    on<AuthProfileSubmitted>(_onProfileSubmitted);
    on<AuthOtpTimerTicked>(_onOtpTimerTicked);
    on<AuthResendOtpRequested>(_onResendOtpRequested);
    on<AuthStepChanged>(_onStepChanged);
  }

  void _onStepChanged(AuthStepChanged event, Emitter<AuthState> emit) {
    emit(state.copyWith(step: event.step));
  }

  Future<void> _onPhoneNumberSubmitted(
      AuthPhoneNumberSubmitted event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    emit(state.copyWith(
      status: AuthStatus.initial,
      step: AuthStep.otpVerification,
      phoneNumber: event.phoneNumber,
    ));
    
    _startTimer(emit);
  }

  Future<void> _onOtpSubmitted(
      AuthOtpSubmitted event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    if (event.otpCode == '111111') {
      _timer?.cancel();
      // If user exists, go to home (simulated by success status)
      // If user is new, go to password creation
      // For this demo, let's assume if it ends in '0', they are new
      if (state.phoneNumber.endsWith('0')) {
        emit(state.copyWith(
          status: AuthStatus.initial,
          step: AuthStep.passwordCreation,
          otpCode: event.otpCode,
        ));
      } else {
        emit(state.copyWith(
          status: AuthStatus.success,
          otpCode: event.otpCode,
        ));
      }
    } else {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Kod noto\'g\'ri',
      ));
    }
  }

  Future<void> _onPasswordSubmitted(
      AuthPasswordSubmitted event, Emitter<AuthState> emit) async {
    emit(state.copyWith(
      password: event.password,
      step: AuthStep.profileSetup,
    ));
  }

  Future<void> _onProfileSubmitted(
      AuthProfileSubmitted event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    emit(state.copyWith(
      status: AuthStatus.success,
      fullName: event.fullName,
      username: event.username,
      profilePhotoPath: event.profilePhotoPath,
      language: event.language,
    ));
  }

  void _onOtpTimerTicked(AuthOtpTimerTicked event, Emitter<AuthState> emit) {
    emit(state.copyWith(otpTimer: event.duration));
    if (event.duration == 0) {
      _timer?.cancel();
    }
  }

  void _onResendOtpRequested(AuthResendOtpRequested event, Emitter<AuthState> emit) {
    _timer?.cancel();
    emit(state.copyWith(otpTimer: 120));
    _startTimer(emit);
  }

  void _startTimer(Emitter<AuthState> emit) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final newDuration = 120 - timer.tick;
      if (newDuration >= 0) {
        add(AuthOtpTimerTicked(newDuration));
      } else {
        timer.cancel();
      }
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
