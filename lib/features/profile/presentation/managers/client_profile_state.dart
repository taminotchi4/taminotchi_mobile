import '../../domain/entities/client_profile_entity.dart';

class ClientProfileState {
  final bool isLoading;
  final ClientProfileEntity? profile;
  final String? error;
  final bool isLoggedOut;

  const ClientProfileState({
    this.isLoading = false,
    this.profile,
    this.error,
    this.isLoggedOut = false,
  });

  ClientProfileState copyWith({
    bool? isLoading,
    ClientProfileEntity? profile,
    String? error,
    bool? isLoggedOut,
  }) {
    return ClientProfileState(
      isLoading: isLoading ?? this.isLoading,
      profile: profile ?? this.profile,
      error: error,
      isLoggedOut: isLoggedOut ?? this.isLoggedOut,
    );
  }
}
