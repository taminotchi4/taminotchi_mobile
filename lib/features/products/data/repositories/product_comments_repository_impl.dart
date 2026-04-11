import '../../../../core/utils/result.dart';
import '../../domain/entities/product_comment_entity.dart';
import '../../domain/repositories/product_comments_repository.dart';
import '../datasources/product_comments_remote_data_source.dart';
import '../datasources/product_comments_local_data_source.dart';

class ProductCommentsRepositoryImpl implements ProductCommentsRepository {
  final ProductCommentsRemoteDataSource remoteDataSource;
  final ProductCommentsLocalDataSource localDataSource;

  /// productId -> commentId mapping (filled when product is loaded)
  final Map<String, String> _commentIdCache = {};

  ProductCommentsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  /// commentId ni cache ga saqlaydi (ProductDetailsBloc yoki ProductsBloc dan chaqiriladi)
  void cacheCommentId(String productId, String commentId) {
    _commentIdCache[productId] = commentId;
  }

  @override
  Future<Result<List<ProductCommentEntity>>> getComments(
    String productId,
  ) async {
    final commentId = _commentIdCache[productId];
    if (commentId == null || commentId.isEmpty) {
      // commentId yo'q — bo'sh ro'yxat qaytaramiz
      return Result.ok([]);
    }
    final result = await remoteDataSource.getMessages(commentId, productId);
    return result.fold(
      (error) => Result.error(error),
      (models) => Result.ok(
          models.map((m) => m.toEntity(productId)).toList()),
    );
  }

  @override
  Future<Result<ProductCommentEntity>> addComment(
    ProductCommentEntity comment,
  ) async {
    final commentId = _commentIdCache[comment.productId];
    if (commentId == null || commentId.isEmpty) {
      return Result.error(Exception('commentId topilmadi'));
    }
    final result = await remoteDataSource.sendMessage(
      commentId: commentId,
      text: comment.content,
      productId: comment.productId,
    );
    return result.fold(
      (error) => Result.error(error),
      (model) => Result.ok(model.toEntity(comment.productId)),
    );
  }

  @override
  Future<Result<ProductCommentEntity>> updateComment(
    String commentId,
    String content,
  ) async {
    // Update local optimistically (backend update endpoint may vary)
    try {
      final updated = localDataSource.updateComment(commentId, content);
      return Result.ok(updated);
    } catch (_) {
      return Result.error(Exception('Izohni yangilashda xatolik'));
    }
  }

  @override
  Future<Result<void>> deleteComment(String commentId) async {
    final result = await remoteDataSource.deleteMessage(commentId);
    return result.fold(
      (error) => Result.error(error),
      (_) {
        localDataSource.deleteComment(commentId);
        return const Result.ok(null);
      },
    );
  }
}
