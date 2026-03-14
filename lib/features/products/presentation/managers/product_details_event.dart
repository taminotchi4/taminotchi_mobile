sealed class ProductDetailsEvent {
  const ProductDetailsEvent();
}

class ProductDetailsStarted extends ProductDetailsEvent {
  final String productId;

  const ProductDetailsStarted(this.productId);
}

class ProductRatingUpdated extends ProductDetailsEvent {
  final double rating;

  const ProductRatingUpdated(this.rating);
}
