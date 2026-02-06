import '../../domain/entities/product_comment_entity.dart';

class ProductCommentsLocalDataSource {
  final Map<String, List<ProductCommentEntity>> _comments = {};

  List<ProductCommentEntity> getComments(String productId) {
    return List.unmodifiable(_comments[productId] ?? []);
  }

  ProductCommentEntity addComment(ProductCommentEntity comment) {
    final list = _comments.putIfAbsent(comment.productId, () => []);
    list.add(comment);
    return comment;
  }

  ProductCommentEntity updateComment(String commentId, String content) {
    for (final entry in _comments.entries) {
      final index = entry.value.indexWhere((item) => item.id == commentId);
      if (index != -1) {
        final current = entry.value[index];
        final updated = ProductCommentEntity(
          id: current.id,
          productId: current.productId,
          userId: current.userId,
          userName: current.userName,
          authorType: current.authorType,
          content: content,
          createdAt: current.createdAt,
          rating: current.rating,
        );
        entry.value[index] = updated;
        return updated;
      }
    }
    throw Exception('Comment not found');
  }

  void deleteComment(String commentId) {
    for (final entry in _comments.entries) {
      entry.value.removeWhere((item) => item.id == commentId);
    }
  }
}
