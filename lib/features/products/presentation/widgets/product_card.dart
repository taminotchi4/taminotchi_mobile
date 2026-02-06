import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/dimens.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/formatters.dart';
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
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppDimens.cardRadius.r),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppDimens.cardRadius.r),
                  ),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: ProductImageSlider(images: product.imagePaths),
                  ),
                ),
                Positioned(
                  top: 8.h,
                  right: 8.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 14.r,
                          color: const Color(0xFFFFB800),
                        ),
                        2.horizontalSpace,
                        Text(
                          product.rating.toStringAsFixed(1),
                          style: AppStyles.bodySmall.copyWith(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(AppDimens.md.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    AppDimens.xs.height,
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppDimens.imageRadius.r),
                          child: Container(
                            width: 16.w,
                            height: 16.w,
                            color: Theme.of(context).dividerColor,
                            child: AppSvgIcon(
                              assetPath: product.seller.avatarPath,
                              size: 10.w,
                              color: Theme.of(context).iconTheme.color,
                            ),
                          ),
                        ),
                        4.horizontalSpace,
                        Expanded(
                          child: Text(
                            product.seller.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppStyles.bodySmall.copyWith(
                              fontSize: 10.sp,
                              color: Theme.of(context).textTheme.bodySmall?.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            formatPrice(product.price),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppStyles.h5Bold.copyWith(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            // TODO: impl add to cart
                          },
                          borderRadius: BorderRadius.circular(8.r),
                          child: Container(
                            padding: EdgeInsets.all(8.r),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Icon(
                              Icons.add_shopping_cart_rounded,
                              color: Colors.white,
                              size: 18.r,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
