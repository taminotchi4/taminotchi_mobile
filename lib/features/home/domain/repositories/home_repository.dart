import '../../../../core/utils/result.dart';
import '../entities/comment_entity.dart';
import '../entities/post_category_entity.dart';
import '../entities/post_entity.dart';
import '../entities/post_image_entity.dart';
import '../entities/user_role.dart';
import '../entities/post_status.dart';

abstract class HomeRepository {
  Future<Result<List<PostEntity>>> getAllPosts();

  Future<Result<List<PostEntity>>> getMyPosts(String userId);

  Future<Result<PostEntity>> createPost({
    required String content,
    required List<PostImageEntity> images,
    required PostCategoryEntity category,
  });

  Future<Result<PostEntity?>> getPostById(String id);

  Future<Result<List<CommentEntity>>> getComments(String postId);

  Future<Result<Map<String, int>>> getCommentCounts();

  Future<Result<List<PostCategoryEntity>>> getCategories();

  Future<Result<String>> getCurrentUserId();

  Future<Result<UserRole>> getCurrentUserRole();

  Future<Result<void>> replyToComment({
    required String postId,
    required String parentCommentId,
    required String content,
  });

  Future<Result<void>> updatePostStatus({
    required String postId,
    required PostStatus status,
  });
}
