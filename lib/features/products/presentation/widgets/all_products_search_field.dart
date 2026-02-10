import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/dimens.dart';
import '../../../../core/utils/icons.dart';
import '../../../../core/utils/styles.dart';
import '../../../../global/widgets/app_svg_icon.dart';
import '../managers/products_bloc.dart';
import '../managers/products_event.dart';

class AllProductsSearchField extends StatelessWidget {
  const AllProductsSearchField({super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: (value) =>
          context.read<ProductsBloc>().add(ProductsUpdateSearch(value)),
      style: AppStyles.bodyRegular.copyWith(
        color: Theme.of(context).textTheme.bodyMedium?.color,
      ),
      decoration: InputDecoration(
        hintText: 'Qidirish...',
        hintStyle:
            AppStyles.bodyRegular.copyWith(color: Theme.of(context).hintColor),
        filled: true,
        fillColor: Theme.of(context).cardColor,
        isDense: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.imageRadius.r),
          borderSide: BorderSide(
            color: Theme.of(context).dividerColor,
            width: AppDimens.borderWidth.w,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.imageRadius.r),
          borderSide: BorderSide(
            color: Theme.of(context).dividerColor,
            width: AppDimens.borderWidth.w,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.imageRadius.r),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: AppDimens.borderWidth.w,
          ),
        ),
        prefixIcon: Padding(
          padding: EdgeInsets.all(AppDimens.sm.r),
          child: AppSvgIcon(
            assetPath: AppIcons.search,
            size: AppDimens.iconMd,
            color: Theme.of(context).iconTheme.color,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          vertical: AppDimens.sm.h,
          horizontal: AppDimens.md.w,
        ),
        constraints: BoxConstraints(
          minHeight: AppDimens.searchFieldHeight.h,
        ),
      ),
    );
  }
}
