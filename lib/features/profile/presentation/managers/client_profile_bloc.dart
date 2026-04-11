import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/validators.dart';
import '../../../auth/domain/usecases/check_username_usecase.dart';
import '../../domain/usecases/get_client_profile_usecase.dart';
import '../../domain/usecases/update_client_profile_usecase.dart';
import '../../domain/usecases/upload_profile_photo_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/delete_account_usecase.dart';
import 'client_profile_event.dart';
import 'client_profile_state.dart';

class ClientProfileBloc extends Bloc<ClientProfileEvent, ClientProfileState> {
  final GetClientProfileUseCase getProfileUseCase;
  final UpdateClientProfileUseCase updateProfileUseCase;
  final UploadProfilePhotoUseCase uploadPhotoUseCase;
  final LogoutUseCase logoutUseCase;
  final DeleteAccountUseCase deleteAccountUseCase;
  final CheckUsernameUseCase checkUsernameUseCase;
  Timer? _debounceTimer;

  ClientProfileBloc({
    required this.getProfileUseCase,
    required this.updateProfileUseCase,
    required this.uploadPhotoUseCase,
    required this.logoutUseCase,
    required this.deleteAccountUseCase,
    required this.checkUsernameUseCase,
  }) : super(const ClientProfileState()) {
    on<ClientProfileStarted>(_onStarted);
    on<ClientProfileUpdated>(_onUpdated);
    on<ClientProfilePhotoChanged>(_onPhotoChanged);
    on<ClientProfileLogoutRequested>(_onLogoutRequested);
    on<ClientProfileUsernameChanged>(_onUsernameChanged);
    on<ClientProfileDeleteAccountRequested>(_onDeleteAccountRequested);
  }

  Future<void> _onStarted(
    ClientProfileStarted event,
    Emitter<ClientProfileState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final profile = await getProfileUseCase();
      emit(state.copyWith(isLoading: false, profile: profile));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onUpdated(
    ClientProfileUpdated event,
    Emitter<ClientProfileState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final profile = await updateProfileUseCase(event.profile);
      emit(state.copyWith(isLoading: false, profile: profile));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onPhotoChanged(
    ClientProfilePhotoChanged event,
    Emitter<ClientProfileState> emit,
  ) async {
    if (state.profile == null) return;
    
    emit(state.copyWith(isLoading: true));
    try {
      final photoUrl = await uploadPhotoUseCase(event.imagePath);
      final updatedProfile = state.profile!.copyWith(photoUrl: photoUrl);
      final profile = await updateProfileUseCase(updatedProfile);
      emit(state.copyWith(isLoading: false, profile: profile));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
    ClientProfileLogoutRequested event,
    Emitter<ClientProfileState> emit,
  ) async {
    try {
      await logoutUseCase();
      emit(state.copyWith(isLoggedOut: true));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onDeleteAccountRequested(
    ClientProfileDeleteAccountRequested event,
    Emitter<ClientProfileState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      await deleteAccountUseCase();
      emit(state.copyWith(isLoading: false, isLoggedOut: true));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onUsernameChanged(
    ClientProfileUsernameChanged event,
    Emitter<ClientProfileState> emit,
  ) async {
    final username = event.username.trim();

    // If matches current, it's available and valid
    if (username == event.currentUsername) {
      emit(state.copyWith(
        isUsernameAvailable: true,
        isCheckingUsername: false,
        usernameValidationError: null,
      ));
      return;
    }

    if (username.isEmpty) {
      emit(state.copyWith(
        isUsernameAvailable: null,
        isCheckingUsername: false,
        usernameValidationError: null,
      ));
      return;
    }

    // Client-side validation
    final validationError = AppValidators.validateUsername(username);
    if (validationError != null) {
      emit(state.copyWith(
        isUsernameAvailable: false,
        isCheckingUsername: false,
        usernameValidationError: validationError,
      ));
      return;
    }

    emit(state.copyWith(
      isCheckingUsername: true,
      isUsernameAvailable: null,
      usernameValidationError: null,
    ));

    _debounceTimer?.cancel();
    final completer = Completer<void>();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (!completer.isCompleted) completer.complete();
    });

    await completer.future;

    try {
      final response = await checkUsernameUseCase(username);
      emit(state.copyWith(
        isCheckingUsername: false,
        isUsernameAvailable: !response.exists,
        usernameValidationError: response.exists ? 'Bu username allaqachon band' : null,
      ));
    } catch (e) {
      emit(state.copyWith(
        isCheckingUsername: false,
        isUsernameAvailable: null,
        usernameValidationError: null,
      ));
    }
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
