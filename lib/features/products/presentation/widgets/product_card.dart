import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/dimens.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/icons.dart';
import '../../../../core/utils/styles.dart';
import '../../../../global/widgets/app_svg_icon.dart';
import '../../domain/entities/product_entity.dart';
import 'product_image_slider.dart';

class ProductCard extends StatelessWidget {
  final ProductEntity product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push(Routes.getProductDetail(product.id)),
      borderRadius: BorderRadius.circular(AppDimens.cardRadius.r),
      child: Container(
        padding: EdgeInsets.all(AppDimens.md.r),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppDimens.cardRadius.r),
          border: Border.all(
            color: Theme.of(context).dividerColor,
            width: AppDimens.borderWidth.w,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProductImageSlider(images: product.imagePaths),
            AppDimens.md.height,
            Text(
              product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppStyles.h5Bold.copyWith(
                fontSize: AppStyles.bodyRegular.fontSize,
                color: Theme.of(context).textTheme.titleMedium?.color,
              ),
            ),
            AppDimens.xs.height,
            Text(
              formatPrice(product.price),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppStyles.bodySmall.copyWith(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            AppDimens.sm.height,
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimens.imageRadius.r),
                  child: Container(
                    width: AppDimens.avatarXs.w,
                    height: AppDimens.avatarXs.w,
                    color: Theme.of(context).dividerColor,
                    child: AppSvgIcon(
                      assetPath: product.seller.avatarPath,
                      size: AppDimens.iconSm,
                      color: Theme.of(context).iconTheme.color,
                    ),
                  ),
                ),
                AppDimens.sm.width,
                Expanded(
                  child: Text(
                    product.seller.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyles.bodySmall.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ),
              ],
            ),
            AppDimens.sm.height,
            Row(
              children: [
                AppSvgIcon(
                  assetPath: AppIcons.star,
                  size: AppDimens.iconSm,
                  color: Theme.of(context).iconTheme.color,
                ),
                AppDimens.xs.width,
                Text(
                  product.rating.toStringAsFixed(1),
                  style: AppStyles.bodySmall.copyWith(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                AppDimens.sm.width,
                Text(
                  '(${product.reviewCount})',
                  style: AppStyles.bodySmall.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
                const Spacer(),
                AppSvgIcon(
                  assetPath: AppIcons.cart,
                  size: AppDimens.iconMd,
                  color: Theme.of(context).iconTheme.color,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
