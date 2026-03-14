import '../../domain/entities/post_category_entity.dart';

class PostCategoryModel extends PostCategoryEntity {
  const PostCategoryModel({
    required super.id,
    required super.name,
    required super.iconPath,
    super.subcategories,
    super.parentId,
  });

  factory PostCategoryModel.fromJson(Map<String, dynamic> json) {
    return PostCategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      iconPath: (json['iconUrl'] ?? json['photoUrl'] ?? '') as String, // Handle null iconUrl
      parentId: (json['parentId'] ?? json['categoryId']) as String?,
      subcategories: (json['children'] as List<dynamic>?)
          ?.map((e) => PostCategoryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconUrl': iconPath,
      'children': subcategories?.map((e) {
        if (e is PostCategoryModel) {
          return e.toJson();
        }
        return {
          'id': e.id,
          'name': e.name,
          'iconUrl': e.iconPath,
          'parentId': e.parentId,
        };
      }).toList(),
      'parentId': parentId,
    };
  }

  factory PostCategoryModel.fromEntity(PostCategoryEntity entity) {
    return PostCategoryModel(
      id: entity.id,
      name: entity.name,
      iconPath: entity.iconPath,
      subcategories: entity.subcategories,
      parentId: entity.parentId,
    );
  }

  PostCategoryEntity toEntity() => this;
}
