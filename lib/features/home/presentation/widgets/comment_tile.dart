import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/dimens.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/styles.dart';
import '../../domain/entities/comment_entity.dart';

class CommentTile extends StatefulWidget {
  final CommentEntity comment;
  final bool isMine;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onReply;

  const CommentTile({
    super.key,
    required this.comment,
    this.isMine = false,
    this.onEdit,
    this.onDelete,
    this.onReply,
  });

  @override
  State<CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends State<CommentTile> {
  bool _isRepliesExpanded = false;

  String _formatCommentTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppDimens.md.r),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppDimens.cardRadius.r),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.3),
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.05),
            blurRadius: 4.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppDimens.circleRadius.r),
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
                    widget.comment.userName.isNotEmpty 
                        ? widget.comment.userName[0].toUpperCase()
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
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        widget.comment.userName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.titleMedium?.color,
                        ),
                      ),
                    ),
                    if (widget.comment.userRole != null) ...[
                      AppDimens.xs.width,
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: widget.comment.userRole == 'Market' 
                              ? Theme.of(context).primaryColor.withOpacity(0.1)
                              : Theme.of(context).dividerColor.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          widget.comment.userRole!,
                          style: AppStyles.bodySmall.copyWith(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.bold,
                            color: widget.comment.userRole == 'Market'
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Text(
                _formatCommentTime(widget.comment.createdAt),
                style: AppStyles.bodySmall.copyWith(
                  fontSize: 10.sp,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
              if (widget.isMine) ...[
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
                    if (value == 'edit' && widget.onEdit != null) {
                      widget.onEdit!();
                    } else if (value == 'delete' && widget.onDelete != null) {
                      widget.onDelete!();
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
          Text(
            widget.comment.content,
            style: AppStyles.bodyRegular.copyWith(
              color: Theme.of(context).textTheme.bodyMedium?.color,
              height: 1.4,
            ),
          ),
          if (widget.onReply != null) ...[
            AppDimens.sm.height,
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onReply,
                borderRadius: BorderRadius.circular(4.r),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 4.w,
                    vertical: 2.h,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.reply_rounded,
                        size: 16.sp,
                        color: Theme.of(context).primaryColor,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Javob berish',
                        style: AppStyles.bodySmall.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          if (widget.comment.replies != null && widget.comment.replies!.isNotEmpty) ...[
            AppDimens.md.height,
            InkWell(
              onTap: () {
                setState(() {
                  _isRepliesExpanded = !_isRepliesExpanded;
                });
              },
              borderRadius: BorderRadius.circular(4.r),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 4.h),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 24.w,
                      height: 1.h,
                      color: Theme.of(context).dividerColor,
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      _isRepliesExpanded 
                        ? 'Javoblarni yashirish' 
                        : 'Javoblarni ko\'rish (${widget.comment.replies!.length})',
                      style: AppStyles.bodySmall.copyWith(
                        color: Theme.of(context).hintColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_isRepliesExpanded) ...[
              AppDimens.sm.height,
              ...widget.comment.replies!.map((reply) {
                return Padding(
                  padding: EdgeInsets.only(top: AppDimens.sm.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: 24.w), // Indent replies
                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(AppDimens.circleRadius.r),
                        child: Container(
                          width: 24.w,
                          height: 24.w,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            reply.userName.isNotEmpty
                                ? reply.userName[0].toUpperCase()
                                : '?',
                            style: AppStyles.bodySmall.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 10.sp,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  reply.userName,
                                  style: AppStyles.bodySmall.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.color,
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                if (reply.userRole != null)
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 4.w, vertical: 1.h),
                                    decoration: BoxDecoration(
                                      color: reply.userRole == 'Market'
                                          ? Theme.of(context)
                                              .primaryColor
                                              .withOpacity(0.1)
                                          : Theme.of(context)
                                              .dividerColor
                                              .withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(2.r),
                                    ),
                                    child: Text(
                                      reply.userRole!,
                                      style: AppStyles.bodySmall.copyWith(
                                        fontSize: 8.sp,
                                        fontWeight: FontWeight.bold,
                                        color: reply.userRole == 'Market'
                                            ? Theme.of(context).primaryColor
                                            : Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.color,
                                      ),
                                    ),
                                  ),
                                const Spacer(),
                                Text(
                                  _formatCommentTime(reply.createdAt),
                                  style: AppStyles.bodySmall.copyWith(
                                    fontSize: 10.sp,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              reply.content,
                              style: AppStyles.bodyRegular.copyWith(
                                fontSize: 12.sp,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ],
      ),
    );
  }
}
