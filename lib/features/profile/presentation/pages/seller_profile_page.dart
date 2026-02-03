import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/dimens.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/icons.dart';
import '../../../../core/utils/styles.dart';
import '../../../../global/widgets/app_svg_icon.dart';
import '../../../../global/widgets/app_back_button.dart';
import '../../../../global/widgets/common_app_bar.dart';
import '../../../products/domain/entities/seller_entity.dart';
import '../../../products/presentation/managers/products_bloc.dart';
import '../../../products/presentation/managers/products_state.dart';

class SellerProfilePage extends StatelessWidget {
  final String sellerId;

  const SellerProfilePage({super.key, required this.sellerId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(
        title: 'Sotuvchi',
        leading: AppBackButton(),
      ),
      body: BlocBuilder<ProductsBloc, ProductsState>(
        builder: (context, state) {
          SellerEntity? seller;
          for (final product in state.products) {
            if (product.seller.id == sellerId) {
              seller = product.seller;
              break;
            }
          }
          if (seller == null) {
            return Center(
              child: Text(
                'Sotuvchi topilmadi',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppStyles.bodySmall.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            );
          }
          return Padding(
            padding: EdgeInsets.all(AppDimens.lg.r),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimens.imageRadius.r),
                  child: Container(
                    width: AppDimens.avatarLg.w,
                    height: AppDimens.avatarLg.w,
                    color: Theme.of(context).dividerColor,
                    child: const AppSvgIcon(
                      assetPath: AppIcons.user,
                      size: AppDimens.iconLg,
                    ),
                  ),
                ),
                AppDimens.md.width,
                Expanded(
                  child: Text(
                    seller.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyles.h5Bold.copyWith(
                      color: Theme.of(context).textTheme.titleMedium?.color,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
