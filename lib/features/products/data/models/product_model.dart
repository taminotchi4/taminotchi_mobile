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

  factory SellerModel.fromJson(Map<String, dynamic> json) {
    return SellerModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      avatarPath: json['photoPath'] as String? ?? '',
    );
  }

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

  factory ProductCategoryModel.fromJson(Map<String, dynamic> json) {
    return ProductCategoryModel(
      id: json['id'] as String? ?? '',
      name: (json['nameUz'] ?? json['nameRu'] ?? '') as String,
      iconPath: (json['iconUrl'] ?? json['photoUrl'] ?? '') as String,
    );
  }

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
  final List<int> colors;
  final List<String> sizes;
  final ProductCategoryModel category;
  final String? commentId;

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
    this.commentId,
    this.colors = const [],
    this.sizes = const [],
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // Parse photos list
    final List<dynamic> photosRaw = json['photos'] as List<dynamic>? ?? [];
    final photos = photosRaw
        .map((p) => (p as Map<String, dynamic>)['path'] as String? ?? '')
        .where((p) => p.isNotEmpty)
        .toList();

    // Parse price
    double parsedPrice = 0.0;
    final rawPrice = json['price'];
    if (rawPrice != null) {
      parsedPrice = double.tryParse(rawPrice.toString()) ?? 0.0;
    }

    // Parse category
    ProductCategoryModel category;
    if (json['supCategory'] != null) {
      category = ProductCategoryModel.fromJson(
          json['supCategory'] as Map<String, dynamic>);
    } else if (json['category'] != null) {
      category = ProductCategoryModel.fromJson(
          json['category'] as Map<String, dynamic>);
    } else {
      category = const ProductCategoryModel(
          id: 'unknown', name: 'Boshqa', iconPath: '');
    }

    // Parse seller/market
    SellerModel seller;
    if (json['market'] != null) {
      seller = SellerModel.fromJson(json['market'] as Map<String, dynamic>);
    } else {
      seller = const SellerModel(id: '', name: 'Noma\'lum', avatarPath: '');
    }

    // Parse comment info
    int reviewCount = 0;
    String? commentId;
    if (json['comment'] != null) {
      final commentData = json['comment'] as Map<String, dynamic>;
      reviewCount = commentData['messageCount'] as int? ?? 0;
      commentId = commentData['id'] as String?;
    }
    commentId ??= json['commentId'] as String?;

    return ProductModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: parsedPrice,
      rating: 0.0,
      reviewCount: reviewCount,
      imagePaths: photos,
      seller: seller,
      category: category,
      commentId: commentId,
    );
  }

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
        commentId: commentId,
        colors: colors,
        sizes: sizes,
      );
}
