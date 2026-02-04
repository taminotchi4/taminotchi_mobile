class ProductDetailsState {
  final double rating;
  final bool isLoading;

  const ProductDetailsState({
    required this.rating,
    required this.isLoading,
  });

  factory ProductDetailsState.initial() => const ProductDetailsState(
    rating: 0,
    isLoading: false,
  );

  ProductDetailsState copyWith({
    double? rating,
    bool? isLoading,
  }) {
    return ProductDetailsState(
      rating: rating ?? this.rating,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
