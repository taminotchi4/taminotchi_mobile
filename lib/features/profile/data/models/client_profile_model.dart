import '../../domain/entities/client_profile_entity.dart';

class ClientProfileModel extends ClientProfileEntity {
  const ClientProfileModel({
    required super.id,
    required super.name,
    required super.username,
    required super.phone,
    super.photoUrl,
    required super.language,
  });

  factory ClientProfileModel.fromJson(Map<String, dynamic> json) {
    return ClientProfileModel(
      id: json['id'] as String,
      name: json['fullName'] as String? ?? '',
      username: json['username'] as String? ?? '',
      phone: json['phoneNumber'] as String? ?? '',
      photoUrl: json['photoPath'] as String?,
      language: json['language'] as String? ?? 'uz',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': name,
      'username': username,
      'phoneNumber': phone,
      'photoPath': photoUrl,
      'language': language,
    };
  }
}
