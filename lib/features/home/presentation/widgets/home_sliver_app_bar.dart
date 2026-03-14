import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/dimens.dart';
import '../../../../core/utils/icons.dart';
import '../../../../core/utils/styles.dart';
import '../../../../global/widgets/app_svg_icon.dart';

class HomeSliverAppBar extends StatelessWidget {
  final VoidCallback? onLeftTap;
  final VoidCallback? onRightTap;

  const HomeSliverAppBar({
    super.key,
    this.onLeftTap,
    this.onRightTap,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      floating: true,
      snap: true,
      pinned: false,
      elevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      expandedHeight: AppDimens.appBarExpanded.h,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppDimens.lg.w,
                AppDimens.sm.h,
                AppDimens.lg.w,
                AppDimens.md.h,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: AppDimens.appBarButton.w,
                        height: AppDimens.appBarButton.w,
                        child: InkWell(
                          onTap: onLeftTap,
                          borderRadius:
                              BorderRadius.circular(AppDimens.imageRadius.r),
                          child: Center(
                            child: AppSvgIcon(
                              assetPath: AppIcons.menu,
                              size: AppDimens.iconLg,
                              color: Theme.of(context).iconTheme.color,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            'Home',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                              style: AppStyles.h4Bold.copyWith(
                                color: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.color,
                              ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: AppDimens.appBarButton.w,
                        height: AppDimens.appBarButton.w,
                        child: InkWell(
                          onTap: onRightTap,
                          borderRadius:
                              BorderRadius.circular(AppDimens.imageRadius.r),
                          child: Center(
                            child: AppSvgIcon(
                              assetPath: AppIcons.notification,
                              size: AppDimens.avatarXs,
                              color: Theme.of(context).iconTheme.color,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
