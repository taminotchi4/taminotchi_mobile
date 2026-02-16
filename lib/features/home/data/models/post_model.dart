import '../../domain/entities/post_category_entity.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/entities/post_image_entity.dart';
import '../../domain/entities/post_status.dart';
import 'post_category_model.dart';

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
  final PostStatus status;

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
    this.status = PostStatus.active,
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
    status: status,
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
    status: entity.status,
  );
}
