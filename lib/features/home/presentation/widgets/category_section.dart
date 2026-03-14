import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/dimens.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/styles.dart';
import '../../../../global/widgets/app_svg_icon.dart';
import '../../domain/entities/post_category_entity.dart';

class CategorySection extends StatelessWidget {
  final List<PostCategoryEntity> categories;

  const CategorySection({
    super.key,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();

    final halfCount = (categories.length / 2).ceil();
    final firstRow = categories.take(halfCount).toList();
    final secondRow = categories.skip(halfCount).toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: AppDimens.lg.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCategoryRow(context, firstRow),
          AppDimens.md.height,
          _buildCategoryRow(context, secondRow),
        ],
      ),
    );
  }

  Widget _buildCategoryRow(BuildContext context, List<PostCategoryEntity> items) {
    return Row(
      children: items.map((category) {
        return Padding(
          padding: EdgeInsets.only(right: AppDimens.lg.w),
          child: _buildCategoryItem(context, category),
        );
      }).toList(),
    );
  }

  Widget _buildCategoryItem(BuildContext context, PostCategoryEntity category) {
    return InkWell(
      onTap: () => context.push(Routes.getCategoryFeed(category.id)),
      borderRadius: BorderRadius.circular(AppDimens.circleRadius.r),
      child: SizedBox(
        width: 70.w,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56.w,
              height: 56.w,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).dividerColor.withOpacity(0.3),
                  width: 1.w,
                ),
              ),
              child: Center(
                child: AppSvgIcon(
                  assetPath: category.iconPath,
                  size: AppDimens.iconLg,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            AppDimens.xs.height,
            Text(
              category.name,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: AppStyles.bodySmall.copyWith(
                fontSize: 11.sp,
                height: 1.2,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
