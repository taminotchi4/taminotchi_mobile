import '../../../products/domain/entities/product_category_entity.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../domain/entities/follower_entity.dart';
import '../../domain/entities/profile_user_role.dart';
import '../../domain/entities/seller_profile_entity.dart';
import 'seller_profile_event.dart';

class SellerProfileState {
  final SellerProfileEntity? seller;
  final List<FollowerEntity> followers;
  final List<ProductEntity> sellerProducts;
  final List<ProductEntity> filteredProducts;
  final ProductCategoryEntity? selectedCategory;
  final SellerProductSort sort;
  final bool isLoading;
  final String currentUserId;
  final ProfileUserRole currentUserRole;
  final int productsCount;
  final int followersCount;

  const SellerProfileState({
    required this.seller,
    required this.followers,
    required this.sellerProducts,
    required this.filteredProducts,
    required this.selectedCategory,
    required this.sort,
    required this.isLoading,
    required this.currentUserId,
    required this.currentUserRole,
    required this.productsCount,
    required this.followersCount,
  });

  factory SellerProfileState.initial() => const SellerProfileState(
    seller: null,
    followers: [],
    sellerProducts: [],
    filteredProducts: [],
    selectedCategory: null,
    sort: SellerProductSort.none,
    isLoading: false,
    currentUserId: '',
    currentUserRole: ProfileUserRole.user,
    productsCount: 0,
    followersCount: 0,
  );

  bool get canFollow => currentUserRole == ProfileUserRole.user;

  SellerProfileState copyWith({
    SellerProfileEntity? seller,
    List<FollowerEntity>? followers,
    List<ProductEntity>? sellerProducts,
    List<ProductEntity>? filteredProducts,
    ProductCategoryEntity? selectedCategory,
    SellerProductSort? sort,
    bool? isLoading,
    String? currentUserId,
    ProfileUserRole? currentUserRole,
    int? productsCount,
    int? followersCount,
  }) {
    return SellerProfileState(
      seller: seller ?? this.seller,
      followers: followers ?? this.followers,
      sellerProducts: sellerProducts ?? this.sellerProducts,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      sort: sort ?? this.sort,
      isLoading: isLoading ?? this.isLoading,
      currentUserId: currentUserId ?? this.currentUserId,
      currentUserRole: currentUserRole ?? this.currentUserRole,
      productsCount: productsCount ?? this.productsCount,
      followersCount: followersCount ?? this.followersCount,
    );
  }
}
