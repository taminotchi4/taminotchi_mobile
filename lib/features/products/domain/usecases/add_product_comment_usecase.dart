import '../../../../core/utils/result.dart';
import '../entities/product_comment_entity.dart';
import '../repositories/product_comments_repository.dart';

class AddProductCommentUseCase {
  final ProductCommentsRepository repository;

  const AddProductCommentUseCase(this.repository);

  Future<Result<ProductCommentEntity>> call(ProductCommentEntity comment) {
    return repository.addComment(comment);
  }
}
