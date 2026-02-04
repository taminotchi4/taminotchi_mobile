import '../../domain/entities/product_comment_entity.dart';

sealed class ProductCommentsEvent {
  const ProductCommentsEvent();
}

class ProductCommentsStarted extends ProductCommentsEvent {
  final String productId;

  const ProductCommentsStarted(this.productId);
}

class ProductCommentAdded extends ProductCommentsEvent {
  final ProductCommentEntity comment;

  const ProductCommentAdded(this.comment);
}

class ProductCommentUpdated extends ProductCommentsEvent {
  final String commentId;
  final String content;

  const ProductCommentUpdated(this.commentId, this.content);
}

class ProductCommentDeleted extends ProductCommentsEvent {
  final String commentId;

  const ProductCommentDeleted(this.commentId);
}
