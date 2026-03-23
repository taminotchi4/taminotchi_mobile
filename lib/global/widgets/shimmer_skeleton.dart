import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerSkeleton extends StatelessWidget {
  final double height;
  final double width;
  final double borderRadius;
  final ShapeBorder shape;

  const ShimmerSkeleton({
    super.key,
    this.height = 20,
    this.width = double.infinity,
    this.borderRadius = 8,
    this.shape = const RoundedRectangleBorder(),
  });

  const ShimmerSkeleton.circular({
    super.key,
    required double size,
    this.borderRadius = 100,
  })  : height = size,
        width = size,
        shape = const CircleBorder();

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDarkMode ? Colors.grey[700]! : Colors.grey[100]!,
      child: Container(
        height: height,
        width: width,
        decoration: ShapeDecoration(
          color: Colors.grey,
          shape: borderRadius > 0 && shape is RoundedRectangleBorder
              ? RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius))
              : shape,
        ),
      ),
    );
  }
}
