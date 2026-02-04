import '../../../../core/utils/result.dart';
import '../repositories/product_comments_repository.dart';

class DeleteProductCommentUseCase {
  final ProductCommentsRepository repository;

  const DeleteProductCommentUseCase(this.repository);

  Future<Result<void>> call(String commentId) {
    return repository.deleteComment(commentId);
  }
}
