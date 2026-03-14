import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/dimens.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/utils/styles.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../global/widgets/app_svg_icon.dart';
import '../../../home/domain/entities/post_category_entity.dart';
import '../../../home/presentation/managers/home_state.dart';

class CategoryFeedSubcategoryList extends StatelessWidget {
  final HomeState state;
  final PostCategoryEntity category;

  const CategoryFeedSubcategoryList({
    super.key,
    required this.state,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final subcategories = [
      PostCategoryEntity(
        id: '${category.id}_general',
        name: 'Umumiy',
        iconPath: category.iconPath,
        parentId: category.id,
      ),
      if (category.subcategories != null) ...category.subcategories!,
    ];

    return ListView.separated(
      padding: EdgeInsets.all(AppDimens.lg.r),
      itemCount: subcategories.length,
      separatorBuilder: (context, _) => AppDimens.md.height,
      itemBuilder: (context, index) {
        final subcategory = subcategories[index];
        final isGeneral = subcategory.id == '${category.id}_general';
        final postCount = isGeneral
            ? state.posts.where((p) =>
                p.category.id == category.id ||
                p.category.parentId == category.id
              ).length
            : state.posts.where((p) => p.category.id == subcategory.id).length;

        return InkWell(
          onTap: () {
            if (isGeneral) {
              context.push('${Routes.getCategoryFeed(category.id)}?showAll=true');
            } else {
              context.push(Routes.getCategoryFeed(subcategory.id));
            }
          },
          borderRadius: BorderRadius.circular(AppDimens.imageRadius.r),
          child: Container(
            padding: EdgeInsets.all(AppDimens.md.r),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(AppDimens.imageRadius.r),
              border: Border.all(
                color: Theme.of(context).dividerColor,
                width: AppDimens.borderWidth.w,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimens.imageRadius.r),
                  ),
                  child: Center(
                    child: AppSvgIcon(
                      assetPath: subcategory.iconPath,
                      size: AppDimens.iconMd,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                AppDimens.md.width,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subcategory.name,
                        style: AppStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      AppDimens.xs.height,
                      Text(
                        '$postCount e\'lon',
                        style: AppStyles.bodySmall.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: AppDimens.iconMd.r,
                  color: Theme.of(context).iconTheme.color,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
