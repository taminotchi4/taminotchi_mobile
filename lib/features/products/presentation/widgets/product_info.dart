import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/dimens.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/styles.dart';
import '../../domain/entities/product_entity.dart';
import '../managers/product_details_bloc.dart';
import '../managers/product_details_event.dart';
import '../managers/product_details_state.dart';

class ProductInfo extends StatelessWidget {
  final ProductEntity product;

  const ProductInfo({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppDimens.lg.height,
        Text(
          product.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppStyles.h4Bold.copyWith(
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        AppDimens.sm.height,
        _buildRatingSection(context),
        AppDimens.md.height,
        Row(
          children: [
            Text(
              formatPrice(product.price),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppStyles.h2Bold.copyWith(
                color: Theme.of(context).primaryColor,
                fontSize: 24.sp,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRatingSection(BuildContext context) {
    return Row(
      children: [
        BlocBuilder<ProductDetailsBloc, ProductDetailsState>(
          builder: (context, state) {
            final rating = state.rating;
            return Row(
              children: List.generate(5, (index) {
                final isActive = rating >= index + 1;
                return InkWell(
                  onTap: () => context.read<ProductDetailsBloc>().add(
                        ProductRatingUpdated(index + 1),
                      ),
                  child: Padding(
                    padding: EdgeInsets.only(right: AppDimens.xs.w),
                    child: Icon(
                      Icons.star_rounded,
                      size: AppDimens.iconSm,
                      color: isActive
                          ? const Color(0xFFFFB800)
                          : Theme.of(context).dividerColor,
                    ),
                  ),
                );
              }),
            );
          },
        ),
        AppDimens.sm.width,
        BlocBuilder<ProductDetailsBloc, ProductDetailsState>(
          builder: (context, state) {
            return Text(
              state.rating.toStringAsFixed(1),
              style: AppStyles.bodySmall.copyWith(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            );
          },
        ),
      ],
    );
  }
}
