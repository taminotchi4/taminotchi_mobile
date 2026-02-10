import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/dimens.dart';
import '../../../../core/utils/styles.dart';
import '../../../../core/utils/extensions.dart';

class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final Color? titleColor;
  final VoidCallback? onTap;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.title,
    this.trailing,
    this.titleColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.cardRadius.r),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppDimens.md.w,
          vertical: AppDimens.md.h,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24.r,
              color: titleColor ?? Theme.of(context).iconTheme.color,
            ),
            AppDimens.md.width,
            Expanded(
              child: Text(
                title,
                style: AppStyles.bodyMedium.copyWith(
                  color: titleColor ??
                      Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
