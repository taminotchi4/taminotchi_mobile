import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/dimens.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/utils/icons.dart';
import '../../../../core/utils/styles.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../global/widgets/app_back_button.dart';
import '../../../../global/widgets/app_svg_icon.dart';
import '../../../../global/widgets/common_app_bar.dart';
import '../../../products/domain/entities/product_category_entity.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../../products/presentation/widgets/products_grid.dart';
import '../managers/seller_profile_bloc.dart';
import '../managers/seller_profile_event.dart';
import '../managers/seller_profile_state.dart';

class SellerProfilePage extends StatefulWidget {
  final String sellerId;

  const SellerProfilePage({super.key, required this.sellerId});

  @override
  State<SellerProfilePage> createState() => _SellerProfilePageState();
}

class _SellerProfilePageState extends State<SellerProfilePage> {
  @override
  void initState() {
    super.initState();
    context.read<SellerProfileBloc>().add(
          SellerProfileStarted(widget.sellerId),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: 'Sotuvchi',
        leading: const AppBackButton(),
        actions: [
          InkWell(
            onTap: () => context.push(
              Routes.getSellerChat(widget.sellerId),
            ),
            borderRadius: BorderRadius.circular(AppDimens.imageRadius.r),
            child: Padding(
              padding: EdgeInsets.all(AppDimens.sm.r),
              child: AppSvgIcon(
                assetPath: AppIcons.chat,
                size: AppDimens.iconMd,
                color: Theme.of(context).iconTheme.color,
              ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<SellerProfileBloc, SellerProfileState>(
        builder: (context, state) {
          final seller = state.seller;
          if (state.isLoading && seller == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (seller == null) {
            return Center(
              child: Text(
                'Sotuvchi topilmadi',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppStyles.bodySmall.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            );
          }
          return DefaultTabController(
            length: 1,
            child: ListView(
              padding: EdgeInsets.all(AppDimens.lg.r),
              children: [
                _header(context, state),
                AppDimens.md.height,
                _countsRow(context, state),
                AppDimens.lg.height,
                TabBar(
                  labelColor: Theme.of(context).textTheme.titleMedium?.color,
                  indicatorColor: Theme.of(context).primaryColor,
                  tabs: const [
                    Tab(text: 'Products'),
                  ],
                ),
                AppDimens.md.height,
                _filterRow(context, state),
                AppDimens.md.height,
                ProductsGrid(
                  products: state.filteredProducts,
                  showLoadMore: false,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _header(BuildContext context, SellerProfileState state) {
    final seller = state.seller!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimens.imageRadius.r),
          child: Container(
            width: AppDimens.avatarLg.w,
            height: AppDimens.avatarLg.w,
            color: Theme.of(context).dividerColor,
            child: AppSvgIcon(
              assetPath: seller.avatarPath,
              size: AppDimens.iconLg,
              color: Theme.of(context).iconTheme.color,
            ),
          ),
        ),
        AppDimens.md.width,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                seller.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppStyles.h5Bold.copyWith(
                  color: Theme.of(context).textTheme.titleMedium?.color,
                ),
              ),
              AppDimens.xs.height,
              Text(
                seller.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: AppStyles.bodySmall.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
              AppDimens.md.height,
              _followButton(context, state),
            ],
          ),
        ),
      ],
    );
  }

  Widget _followButton(BuildContext context, SellerProfileState state) {
    final seller = state.seller!;
    return InkWell(
      onTap: state.canFollow
          ? () => context.read<SellerProfileBloc>().add(
                const SellerProfileToggleFollow(),
              )
          : null,
      borderRadius: BorderRadius.circular(AppDimens.imageRadius.r),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppDimens.lg.w,
          vertical: AppDimens.sm.h,
        ),
        decoration: BoxDecoration(
          color: seller.isFollowing
              ? Theme.of(context).cardColor
              : Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(AppDimens.imageRadius.r),
          border: Border.all(
            color: Theme.of(context).dividerColor,
            width: AppDimens.borderWidth.w,
          ),
        ),
        child: Text(
          seller.isFollowing ? 'Following' : 'Follow',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppStyles.bodySmall.copyWith(
            color: seller.isFollowing
                ? Theme.of(context).textTheme.bodyMedium?.color
                : Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _countsRow(BuildContext context, SellerProfileState state) {
    return Row(
      children: [
        InkWell(
          onTap: () => context.push(Routes.getSellerFollowers(state.seller!.id)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                state.followersCount.toString(),
                style: AppStyles.h5Bold.copyWith(
                  color: Theme.of(context).textTheme.titleMedium?.color,
                ),
              ),
              Text(
                'Followers',
                style: AppStyles.bodySmall.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
        ),
        AppDimens.xxl.width,
        InkWell(
          onTap: () {},
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                state.productsCount.toString(),
                style: AppStyles.h5Bold.copyWith(
                  color: Theme.of(context).textTheme.titleMedium?.color,
                ),
              ),
              Text(
                'Products',
                style: AppStyles.bodySmall.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _filterRow(BuildContext context, SellerProfileState state) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Mahsulotlar',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppStyles.h5Bold.copyWith(
              color: Theme.of(context).textTheme.titleMedium?.color,
            ),
          ),
        ),
        InkWell(
          onTap: () => _openFilterDialog(context, state),
          borderRadius: BorderRadius.circular(AppDimens.imageRadius.r),
          child: Padding(
            padding: EdgeInsets.all(AppDimens.sm.r),
            child: AppSvgIcon(
              assetPath: AppIcons.filter,
              size: AppDimens.iconMd,
              color: Theme.of(context).iconTheme.color,
            ),
          ),
        ),
      ],
    );
  }

  void _openFilterDialog(BuildContext context, SellerProfileState state) {
    final categories = _uniqueCategories(state.sellerProducts);
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: AppDimens.lg.w),
          backgroundColor: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.cardRadius.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(AppDimens.lg.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Filter',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppStyles.h5Bold.copyWith(
                    color: Theme.of(context).textTheme.titleMedium?.color,
                  ),
                ),
                AppDimens.lg.height,
                Wrap(
                  spacing: AppDimens.sm.w,
                  runSpacing: AppDimens.sm.h,
                  children: categories.map((category) {
                    final isSelected =
                        state.selectedCategory?.id == category.id;
                    return InkWell(
                      onTap: () {
                        context.read<SellerProfileBloc>().add(
                              SellerProfileFilterCategory(category),
                            );
                        Navigator.of(context).pop();
                      },
                      borderRadius:
                          BorderRadius.circular(AppDimens.imageRadius.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDimens.md.w,
                          vertical: AppDimens.sm.h,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context)
                                  .primaryColor
                                  .withValues(alpha: 0.1)
                              : Theme.of(context).scaffoldBackgroundColor,
                          borderRadius:
                              BorderRadius.circular(AppDimens.imageRadius.r),
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).dividerColor,
                            width: AppDimens.borderWidth.w,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppSvgIcon(
                              assetPath: category.iconPath,
                              size: AppDimens.iconSm,
                              color: Theme.of(context).iconTheme.color,
                            ),
                            AppDimens.xs.width,
                            Text(
                              category.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppStyles.bodySmall.copyWith(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                AppDimens.lg.height,
                Wrap(
                  spacing: AppDimens.sm.w,
                  children: [
                    _sortChip(
                      context,
                      label: 'Most sold',
                      selected: state.sort == SellerProductSort.mostSold,
                      onTap: () => _applySort(
                        context,
                        SellerProductSort.mostSold,
                      ),
                    ),
                    _sortChip(
                      context,
                      label: 'Highest rating',
                      selected: state.sort == SellerProductSort.highestRating,
                      onTap: () => _applySort(
                        context,
                        SellerProductSort.highestRating,
                      ),
                    ),
                    _sortChip(
                      context,
                      label: 'Default',
                      selected: state.sort == SellerProductSort.none,
                      onTap: () => _applySort(
                        context,
                        SellerProductSort.none,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sortChip(
    BuildContext context, {
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        onTap();
        Navigator.of(context).pop();
      },
      borderRadius: BorderRadius.circular(AppDimens.imageRadius.r),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppDimens.md.w,
          vertical: AppDimens.sm.h,
        ),
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
              : Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(AppDimens.imageRadius.r),
          border: Border.all(
            color: selected
                ? Theme.of(context).primaryColor
                : Theme.of(context).dividerColor,
            width: AppDimens.borderWidth.w,
          ),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppStyles.bodySmall.copyWith(
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      ),
    );
  }

  void _applySort(BuildContext context, SellerProductSort sort) {
    context.read<SellerProfileBloc>().add(SellerProfileSortChanged(sort));
  }

  List<ProductCategoryEntity> _uniqueCategories(List<ProductEntity> products) {
    final map = <String, ProductCategoryEntity>{};
    map['all'] = const ProductCategoryEntity(
      id: 'all',
      name: 'Barchasi',
      iconPath: AppIcons.category,
    );
    for (final product in products) {
      map[product.category.id] = product.category;
    }
    return map.values.toList();
  }
}
