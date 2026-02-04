import '../../domain/entities/product_comment_entity.dart';

class ProductCommentsState {
  final List<ProductCommentEntity> comments;
  final bool isLoading;

  const ProductCommentsState({
    required this.comments,
    required this.isLoading,
  });

  factory ProductCommentsState.initial() => const ProductCommentsState(
    comments: [],
    isLoading: false,
  );

  ProductCommentsState copyWith({
    List<ProductCommentEntity>? comments,
    bool? isLoading,
  }) {
    return ProductCommentsState(
      comments: comments ?? this.comments,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
