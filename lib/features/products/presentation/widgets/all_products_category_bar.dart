import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/dimens.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/icons.dart';
import '../../../../core/utils/styles.dart';
import '../../../../global/widgets/app_svg_icon.dart';
import '../managers/products_bloc.dart';
import '../managers/products_event.dart';
import '../managers/products_state.dart';

class AllProductsCategoryBar extends StatelessWidget {
  final ProductsState state;

  const AllProductsCategoryBar({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppDimens.huge.h,
      child: Row(
        children: [
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: state.categories.length,
              separatorBuilder: (context, _) => AppDimens.sm.width,
              itemBuilder: (context, index) {
                final category = state.categories[index];
                final isSelected = state.selectedCategory?.id == category.id;
                return InkWell(
                  onTap: () => context
                      .read<ProductsBloc>()
                      .add(ProductsSelectCategory(category)),
                  borderRadius: BorderRadius.circular(AppDimens.imageRadius.r),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDimens.md.w,
                      vertical: AppDimens.xs.h,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).primaryColor.withOpacity(0.1)
                          : Theme.of(context).cardColor,
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
                      children: [
                        AppSvgIcon(
                          assetPath: category.iconPath,
                          size: 16,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        AppDimens.xs.width,
                        Text(
                          category.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppStyles.bodySmall.copyWith(
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          AppDimens.sm.width,
          InkWell(
            onTap: () => _openCategorySheet(context, state),
            borderRadius: BorderRadius.circular(AppDimens.imageRadius.r),
            child: Container(
              padding: EdgeInsets.all(AppDimens.sm.r),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(AppDimens.imageRadius.r),
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                  width: AppDimens.borderWidth.w,
                ),
              ),
              child: AppSvgIcon(
                assetPath: AppIcons.filter,
                size: AppDimens.iconMd,
                color: Theme.of(context).iconTheme.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openCategorySheet(BuildContext context, ProductsState state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimens.cardRadius.r),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(AppDimens.lg.r),
          child: Wrap(
            spacing: AppDimens.sm.w,
            runSpacing: AppDimens.sm.h,
            children: state.categories.map((category) {
              final count = state.categoryCounts[category.id] ?? 0;
              return InkWell(
                onTap: () {
                  context
                      .read<ProductsBloc>()
                      .add(ProductsSelectCategory(category));
                  Navigator.of(context).pop();
                },
                borderRadius: BorderRadius.circular(AppDimens.imageRadius.r),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimens.md.w,
                    vertical: AppDimens.sm.h,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(AppDimens.imageRadius.r),
                    border: Border.all(
                      color: Theme.of(context).dividerColor,
                      width: AppDimens.borderWidth.w,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppSvgIcon(
                        assetPath: category.iconPath,
                        size: 16.r,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      AppDimens.xs.width,
                      Text(
                        category.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppStyles.bodySmall.copyWith(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                      AppDimens.xs.width,
                      Text(
                        formatCompactCount(count),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppStyles.bodySmall.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
