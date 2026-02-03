import '../../../../core/utils/result.dart';
import '../entities/post_category_entity.dart';
import '../repositories/home_repository.dart';

class GetCategoriesUseCase {
  final HomeRepository repository;

  const GetCategoriesUseCase(this.repository);

  Future<Result<List<PostCategoryEntity>>> call() => repository.getCategories();
}
