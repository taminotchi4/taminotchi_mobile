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
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Edit functionality coming soon')),
                            );
                          } else if (value == 'delete') {
                            // TODO: Implement delete in MyPostsPage if needed or redirect to detail
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('O\'chirish uchun e\'lon ustiga bosing')),
                            );
                          } else if (value == 'toggle_status') {
                            final newStatus = post.status == PostStatus.active
                                ? PostStatus.archived
                                : PostStatus.active;
                            context.read<HomeBloc>().add(
                                  HomeUpdatePostStatus(
                                    postId: post.id,
                                    status: newStatus,
                                  ),
                                );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  newStatus == PostStatus.active
                                      ? 'E\'lon faollashtirildi'
                                      : 'E\'lon kelishilgan deb belgilandi',
                                ),
                              ),
                            );
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'toggle_status',
                            child: Row(
                              children: [
                                Icon(
                                  post.status == PostStatus.active
                                      ? Icons.check_circle_outline
                                      : Icons.fiber_manual_record,
                                  color: post.status == PostStatus.active
                                      ? Colors.grey
                                      : Colors.green,
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  post.status == PostStatus.active
                                      ? 'Kelishilgan'
                                      : 'Faollashtirish',
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit_outlined,
                                    color: Theme.of(context).primaryColor),
                                SizedBox(width: 8.w),
                                const Text('Tahrirlash'),
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
                                const Text('O\'chirish'),
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
            ],
          );
        },
      ),
    );
  }
}
