import '../../../products/domain/entities/product_category_entity.dart';

sealed class SellerProfileEvent {
  const SellerProfileEvent();
}

class SellerProfileStarted extends SellerProfileEvent {
  final String sellerId;

  const SellerProfileStarted(this.sellerId);
}

class SellerProfileToggleFollow extends SellerProfileEvent {
  const SellerProfileToggleFollow();
}

class SellerProfileOpenFollowers extends SellerProfileEvent {
  const SellerProfileOpenFollowers();
}

class SellerProfileFilterCategory extends SellerProfileEvent {
  final ProductCategoryEntity? category;

  const SellerProfileFilterCategory(this.category);
}

class SellerProfileSortChanged extends SellerProfileEvent {
  final SellerProductSort sort;

  const SellerProfileSortChanged(this.sort);
}

enum SellerProductSort { none, mostSold, highestRating }
