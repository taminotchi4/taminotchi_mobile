import '../../../../core/utils/result.dart';
import '../entities/product_category_entity.dart';
import '../repositories/products_repository.dart';

class GetProductCategoriesUseCase {
  final ProductsRepository repository;

  const GetProductCategoriesUseCase(this.repository);

  Future<Result<List<ProductCategoryEntity>>> call() =>
      repository.getCategories();
}
