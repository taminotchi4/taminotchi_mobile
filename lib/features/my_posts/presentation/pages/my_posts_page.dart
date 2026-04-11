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
import '../../../home/domain/entities/post_status.dart';
import '../../../home/presentation/managers/home_event.dart';
import '../../../home/presentation/managers/home_state.dart';
import '../../../home/presentation/widgets/post_card.dart';
import '../../../home/presentation/widgets/post_creation_section.dart';

class MyPostsPage extends StatelessWidget {
  const MyPostsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: context.l10n.myPosts),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state.myPosts.isEmpty) {
            return Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppDimens.lg.r),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      context.l10n.noPostsYet,
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
                child: RefreshIndicator(
                  onRefresh: () async {
                    context.read<HomeBloc>().add(const HomeRefresh());
                  },
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
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
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(context.l10n.editComingSoon),
                                ),
                              );
                            } else if (value == 'delete') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(context.l10n.clickPostToDelete),
                                ),
                              );
                            } else {
                              PostStatus? newStatus;
                              if (value == 'status_active') newStatus = PostStatus.active;
                              if (value == 'status_agreed') newStatus = PostStatus.agreed;
                              if (value == 'status_negotiation') newStatus = PostStatus.negotiation;
                              
                              if (newStatus != null) {
                                context.read<HomeBloc>().add(
                                      HomeUpdatePostStatus(
                                        postId: post.id,
                                        status: newStatus,
                                      ),
                                    );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Status o\'zgartirildi: ${newStatus.label}'),
                                  ),
                                );
                              }
                            }
                          },
                          itemBuilder: (context) => [
                            if (post.status != PostStatus.active)
                              PopupMenuItem(
                                value: 'status_active',
                                child: Row(
                                  children: [
                                    const Icon(Icons.refresh, color: Colors.green),
                                    SizedBox(width: 8.w),
                                    Text(context.l10n.reactivate),
                                  ],
                                ),
                              ),
                            if (post.status == PostStatus.active) ...[
                              PopupMenuItem(
                                value: 'status_negotiation',
                                child: Row(
                                  children: [
                                    const Icon(Icons.handshake_outlined, color: Colors.orange),
                                    SizedBox(width: 8.w),
                                    Text(context.l10n.statusNegotiation),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'status_agreed',
                                child: Row(
                                  children: [
                                    const Icon(Icons.check_circle_outline, color: Colors.blue),
                                    SizedBox(width: 8.w),
                                    Text(context.l10n.statusAgreed),
                                  ],
                                ),
                              ),
                            ],
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit_outlined,
                                      color: Theme.of(context).primaryColor),
                                  SizedBox(width: 8.w),
                                  Text(context.l10n.edit),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  const Icon(Icons.delete_outline_rounded,
                                      color: Colors.red),
                                  SizedBox(width: 8.w),
                                  Text(context.l10n.delete),
                                ],
                              ),
                            ),
                          ],
                          child: Icon(Icons.more_vert, size: 20.sp),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
