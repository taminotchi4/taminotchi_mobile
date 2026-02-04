import '../../../../core/utils/result.dart';
import '../../domain/entities/product_comment_entity.dart';
import '../../domain/repositories/product_comments_repository.dart';
import '../datasources/product_comments_local_data_source.dart';

class ProductCommentsRepositoryImpl implements ProductCommentsRepository {
  final ProductCommentsLocalDataSource localDataSource;

  const ProductCommentsRepositoryImpl(this.localDataSource);

  @override
  Future<Result<List<ProductCommentEntity>>> getComments(
    String productId,
  ) async {
    try {
      return Result.ok(localDataSource.getComments(productId));
    } catch (_) {
      return Result.error(Exception('Failed to load comments'));
    }
  }

  @override
  Future<Result<ProductCommentEntity>> addComment(
    ProductCommentEntity comment,
  ) async {
    try {
      return Result.ok(localDataSource.addComment(comment));
    } catch (_) {
      return Result.error(Exception('Failed to add comment'));
    }
  }

  @override
  Future<Result<ProductCommentEntity>> updateComment(
    String commentId,
    String content,
  ) async {
    try {
      return Result.ok(localDataSource.updateComment(commentId, content));
    } catch (_) {
      return Result.error(Exception('Failed to update comment'));
    }
  }

  @override
  Future<Result<void>> deleteComment(String commentId) async {
    try {
      localDataSource.deleteComment(commentId);
      return const Result.ok(null);
    } catch (_) {
      return Result.error(Exception('Failed to delete comment'));
    }
  }
}
