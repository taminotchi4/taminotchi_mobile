import '../../../../core/utils/result.dart';
import '../../domain/entities/product_category_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/products_repository.dart';
import '../datasources/products_local_data_source.dart';

class ProductsRepositoryImpl implements ProductsRepository {
  final ProductsLocalDataSource localDataSource;

  const ProductsRepositoryImpl(this.localDataSource);

  @override
  Future<Result<List<ProductEntity>>> getProducts() async {
    try {
      final products =
          localDataSource.getProducts().map((e) => e.toEntity()).toList();
      return Result.ok(products);
    } catch (_) {
      return Result.error(Exception('Failed to load products'));
    }
  }

  @override
  Future<Result<ProductEntity?>> getProductById(String id) async {
    try {
      final product = localDataSource.getProductById(id)?.toEntity();
      return Result.ok(product);
    } catch (_) {
      return Result.error(Exception('Failed to load product'));
    }
  }

  @override
  Future<Result<List<ProductCategoryEntity>>> getCategories() async {
    try {
      final categories =
          localDataSource.getCategories().map((e) => e.toEntity()).toList();
      return Result.ok(categories);
    } catch (_) {
      return Result.error(Exception('Failed to load categories'));
    }
  }
}
