import '../../domain/entities/client_profile_entity.dart';

class ClientProfileState {
  final bool isLoading;
  final ClientProfileEntity? profile;
  final String? error;
  final bool isLoggedOut;
  final bool isCheckingUsername;
  final bool? isUsernameAvailable;
  final String? usernameValidationError;

  const ClientProfileState({
    this.isLoading = false,
    this.profile,
    this.error,
    this.isLoggedOut = false,
    this.isCheckingUsername = false,
    this.isUsernameAvailable,
    this.usernameValidationError,
  });

  ClientProfileState copyWith({
    bool? isLoading,
    ClientProfileEntity? profile,
    String? error,
    bool? isLoggedOut,
    bool? isCheckingUsername,
    bool? isUsernameAvailable,
    String? usernameValidationError,
  }) {
    return ClientProfileState(
      isLoading: isLoading ?? this.isLoading,
      profile: profile ?? this.profile,
      error: error,
      isLoggedOut: isLoggedOut ?? this.isLoggedOut,
      isCheckingUsername: isCheckingUsername ?? this.isCheckingUsername,
      isUsernameAvailable: isUsernameAvailable,
      usernameValidationError: usernameValidationError,
    );
  }
}
