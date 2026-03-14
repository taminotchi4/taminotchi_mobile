class ClientProfileEntity {
  final String id;
  final String name;
  final String username;
  final String phone;
  final String? photoUrl;
  final String language;

  const ClientProfileEntity({
    required this.id,
    required this.name,
    required this.username,
    required this.phone,
    this.photoUrl,
    required this.language,
  });

  ClientProfileEntity copyWith({
    String? id,
    String? name,
    String? username,
    String? phone,
    String? photoUrl,
    String? language,
  }) {
    return ClientProfileEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      language: language ?? this.language,
    );
  }
}
