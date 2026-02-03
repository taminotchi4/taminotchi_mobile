import '../../domain/entities/product_category_entity.dart';

sealed class ProductsEvent {
  const ProductsEvent();
}

class ProductsStarted extends ProductsEvent {
  const ProductsStarted();
}

class ProductsLoadMore extends ProductsEvent {
  const ProductsLoadMore();
}

class ProductsSelectCategory extends ProductsEvent {
  final ProductCategoryEntity category;

  const ProductsSelectCategory(this.category);
}

class ProductsUpdateSearch extends ProductsEvent {
  final String query;

  const ProductsUpdateSearch(this.query);
}

class ProductsLoadDetail extends ProductsEvent {
  final String productId;

  const ProductsLoadDetail(this.productId);
}
