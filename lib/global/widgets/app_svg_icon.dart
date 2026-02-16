import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppSvgIcon extends StatelessWidget {
  final String assetPath;
  final double size;
  final Color? color;

  const AppSvgIcon({
    super.key,
    required this.assetPath,
    this.size = 20,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? Theme.of(context).iconTheme.color;
    final isNetwork = assetPath.startsWith('http');

    if (isNetwork) {
      return SvgPicture.network(
        assetPath,
        width: size.w,
        height: size.w,
        colorFilter: iconColor == null
            ? null
            : ColorFilter.mode(iconColor, BlendMode.srcIn),
        placeholderBuilder: (BuildContext context) => Container(
            padding: const EdgeInsets.all(10.0),
            child: const CircularProgressIndicator()),
      );
    }

    return SvgPicture.asset(
      assetPath,
      width: size.w,
      height: size.w,
      colorFilter: iconColor == null
          ? null
          : ColorFilter.mode(iconColor, BlendMode.srcIn),
    );
  }
}
