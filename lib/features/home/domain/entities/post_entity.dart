import 'post_category_entity.dart';
import 'post_image_entity.dart';

class PostEntity {
  final String id;
  final String authorId;
  final String authorName;
  final String authorAvatarPath;
  final String content;
  final List<PostImageEntity> images;
  final PostCategoryEntity category;
  final DateTime createdAt;
  final int privateReplyCount;

  const PostEntity({
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
}
