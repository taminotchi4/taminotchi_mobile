import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constants/dimens.dart';
import '../../core/utils/icons.dart';
import 'app_svg_icon.dart';

class AnimatedBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AnimatedBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: EdgeInsets.fromLTRB(
          AppDimens.lg.w,
          AppDimens.sm.h,
          AppDimens.lg.w,
          AppDimens.lg.h,
        ),
        padding: EdgeInsets.symmetric(
          vertical: AppDimens.sm.h,
          horizontal: AppDimens.md.w,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppDimens.cardRadius.r),
          border: Border.all(
            color: Theme.of(context).dividerColor,
            width: AppDimens.borderWidth.w,
          ),
        ),
        child: Row(
          children: [
            _NavItem(
              icon: AppIcons.home,
              isActive: currentIndex == 0,
              onTap: () => onTap(0),
            ),
            _NavItem(
              icon: AppIcons.myPosts,
              isActive: currentIndex == 1,
              onTap: () => onTap(1),
            ),
            _NavItem(
              icon: AppIcons.orders,
              isActive: currentIndex == 2,
              onTap: () => onTap(2),
            ),
            _NavItem(
              icon: AppIcons.profile,
              isActive: currentIndex == 3,
              onTap: () => onTap(3),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  static const Duration _animDuration = Duration(milliseconds: 250);
  static const double _activeScale = 1.1;
  final String icon;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.imageRadius.r),
        child: AnimatedContainer(
          duration: _animDuration,
          padding: EdgeInsets.symmetric(vertical: AppDimens.sm.h),
          decoration: BoxDecoration(
            color: isActive
                ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppDimens.imageRadius.r),
          ),
          child: AnimatedScale(
            duration: _animDuration,
            scale: isActive ? _activeScale : 1.0,
            child: AppSvgIcon(
              assetPath: icon,
              size: 22,
              color: isActive
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).iconTheme.color,
            ),
          ),
        ),
      ),
    );
  }
}
