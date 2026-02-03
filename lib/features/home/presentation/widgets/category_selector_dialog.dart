import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/dimens.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/styles.dart';
import '../../../../global/widgets/app_svg_icon.dart';
import '../../domain/entities/post_category_entity.dart';

class CategorySelectorDialog extends StatelessWidget {
  final List<PostCategoryEntity> categories;
  final PostCategoryEntity? selectedCategory;

  const CategorySelectorDialog({
    super.key,
    required this.categories,
    required this.selectedCategory,
  });

  @override
  Widget build(BuildContext context) {
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
              'Kategoriyani tanlang',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppStyles.h5Bold.copyWith(
                color: Theme.of(context).textTheme.titleMedium?.color,
              ),
            ),
            AppDimens.lg.height,
            SingleChildScrollView(
              child: Wrap(
                spacing: AppDimens.sm.w,
                runSpacing: AppDimens.sm.h,
                children: categories.map((category) {
                  final isSelected = selectedCategory?.id == category.id;
                  return InkWell(
                    onTap: () => Navigator.of(context).pop(category),
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
                                .withValues(alpha: 0.12)
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
                          AppDimens.sm.width,
                          ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: AppDimens.categoryChipMaxWidth.w,
                          ),
                            child: Text(
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
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
