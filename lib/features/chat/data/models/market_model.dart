class MarketModel {
  final String id;
  final String name;
  final String username;
  final String? photoPath;
  final String role;
  final String language;

  MarketModel({
    required this.id,
    required this.name,
    required this.username,
    this.photoPath,
    required this.role,
    required this.language,
  });

  factory MarketModel.fromJson(Map<String, dynamic> json) {
    return MarketModel(
      id: json['id'],
      name: json['name'],
      username: json['username'],
      photoPath: json['photoPath'],
      role: json['role'] ?? 'market',
      language: json['language'] ?? 'uz',
    );
  }
}
