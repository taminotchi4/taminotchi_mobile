import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/dimens.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/styles.dart';
import '../../../../global/widgets/common_app_bar.dart';
import '../../../home/presentation/managers/home_bloc.dart';
import '../../../home/presentation/managers/home_state.dart';
import '../../../home/presentation/widgets/post_card.dart';

class MyPostsPage extends StatelessWidget {
  const MyPostsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: 'Mening postlarim'),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state.myPosts.isEmpty) {
            return Center(
              child: Text(
                'Hozircha postlar yo\'q',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppStyles.bodySmall.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            );
          }
          return ListView.separated(
            padding: EdgeInsets.all(AppDimens.lg.r),
            itemCount: state.myPosts.length,
            separatorBuilder: (context, _) => AppDimens.md.height,
            itemBuilder: (context, index) {
              final post = state.myPosts[index];
              final commentCount = state.commentCounts[post.id] ?? 0;
              return PostCard(
                post: post,
                commentCount: commentCount,
                onTap: () => context.push(Routes.getPostDetail(post.id)),
              );
            },
          );
        },
      ),
    );
  }
}
