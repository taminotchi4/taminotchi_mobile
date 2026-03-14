import '../../../../core/utils/result.dart';
import '../entities/product_comment_entity.dart';
import '../repositories/product_comments_repository.dart';

class GetProductCommentsUseCase {
  final ProductCommentsRepository repository;

  const GetProductCommentsUseCase(this.repository);

  Future<Result<List<ProductCommentEntity>>> call(String productId) {
    return repository.getComments(productId);
  }
}
