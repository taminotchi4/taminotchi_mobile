import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/colors.dart';
import '../../../../core/constants/dimens.dart';
import '../../../../core/utils/icons.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/styles.dart';
import '../../../../global/widgets/app_svg_icon.dart';
import '../../domain/entities/post_category_entity.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/entities/post_image_entity.dart';
import '../../domain/entities/post_status.dart';
import '../managers/home_bloc.dart';
import '../managers/home_state.dart';
import 'image_viewer_dialog.dart';
import '../../../../global/widgets/telegram_image.dart';

class PostCard extends StatelessWidget {
  final PostEntity post;
  final int commentCount;
  final VoidCallback? onTap;
  final int? textMaxLines;
  final bool showFullText;
  final Widget? trailing;

  const PostCard({
    super.key,
    required this.post,
    required this.commentCount,
    this.onTap,
    this.textMaxLines,
    this.showFullText = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(AppDimens.cardRadius.r),
      elevation: AppDimens.cardElevation,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.cardRadius.r),
        child: Padding(
          padding: EdgeInsets.all(AppDimens.md.r),
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(context),
                AppDimens.md.height,
                if (post.images.isNotEmpty) _buildImageSection(context),
                if (post.images.isNotEmpty) AppDimens.md.height,
                Text(
                  post.content,
                  maxLines: showFullText
                      ? null
                      : (textMaxLines ?? (post.images.isNotEmpty ? 3 : 5)),
                  overflow:
                      showFullText ? TextOverflow.visible : TextOverflow.ellipsis,
                  style: AppStyles.bodyRegular.copyWith(
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                ),
                if (showFullText && (post.price != null || post.address != null)) ...[
                  AppDimens.md.height,
                  _buildDetailsSection(context),
                ],
                AppDimens.md.height,
                _buildFooter(context, commentCount),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppDimens.sm.r),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(AppDimens.imageRadius.r),
      ),
      child: Column(
        children: [
          if (post.price != null && post.price != '0.00' && post.price != '0')
            _detailItem(
              context,
              Icons.payments_outlined,
              context.l10n.priceLabel,
              '${post.price} so\'m',
              color: Colors.green,
            ),
          if (post.address != null && post.address!.isNotEmpty)
            _detailItem(
              context,
              Icons.location_on_outlined,
              context.l10n.addressLabel,
              post.address!,
              color: Colors.blue,
            ),
        ],
      ),
    );
  }

  Widget _detailItem(BuildContext context, IconData icon, String label, String value, {Color? color}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Icon(icon, size: 16.sp, color: color ?? Theme.of(context).primaryColor),
          SizedBox(width: 8.w),
          Text(
            label,
            style: AppStyles.bodySmall.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Text(
              value,
              style: AppStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: color ?? Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimens.circleRadius.r),
            child: post.authorAvatarPath.startsWith('http')
                ? (post.authorAvatarPath.endsWith('.svg')
                    ? SvgPicture.network(
                        post.authorAvatarPath,
                        width: AppDimens.iconMd.w,
                        height: AppDimens.iconMd.w,
                        colorFilter: const ColorFilter.mode(
                          AppColors.gray700,
                          BlendMode.srcIn,
                        ),
                      )
                    : Image.network(
                        post.authorAvatarPath,
                        width: AppDimens.avatar.w,
                        height: AppDimens.avatar.w,
                        fit: BoxFit.cover,
                      ))
                : SvgPicture.asset(
                    post.authorAvatarPath,
                    width: AppDimens.iconMd.w,
                    height: AppDimens.iconMd.w,
                    colorFilter: const ColorFilter.mode(
                      AppColors.gray700,
                      BlendMode.srcIn,
                    ),
                  ),
          ),
        AppDimens.sm.width,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.authorName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppStyles.h5Bold.copyWith(
                  color: Theme.of(context).textTheme.titleMedium?.color,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                _formatDate(post.createdAt, context),
                style: AppStyles.bodySmall.copyWith(
                  fontSize: 10.sp,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
        ),
        AppDimens.sm.width,
        _buildStatusChip(context),
        if (trailing != null) ...[
          AppDimens.sm.width,
          trailing!,
        ],
      ],
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    final isArchived = post.status == PostStatus.archived;
    final color = isArchived ? Colors.grey : Colors.green;
    final icon = isArchived ? Icons.check_circle_outline : Icons.fiber_manual_record;
    final label = isArchived ? context.l10n.statusAgreed : context.l10n.statusActive;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10.sp, color: color),
          SizedBox(width: 4.w),
          Text(
            label,
            style: AppStyles.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 10.sp,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date, BuildContext context) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays > 0) {
      return context.l10n.daysAgo(difference.inDays);
    } else if (difference.inHours > 0) {
      return context.l10n.hoursAgo(difference.inHours);
    } else if (difference.inMinutes > 0) {
      return context.l10n.minutesAgo(difference.inMinutes);
    } else {
      return context.l10n.justNow;
    }
  }

  Widget _buildImageSection(BuildContext context) {
    return SizedBox(
      height: showFullText ? 200.h : 70.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: post.images.length,
        separatorBuilder: (_, __) => AppDimens.sm.width,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                barrierColor: Colors.black54,
                builder: (_) => ImageViewerDialog(images: post.images, initialIndex: index),
              );
            },
            child: AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppDimens.imageRadius.r),
                child: _buildImageContent(post.images[index]),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFooter(BuildContext context, int commentCount) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        final categoryName = _getCategoryDisplayName(state.categories);
        
        return Row(
          children: [
            AppSvgIcon(
              assetPath: post.category.iconPath,
              size: AppDimens.iconMd,
              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
            ),
            AppDimens.xs.width,
            Expanded(
              child: Text(
                categoryName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppStyles.bodySmall.copyWith(
                  color:
                      Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                ),
              ),
            ),
            AppDimens.sm.width,
            _infoItem(
              context,
              AppIcons.comment,
              commentCount.toString(),
            ),
            AppDimens.md.width,
            _infoItem(
              context,
              AppIcons.privateReply,
              post.privateReplyCount.toString(),
            ),
          ],
        );
      },
    );
  }

  String _getCategoryDisplayName(List<PostCategoryEntity> categories) {
    // If category has a parent, show "Parent > Child" format
    if (post.category.parentId != null && post.category.parentId!.isNotEmpty) {
      // Find parent category
      final parentCategory = categories.where((cat) => cat.id == post.category.parentId).firstOrNull;
      if (parentCategory != null) {
        return '${parentCategory.name} > ${post.category.name}';
      }
    }
    return post.category.name;
  }

  Widget _infoItem(BuildContext context, String icon, String text) {
    final color = Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7);
    return Row(
      children: [
        AppSvgIcon(
          assetPath: icon,
          size: AppDimens.iconSm,
          color: color,
        ),
        AppDimens.xs.width,
        Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppStyles.bodySmall.copyWith(
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildImageContent(PostImageEntity image) {
    if (image.isLocal) {
      return Image.file(
        File(image.path),
        fit: BoxFit.cover,
      );
    }
    final isNetwork = image.path.startsWith('http');
    final isSvg = image.path.toLowerCase().endsWith('.svg');

    if (isNetwork) {
      if (isSvg) {
        return SvgPicture.network(
          image.path,
          fit: BoxFit.cover,
          placeholderBuilder: (context) => Container(
            color: AppColors.gray100,
            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
        );
      }
      return TelegramImage(
        imageUrl: image.path,
        fit: BoxFit.cover,
      );
    }

    if (isSvg) {
      return SvgPicture.asset(image.path, fit: BoxFit.cover);
    }
    return Image.asset(image.path, fit: BoxFit.cover);
  }
}
