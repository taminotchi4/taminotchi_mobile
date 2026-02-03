import '../../../../core/utils/icons.dart';
import '../models/product_model.dart';

class ProductsLocalDataSource {
  static final List<ProductModel> _products = [];
  static bool _initialized = false;

  final List<ProductCategoryModel> _categories = const [
    ProductCategoryModel(
      id: 'all',
      name: 'Barchasi',
      iconPath: AppIcons.category,
    ),
    ProductCategoryModel(
      id: 'tech',
      name: 'Texnika',
      iconPath: AppIcons.categoryTech,
    ),
    ProductCategoryModel(
      id: 'food',
      name: 'Oziq-ovqat',
      iconPath: AppIcons.categoryFood,
    ),
    ProductCategoryModel(
      id: 'service',
      name: 'Xizmatlar',
      iconPath: AppIcons.categoryService,
    ),
    ProductCategoryModel(
      id: 'event',
      name: 'Tadbirlar',
      iconPath: AppIcons.categoryEvent,
    ),
  ];

  void ensureSeeded() {
    if (_initialized) return;
    _initialized = true;

    final seller1 = const SellerModel(
      id: 'seller_1',
      name: 'Market Plus',
      avatarPath: AppIcons.user,
    );
    final seller2 = const SellerModel(
      id: 'seller_2',
      name: 'Smart Store',
      avatarPath: AppIcons.user,
    );

    const double basePrice = 120000;
    const double priceStep = 3500;
    const baseReviews = 12;
    const reviewStep = 2;
    const baseRating = 4.2;
    const ratingStep = 0.1;

    final images = [
      AppImages.product1,
      AppImages.product2,
      AppImages.product3,
      AppImages.product4,
      AppImages.product5,
      AppImages.product6,
      AppImages.product7,
      AppImages.product8,
    ];

    final categories = _categories.where((cat) => cat.id != 'all').toList();

    const seedCount = 20;
    for (var i = 0; i < seedCount; i++) {
      final category = categories[i % categories.length];
      final seller = i.isEven ? seller1 : seller2;
      final productImages = [
        images[i % images.length],
        images[(i + 1) % images.length],
      ];
      _products.add(
        ProductModel(
          id: 'product_$i',
          name: 'Mahsulot nomi $i',
          description:
              'Bu mahsulot haqida qisqacha ma\'lumot. Sifatli va ishonchli.',
          price: basePrice + i * priceStep,
          rating: baseRating + (i % 5) * ratingStep,
          reviewCount: baseReviews + i * reviewStep,
          imagePaths: productImages,
          seller: seller,
          category: category,
        ),
      );
    }
  }

  List<ProductModel> getProducts() {
    ensureSeeded();
    return List.unmodifiable(_products);
  }

  ProductModel? getProductById(String id) {
    ensureSeeded();
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (_) {
      return null;
    }
  }

  List<ProductCategoryModel> getCategories() {
    ensureSeeded();
    return List.unmodifiable(_categories);
  }
}
