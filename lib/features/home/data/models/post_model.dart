import '../../domain/entities/post_category_entity.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/entities/post_image_entity.dart';

class PostImageModel {
  final String path;
  final bool isLocal;

  const PostImageModel({
    required this.path,
    required this.isLocal,
  });

  PostImageEntity toEntity() => PostImageEntity(path: path, isLocal: isLocal);

  factory PostImageModel.fromEntity(PostImageEntity entity) =>
      PostImageModel(path: entity.path, isLocal: entity.isLocal);
}

class PostCategoryModel {
  final String id;
  final String name;
  final String iconPath;

  const PostCategoryModel({
    required this.id,
    required this.name,
    required this.iconPath,
  });

  PostCategoryEntity toEntity() =>
      PostCategoryEntity(id: id, name: name, iconPath: iconPath);

  factory PostCategoryModel.fromEntity(PostCategoryEntity entity) =>
      PostCategoryModel(
        id: entity.id,
        name: entity.name,
        iconPath: entity.iconPath,
      );
}

class PostModel {
  final String id;
  final String authorId;
  final String authorName;
  final String authorAvatarPath;
  final String content;
  final List<PostImageModel> images;
  final PostCategoryModel category;
  final DateTime createdAt;
  final int privateReplyCount;

  const PostModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorAvatarPath,
    required this.content,
    required this.images,
    required this.category,
    required this.createdAt,
    required this.privateReplyCount,
  });

  PostEntity toEntity() => PostEntity(
    id: id,
    authorId: authorId,
    authorName: authorName,
    authorAvatarPath: authorAvatarPath,
    content: content,
    images: images.map((e) => e.toEntity()).toList(),
    category: category.toEntity(),
    createdAt: createdAt,
    privateReplyCount: privateReplyCount,
  );

  factory PostModel.fromEntity(PostEntity entity) => PostModel(
    id: entity.id,
    authorId: entity.authorId,
    authorName: entity.authorName,
    authorAvatarPath: entity.authorAvatarPath,
    content: entity.content,
    images: entity.images.map(PostImageModel.fromEntity).toList(),
    category: PostCategoryModel.fromEntity(entity.category),
    createdAt: entity.createdAt,
    privateReplyCount: entity.privateReplyCount,
  );
}
