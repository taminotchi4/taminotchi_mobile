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
import '../datasources/elon_remote_datasource.dart';
import '../models/comment_model.dart';
import '../models/post_category_model.dart';
import '../../domain/entities/group_entity.dart';
import '../../../auth/data/datasources/auth_local_data_source.dart';

import '../datasources/home_sql_data_source.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeLocalDataSource localDataSource;
  final HomeSqlDataSource sqlDataSource;
  final CategoryRemoteDataSource categoryRemoteDataSource;
  final AuthLocalDataSource authLocalDataSource;
  final ElonRemoteDataSource elonRemoteDataSource;

  const HomeRepositoryImpl({
    required this.localDataSource,
    required this.sqlDataSource,
    required this.categoryRemoteDataSource,
    required this.authLocalDataSource,
    required this.elonRemoteDataSource,
  });

  @override
  Future<Result<List<PostEntity>>> getAllPosts({bool forceRefresh = false}) async {
    try {
      if (!forceRefresh) {
        final cached = await sqlDataSource.getPosts();
        if (cached.isNotEmpty) {
          return Result.ok(cached.map((e) => e.toEntity()).toList());
        }
      }

      final result = await elonRemoteDataSource.getElons();
      return result.fold(
        (error) => Result.error(error),
        (models) async {
          await sqlDataSource.savePosts(models);
          return Result.ok(models.map((e) => e.toEntity()).toList());
        },
      );
    } catch (e) {
      final cached = await sqlDataSource.getPosts();
      if (cached.isNotEmpty) return Result.ok(cached.map((e) => e.toEntity()).toList());
      return Result.error(Exception('Failed to load posts: $e'));
    }
  }

  @override
  Future<Result<List<PostEntity>>> getPostsByGroup(String groupId, {bool forceRefresh = false}) async {
    try {
      final result = await elonRemoteDataSource.getElonsByGroup(groupId: groupId);
      return result.fold(
        (error) => Result.error(error),
        (models) => Result.ok(models.map((e) => e.toEntity()).toList()),
      );
    } catch (e) {
      return Result.error(Exception('Failed to load posts by group: $e'));
    }
  }

  @override
  Future<Result<List<PostEntity>>> getPostsByCategory(String categoryId, {bool forceRefresh = false}) async {
    try {
      if (!forceRefresh) {
        final cached = await sqlDataSource.getPosts(categoryId: categoryId);
        if (cached.isNotEmpty) {
          return Result.ok(cached.map((e) => e.toEntity()).toList());
        }
      }

      final result = await elonRemoteDataSource.getElonsByCategory(categoryId: categoryId);
      return result.fold(
        (error) => Result.error(error),
        (models) async {
          await sqlDataSource.savePosts(models);
          return Result.ok(models.map((e) => e.toEntity()).toList());
        },
      );
    } catch (e) {
      final cached = await sqlDataSource.getPosts(categoryId: categoryId);
      if (cached.isNotEmpty) return Result.ok(cached.map((e) => e.toEntity()).toList());
      return Result.error(Exception('Failed to load posts by category: $e'));
    }
  }

  @override
  Future<Result<List<GroupEntity>>> getGroupsByCategory(String categoryId, {bool forceRefresh = false}) async {
    try {
      if (!forceRefresh) {
        final cached = await sqlDataSource.getGroupsByCategory(categoryId);
        if (cached.isNotEmpty) {
          return Result.ok(cached.map((e) => e.toEntity()).toList());
        }
      }

      final result = await categoryRemoteDataSource.getGroupsByCategory(categoryId);
      await sqlDataSource.saveGroups(result);
      return Result.ok(result.map((e) => e.toEntity()).toList());
    } catch (e) {
      final cached = await sqlDataSource.getGroupsByCategory(categoryId);
      if (cached.isNotEmpty) return Result.ok(cached.map((e) => e.toEntity()).toList());
      return Result.error(Exception('Failed to load groups by category: $e'));
    }
  }

  @override
  Future<Result<List<PostEntity>>> getMyPosts({bool forceRefresh = false}) async {
    try {
      final result = await elonRemoteDataSource.getMyElons();
      return result.fold(
        (error) => Result.error(error),
        (models) => Result.ok(models.map((e) => e.toEntity()).toList()),
      );
    } catch (e) {
      return Result.error(Exception('Failed to load my posts: $e'));
    }
  }

  @override
  Future<Result<PostEntity>> createPost({
    required String content,
    required List<PostImageEntity> images,
    required PostCategoryEntity category,
    String? price,
    String? adressname,
    String? supCategoryId,
  }) async {
    try {
      final photoPaths = images.where((e) => e.isLocal).map((e) => e.path).toList();
      
      final result = await elonRemoteDataSource.createElon(
        text: content,
        categoryId: category.id,
        supCategoryId: supCategoryId ?? category.parentId,
        price: price,
        adressname: adressname,
        photosPaths: photoPaths,
      );

      return result.fold(
        (error) => Result.error(error),
        (model) => Result.ok(model.toEntity()),
      );
    } catch (e) {
      return Result.error(Exception('Failed to create post: $e'));
    }
  }

  @override
  Future<Result<PostEntity?>> getPostById(String id) async {
    try {
      final result = await elonRemoteDataSource.getElonById(id);
      return result.fold(
        (error) => Result.error(error),
        (model) => Result.ok(model.toEntity()),
      );
    } catch (e) {
      return Result.error(Exception('Failed to load post by id: $e'));
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
  Future<Result<List<PostCategoryEntity>>> getCategories({bool forceRefresh = false}) async {
    try {
      if (!forceRefresh) {
        final cached = await sqlDataSource.getCategories();
        if (cached.isNotEmpty) {
          return Result.ok(cached.map((e) => e.toEntity()).toList());
        }
      }

      final categories = await categoryRemoteDataSource.getCategories();
      List<PostCategoryModel> subcategories = [];
      try {
        subcategories = await categoryRemoteDataSource.getSubCategories();
      } catch (e) {
        print('Error loading subcategories: $e');
      }

      final populatedCategories = categories.map((category) {
        final categorySubs = subcategories
            .where((sub) => sub.parentId == category.id)
            .map((sub) => sub.toEntity())
            .toList();

        return PostCategoryModel(
          id: category.id,
          name: category.name,
          iconPath: category.iconPath,
          parentId: category.parentId,
          subcategories: categorySubs.isEmpty ? null : categorySubs,
        );
      }).toList();

      await sqlDataSource.saveCategories(populatedCategories);
      return Result.ok(populatedCategories.map((e) => e.toEntity()).toList());
    } catch (e) {
      final cached = await sqlDataSource.getCategories();
      if (cached.isNotEmpty) return Result.ok(cached.map((e) => e.toEntity()).toList());
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
      print('🔍 HomeRepository: Checking user role. Token exists: ${token != null && token.isNotEmpty}');
      if (token != null && token.isNotEmpty) {
        return Result.ok(UserRole.user); // Assuming standard user role for now
      }
      return Result.ok(UserRole.guest);
    } catch (e) {
      print('❌ HomeRepository: Error getting user role: $e');
      return Result.ok(UserRole.guest); // Fallback to guest if something fails
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
      final result = await elonRemoteDataSource.updateElonStatus(postId, status.value);
      return result.fold(
        (error) => Result.error(error),
        (_) {
          localDataSource.updatePostStatus(postId, status);
          return Result.ok(null);
        },
      );
    } catch (e) {
      return Result.error(Exception('Failed to update post status: $e'));
    }
  }
}
