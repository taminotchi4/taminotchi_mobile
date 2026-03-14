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
import '../../../home/domain/entities/group_entity.dart';
import '../../../../global/widgets/shimmer_skeleton.dart';

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
    final allGroupsForCategory = state.categoryGroups[category.id] ?? [];

    if (state.isLoadingGroups && allGroupsForCategory.isEmpty) {
      return _buildSkeleton(context);
    }

    // Find the "Umumiy" group (where supCategoryId is null)
    final GroupEntity? generalGroup = allGroupsForCategory.where(
      (group) => group.supCategoryId == null,
    ).firstOrNull;

    // Filter out the general group to get other subcategories/groups
    final List<GroupEntity> otherGroups = allGroupsForCategory
        .where((group) => group.supCategoryId != null)
        .toList();

    return ListView.separated(
      padding: EdgeInsets.all(AppDimens.lg.r),
      itemCount: otherGroups.length + (generalGroup != null ? 1 : 0), // +1 for "Umumiy" if it exists
      separatorBuilder: (context, _) => AppDimens.md.height,
      itemBuilder: (context, index) {
        if (generalGroup != null && index == 0) {
          // General item
          final postCount = state.posts
              .where((p) =>
                  p.category.id == category.id || // Posts directly under the main category
                  p.category.parentId == category.id || // Posts under subcategories of the main category
                  p.groups.any((g) => g.id == generalGroup.id) // Posts belonging to the general group
              )
              .length;
          return _buildItem(
            context,
            id: generalGroup.id,
            name: 'Umumiy', // Hardcoded name for the general group
            iconPath: category.iconPath,
            profilePhoto: generalGroup.profilePhoto,
            postCount: postCount,
            isGeneral: true,
          );
        }

        final group = otherGroups[index - (generalGroup != null ? 1 : 0)];
        final postCount = state.posts
            .where((p) =>
                p.category.id == group.id || // Posts directly under this group (if it's a category)
                p.groups.any((g) => g.id == group.id) // Posts belonging to this group
            )
            .length;

        return _buildItem(
          context,
          id: group.id,
          name: group.name,
          iconPath: category.iconPath,
          profilePhoto: group.profilePhoto,
          postCount: postCount,
        );
      },
    );
  }

  Widget _buildItem(
    BuildContext context, {
    required String id,
    required String name,
    required String iconPath,
    String? profilePhoto,
    required int postCount,
    bool isGeneral = false,
  }) {
    return InkWell(
      onTap: () {
        if (isGeneral) {
          context.push('${Routes.getCategoryFeed(id)}?showAll=true');
        } else {
          // Navigating to category feed for the specific sub/group
          context.push(Routes.getCategoryFeed(id));
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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppDimens.imageRadius.r),
                child: profilePhoto != null && profilePhoto.isNotEmpty
                    ? Image.network(
                        profilePhoto,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholderIcon(context, iconPath),
                      )
                    : _buildPlaceholderIcon(context, iconPath),
              ),
            ),
            AppDimens.md.width,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
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
  }

  Widget _buildPlaceholderIcon(BuildContext context, String iconPath) {
    return Center(
      child: AppSvgIcon(
        assetPath: iconPath,
        size: AppDimens.iconMd,
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.all(AppDimens.lg.r),
      itemCount: 8,
      separatorBuilder: (context, _) => AppDimens.md.height,
      itemBuilder: (context, index) {
        return Container(
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
              const ShimmerSkeleton(
                height: 48,
                width: 48,
                borderRadius: AppDimens.imageRadius,
              ),
              AppDimens.md.width,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ShimmerSkeleton(height: 16, width: 140),
                    AppDimens.xs.height,
                    const ShimmerSkeleton(height: 12, width: 60),
                  ],
                ),
              ),
              const ShimmerSkeleton(height: 24, width: 24, borderRadius: 100),
            ],
          ),
        );
      },
    );
  }
}
