import '../../../../core/utils/result.dart';
import '../entities/product_entity.dart';
import '../repositories/products_repository.dart';

class GetProductByIdUseCase {
  final ProductsRepository repository;

  const GetProductByIdUseCase(this.repository);

  Future<Result<ProductEntity?>> call(String id) =>
      repository.getProductById(id);
}
