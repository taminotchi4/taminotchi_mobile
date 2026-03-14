import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/dimens.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/styles.dart';
import '../../../../global/widgets/app_svg_icon.dart';
import '../../domain/entities/product_entity.dart';

class ProductSellerInfo extends StatelessWidget {
  final ProductEntity product;

  const ProductSellerInfo({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppDimens.lg.height,
        InkWell(
          onTap: () => context.push(Routes.getSellerProfile(product.seller.id)),
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
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimens.imageRadius.r),
                  child: Container(
                    width: 50.w,
                    height: 50.w,
                    color: Theme.of(context).dividerColor,
                    child: AppSvgIcon(
                      assetPath: product.seller.avatarPath,
                      size: 24.w,
                      color: Theme.of(context).iconTheme.color,
                    ),
                  ),
                ),
                AppDimens.md.width,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.seller.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                      Text(
                        'Sotuvchi',
                        style: AppStyles.bodySmall.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Theme.of(context).iconTheme.color,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
