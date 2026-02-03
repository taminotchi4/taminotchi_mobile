import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/utils/colors.dart';
import '../../../../core/constants/dimens.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/styles.dart';
import '../../domain/entities/comment_entity.dart';

class CommentTile extends StatelessWidget {
  final CommentEntity comment;

  const CommentTile({super.key, required this.comment});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimens.circleRadius.r),
          child: Container(
            width: AppDimens.avatarSm.w,
            height: AppDimens.avatarSm.w,
            color: AppColors.gray100,
            alignment: Alignment.center,
            child: SvgPicture.asset(
              comment.userAvatarPath,
              width: AppDimens.iconSm.w,
              height: AppDimens.iconSm.w,
              colorFilter: const ColorFilter.mode(
                AppColors.gray700,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
        AppDimens.sm.width,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                comment.userName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppStyles.h5Bold.copyWith(
                  fontSize: AppStyles.bodyRegular.fontSize,
                  color: Theme.of(context).textTheme.titleMedium?.color,
                ),
              ),
              AppDimens.xxs.height,
              Text(
                comment.content,
                style: AppStyles.bodyRegular.copyWith(
                  fontSize: AppStyles.bodySmall.fontSize,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
