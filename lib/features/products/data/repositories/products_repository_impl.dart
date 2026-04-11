import '../../../../core/utils/result.dart';
import '../../domain/entities/product_category_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/products_repository.dart';
import '../datasources/products_remote_data_source.dart';

class ProductsRepositoryImpl implements ProductsRepository {
  final ProductsRemoteDataSource remoteDataSource;

  const ProductsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Result<List<ProductEntity>>> getProducts({bool forceRefresh = false}) async {
    try {
      final result = await remoteDataSource.getProducts();
      return result.fold(
        (error) => Result.error(error),
        (products) => Result.ok(products.map((e) => e.toEntity()).toList()),
      );
    } catch (e) {
      return Result.error(Exception('Mahsulotlarni yuklashda xatolik: $e'));
    }
  }

  @override
  Future<Result<ProductEntity?>> getProductById(String id) async {
    try {
      final result = await remoteDataSource.getProductById(id);
      return result.fold(
        (error) => Result.error(error),
        (product) => Result.ok(product.toEntity()),
      );
    } catch (e) {
      return Result.error(Exception('Mahsulotni yuklashda xatolik: $e'));
    }
  }

  @override
  Future<Result<List<ProductCategoryEntity>>> getCategories({bool forceRefresh = false}) async {
    // Categories are derived from products – return empty list;
    // category bar in AllProductsPage will populate from loaded products.
    return Result.ok([]);
  }
}
