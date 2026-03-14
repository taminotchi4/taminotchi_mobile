import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constants/dimens.dart';
import '../../core/utils/icons.dart';
import 'app_svg_icon.dart';

class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).pop(),
      borderRadius: BorderRadius.circular(AppDimens.imageRadius.r),
      child: Padding(
        padding: EdgeInsets.all(AppDimens.sm.r),
        child: AppSvgIcon(
          assetPath: AppIcons.back,
          size: AppDimens.iconMd,
          color: Theme.of(context).iconTheme.color,
        ),
      ),
    );
  }
}
