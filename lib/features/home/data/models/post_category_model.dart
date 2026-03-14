import '../../domain/entities/post_category_entity.dart';

class PostCategoryModel extends PostCategoryEntity {
  const PostCategoryModel({
    required super.id,
    required super.name,
    required super.iconPath,
    super.subcategories,
    super.parentId,
    super.hintText,
  });

  factory PostCategoryModel.fromJson(Map<String, dynamic> json) {
    return PostCategoryModel(
      id: json['id'] as String,
      name: (json['nameUz'] ?? json['nameRu'] ?? json['name'] ?? '') as String,
      iconPath: (json['iconUrl'] ?? json['photoUrl'] ?? '') as String,
      parentId: (json['parentId'] ?? json['categoryId']) as String?,
      hintText: (json['hintTextUz'] ?? json['hintTextRu'] ?? json['hintText']) as String?,
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
      'hintText': hintText,
      'children': subcategories?.map((e) {
        if (e is PostCategoryModel) {
          return e.toJson();
        }
        return {
          'id': e.id,
          'name': e.name,
          'iconUrl': e.iconPath,
          'parentId': e.parentId,
          'hintText': e.hintText,
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
      hintText: entity.hintText,
    );
  }

  PostCategoryEntity toEntity() => this;
}
