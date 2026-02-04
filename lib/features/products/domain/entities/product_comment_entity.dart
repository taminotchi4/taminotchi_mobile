enum ProductCommentAuthor { user, seller }

class ProductCommentEntity {
  final String id;
  final String productId;
  final String userId;
  final String userName;
  final ProductCommentAuthor authorType;
  final String content;
  final DateTime createdAt;

  const ProductCommentEntity({
    required this.id,
    required this.productId,
    required this.userId,
    required this.userName,
    required this.authorType,
    required this.content,
    required this.createdAt,
  });
}
