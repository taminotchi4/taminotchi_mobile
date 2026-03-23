import '../../../../core/utils/result.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/repositories/home_repository.dart';

class GetPostsByCategoryUseCase {
  final HomeRepository repository;

  GetPostsByCategoryUseCase(this.repository);

  Future<Result<List<PostEntity>>> call(String categoryId) {
    return repository.getPostsByCategory(categoryId);
  }
}
