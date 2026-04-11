import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/dimens.dart';

class ProductImageSlider extends StatelessWidget {
  final List<String> images;

  const ProductImageSlider({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppDimens.imageRadius.r);
    if (images.isEmpty) {
      return ClipRRect(
        borderRadius: radius,
        child: Container(
          height: AppDimens.productImageHeight.h,
          color: Theme.of(context).dividerColor,
        ),
      );
    }
    if (images.length == 1) {
      return ClipRRect(
        borderRadius: radius,
        child: SizedBox(
          height: AppDimens.productImageHeight.h,
          child: _buildImage(images.first),
        ),
      );
    }
    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        height: AppDimens.productImageHeight.h,
        child: PageView.builder(
          itemCount: images.length,
          itemBuilder: (context, index) => _buildImage(images[index]),
        ),
      ),
    );
  }

  Widget _buildImage(String path) {
    final isUrl = path.startsWith('http://') || path.startsWith('https://');
    if (isUrl) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            color: Theme.of(context).dividerColor,
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => Container(
          color: Theme.of(context).dividerColor,
          child: const Icon(Icons.broken_image_outlined, size: 40),
        ),
      );
    }
    if (path.toLowerCase().endsWith('.svg')) {
      return SvgPicture.asset(path, fit: BoxFit.cover);
    }
    return Image.asset(
      path,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        color: Theme.of(context).dividerColor,
        child: const Icon(Icons.broken_image_outlined, size: 40),
      ),
    );
  }
}
