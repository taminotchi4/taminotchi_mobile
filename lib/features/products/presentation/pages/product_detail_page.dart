import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/dimens.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/icons.dart';
import '../../../../core/utils/styles.dart';
import '../../../../global/widgets/app_svg_icon.dart';
import '../../../../global/widgets/app_back_button.dart';
import '../../../../global/widgets/common_app_bar.dart';
import '../../domain/entities/product_entity.dart';
import '../managers/products_bloc.dart';
import '../managers/products_event.dart';
import '../managers/products_state.dart';
import '../widgets/product_image_slider.dart';

class ProductDetailPage extends StatefulWidget {
  final String productId;

  const ProductDetailPage({super.key, required this.productId});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<ProductsBloc>().add(ProductsLoadDetail(widget.productId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(
        title: 'Mahsulot',
        leading: AppBackButton(),
      ),
      body: BlocBuilder<ProductsBloc, ProductsState>(
        builder: (context, state) {
          ProductEntity? product = state.activeProduct;
          if (product == null) {
            for (final item in state.products) {
              if (item.id == widget.productId) {
                product = item;
                break;
              }
            }
          }
          if (product == null) {
            return Center(
              child: Text(
                'Mahsulot topilmadi',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppStyles.bodySmall.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            );
          }
          return _buildContent(context, product);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, ProductEntity product) {
    return ListView(
      padding: EdgeInsets.all(AppDimens.lg.r),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimens.imageRadius.r),
          child: SizedBox(
            height: AppDimens.productDetailImageHeight.h,
            child: ProductImageSlider(images: product.imagePaths),
          ),
        ),
        AppDimens.lg.height,
        Text(
          product.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppStyles.h5Bold.copyWith(
            color: Theme.of(context).textTheme.titleMedium?.color,
          ),
        ),
        AppDimens.sm.height,
        Text(
          formatPrice(product.price),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppStyles.bodyRegular.copyWith(
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        AppDimens.lg.height,
        Text(
          product.description,
          style: AppStyles.bodyRegular.copyWith(
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        AppDimens.lg.height,
        InkWell(
          onTap: () => context.push(Routes.getSellerProfile(product.seller.id)),
          borderRadius: BorderRadius.circular(AppDimens.imageRadius.r),
          child: Container(
            padding: EdgeInsets.all(AppDimens.md.r),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(AppDimens.imageRadius.r),
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
                    width: AppDimens.sellerAvatar.w,
                    height: AppDimens.sellerAvatar.w,
                    color: Theme.of(context).dividerColor,
                    child: const AppSvgIcon(
                      assetPath: AppIcons.user,
                      size: AppDimens.iconMd,
                    ),
                  ),
                ),
                AppDimens.md.width,
                Expanded(
                  child: Text(
                    product.seller.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyles.bodySmall.copyWith(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
                AppDimens.sm.width,
                AppSvgIcon(
                  assetPath: AppIcons.profile,
                  size: AppDimens.iconMd,
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
