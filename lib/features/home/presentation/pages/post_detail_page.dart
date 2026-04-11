import 'dart:core';
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
import '../../domain/entities/comment_entity.dart';
import '../widgets/post_card.dart';
import '../../../chat/presentation/managers/comment_bloc.dart';
import '../../../chat/data/models/message_model.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../chat/domain/repositories/chat_repository.dart';
import 'dart:async';

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
  final FocusNode _focusNode = FocusNode();
  CommentBloc? _commentBloc;
  MessageModel? _replyingTo;
  bool _isJoining = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<HomeBloc>().add(HomeLoadPostDetails(widget.postId));
  }

  @override
  void dispose() {
    if (_commentBloc != null) {
      // Close the local bloc; leave_comment is handled in CommentBloc.close()
      _commentBloc!.close();
    }
    _tabController.dispose();
    _commentController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _initCommentBloc(String? commentId) async {
    if (commentId == null || _isJoining) return;
    _isJoining = true;
    if (!mounted) return;
    setState(() {
      _commentBloc = CommentBloc(
        authRepository: context.read<AuthRepository>(),
        chatRepository: context.read<ChatRepository>(),
      );
      _commentBloc!.add(CommentJoin(commentId));
    });
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
            appBar: CommonAppBar(title: context.l10n.post, leading: const AppBackButton()),
            body: Center(
              child: Text(
                context.l10n.postNotFound,
                style: AppStyles.bodyRegular.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ),
          );
        }

        // Initialize WebSocket if not already done
        if (post.commentId != null && _commentBloc == null) {
          _initCommentBloc(post.commentId);
        }

        final isOwner = post.authorId == state.currentUserId;

        final scaffold = Scaffold(
          appBar: CommonAppBar(
            title: context.l10n.post,
            leading: const AppBackButton(),
            actions: [
              if (isOwner)
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(context.l10n.editComingSoon)),
                      );
                    } else if (value == 'delete') {
                      _showDeleteDialog();
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
                  icon: Icon(
                    Icons.more_vert,
                    size: 24.sp,
                    color: Theme.of(context).appBarTheme.iconTheme?.color ??
                        Theme.of(context).iconTheme.color,
                  ),
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                    if (post.status != PostStatus.active)
                      PopupMenuItem<String>(
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
                      PopupMenuItem<String>(
                        value: 'status_negotiation',
                        child: Row(
                          children: [
                            const Icon(Icons.handshake_outlined, color: Colors.orange),
                            SizedBox(width: 8.w),
                            Text(context.l10n.statusNegotiation),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
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
                    PopupMenuItem<String>(
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
                    PopupMenuItem<String>(
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
                          padding: EdgeInsets.symmetric(horizontal: AppDimens.lg.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_commentBloc != null)
                                BlocBuilder<CommentBloc, CommentState>(
                                  bloc: _commentBloc,
                                  builder: (context, commentState) {
                                    return PostCard(
                                      post: post,
                                      commentCount: commentState.messages.length,
                                      showFullText: true,
                                    );
                                  },
                                )
                              else
                                PostCard(
                                  post: post,
                                  commentCount: state.activeComments.length,
                                  showFullText: true,
                                ),
                              AppDimens.lg.height,
                            ],
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
                              tabs: [
                                Tab(text: context.l10n.comments),
                                Tab(text: context.l10n.privateReplies), // Private Chats
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
              if (post.commentId != null && _commentBloc != null)
                _buildInputBar(context, post.commentId!),
            ],
          ),
        );

        return _commentBloc == null
            ? scaffold
            : BlocProvider<CommentBloc>.value(
                value: _commentBloc!,
                child: scaffold,
              );
      },
    );
  }

Widget _buildInputBar(BuildContext context, String commentId) {
final theme = Theme.of(context);
return Container(
padding: EdgeInsets.fromLTRB(
  AppDimens.md.w,
  AppDimens.sm.h,
  AppDimens.md.w,
  MediaQuery.of(context).padding.bottom + AppDimens.sm.h),
decoration: BoxDecoration(
color: theme.cardColor,
border: Border(top: BorderSide(color: theme.dividerColor.withOpacity(0.1))),
),
child: Column(
mainAxisSize: MainAxisSize.min,
children: [
  if (_replyingTo != null)
    Container(
      padding: EdgeInsets.all(8.r),
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Javob berilmoqda: ${_replyingTo!.senderName}',
              style: AppStyles.bodySmall.copyWith(color: theme.primaryColor),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, size: 16.r),
            onPressed: () => setState(() => _replyingTo = null),
          ),
        ],
      ),
    ),
  Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Expanded(
        child: TextField(
          controller: _commentController,
          focusNode: _focusNode,
          maxLines: 4,
          minLines: 1,
          style: AppStyles.bodySmall.copyWith(fontSize: 13.sp),
          decoration: InputDecoration(
            hintText: 'Sharh yozing...',
            hintStyle: AppStyles.bodySmall.copyWith(color: Colors.grey, fontSize: 13.sp),
            filled: true,
            fillColor: theme.scaffoldBackgroundColor,
            isDense: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.r),
              borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.2)),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          ),
          onChanged: (text) {
            if (text.isNotEmpty) {
              _commentBloc?.add(CommentTyping(commentId));
            }
          },
        ),
      ),
      SizedBox(width: 8.w),
      GestureDetector(
        onTap: () {
          final text = _commentController.text.trim();
          if (text.isNotEmpty && _commentBloc != null) {
            _commentBloc!.add(CommentSendMessage(
              commentId: commentId,
              text: text,
              replyToId: _replyingTo?.id,
            ));
            _commentController.clear();
            setState(() => _replyingTo = null);
            _focusNode.unfocus();
          }
        },
        child: Container(
          width: 40.r,
          height: 40.r,
          decoration: BoxDecoration(
            color: theme.primaryColor,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.send_rounded, color: Colors.white, size: 18.r),
        ),
      ),
    ],
  ),
],
),
);
}

  Widget _buildCommentsList(BuildContext context, HomeState state,
      {required bool isOwner}) {
    if (state.activePost?.commentId == null || _commentBloc == null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.only(top: AppDimens.xxl.h),
          child: Text(
            context.l10n.noComments,
            style: AppStyles.bodyRegular.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ),
      );
    }

    return BlocBuilder<CommentBloc, CommentState>(
      bloc: _commentBloc,
      builder: (BuildContext context, CommentState commentState) {
        if (commentState.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final flatComments = commentState.messages;
        final rootComments = flatComments.where((c) => c.replyToId == null).toList();
        final Map<String, List<MessageModel>> repliesMap = {};
        for (var c in flatComments) {
          if (c.replyToId != null) {
            repliesMap.putIfAbsent(c.replyToId!, () => []).add(c);
          }
        }

        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: AppDimens.lg.w),
          itemCount: rootComments.length + (!isOwner ? 1 : 0) + (commentState.typingUserIds.isNotEmpty ? 1 : 0),
          itemBuilder: (context, index) {
            if (!isOwner && index == 0) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: AppDimens.md.h),
                child: Text(
                  context.l10n.comments,
                  style: AppStyles.h4Bold.copyWith(
                    color: Theme.of(context).textTheme.titleMedium?.color,
                  ),
                ),
              );
            }
            
            final actualIndex = !isOwner ? index - 1 : index;
            
            if (actualIndex >= rootComments.length) {
              // Typing indicator
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Row(
                  children: [
                    SizedBox(width: 20.w, height: 20.w, child: const CircularProgressIndicator(strokeWidth: 1)),
                    SizedBox(width: 8.w),
                    Text("Kimdir yozmoqda...", style: AppStyles.bodySmall.copyWith(fontStyle: FontStyle.italic)),
                  ],
                ),
              );
            }

            final rootComment = rootComments[actualIndex];
            final commentReplies = repliesMap[rootComment.id] ?? [];
            
            final commentEntity = rootComment.toCommentEntity(widget.postId);
            final List<CommentEntity> mappedReplies = commentReplies.map((r) => r.toCommentEntity(widget.postId)).toList();

            return Padding(
              padding: EdgeInsets.only(bottom: AppDimens.md.h),
              child: CommentTile(
                comment: CommentEntity(
                  id: commentEntity.id,
                  postId: commentEntity.postId,
                  userName: commentEntity.userName,
                  userAvatarPath: commentEntity.userAvatarPath,
                  content: commentEntity.content,
                  createdAt: commentEntity.createdAt,
                  replies: mappedReplies,
                ),
                isMine: rootComment.senderId == state.currentUserId,
                onReply: () {
                  setState(() => _replyingTo = rootComment);
                  _focusNode.requestFocus();
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRepliesList(BuildContext context) {
    if (_mockReplies.isEmpty) {
      return Center(
        child: Text(
          context.l10n.noReplies,
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
          context.l10n.deleteConfirmContent,
          style: AppStyles.bodyRegular.copyWith(
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              context.l10n.cancel,
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
            child: Text(
              context.l10n.delete,
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
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
