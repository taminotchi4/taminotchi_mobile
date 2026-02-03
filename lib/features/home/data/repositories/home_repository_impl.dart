import '../../../../core/utils/result.dart';
import '../../domain/entities/comment_entity.dart';
import '../../domain/entities/post_category_entity.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/entities/post_image_entity.dart';
import '../../domain/entities/user_role.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_local_data_source.dart';
import '../models/post_model.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeLocalDataSource localDataSource;

  const HomeRepositoryImpl(this.localDataSource);

  @override
  Future<Result<List<PostEntity>>> getAllPosts() async {
    try {
      final posts =
          localDataSource.getAllPosts().map((e) => e.toEntity()).toList();
      return Result.ok(posts);
    } catch (e) {
      return Result.error(Exception('Failed to load posts'));
    }
  }

  @override
  Future<Result<List<PostEntity>>> getMyPosts(String userId) async {
    try {
      final posts =
          localDataSource.getMyPosts(userId).map((e) => e.toEntity()).toList();
      return Result.ok(posts);
    } catch (e) {
      return Result.error(Exception('Failed to load posts'));
    }
  }

  @override
  Future<Result<PostEntity>> createPost({
    required String content,
    required List<PostImageEntity> images,
    required PostCategoryEntity category,
  }) async {
    try {
      final imageModels = images.map(PostImageModel.fromEntity).toList();
      final categoryModel = PostCategoryModel.fromEntity(category);
      final post = localDataSource
          .addPost(
            content: content,
            images: imageModels,
            category: categoryModel,
          )
          .toEntity();
      return Result.ok(post);
    } catch (e) {
      return Result.error(Exception('Failed to create post'));
    }
  }

  @override
  Future<Result<PostEntity?>> getPostById(String id) async {
    try {
      final post = localDataSource.getPostById(id)?.toEntity();
      return Result.ok(post);
    } catch (e) {
      return Result.error(Exception('Failed to load post'));
    }
  }

  @override
  Future<Result<List<CommentEntity>>> getComments(String postId) async {
    try {
      final comments = localDataSource
          .getComments(postId)
          .map((e) => e.toEntity())
          .toList();
      return Result.ok(comments);
    } catch (e) {
      return Result.error(Exception('Failed to load comments'));
    }
  }

  @override
  Future<Result<Map<String, int>>> getCommentCounts() async {
    try {
      return Result.ok(localDataSource.getCommentCounts());
    } catch (e) {
      return Result.error(Exception('Failed to load comment counts'));
    }
  }

  @override
  Future<Result<List<PostCategoryEntity>>> getCategories() async {
    try {
      final categories =
          localDataSource.getCategories().map((e) => e.toEntity()).toList();
      return Result.ok(categories);
    } catch (e) {
      return Result.error(Exception('Failed to load categories'));
    }
  }

  @override
  Future<Result<String>> getCurrentUserId() async {
    try {
      return Result.ok(localDataSource.getCurrentUserId());
    } catch (e) {
      return Result.error(Exception('Failed to load user'));
    }
  }

  @override
  Future<Result<UserRole>> getCurrentUserRole() async {
    try {
      return Result.ok(localDataSource.getCurrentUserRole());
    } catch (e) {
      return Result.error(Exception('Failed to load role'));
    }
  }
}
