import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constants/dimens.dart';
import '../../core/utils/styles.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;

  const CommonAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
  });

  @override
  Size get preferredSize => Size.fromHeight(AppDimens.appBarHeight.h);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AppBar(
      backgroundColor: isDark ? const Color(0xFF0E1013) : Theme.of(context).scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      shape: isDark
          ? RoundedRectangleBorder(
              side: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 1.0,
              ),
            )
          : null,
      leading: leading != null
          ? Center(child: leading)
          : null,
      leadingWidth: 56.w,
      actions: actions != null
          ? actions!.map((a) => Center(child: a)).toList()
          : null,
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppStyles.h4Bold.copyWith(
          fontSize: 18.sp,
          color: Theme.of(context).textTheme.titleLarge?.color,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(1.h),
        child: isDark 
            ? const SizedBox.shrink() 
            : Divider(
                height: 1.h,
                thickness: 1.h,
                color: Theme.of(context).dividerColor.withOpacity(0.3),
              ),
      ),
    );
  }
}
