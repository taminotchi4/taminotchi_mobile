import '../../../../core/utils/result.dart';
import '../entities/product_entity.dart';
import '../repositories/products_repository.dart';

class GetProductsUseCase {
  final ProductsRepository repository;

  const GetProductsUseCase(this.repository);

  Future<Result<List<ProductEntity>>> call() => repository.getProducts();
}
