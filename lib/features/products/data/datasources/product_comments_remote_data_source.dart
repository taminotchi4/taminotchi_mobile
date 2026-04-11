import '../../../../core/network/client.dart';
import '../../../../core/utils/result.dart';
import '../models/product_comment_model.dart';

abstract class ProductCommentsRemoteDataSource {
  /// Mahsulot izohlarini olish (commentId orqali)
  Future<Result<List<ProductCommentModel>>> getMessages(String commentId, String productId);

  /// Yangi izoh yuborish
  Future<Result<ProductCommentModel>> sendMessage({
    required String commentId,
    required String text,
    required String productId,
  });

  /// Izohni o'chirish
  Future<Result<void>> deleteMessage(String messageId);
}

class ProductCommentsRemoteDataSourceImpl
    implements ProductCommentsRemoteDataSource {
  final ApiClient client;

  ProductCommentsRemoteDataSourceImpl({required this.client});

  @override
  Future<Result<List<ProductCommentModel>>> getMessages(
    String commentId,
    String productId,
  ) async {
    final response = await client.get<Map<String, dynamic>>(
      'comment/$commentId/messages?page=1&limit=100',
    );

    return response.fold(
      (error) => Result.error(error),
      (data) {
        try {
          final List<dynamic> list = data['data'] as List<dynamic>? ?? [];
          final messages = list
              .map((json) => ProductCommentModel.fromJson(
                    json as Map<String, dynamic>,
                  ))
              .toList();
          return Result.ok(messages);
        } catch (e) {
          return Result.error(
              Exception('Izohlarni parse qilishda xatolik: $e'));
        }
      },
    );
  }

  @override
  Future<Result<ProductCommentModel>> sendMessage({
    required String commentId,
    required String text,
    required String productId,
  }) async {
    final response = await client.post<Map<String, dynamic>>(
      'comment/$commentId/messages',
      data: {'text': text},
    );

    return response.fold(
      (error) => Result.error(error),
      (data) {
        try {
          final msgData = data['data'] as Map<String, dynamic>? ?? {};
          return Result.ok(ProductCommentModel.fromJson(msgData));
        } catch (e) {
          return Result.error(Exception('Izohni parse qilishda xatolik: $e'));
        }
      },
    );
  }

  @override
  Future<Result<void>> deleteMessage(String messageId) async {
    final response = await client.delete<Map<String, dynamic>>(
      'comment/messages/$messageId',
    );

    return response.fold(
      (error) => Result.error(error),
      (_) => const Result.ok(null),
    );
  }
}
