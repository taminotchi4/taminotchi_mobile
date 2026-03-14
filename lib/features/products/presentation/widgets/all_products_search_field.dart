import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/icons.dart';
import '../../../../core/utils/styles.dart';
import '../../../../global/widgets/app_svg_icon.dart';
import '../managers/products_bloc.dart';
import '../managers/products_event.dart';

class AllProductsSearchField extends StatelessWidget {
  const AllProductsSearchField({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      height: 44.h,
      decoration: BoxDecoration(
        color: isDark 
            ? Colors.grey[850]?.withOpacity(0.5)
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDark 
              ? Colors.grey[700]!.withOpacity(0.3)
              : Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: TextField(
        onChanged: (value) =>
            context.read<ProductsBloc>().add(ProductsUpdateSearch(value)),
        style: AppStyles.bodyRegular.copyWith(
          color: Theme.of(context).textTheme.bodyMedium?.color,
          fontSize: 14.sp,
        ),
        decoration: InputDecoration(
          hintText: context.l10n.search,
          hintStyle: AppStyles.bodyRegular.copyWith(
            color: Theme.of(context).hintColor.withOpacity(0.6),
            fontSize: 14.sp,
          ),
          filled: false,
          isDense: true,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          prefixIcon: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: AppSvgIcon(
              assetPath: AppIcons.search,
              size: 20.r,
              color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
            ),
          ),
          prefixIconConstraints: BoxConstraints(
            minWidth: 40.w,
            minHeight: 44.h,
          ),
          contentPadding: EdgeInsets.symmetric(
            vertical: 12.h,
            horizontal: 16.w,
          ),
        ),
      ),
    );
  }
}
