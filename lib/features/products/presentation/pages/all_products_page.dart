import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/dimens.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/icons.dart';
import '../../../../core/utils/styles.dart';
import '../../../../global/widgets/app_svg_icon.dart';
import '../../../../global/widgets/app_back_button.dart';
import '../../../../global/widgets/common_app_bar.dart';
import '../managers/products_bloc.dart';
import '../managers/products_event.dart';
import '../managers/products_state.dart';
import '../widgets/products_grid.dart';

class AllProductsPage extends StatelessWidget {
  const AllProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(
        title: 'Barchasi',
        leading: AppBackButton(),
      ),
      body: BlocBuilder<ProductsBloc, ProductsState>(
        builder: (context, state) {
          return ListView(
            padding: EdgeInsets.all(AppDimens.lg.r),
            children: [
              _buildSearchField(context),
              AppDimens.md.height,
              _buildCategoryRow(context, state),
              AppDimens.lg.height,
              ProductsGrid(
                products: state.filteredProducts,
                showLoadMore: false,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return TextField(
      onChanged: (value) =>
          context.read<ProductsBloc>().add(ProductsUpdateSearch(value)),
      decoration: InputDecoration(
        hintText: 'Qidirish...',
        hintStyle:
            AppStyles.bodyRegular.copyWith(color: Theme.of(context).hintColor),
        filled: true,
        fillColor: Theme.of(context).cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.imageRadius.r),
          borderSide: BorderSide(
            color: Theme.of(context).dividerColor,
            width: AppDimens.borderWidth.w,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.imageRadius.r),
          borderSide: BorderSide(
            color: Theme.of(context).dividerColor,
            width: AppDimens.borderWidth.w,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.imageRadius.r),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: AppDimens.borderWidth.w,
          ),
        ),
        prefixIcon: Padding(
          padding: EdgeInsets.all(AppDimens.sm.r),
          child: AppSvgIcon(
            assetPath: AppIcons.search,
            size: AppDimens.iconMd,
            color: Theme.of(context).iconTheme.color,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryRow(BuildContext context, ProductsState state) {
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
                          ? Theme.of(context)
                              .primaryColor
                              .withValues(alpha: 0.1)
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
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color,
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
                    borderRadius:
                        BorderRadius.circular(AppDimens.imageRadius.r),
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
                        size: 16,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      AppDimens.xs.width,
                      Text(
                        category.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppStyles.bodySmall.copyWith(
                          color:
                              Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                      AppDimens.xs.width,
                      Text(
                        formatCompactCount(count),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppStyles.bodySmall.copyWith(
                          color:
                              Theme.of(context).textTheme.bodySmall?.color,
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
