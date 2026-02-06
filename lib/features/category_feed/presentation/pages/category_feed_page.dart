import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/dimens.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/styles.dart';
import '../../../../global/widgets/app_back_button.dart';
import '../../../../global/widgets/app_svg_icon.dart';
import '../../../../global/widgets/common_app_bar.dart';
import '../../../home/domain/entities/post_category_entity.dart';
import '../../../home/presentation/managers/home_bloc.dart';
import '../../../home/presentation/managers/home_state.dart';
import '../../../home/presentation/widgets/post_card.dart';

class CategoryFeedPage extends StatelessWidget {
  final String categoryId;
  final bool showAllPosts;

  const CategoryFeedPage({
    super.key,
    required this.categoryId,
    this.showAllPosts = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: _getCategoryTitle(context),
        leading: const AppBackButton(),
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          // Find category in top-level categories
          var category = state.categories.where((cat) => cat.id == categoryId).firstOrNull;
          
          // If not found, search in subcategories
          if (category == null) {
            for (final cat in state.categories) {
              if (cat.subcategories != null) {
                category = cat.subcategories!.where((sub) => sub.id == categoryId).firstOrNull;
                if (category != null) break;
              }
            }
          }

          // If still not found, show empty state
          if (category == null) {
            return _buildPostList(context, state, categoryId);
          }

          // If showAllPosts is true, always show posts list
          if (showAllPosts) {
            return _buildPostList(context, state, categoryId);
          }

          if (category.hasSubcategories) {
            return _buildSubcategoryList(context, state, category);
          } else {
            return _buildPostList(context, state, categoryId);
          }
        },
      ),
    );
  }

  Widget _buildSubcategoryList(
    BuildContext context,
    HomeState state,
    PostCategoryEntity category,
  ) {
    final subcategories = [
      PostCategoryEntity(
        id: '${category.id}_general',
        name: 'Umumiy',
        iconPath: category.iconPath,
        parentId: category.id,
      ),
      ...category.subcategories!,
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
            // For "Umumiy", navigate with parent category ID and showAll=true
            // For subcategories, navigate with subcategory ID
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
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
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

  Widget _buildPostList(
    BuildContext context,
    HomeState state,
    String catId,
  ) {
    final categoryPosts = state.posts
        .where((post) => post.category.id == catId || post.category.parentId == catId)
        .toList();

    if (categoryPosts.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(AppDimens.lg.r),
          child: Text(
            'Bu kategoriyada hozircha e\'lonlar yo\'q',
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppStyles.bodyRegular.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.all(AppDimens.lg.r),
      itemCount: categoryPosts.length,
      separatorBuilder: (context, _) => AppDimens.md.height,
      itemBuilder: (context, index) {
        final post = categoryPosts[index];
        final commentCount = state.commentCounts[post.id] ?? 0;
        return PostCard(
          post: post,
          commentCount: commentCount,
          onTap: () => context.push(Routes.getPostDetail(post.id)),
        );
      },
    );
  }

  String _getCategoryTitle(BuildContext context) {
    final state = context.read<HomeBloc>().state;
    
    // First try to find in top-level categories
    var category = state.categories.where((cat) => cat.id == categoryId).firstOrNull;
    
    // If not found, search in subcategories
    if (category == null) {
      for (final cat in state.categories) {
        if (cat.subcategories != null) {
          category = cat.subcategories!.where((sub) => sub.id == categoryId).firstOrNull;
          if (category != null) break;
        }
      }
    }
    
    return category?.name ?? 'Kategoriya';
  }
}
