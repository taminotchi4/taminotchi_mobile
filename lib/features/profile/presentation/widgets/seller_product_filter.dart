import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/dimens.dart';
import '../../../../core/utils/icons.dart';
import '../../../../core/utils/styles.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../global/widgets/app_svg_icon.dart';
import '../../../products/domain/entities/product_category_entity.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../managers/seller_profile_bloc.dart';
import '../managers/seller_profile_event.dart';
import '../managers/seller_profile_state.dart';

class SellerProductFilter extends StatelessWidget {
  final SellerProfileState state;

  const SellerProductFilter({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
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
                                  .withOpacity(0.1)
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
              ? Theme.of(context).primaryColor.withOpacity(0.1)
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
