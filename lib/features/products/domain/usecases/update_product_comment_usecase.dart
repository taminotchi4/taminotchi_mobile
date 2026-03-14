import '../../../../core/utils/result.dart';
import '../entities/product_comment_entity.dart';
import '../repositories/product_comments_repository.dart';

class UpdateProductCommentUseCase {
  final ProductCommentsRepository repository;

  const UpdateProductCommentUseCase(this.repository);

  Future<Result<ProductCommentEntity>> call(
    String commentId,
    String content,
  ) {
    return repository.updateComment(commentId, content);
  }
}
