import '../../../../core/utils/result.dart';
import '../entities/product_category_entity.dart';
import '../entities/product_entity.dart';

abstract class ProductsRepository {
  Future<Result<List<ProductEntity>>> getProducts({bool forceRefresh = false});

  Future<Result<ProductEntity?>> getProductById(String id);

  Future<Result<List<ProductCategoryEntity>>> getCategories({bool forceRefresh = false});
}
