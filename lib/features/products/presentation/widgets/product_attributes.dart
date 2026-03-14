import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/dimens.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/styles.dart';

class ProductAttributes extends StatelessWidget {
  final List<int> colors;
  final List<String> sizes;
  final int? selectedColor;
  final String? selectedSize;
  final String? sizeError;
  final Function(int) onColorSelected;
  final Function(String) onSizeSelected;

  const ProductAttributes({
    super.key,
    required this.colors,
    required this.sizes,
    required this.onColorSelected,
    required this.onSizeSelected,
    this.selectedColor,
    this.selectedSize,
    this.sizeError,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (colors.isNotEmpty) ...[
          AppDimens.lg.height,
          Text(
            'Ranglar',
            style: AppStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          AppDimens.sm.height,
          Wrap(
            spacing: 12.w,
            children: colors.map((colorValue) {
              final isSelected = selectedColor == colorValue;
              return GestureDetector(
                onTap: () => onColorSelected(colorValue),
                child: Container(
                  width: 32.w,
                  height: 32.w,
                  decoration: BoxDecoration(
                    color: Color(colorValue),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).dividerColor,
                      width: isSelected ? 2.w : 1.w,
                    ),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: Color(colorValue).withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                    ],
                  ),
                  child: isSelected
                      ? Icon(Icons.check, size: 16.r, color: Colors.white)
                      : null,
                ),
              );
            }).toList(),
          ),
        ],
        if (sizes.isNotEmpty) ...[
          AppDimens.lg.height,
          Text(
            'O\'lchamlar',
            style: AppStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          AppDimens.sm.height,
          Wrap(
            spacing: 12.w,
            children: sizes.map((size) {
              final isSelected = selectedSize == size;
              return GestureDetector(
                onTap: () => onSizeSelected(size),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).dividerColor,
                      width: 1.w,
                    ),
                  ),
                  child: Text(
                    size,
                    style: AppStyles.bodySmall.copyWith(
                      color: isSelected
                          ? Colors.white
                          : Theme.of(context).textTheme.bodyMedium?.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          if (sizeError != null) ...[
            AppDimens.xs.height,
            Text(
              sizeError!,
              style: AppStyles.bodySmall.copyWith(color: Colors.red),
            ),
          ],
        ],
      ],
    );
  }
}
