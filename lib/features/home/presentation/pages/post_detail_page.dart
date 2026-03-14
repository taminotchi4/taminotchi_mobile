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
import 'package:go_router/go_router.dart';
import '../../../../core/routing/routes.dart';
import '../widgets/comment_tile.dart';
import '../../domain/entities/post_status.dart';
import '../widgets/post_card.dart';

// Mock Reply Data for "Javoblar" tab
final _mockReplies = [
  {
    'name': 'Ali Valiyev',
    'message': 'Narxi qancha?',
    'time': '10:30',
    'unread': true,
  },
  {
    'name': 'Olimjon',
    'message': 'Dostavka bormi?',
    'time': 'Kecha',
    'unread': false,
  },
];

class PostDetailPage extends StatefulWidget {
  final String postId;

  const PostDetailPage({super.key, required this.postId});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<HomeBloc>().add(HomeLoadPostDetails(widget.postId));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state.isLoadingDetails) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        final post = state.activePost;
        if (post == null) {
          return Scaffold(
            appBar: const CommonAppBar(title: 'Post', leading: AppBackButton()),
            body: Center(
              child: Text(
                'Post topilmadi',
                style: AppStyles.bodyRegular.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ),
          );
        }

        final isOwner = post.authorId == state.currentUserId;

        return Scaffold(
          appBar: CommonAppBar(
            title: 'Post',
            leading: const AppBackButton(),
            actions: [
              if (isOwner)
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Edit functionality coming soon')),
                      );
                    } else if (value == 'delete') {
                      _showDeleteDialog();
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
                  icon: Icon(
                    Icons.more_vert,
                    size: 24.sp,
                    color: Theme.of(context).appBarTheme.iconTheme?.color ??
                        Theme.of(context).iconTheme.color,
                  ),
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
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
                                ? 'Kelishilgan deb belgilash'
                                : 'Qayta faollashtirish',
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
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
                    PopupMenuItem<String>(
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
                ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(AppDimens.lg.w),
                          child: PostCard(
                            post: post,
                            commentCount: state.activeComments.length,
                            showFullText: true,
                          ),
                        ),
                      ),
                      if (isOwner)
                        SliverPersistentHeader(
                          delegate: _SliverAppBarDelegate(
                            TabBar(
                              controller: _tabController,
                              labelColor: Theme.of(context).primaryColor,
                              unselectedLabelColor:
                                  Theme.of(context).textTheme.bodySmall?.color,
                              indicatorColor: Theme.of(context).primaryColor,
                              tabs: const [
                                Tab(text: 'Izohlar'),
                                Tab(text: 'Javoblar'), // Private Chats
                              ],
                            ),
                          ),
                          pinned: true,
                        ),
                    ];
                  },
                  body: isOwner
                      ? TabBarView(
                          controller: _tabController,
                          children: [
                            _buildCommentsList(context, state, isOwner: true),
                            _buildRepliesList(context),
                          ],
                        )
                      : _buildCommentsList(context, state, isOwner: false),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCommentsList(BuildContext context, HomeState state,
      {required bool isOwner}) {
    if (state.activeComments.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.only(top: AppDimens.xxl.h),
          child: Text(
            'Izohlar hozircha yo\'q',
            style: AppStyles.bodyRegular.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: AppDimens.lg.w),
      itemCount: state.activeComments.length + (!isOwner ? 1 : 0),
      itemBuilder: (context, index) {
        if (!isOwner && index == 0) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: AppDimens.md.h),
            child: Text(
              'Izohlar',
              style: AppStyles.h4Bold.copyWith(
                color: Theme.of(context).textTheme.titleMedium?.color,
              ),
            ),
          );
        }
        final commentIndex = !isOwner ? index - 1 : index;
        return Padding(
          padding: EdgeInsets.only(bottom: AppDimens.md.h),
          child: CommentTile(
            comment: state.activeComments[commentIndex],
            // In real app, check comment ownership
            isMine: false, // TODO: Add userId to CommentEntity to check ownership
            onReply: () {
              _showReplyDialog(context, state.activeComments[commentIndex].id);
            },
          ),
        );
      },
    );
  }

  Widget _buildRepliesList(BuildContext context) {
    if (_mockReplies.isEmpty) {
      return Center(
        child: Text(
          'Javoblar hozircha yo\'q',
          style: AppStyles.bodyRegular.copyWith(
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
      );
    }
    return ListView.separated(
      padding: EdgeInsets.all(AppDimens.lg.w),
      itemCount: _mockReplies.length,
      separatorBuilder: (context, index) => AppDimens.md.height,
      itemBuilder: (context, index) {
        final reply = _mockReplies[index];
        return InkWell(
          onTap: () {
            context.push(
              Routes.sellerChat,
              extra: {
                'name': reply['name'],
                'role': 'User', // Assume replying users are regular users
              },
            );
          },
          borderRadius: BorderRadius.circular(AppDimens.cardRadius.r),
          child: Container(
            padding: EdgeInsets.all(AppDimens.md.r),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(AppDimens.cardRadius.r),
              border: Border.all(
                color: Theme.of(context).dividerColor.withOpacity(0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withOpacity(0.05),
                  blurRadius: 4.r,
                  offset: Offset(0, 2.h),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20.r,
                  backgroundColor:
                      Theme.of(context).primaryColor.withOpacity(0.1),
                  child: Text(
                    (reply['name'] as String)[0],
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                AppDimens.md.width,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            reply['name'] as String,
                            style: AppStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).textTheme.titleMedium?.color,
                            ),
                          ),
                          Text(
                            reply['time'] as String,
                            style: AppStyles.bodySmall.copyWith(
                              color: Theme.of(context).textTheme.bodySmall?.color,
                            ),
                          ),
                        ],
                      ),
                      AppDimens.xs.height,
                      Text(
                        reply['message'] as String,
                        style: AppStyles.bodyRegular.copyWith(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text(
          'O\'chirish',
          style: AppStyles.h4Bold.copyWith(
            color: Theme.of(context).textTheme.titleMedium?.color,
          ),
        ),
        content: Text(
          'Postni o\'chirmoqchimisiz?',
          style: AppStyles.bodyRegular.copyWith(
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Bekor qilish',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.of(context).pop(); // Close page (simulate delete)
              // TODO: Dispatch delete event to bloc
            },
            child: const Text(
              'O\'chirish',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showReplyDialog(BuildContext context, String commentId) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimens.cardRadius.r),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: AppDimens.lg.w,
            right: AppDimens.lg.w,
            bottom: MediaQuery.of(context).viewInsets.bottom + AppDimens.lg.h,
            top: AppDimens.lg.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Javob yozish',
                      style: AppStyles.h4Bold.copyWith(
                        color: Theme.of(context).textTheme.titleMedium?.color,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    borderRadius: BorderRadius.circular(
                      AppDimens.imageRadius.r,
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(AppDimens.sm.r),
                      child: Icon(
                        Icons.close_rounded,
                        size: AppDimens.iconMd.r,
                        color: Theme.of(context).iconTheme.color,
                      ),
                    ),
                  ),
                ],
              ),
              AppDimens.md.height,
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      maxLines: 3,
                      minLines: 1,
                      style: AppStyles.bodyRegular.copyWith(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Javobingizni yozing...',
                        hintStyle: AppStyles.bodyRegular.copyWith(
                          color: Theme.of(context).hintColor,
                        ),
                        filled: true,
                        fillColor: Theme.of(context).scaffoldBackgroundColor,
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimens.imageRadius.r,
                          ),
                          borderSide: BorderSide(
                            color: Theme.of(context).dividerColor,
                            width: AppDimens.borderWidth.w,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimens.imageRadius.r,
                          ),
                          borderSide: BorderSide(
                            color: Theme.of(context).dividerColor,
                            width: AppDimens.borderWidth.w,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimens.imageRadius.r,
                          ),
                          borderSide: BorderSide(
                            color: Theme.of(context).primaryColor,
                            width: AppDimens.borderWidth.w,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: AppDimens.sm.h,
                          horizontal: AppDimens.md.w,
                        ),
                      ),
                    ),
                  ),
                  AppDimens.sm.width,
                  InkWell(
                    onTap: () {
                      if (controller.text.trim().isNotEmpty) {
                        context.read<HomeBloc>().add(
                              HomeReplyToComment(
                                postId: widget.postId,
                                parentCommentId: commentId,
                                content: controller.text.trim(),
                              ),
                            );
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Javob yuborildi')),
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(AppDimens.imageRadius.r),
                    child: Container(
                      padding: EdgeInsets.all(AppDimens.sm.r),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(
                          AppDimens.imageRadius.r,
                        ),
                      ),
                      child: Icon(
                        Icons.send_rounded,
                        size: AppDimens.iconMd.r,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}



