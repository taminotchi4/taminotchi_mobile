import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../products/domain/entities/product_category_entity.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../../products/domain/usecases/get_products_usecase.dart';
import '../../domain/entities/seller_profile_entity.dart';
import '../../domain/usecases/get_current_user_profile_usecase.dart';
import '../../domain/usecases/get_followers_usecase.dart';
import '../../domain/usecases/get_seller_profile_usecase.dart';
import '../../domain/usecases/toggle_follow_usecase.dart';
import 'seller_profile_event.dart';
import 'seller_profile_state.dart';

class SellerProfileBloc extends Bloc<SellerProfileEvent, SellerProfileState> {
  final GetSellerProfileUseCase getSellerProfileUseCase;
  final GetFollowersUseCase getFollowersUseCase;
  final ToggleFollowUseCase toggleFollowUseCase;
  final GetCurrentUserProfileUseCase getCurrentUserProfileUseCase;
  final GetProductsUseCase getProductsUseCase;
  final Random _random = Random();
  final Map<String, int> _soldCounts = {};

  SellerProfileBloc({
    required this.getSellerProfileUseCase,
    required this.getFollowersUseCase,
    required this.toggleFollowUseCase,
    required this.getCurrentUserProfileUseCase,
    required this.getProductsUseCase,
  }) : super(SellerProfileState.initial()) {
    on<SellerProfileStarted>(_onStarted);
    on<SellerProfileToggleFollow>(_onToggleFollow);
    on<SellerProfileFilterCategory>(_onFilterCategory);
    on<SellerProfileSortChanged>(_onSortChanged);
  }

  Future<void> _onStarted(
    SellerProfileStarted event,
    Emitter<SellerProfileState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    final userIdResult = await getCurrentUserProfileUseCase.getUserId();
    final roleResult = await getCurrentUserProfileUseCase.getRole();
    userIdResult.fold(
      (_) {},
      (id) => emit(state.copyWith(currentUserId: id)),
    );
    roleResult.fold(
      (_) {},
      (role) => emit(state.copyWith(currentUserRole: role)),
    );

    final profileResult = await getSellerProfileUseCase(event.sellerId);
    final followersResult = await getFollowersUseCase(event.sellerId);
    final productsResult = await getProductsUseCase();

    profileResult.fold(
      (_) => emit(state.copyWith(isLoading: false)),
      (seller) {
        followersResult.fold(
          (_) => emit(state.copyWith(isLoading: false, seller: seller)),
          (followers) {
            productsResult.fold(
              (_) => emit(
                state.copyWith(
                  isLoading: false,
                  seller: seller,
                  followers: followers,
                  followersCount: followers.length,
                ),
              ),
              (products) {
                final sellerProducts = products
                    .where((product) => product.seller.id == seller.id)
                    .map(_withSoldCount)
                    .toList();
                final filtered = _applyFilters(
                  sellerProducts,
                  state.selectedCategory,
                  state.sort,
                );
                final updatedSeller = SellerProfileEntity(
                  id: seller.id,
                  name: seller.name,
                  description: seller.description,
                  avatarPath: seller.avatarPath,
                  followersCount: followers.length,
                  productsCount: sellerProducts.length,
                  isFollowing: seller.isFollowing,
                  address: seller.address,
                );
                emit(
                  state.copyWith(
                    isLoading: false,
                    seller: updatedSeller,
                    followers: followers,
                    followersCount: followers.length,
                    sellerProducts: sellerProducts,
                    filteredProducts: filtered,
                    productsCount: sellerProducts.length,
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _onToggleFollow(
    SellerProfileToggleFollow event,
    Emitter<SellerProfileState> emit,
  ) async {
    final seller = state.seller;
    if (seller == null || !state.canFollow) return;
    final result = await toggleFollowUseCase(seller.id, state.currentUserId);
    result.fold(
      (_) {},
      (count) {
        emit(
          state.copyWith(
            seller: SellerProfileEntity(
              id: seller.id,
              name: seller.name,
              description: seller.description,
              avatarPath: seller.avatarPath,
              followersCount: count,
              productsCount: seller.productsCount,
              isFollowing: !seller.isFollowing,
              address: seller.address,
            ),
            followersCount: count,
          ),
        );
      },
    );
  }

  void _onFilterCategory(
    SellerProfileFilterCategory event,
    Emitter<SellerProfileState> emit,
  ) {
    final filtered = _applyFilters(
      state.sellerProducts,
      event.category,
      state.sort,
    );
    emit(
      state.copyWith(
        selectedCategory: event.category,
        filteredProducts: filtered,
      ),
    );
  }

  void _onSortChanged(
    SellerProfileSortChanged event,
    Emitter<SellerProfileState> emit,
  ) {
    final filtered = _applyFilters(
      state.sellerProducts,
      state.selectedCategory,
      event.sort,
    );
    emit(state.copyWith(sort: event.sort, filteredProducts: filtered));
  }

  List<ProductEntity> _applyFilters(
    List<ProductEntity> products,
    ProductCategoryEntity? category,
    SellerProductSort sort,
  ) {
    var filtered = products;
    if (category != null && category.id != 'all') {
      filtered = filtered
          .where((item) => item.category.id == category.id)
          .toList();
    }
    if (sort == SellerProductSort.highestRating) {
      filtered.sort((a, b) => b.rating.compareTo(a.rating));
    } else if (sort == SellerProductSort.mostSold) {
      filtered.sort((a, b) => _soldCount(b).compareTo(_soldCount(a)));
    }
    return filtered;
  }

  ProductEntity _withSoldCount(ProductEntity product) {
    return product;
  }

  int _soldCount(ProductEntity product) {
    return _soldCounts.putIfAbsent(
      product.id,
      () => 10 + _random.nextInt(90),
    );
  }
}
