import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/dimens.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/styles.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? sellerName;
  final String? sellerRole;

  const ChatAppBar({
    super.key,
    this.sellerName,
    this.sellerRole,
  });

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + 1.h);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      backgroundColor: isDark ? const Color(0xFF0E1013) : const Color(0xFFF5F5F5),
      shape: isDark
          ? RoundedRectangleBorder(
              side: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 1.0,
              ),
            )
          : null,
      elevation: 0,
      leading: Padding(
        padding: EdgeInsets.only(left: 8.w),
        child: IconButton(
          icon: Icon(
            Icons.arrow_back,
            size: 22.r,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          CircleAvatar(
            radius: 20.r,
            backgroundColor: Theme.of(context).primaryColor,
            child: Text(
              (sellerName?.isNotEmpty == true)
                  ? sellerName![0].toUpperCase()
                  : '?',
              style: AppStyles.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          AppDimens.sm.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        sellerName ?? 'Foydalanuvchi',
                        style: AppStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.titleMedium?.color,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (sellerRole != null) ...[
                      AppDimens.xs.width,
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: sellerRole == 'Market'
                              ? Theme.of(context).primaryColor.withOpacity(0.15)
                              : Theme.of(context).dividerColor.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          sellerRole!,
                          style: AppStyles.bodySmall.copyWith(
                            fontSize: 9.sp,
                            color: sellerRole == 'Market'
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).textTheme.bodySmall?.color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  'Online',
                  style: AppStyles.bodySmall.copyWith(fontSize: 11.sp, color: Colors.green),
                ),
              ],
            ),
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(1.h),
        child: isDark 
            ? const SizedBox.shrink()
            : Container(
                height: 1.h,
                color: Theme.of(context).dividerColor.withOpacity(0.3),
              ),
      ),
    );
  }
}
