class GroupModel {
  final String id;
  final String name;
  final String? description;
  final String? avatar;
  final String? categoryId;
  final int membersCount;
  final DateTime createdAt;

  GroupModel({
    required this.id,
    required this.name,
    this.description,
    this.avatar,
    this.categoryId,
    this.membersCount = 0,
    required this.createdAt,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      avatar: json['photoUrl'] ?? json['avatar'] as String?,
      categoryId: json['categoryId'] as String?,
      membersCount: json['membersCount'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}
