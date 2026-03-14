import '../../domain/entities/client_profile_entity.dart';

abstract class ClientProfileEvent {
  const ClientProfileEvent();
}

class ClientProfileStarted extends ClientProfileEvent {
  const ClientProfileStarted();
}

class ClientProfileUpdated extends ClientProfileEvent {
  final ClientProfileEntity profile;

  const ClientProfileUpdated(this.profile);
}

class ClientProfilePhotoChanged extends ClientProfileEvent {
  final String imagePath;

  const ClientProfilePhotoChanged(this.imagePath);
}

class ClientProfileLogoutRequested extends ClientProfileEvent {
  const ClientProfileLogoutRequested();
}
