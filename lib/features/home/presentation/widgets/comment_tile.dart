import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/dimens.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/styles.dart';
import '../../domain/entities/comment_entity.dart';

class CommentTile extends StatelessWidget {
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
          color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
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
                        Theme.of(context).primaryColor.withValues(alpha: 0.7),
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
                    color: Theme.of(context).textTheme.titleMedium?.color,
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
                    if (value == 'edit' && onEdit != null) {
                      onEdit!();
                    } else if (value == 'delete' && onDelete != null) {
                      onDelete!();
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
            comment.content,
            style: AppStyles.bodyRegular.copyWith(
              color: Theme.of(context).textTheme.bodyMedium?.color,
              height: 1.4,
            ),
          ),
          if (onReply != null) ...[
            AppDimens.sm.height,
            InkWell(
              onTap: onReply,
              child: Text(
                'Javob berish',
                style: AppStyles.bodySmall.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          if (comment.replies != null && comment.replies!.isNotEmpty) ...[
            AppDimens.md.height,
            Divider(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
              thickness: 1.w,
            ),
            AppDimens.sm.height,
            ...comment.replies!.map((reply) {
              return Padding(
                padding: EdgeInsets.only(bottom: AppDimens.sm.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppDimens.circleRadius.r),
                      child: Container(
                        width: 28.w,
                        height: 28.w,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).primaryColor.withValues(alpha: 0.7),
                              Theme.of(context).primaryColor.withValues(alpha: 0.5),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          reply.userName.isNotEmpty 
                              ? reply.userName[0].toUpperCase()
                              : '?',
                          style: AppStyles.bodySmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11.sp,
                          ),
                        ),
                      ),
                    ),
                    AppDimens.xs.width,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  reply.userName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppStyles.bodySmall.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12.sp,
                                    color: Theme.of(context).textTheme.titleMedium?.color,
                                  ),
                                ),
                              ),
                              Text(
                                _formatCommentTime(reply.createdAt),
                                style: AppStyles.bodySmall.copyWith(
                                  fontSize: 9.sp,
                                  color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                          2.verticalSpace,
                          Text(
                            reply.content,
                            style: AppStyles.bodySmall.copyWith(
                              fontSize: 12.sp,
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ],
      ),
    );
  }
}
