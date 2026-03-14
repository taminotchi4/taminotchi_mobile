import '../../domain/entities/product_category_entity.dart';
import '../../domain/entities/product_entity.dart';

class ProductsState {
  static const int initialVisibleCount = 20;
  final List<ProductEntity> products;
  final List<ProductCategoryEntity> categories;
  final ProductCategoryEntity? selectedCategory;
  final String searchQuery;
  final int visibleCount;
  final List<ProductEntity> visibleProducts;
  final List<ProductEntity> filteredProducts;
  final Map<String, int> categoryCounts;
  final ProductEntity? activeProduct;
  final bool isLoading;

  const ProductsState({
    required this.products,
    required this.categories,
    required this.selectedCategory,
    required this.searchQuery,
    required this.visibleCount,
    required this.visibleProducts,
    required this.filteredProducts,
    required this.categoryCounts,
    required this.activeProduct,
    required this.isLoading,
  });

  factory ProductsState.initial() => const ProductsState(
    products: [],
    categories: [],
    selectedCategory: null,
    searchQuery: '',
    visibleCount: initialVisibleCount,
    visibleProducts: [],
    filteredProducts: [],
    categoryCounts: {},
    activeProduct: null,
    isLoading: false,
  );

  ProductsState copyWith({
    List<ProductEntity>? products,
    List<ProductCategoryEntity>? categories,
    ProductCategoryEntity? selectedCategory,
    String? searchQuery,
    int? visibleCount,
    List<ProductEntity>? visibleProducts,
    List<ProductEntity>? filteredProducts,
    Map<String, int>? categoryCounts,
    ProductEntity? activeProduct,
    bool? isLoading,
  }) {
    return ProductsState(
      products: products ?? this.products,
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      visibleCount: visibleCount ?? this.visibleCount,
      visibleProducts: visibleProducts ?? this.visibleProducts,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      categoryCounts: categoryCounts ?? this.categoryCounts,
      activeProduct: activeProduct ?? this.activeProduct,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
