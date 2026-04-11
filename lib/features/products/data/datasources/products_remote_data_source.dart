import '../../../../core/network/client.dart';
import '../../../../core/utils/result.dart';
import '../models/product_model.dart';

abstract class ProductsRemoteDataSource {
  Future<Result<List<ProductModel>>> getProducts({
    int page = 1,
    int limit = 50,
  });

  Future<Result<ProductModel>> getProductById(String id);
}

class ProductsRemoteDataSourceImpl implements ProductsRemoteDataSource {
  final ApiClient client;

  ProductsRemoteDataSourceImpl({required this.client});

  @override
  Future<Result<List<ProductModel>>> getProducts({
    int page = 1,
    int limit = 50,
  }) async {
    final response = await client.get<Map<String, dynamic>>(
      'product?page=$page&limit=$limit',
    );

    return response.fold(
      (error) => Result.error(error),
      (data) {
        try {
          final List<dynamic> list = data['data'] as List<dynamic>? ?? [];
          final products =
              list.map((json) => ProductModel.fromJson(json as Map<String, dynamic>)).toList();
          return Result.ok(products);
        } catch (e) {
          return Result.error(Exception('Mahsulotlarni parse qilishda xatolik: $e'));
        }
      },
    );
  }

  @override
  Future<Result<ProductModel>> getProductById(String id) async {
    final response = await client.get<Map<String, dynamic>>('product/$id');

    return response.fold(
      (error) => Result.error(error),
      (data) {
        try {
          return Result.ok(ProductModel.fromJson(data['data'] as Map<String, dynamic>));
        } catch (e) {
          return Result.error(Exception('Mahsulotni parse qilishda xatolik: $e'));
        }
      },
    );
  }
}
