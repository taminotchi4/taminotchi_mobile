import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/dimens.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/icons.dart';
import '../../../../core/utils/styles.dart';
import '../../../../global/widgets/app_svg_icon.dart';
import '../../domain/entities/product_comment_entity.dart';
import '../managers/product_comments_bloc.dart';
import '../managers/product_comments_event.dart';
import '../managers/product_comments_state.dart';

class ProductCommentsSection extends StatefulWidget {
  final String productId;
  final String currentUserId;
  final String currentUserName;

  const ProductCommentsSection({
    super.key,
    required this.productId,
    required this.currentUserId,
    required this.currentUserName,
  });

  @override
  State<ProductCommentsSection> createState() => _ProductCommentsSectionState();
}

class _ProductCommentsSectionState extends State<ProductCommentsSection> {
  final Map<String, bool> _expandedComments = {};
  double _commentRating = 0.0;
  String? _ratingError;

  String _formatCommentTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppDimens.lg.height,
        _commentsHeader(context),
        AppDimens.md.height,
        _commentsList(context),
      ],
    );
  }

  Widget _commentsHeader(BuildContext context) {
    return Row(
      children: [
        Text(
          'Comments',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppStyles.h5Bold.copyWith(
            color: Theme.of(context).textTheme.titleMedium?.color,
          ),
        ),
        const Spacer(),
        InkWell(
          onTap: () => _openCommentInput(context),
          borderRadius: BorderRadius.circular(AppDimens.imageRadius.r),
          child: Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.edit_note_rounded,
              size: AppDimens.iconMd,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _commentsList(BuildContext context) {
    return BlocBuilder<ProductCommentsBloc, ProductCommentsState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.comments.isEmpty) {
          return Text(
            'Izohlar yoq',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppStyles.bodySmall.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          );
        }
        return Column(
          children: state.comments.map((comment) {
            final isMine = comment.userId == widget.currentUserId;
            return Container(
              margin: EdgeInsets.only(bottom: AppDimens.md.h),
              padding: EdgeInsets.all(AppDimens.md.r),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(AppDimens.cardRadius.r),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withOpacity(0.3),
                  width: 1.w,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                          AppDimens.circleRadius.r,
                        ),
                        child: Container(
                          width: AppDimens.avatarSm.w,
                          height: AppDimens.avatarSm.w,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).primaryColor,
                                Theme.of(context).primaryColor.withOpacity(0.7),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            comment.userName.isNotEmpty
                                ? comment.userName[0].toUpperCase()
                                : '?',
                            style: AppStyles.bodyMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      AppDimens.sm.width,
                      Expanded(
                        child: Text(
                          comment.userName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                      ),
                      Text(
                        _formatCommentTime(comment.createdAt),
                        style: AppStyles.bodySmall.copyWith(
                          fontSize: 10.sp,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                      if (isMine) ...[
                        4.horizontalSpace,
                        PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            Icons.more_vert_rounded,
                            size: 18.r,
                            color: Theme.of(context).iconTheme.color,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          onSelected: (value) {
                            if (value == 'edit') {
                              _openEditComment(context, comment);
                            } else if (value == 'delete') {
                              context.read<ProductCommentsBloc>().add(
                                    ProductCommentDeleted(comment.id),
                                  );
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.edit_outlined,
                                    size: 18.r,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  8.horizontalSpace,
                                  Text(
                                    'Edit',
                                    style: AppStyles.bodySmall.copyWith(
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete_outline_rounded,
                                    size: 18.r,
                                    color: Colors.red,
                                  ),
                                  8.horizontalSpace,
                                  Text(
                                    'Delete',
                                    style: AppStyles.bodySmall.copyWith(
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                  AppDimens.xs.height,
                  _buildCommentText(comment),
                  if (comment.rating > 0.0) ...[
                    AppDimens.xs.height,
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          final starValue = index + 1;
                          final isFilled = comment.rating >= starValue;
                          final isHalfFilled =
                              comment.rating >= starValue - 0.5 && comment.rating < starValue;

                          return Padding(
                            padding: EdgeInsets.only(right: 2.w),
                            child: Icon(
                              isHalfFilled ? Icons.star_half_rounded : Icons.star_rounded,
                              size: 16.r,
                              color: isFilled || isHalfFilled
                                  ? const Color(0xFFFFB800)
                                  : Theme.of(context).dividerColor,
                            ),
                          );
                        }),
                        4.horizontalSpace,
                        Text(
                          comment.rating.toStringAsFixed(1),
                          style: AppStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildCommentText(ProductCommentEntity comment) {
    final isExpanded = _expandedComments[comment.id] ?? false;
    final lines = comment.content.split('\n');
    final totalLines = lines.length;
    final hasMoreThan3Lines = totalLines > 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          comment.content,
          maxLines: isExpanded ? null : 3,
          overflow: isExpanded ? null : TextOverflow.ellipsis,
          style: AppStyles.bodyRegular.copyWith(
            color: Theme.of(context).textTheme.bodyMedium?.color,
            height: 1.4,
          ),
        ),
        if (hasMoreThan3Lines) ...[
          AppDimens.xxs.height,
          InkWell(
            onTap: () {
              setState(() {
                _expandedComments[comment.id] = !isExpanded;
              });
            },
            child: Text(
              isExpanded ? 'Show less' : '...more',
              style: AppStyles.bodySmall.copyWith(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
        AppDimens.xs.height,
        InkWell(
          onTap: () {
            _openCommentInput(context, replyTo: comment);
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.reply_rounded,
                size: 16.r,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
              4.horizontalSpace,
              Text(
                'Reply',
                style: AppStyles.bodySmall.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _openCommentInput(
    BuildContext context, {
    ProductCommentEntity? replyTo,
  }) {
    setState(() {
      _commentRating = 0.0;
      _ratingError = null;
    });
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
                  if (replyTo == null)
                    Expanded(
                      child: _buildRatingWidget(context),
                    )
                  else
                    const Spacer(),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    borderRadius: BorderRadius.circular(
                      AppDimens.imageRadius.r,
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(AppDimens.sm.r),
                      child: AppSvgIcon(
                        assetPath: AppIcons.close,
                        size: AppDimens.iconMd,
                        color: Theme.of(context).iconTheme.color,
                      ),
                    ),
                  ),
                ],
              ),
              if (replyTo == null) ...[
                AppDimens.xs.height,
                Text(
                  "Yulduzchalarni to'ldirish uchun chapdan o'ngga suring.",
                  style: AppStyles.bodySmall.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ],
              AppDimens.md.height,
              if (replyTo != null) ...[
                Container(
                  padding: EdgeInsets.all(AppDimens.sm.r),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.reply_rounded,
                        size: 16.r,
                        color: Theme.of(context).primaryColor,
                      ),
                      4.horizontalSpace,
                      Expanded(
                        child: Text(
                          'Replying to ${replyTo.userName}',
                          style: AppStyles.bodySmall.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                AppDimens.sm.height,
              ],
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
                        hintText: replyTo != null ? 'Write a reply...' : 'Izoh yozing...',
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
                      ),
                    ),
                  ),
                  AppDimens.sm.width,
                  InkWell(
                    onTap: () {
                      final text = controller.text.trim();
                      if (text.isEmpty) return;

                      if (replyTo == null && _commentRating < 1.0) {
                        setState(() {
                          _ratingError = "Kamida 1 yulduzgacha ratingni tanlang";
                        });
                        return;
                      }

                      final commentContent =
                          replyTo != null ? '@${replyTo.userName}: $text' : text;

                      final comment = ProductCommentEntity(
                        id: 'comment_${DateTime.now().millisecondsSinceEpoch}',
                        productId: widget.productId,
                        userId: widget.currentUserId,
                        userName: widget.currentUserName,
                        authorType: ProductCommentAuthor.user,
                        content: commentContent,
                        createdAt: DateTime.now(),
                        rating: _commentRating,
                      );
                      context.read<ProductCommentsBloc>().add(
                            ProductCommentAdded(comment),
                          );
                      
                      // Reset local state if needed, though this is a new bottom sheet instance?
                      // Wait, showModalBottomSheet builder context is separate but setState refers to _ProductCommentsSectionState?
                      // The builder function captures logic. State variable _commentRating is in _ProductCommentsSectionState.
                      // Yes, it works.
                      
                      setState(() {
                        _commentRating = 0.0;
                        _ratingError = null;
                      });
                      Navigator.of(context).pop();
                    },
                    borderRadius: BorderRadius.circular(
                      AppDimens.imageRadius.r,
                    ),
                    child: Container(
                      padding: EdgeInsets.all(AppDimens.sm.r),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(
                          AppDimens.imageRadius.r,
                        ),
                      ),
                      child: const AppSvgIcon(
                        assetPath: AppIcons.send,
                        size: AppDimens.iconMd,
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

  Widget _buildRatingWidget(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setSheetState) {
        // Note: setSheetState is for the bottom sheet local state.
        // But _commentRating is in the main widget state.
        // We need to update both if we want to reflect changes.
        // Actually, just updating main state and rebuilding sheet is tricky.
        // But _buildRatingWidget is called once. Wrapper StatefulBuilder helps.
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onHorizontalDragUpdate: (details) {
                      final RenderBox box = context.findRenderObject() as RenderBox;
                      final localPosition = details.localPosition;
                      final width = box.size.width;

                      double newRating = (localPosition.dx / width * 5.0).clamp(0.0, 5.0);

                      // Round to nearest 0.1
                      newRating = (newRating * 10).round() / 10;

                      // Auto jump to 1.0 if dragged from 0.0
                      if (_commentRating == 0.0 && newRating > 0.0 && newRating < 1.0) {
                        newRating = 1.0;
                      }

                      setSheetState(() {
                        _commentRating = newRating;
                        _ratingError = null;
                      });
                      // Update parent state too to persist? Or just local?
                      // _commentRating is in parent.
                      // setState(() {}); might be needed if displayed elsewhere.
                    },
                    onTapDown: (details) {
                      final RenderBox box = context.findRenderObject() as RenderBox;
                      final localPosition = details.localPosition;
                      final width = box.size.width;

                      double newRating = (localPosition.dx / width * 5.0).clamp(0.0, 5.0);
                      newRating = (newRating * 10).round() / 10;

                      if (_commentRating == 0.0 && newRating > 0.0 && newRating < 1.0) {
                        newRating = 1.0;
                      }

                      setSheetState(() {
                        _commentRating = newRating;
                        _ratingError = null;
                      });
                    },
                    child: Row(
                      children: List.generate(5, (index) {
                        final starValue = index + 1;
                        final isFilled = _commentRating >= starValue;
                        final isHalfFilled =
                            _commentRating >= starValue - 0.5 && _commentRating < starValue;

                        return Padding(
                          padding: EdgeInsets.only(right: 6.w),
                          child: Icon(
                            isHalfFilled ? Icons.star_half_rounded : Icons.star_rounded,
                            size: 40.r,
                            color: isFilled || isHalfFilled
                                ? const Color(0xFFFFB800)
                                : Theme.of(context).dividerColor,
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                8.horizontalSpace,
                Text(
                  _commentRating.toStringAsFixed(1),
                  style: AppStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleMedium?.color,
                  ),
                ),
              ],
            ),
            if (_ratingError != null) ...[
              AppDimens.xs.height,
              Text(
                _ratingError!,
                style: AppStyles.bodySmall.copyWith(
                  color: Colors.red,
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  void _openEditComment(BuildContext context, ProductCommentEntity comment) {
    final controller = TextEditingController(text: comment.content);
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
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  style: AppStyles.bodyRegular.copyWith(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Izohni tahrirlash...',
                    filled: true,
                    fillColor: Theme.of(context).scaffoldBackgroundColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimens.imageRadius.r),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              AppDimens.sm.width,
              InkWell(
                onTap: () {
                  final text = controller.text.trim();
                  if (text.isEmpty) return;
                  context.read<ProductCommentsBloc>().add(
                        ProductCommentUpdated(comment.id, text),
                      );
                  Navigator.of(context).pop();
                },
                child: Container(
                  padding: EdgeInsets.all(AppDimens.sm.r),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(AppDimens.imageRadius.r),
                  ),
                  child: const AppSvgIcon(
                    assetPath: AppIcons.send,
                    size: AppDimens.iconMd,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
