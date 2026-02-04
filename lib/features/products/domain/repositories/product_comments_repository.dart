import '../../../../core/utils/result.dart';
import '../entities/product_comment_entity.dart';

abstract class ProductCommentsRepository {
  Future<Result<List<ProductCommentEntity>>> getComments(String productId);

  Future<Result<ProductCommentEntity>> addComment(ProductCommentEntity comment);

  Future<Result<ProductCommentEntity>> updateComment(
    String commentId,
    String content,
  );

  Future<Result<void>> deleteComment(String commentId);
}
