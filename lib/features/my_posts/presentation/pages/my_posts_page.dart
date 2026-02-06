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
import '../../../home/presentation/widgets/post_creation_section.dart';

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
              child: Padding(
                padding: EdgeInsets.all(AppDimens.lg.r),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'E\'lonlar yo\'q',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppStyles.bodyRegular.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                    AppDimens.lg.height,
                    const PostCreationSection(),
                  ],
                ),
              ),
            );
          }
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppDimens.lg.w,
                  AppDimens.md.h,
                  AppDimens.lg.w,
                  AppDimens.md.h,
                ),
                child: const PostCreationSection(),
              ),
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.fromLTRB(
                    AppDimens.lg.w,
                    0,
                    AppDimens.lg.w,
                    AppDimens.lg.h,
                  ),
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
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
