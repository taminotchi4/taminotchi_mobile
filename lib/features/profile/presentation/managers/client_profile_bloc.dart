import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_client_profile_usecase.dart';
import '../../domain/usecases/update_client_profile_usecase.dart';
import '../../domain/usecases/upload_profile_photo_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import 'client_profile_event.dart';
import 'client_profile_state.dart';

class ClientProfileBloc extends Bloc<ClientProfileEvent, ClientProfileState> {
  final GetClientProfileUseCase getProfileUseCase;
  final UpdateClientProfileUseCase updateProfileUseCase;
  final UploadProfilePhotoUseCase uploadPhotoUseCase;
  final LogoutUseCase logoutUseCase;

  ClientProfileBloc({
    required this.getProfileUseCase,
    required this.updateProfileUseCase,
    required this.uploadPhotoUseCase,
    required this.logoutUseCase,
  }) : super(const ClientProfileState()) {
    on<ClientProfileStarted>(_onStarted);
    on<ClientProfileUpdated>(_onUpdated);
    on<ClientProfilePhotoChanged>(_onPhotoChanged);
    on<ClientProfileLogoutRequested>(_onLogoutRequested);
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
}
