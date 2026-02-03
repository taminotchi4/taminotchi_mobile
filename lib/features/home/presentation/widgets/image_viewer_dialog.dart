import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';

import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/dimens.dart';
import '../../../../core/utils/icons.dart';
import '../../../../global/widgets/app_svg_icon.dart';
import '../../domain/entities/post_image_entity.dart';

class ImageViewerDialog extends StatelessWidget {
  final List<PostImageEntity> images;
  final int initialIndex;

  const ImageViewerDialog({
    super.key,
    required this.images,
    this.initialIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Stack(
        children: [
          PageView.builder(
            controller: PageController(initialPage: initialIndex),
            itemCount: images.length,
            itemBuilder: (context, index) {
              return Container(
                color: Colors.black,
                alignment: Alignment.center,
                child: _buildImage(images[index]),
              );
            },
          ),
          Positioned(
            top: AppDimens.md.h,
            right: AppDimens.md.w,
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              borderRadius: BorderRadius.circular(AppDimens.xl.r),
              child: Container(
                padding: EdgeInsets.all(AppDimens.sm.r),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(AppDimens.xl.r),
                ),
                child: const AppSvgIcon(
                  assetPath: AppIcons.close,
                  size: AppDimens.iconMd,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(PostImageEntity image) {
    if (image.isLocal) {
      return Image.file(
        File(image.path),
        width: 1.sw,
        height: 1.sh,
        fit: BoxFit.contain,
      );
    }
    if (image.path.toLowerCase().endsWith('.svg')) {
      return SvgPicture.asset(
        image.path,
        width: 1.sw,
        height: 1.sh,
        fit: BoxFit.contain,
      );
    }
    return Image.asset(
      image.path,
      width: 1.sw,
      height: 1.sh,
      fit: BoxFit.contain,
    );
  }
}
