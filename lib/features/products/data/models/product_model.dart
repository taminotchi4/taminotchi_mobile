import '../../domain/entities/product_category_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/entities/seller_entity.dart';

class SellerModel {
  final String id;
  final String name;
  final String avatarPath;

  const SellerModel({
    required this.id,
    required this.name,
    required this.avatarPath,
  });

  SellerEntity toEntity() =>
      SellerEntity(id: id, name: name, avatarPath: avatarPath);
}

class ProductCategoryModel {
  final String id;
  final String name;
  final String iconPath;

  const ProductCategoryModel({
    required this.id,
    required this.name,
    required this.iconPath,
  });

  ProductCategoryEntity toEntity() =>
      ProductCategoryEntity(id: id, name: name, iconPath: iconPath);
}

class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final double rating;
  final int reviewCount;
  final List<String> imagePaths;
  final SellerModel seller;
  final ProductCategoryModel category;

  const ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.rating,
    required this.reviewCount,
    required this.imagePaths,
    required this.seller,
    required this.category,
  });

  ProductEntity toEntity() => ProductEntity(
    id: id,
    name: name,
    description: description,
    price: price,
    rating: rating,
    reviewCount: reviewCount,
    imagePaths: imagePaths,
    seller: seller.toEntity(),
    category: category.toEntity(),
  );
}
