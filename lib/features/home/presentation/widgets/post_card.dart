import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/utils/colors.dart';
import '../../../../core/constants/dimens.dart';
import '../../../../core/utils/icons.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/styles.dart';
import '../../../../global/widgets/app_svg_icon.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/entities/post_image_entity.dart';
import 'image_viewer_dialog.dart';

class PostCard extends StatelessWidget {
  final PostEntity post;
  final int commentCount;
  final VoidCallback? onTap;
  final int? textMaxLines;
  final bool showFullText;

  const PostCard({
    super.key,
    required this.post,
    required this.commentCount,
    this.onTap,
    this.textMaxLines,
    this.showFullText = false,
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
              AppDimens.md.height,
              _buildFooter(context, commentCount),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimens.circleRadius.r),
          child: Container(
            width: AppDimens.avatar.w,
            height: AppDimens.avatar.w,
            color: AppColors.gray100,
            alignment: Alignment.center,
            child: SvgPicture.asset(
              post.authorAvatarPath,
              width: AppDimens.iconMd.w,
              height: AppDimens.iconMd.w,
              colorFilter: const ColorFilter.mode(
                AppColors.gray700,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
        AppDimens.sm.width,
        Expanded(
          child: Text(
            post.authorName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppStyles.h5Bold.copyWith(
              color: Theme.of(context).textTheme.titleMedium?.color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageSection(BuildContext context) {
    return SizedBox(
      height: 70.h,
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
    return Row(
      children: [
        AppSvgIcon(
          assetPath: post.category.iconPath,
          size: AppDimens.iconMd,
          color: Theme.of(context).iconTheme.color,
        ),
        const Spacer(),
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
  }

  Widget _infoItem(BuildContext context, String icon, String text) {
    return Row(
      children: [
        AppSvgIcon(assetPath: icon, size: AppDimens.iconSm),
        AppDimens.xs.width,
        Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppStyles.bodySmall.copyWith(
            color: Theme.of(context).textTheme.bodySmall?.color,
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
    if (image.path.toLowerCase().endsWith('.svg')) {
      return SvgPicture.asset(image.path, fit: BoxFit.cover);
    }
    return Image.asset(image.path, fit: BoxFit.cover);
  }
}
