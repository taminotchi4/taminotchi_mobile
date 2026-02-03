import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/product_category_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/usecases/get_product_by_id_usecase.dart';
import '../../domain/usecases/get_product_categories_usecase.dart';
import '../../domain/usecases/get_products_usecase.dart';
import 'products_event.dart';
import 'products_state.dart';

class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  static const int _loadMoreStep = 10;
  final GetProductsUseCase getProductsUseCase;
  final GetProductByIdUseCase getProductByIdUseCase;
  final GetProductCategoriesUseCase getCategoriesUseCase;

  ProductsBloc({
    required this.getProductsUseCase,
    required this.getProductByIdUseCase,
    required this.getCategoriesUseCase,
  }) : super(ProductsState.initial()) {
    on<ProductsStarted>(_onStarted);
    on<ProductsLoadMore>(_onLoadMore);
    on<ProductsSelectCategory>(_onSelectCategory);
    on<ProductsUpdateSearch>(_onUpdateSearch);
    on<ProductsLoadDetail>(_onLoadDetail);
  }

  Future<void> _onStarted(
    ProductsStarted event,
    Emitter<ProductsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    var categories = state.categories;
    final categoriesResult = await getCategoriesUseCase();
    categoriesResult.fold(
      (_) {},
      (loaded) => categories = loaded,
    );
    final productsResult = await getProductsUseCase();
    productsResult.fold(
      (_) => emit(state.copyWith(isLoading: false)),
      (products) {
        final selected = categories.isEmpty ? null : categories.first;
        final filtered = _applyFilters(products, selected, state.searchQuery);
        final visible = _visibleProducts(filtered, state.visibleCount);
        emit(state.copyWith(
          isLoading: false,
          products: products,
          categories: categories,
          selectedCategory: selected,
          filteredProducts: filtered,
          visibleProducts: visible,
          categoryCounts: _buildCounts(products),
        ));
      },
    );
  }

  void _onLoadMore(ProductsLoadMore event, Emitter<ProductsState> emit) {
    final newCount = state.visibleCount + _loadMoreStep;
    final visible = _visibleProducts(state.filteredProducts, newCount);
    emit(state.copyWith(
      visibleCount: newCount,
      visibleProducts: visible,
    ));
  }

  void _onSelectCategory(
    ProductsSelectCategory event,
    Emitter<ProductsState> emit,
  ) {
    final filtered =
        _applyFilters(state.products, event.category, state.searchQuery);
    final visible = _visibleProducts(
      filtered,
      ProductsState.initialVisibleCount,
    );
    emit(state.copyWith(
      selectedCategory: event.category,
      filteredProducts: filtered,
      visibleProducts: visible,
      visibleCount: ProductsState.initialVisibleCount,
    ));
  }

  void _onUpdateSearch(
    ProductsUpdateSearch event,
    Emitter<ProductsState> emit,
  ) {
    final filtered =
        _applyFilters(state.products, state.selectedCategory, event.query);
    final visible = _visibleProducts(
      filtered,
      ProductsState.initialVisibleCount,
    );
    emit(state.copyWith(
      searchQuery: event.query,
      filteredProducts: filtered,
      visibleProducts: visible,
      visibleCount: ProductsState.initialVisibleCount,
    ));
  }

  Future<void> _onLoadDetail(
    ProductsLoadDetail event,
    Emitter<ProductsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    final result = await getProductByIdUseCase(event.productId);
    result.fold(
      (_) => emit(state.copyWith(isLoading: false)),
      (product) => emit(state.copyWith(
        isLoading: false,
        activeProduct: product,
      )),
    );
  }

  List<ProductEntity> _applyFilters(
    List<ProductEntity> products,
    ProductCategoryEntity? category,
    String query,
  ) {
    var filtered = products;
    if (category != null && category.id != 'all') {
      filtered = filtered
          .where((product) => product.category.id == category.id)
          .toList();
    }
    if (query.trim().isNotEmpty) {
      final lowerQuery = query.toLowerCase();
      filtered = filtered
          .where((product) =>
              product.name.toLowerCase().contains(lowerQuery) ||
              product.description.toLowerCase().contains(lowerQuery))
          .toList();
    }
    return filtered;
  }

  List<ProductEntity> _visibleProducts(
    List<ProductEntity> products,
    int count,
  ) {
    if (products.length <= count) return products;
    return products.take(count).toList();
  }

  Map<String, int> _buildCounts(List<ProductEntity> products) {
    final counts = <String, int>{};
    counts['all'] = products.length;
    for (final product in products) {
      counts[product.category.id] = (counts[product.category.id] ?? 0) + 1;
    }
    return counts;
  }
}
