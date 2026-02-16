import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/check_phone_usecase.dart';
import '../../domain/usecases/request_otp_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';
import '../../domain/usecases/complete_register_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final CheckPhoneUseCase _checkPhoneUseCase;
  final RequestOtpUseCase _requestOtpUseCase;
  final VerifyOtpUseCase _verifyOtpUseCase;
  final CompleteRegisterUseCase _completeRegisterUseCase;
  final LoginUseCase _loginUseCase;
  Timer? _timer;

  AuthBloc({
    required CheckPhoneUseCase checkPhoneUseCase,
    required RequestOtpUseCase requestOtpUseCase,
    required VerifyOtpUseCase verifyOtpUseCase,
    required CompleteRegisterUseCase completeRegisterUseCase,
    required LoginUseCase loginUseCase,
  })  : _checkPhoneUseCase = checkPhoneUseCase,
        _requestOtpUseCase = requestOtpUseCase,
        _verifyOtpUseCase = verifyOtpUseCase,
        _completeRegisterUseCase = completeRegisterUseCase,
        _loginUseCase = loginUseCase,
        super(const AuthState()) {
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

    try {
      // Check if phone exists
      final response = await _checkPhoneUseCase(event.phoneNumber);
      
      // Debug: Print the response
      print('📱 Phone check response: exists = ${response.exists}');

      if (response.exists) {
        // User exists → go to Login step
        print('✅ User exists, navigating to Login step');
        emit(state.copyWith(
          status: AuthStatus.initial,
          step: AuthStep.login,
          phoneNumber: event.phoneNumber,
        ));
      } else {
        // User doesn't exist → request OTP and go to OTP verification step
        print('❌ User does not exist, requesting OTP');
        final otpResponse = await _requestOtpUseCase(event.phoneNumber);
        emit(state.copyWith(
          status: AuthStatus.initial,
          step: AuthStep.otpVerification,
          phoneNumber: event.phoneNumber,
          serverOtpCode: otpResponse.otpCode, // For debug only
        ));
        _startTimer(emit);
      }
    } catch (e) {
      print('❗ Error checking phone: $e');
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Telefon raqamni tekshirishda xatolik: ${e.toString()}',
      ));
    }
  }

  Future<void> _onOtpSubmitted(
      AuthOtpSubmitted event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final response = await _verifyOtpUseCase(
        phoneNumber: state.phoneNumber,
        code: event.otpCode,
      );

      if (response.verified) {
        _timer?.cancel();
        emit(state.copyWith(
          status: AuthStatus.initial,
          step: AuthStep.registration,
          otpCode: event.otpCode,
        ));
      } else {
        emit(state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Kod noto\'g\'ri',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'OTP kodni tekshirishda xatolik: ${e.toString()}',
      ));
    }
  }

  Future<void> _onPasswordSubmitted(
      AuthPasswordSubmitted event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final _ = await _loginUseCase(
        phoneNumber: state.phoneNumber,
        password: event.password,
      );

      // TODO: Save access token and user data to local storage
      emit(state.copyWith(
        status: AuthStatus.success,
        password: event.password,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Login xatolik: ${e.toString()}',
      ));
    }
  }

  Future<void> _onProfileSubmitted(
      AuthProfileSubmitted event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      // Complete registration
      final _ = await _completeRegisterUseCase(
        phoneNumber: state.phoneNumber,
        fullName: event.fullName,
        username: event.username ?? '',
        password: event.password,
        language: event.language,
      );

      // TODO: Save user data to local storage if needed
      emit(state.copyWith(
        status: AuthStatus.success,
        fullName: event.fullName,
        username: event.username,
        password: event.password,
        profilePhotoPath: event.profilePhotoPath,
        language: event.language,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Ro\'yxatdan o\'tishda xatolik: ${e.toString()}',
      ));
    }
  }

  void _onOtpTimerTicked(AuthOtpTimerTicked event, Emitter<AuthState> emit) {
    emit(state.copyWith(otpTimer: event.duration));
    if (event.duration == 0) {
      _timer?.cancel();
    }
  }

  void _onResendOtpRequested(
      AuthResendOtpRequested event, Emitter<AuthState> emit) async {
    _timer?.cancel();
    
    try {
      // Re-request OTP
      final otpResponse = await _requestOtpUseCase(state.phoneNumber);
      emit(state.copyWith(
        otpTimer: 120,
        serverOtpCode: otpResponse.otpCode, // For debug only
      ));
      _startTimer(emit);
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'OTP qayta yuborishda xatolik: ${e.toString()}',
      ));
    }
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
