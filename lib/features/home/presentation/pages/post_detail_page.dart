import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/dimens.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/styles.dart';
import '../../../../global/widgets/app_back_button.dart';
import '../../../../global/widgets/common_app_bar.dart';
import '../managers/home_bloc.dart';
import '../managers/home_event.dart';
import '../managers/home_state.dart';
import '../widgets/comment_tile.dart';
import '../widgets/post_card.dart';

class PostDetailPage extends StatefulWidget {
  final String postId;

  const PostDetailPage({super.key, required this.postId});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(HomeLoadPostDetails(widget.postId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(
        title: 'Post',
        leading: AppBackButton(),
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state.isLoadingDetails) {
            return const Center(child: CircularProgressIndicator());
          }
          final post = state.activePost;
          if (post == null) {
            return Center(
              child: Text(
                'Post topilmadi',
                style: AppStyles.bodyRegular.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            );
          }
          return ListView(
            padding: EdgeInsets.fromLTRB(
              AppDimens.lg.w,
              AppDimens.md.h,
              AppDimens.lg.w,
              AppDimens.xxl.h,
            ),
            children: [
              PostCard(
                post: post,
                commentCount: state.activeComments.length,
                showFullText: true,
              ),
              AppDimens.lg.height,
              Row(
                children: [
                  Text(
                    'Private replies:',
                    style: AppStyles.bodySmall.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                  AppDimens.sm.width,
                  Text(
                    post.privateReplyCount.toString(),
                    style: AppStyles.bodySmall.copyWith(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
              AppDimens.lg.height,
              Text(
                'Comments',
                style: AppStyles.h5Bold.copyWith(
                  color: Theme.of(context).textTheme.titleMedium?.color,
                ),
              ),
              AppDimens.md.height,
              ...state.activeComments.map((comment) {
                return Padding(
                  padding: EdgeInsets.only(bottom: AppDimens.md.h),
                  child: CommentTile(comment: comment),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
