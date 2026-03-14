import 'product_category_entity.dart';
import 'seller_entity.dart';

class ProductEntity {
  final String id;
  final String name;
  final String description;
  final double price;
  final double rating;
  final int reviewCount;
  final List<String> imagePaths;
  final SellerEntity seller;
  final ProductCategoryEntity category;

  const ProductEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.rating,
    required this.reviewCount,
    required this.imagePaths,
    required this.seller,
    required this.category,
    this.colors = const [],
    this.sizes = const [],
  });
  
  final List<int> colors;
  final List<String> sizes;
}
