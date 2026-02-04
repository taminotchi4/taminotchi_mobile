import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/dimens.dart';
import '../../../../core/utils/extensions.dart';
import '../../domain/entities/product_entity.dart';
import 'product_card.dart';

class ProductsGrid extends StatelessWidget {
  final List<ProductEntity> products;
  final VoidCallback? onLoadMore;
  final bool showLoadMore;

  const ProductsGrid({
    super.key,
    required this.products,
    required this.showLoadMore,
    this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return Center(
        child: Text(
          'Mahsulotlar topilmadi',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      );
    }
    return Column(
      children: [
        GridView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: products.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: AppDimens.sm.h,
            crossAxisSpacing: AppDimens.sm.w,
            childAspectRatio: AppDimens.productCardAspectRatio,
          ),
          itemBuilder: (context, index) => ProductCard(product: products[index]),
        ),
        if (showLoadMore) ...[
          AppDimens.md.height,
          Center(
            child: InkWell(
              onTap: onLoadMore,
              borderRadius: BorderRadius.circular(AppDimens.cardRadius.r),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimens.xxl.w,
                  vertical: AppDimens.sm.h,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(AppDimens.cardRadius.r),
                  border: Border.all(
                    color: Theme.of(context).dividerColor,
                    width: AppDimens.borderWidth.w,
                  ),
                ),
                child: Text(
                  'Ko\'proq yuklash',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
