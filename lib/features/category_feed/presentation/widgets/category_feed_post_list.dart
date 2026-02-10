import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/dimens.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/styles.dart';
import '../../../home/presentation/managers/home_state.dart';
import '../../../home/presentation/widgets/post_card.dart';

class CategoryFeedPostList extends StatelessWidget {
  final HomeState state;
  final String categoryId;

  const CategoryFeedPostList({
    super.key,
    required this.state,
    required this.categoryId,
  });

  @override
  Widget build(BuildContext context) {
    final categoryPosts = state.posts
        .where((post) => post.category.id == categoryId || post.category.parentId == categoryId)
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
}
