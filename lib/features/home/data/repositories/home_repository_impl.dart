import '../../../../core/utils/result.dart';
import '../../domain/entities/comment_entity.dart';
import '../../domain/entities/post_category_entity.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/entities/post_image_entity.dart';
import '../../domain/entities/post_status.dart';
import '../../domain/entities/user_role.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_local_data_source.dart';
import '../datasources/category_remote_data_source.dart';
import '../models/comment_model.dart';
import '../models/post_model.dart';
import '../models/post_category_model.dart';
import '../../../../core/network/auth_interceptor.dart';
import '../../../auth/data/datasources/auth_local_data_source.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeLocalDataSource localDataSource;
  final CategoryRemoteDataSource categoryRemoteDataSource;
  final AuthLocalDataSource authLocalDataSource;

  const HomeRepositoryImpl({
    required this.localDataSource,
    required this.categoryRemoteDataSource,
    required this.authLocalDataSource,
  });

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
      final categories = await categoryRemoteDataSource.getCategories();
      List<PostCategoryModel> subcategories = [];
      try {
        subcategories = await categoryRemoteDataSource.getSubCategories();
      } catch (e) {
        // Log error but proceed with empty subcategories
        print('Error loading subcategories: $e');
      }

      final populatedCategories = categories.map((category) {
        final categorySubs = subcategories
            .where((sub) => sub.parentId == category.id)
            .toList();

        return PostCategoryEntity(
          id: category.id,
          name: category.name,
          iconPath: category.iconPath,
          parentId: category.parentId,
          subcategories: categorySubs.isEmpty ? null : categorySubs,
        );
      }).toList();

      return Result.ok(populatedCategories);
    } catch (e) {
      return Result.error(Exception('Failed to load categories: $e'));
    }
  }

  @override
  Future<Result<String>> getCurrentUserId() async {
    try {
      final token = await authLocalDataSource.getToken();
      // TODO: Decode token to get actual user ID. For now, returning dummy ID if token exists.
      // If token is null, return empty string indicating guest mode.
      if (token != null && token.isNotEmpty) {
         return Result.ok(localDataSource.getCurrentUserId());
      }
      return Result.ok('');
    } catch (e) {
      return Result.error(Exception('Failed to load user'));
    }
  }

  @override
  Future<Result<UserRole>> getCurrentUserRole() async {
    try {
      final token = await authLocalDataSource.getToken();
      if (token != null && token.isNotEmpty) {
        return Result.ok(UserRole.user); // Assuming standard user role for now
      }
      return Result.error(Exception('Guest user'));
    } catch (e) {
      return Result.error(Exception('Failed to load role'));
    }
  }
  @override
  Future<Result<void>> replyToComment({
    required String postId,
    required String parentCommentId,
    required String content,
  }) async {
    try {
      final userRole = await getCurrentUserRole();
      String role = 'User';
      userRole.fold(
        (error) => role = 'User',
        (data) => role = data == UserRole.seller ? 'Admin' : 'User',
      );

      final reply = CommentModel(
        id: '${parentCommentId}_reply_${DateTime.now().millisecondsSinceEpoch}',
        postId: postId,
        userName: 'Mening akkauntim', // TODO: Get actual user name
        userRole: role,
        userAvatarPath: 'assets/icons/ic_user.svg', // Using string literal as import might be missing
        content: content,
        createdAt: DateTime.now(),
      );
      
      localDataSource.addReply(postId, parentCommentId, reply);
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception('Failed to reply to comment'));
    }
  }

  @override
  Future<Result<void>> updatePostStatus({
    required String postId,
    required PostStatus status,
  }) async {
    try {
      localDataSource.updatePostStatus(postId, status);
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception('Failed to update post status'));
    }
  }
}
