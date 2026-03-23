import '../../domain/entities/group_entity.dart';

class GroupModel {
  final String id;
  final String createdAt;
  final String updatedAt;
  final bool isDeleted;
  final String? deletedAt;
  final String name;
  final String nameUz;
  final String nameRu;
  final String? description;
  final String categoryId;
  final String? supCategoryId;
  final String? profilePhoto;
  final int membersCount;
  final bool isJoined;

  const GroupModel({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    this.deletedAt,
    required this.name,
    required this.nameUz,
    required this.nameRu,
    this.description,
    required this.categoryId,
    this.supCategoryId,
    this.profilePhoto,
    required this.membersCount,
    required this.isJoined,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['id'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      isDeleted: json['isDeleted'] ?? false,
      deletedAt: json['deletedAt'],
      name: json['name'] ?? '',
      nameUz: json['nameUz'] ?? '',
      nameRu: json['nameRu'] ?? '',
      description: json['description'],
      categoryId: json['categoryId'] ?? '',
      supCategoryId: json['supCategoryId'],
      profilePhoto: json['profilePhoto'],
      membersCount: json['membersCount'] ?? 0,
      isJoined: json['isJoined'] ?? false,
    );
  }

  factory GroupModel.fromEntity(GroupEntity entity) {
    return GroupModel(
      id: entity.id,
      createdAt: '', // Default value as it's not in GroupEntity
      updatedAt: '', // Default value as it's not in GroupEntity
      isDeleted: false, // Default value as it's not in GroupEntity
      deletedAt: null, // Default value as it's not in GroupEntity
      name: entity.name, // Assuming entity.name is the primary name
      nameUz: entity.name, // Default to entity.name
      nameRu: entity.name, // Default to entity.name
      description: entity.description,
      categoryId: entity.categoryId,
      supCategoryId: entity.supCategoryId,
      profilePhoto: entity.profilePhoto,
      membersCount: entity.membersCount,
      isJoined: entity.isJoined,
    );
  }

  GroupEntity toEntity() {
    return GroupEntity(
      id: id,
      name: nameUz.isNotEmpty ? nameUz : name,
      description: description,
      categoryId: categoryId,
      supCategoryId: supCategoryId,
      profilePhoto: profilePhoto,
      membersCount: membersCount,
      isJoined: isJoined,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isDeleted': isDeleted,
      'deletedAt': deletedAt,
      'name': name,
      'nameUz': nameUz,
      'nameRu': nameRu,
      'description': description,
      'categoryId': categoryId,
      'supCategoryId': supCategoryId,
      'profilePhoto': profilePhoto,
      'membersCount': membersCount,
      'isJoined': isJoined,
    };
  }
}
