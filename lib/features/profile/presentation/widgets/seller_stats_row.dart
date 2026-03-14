import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/dimens.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/utils/styles.dart';
import '../managers/seller_profile_state.dart';

class SellerStatsRow extends StatelessWidget {
  final SellerProfileState state;

  const SellerStatsRow({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.seller == null) return const SizedBox.shrink();

    return Row(
      children: [
        Expanded(
          child: _countItem(
            context,
            count: state.followersCount.toString(),
            label: 'Followers',
            icon: Icons.people_outline,
            onTap: () =>
                context.push(Routes.getSellerFollowers(state.seller!.id)),
          ),
        ),
        AppDimens.md.width,
        Expanded(
          child: _countItem(
            context,
            count: state.productsCount.toString(),
            label: 'Products',
            icon: Icons.inventory_2_outlined,
            onTap: () {},
          ),
        ),
      ],
    );
  }

  Widget _countItem(
    BuildContext context, {
    required String count,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.cardRadius.r),
      child: Container(
        padding: EdgeInsets.all(AppDimens.md.r),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppDimens.cardRadius.r),
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.5),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 20.r,
                color: Theme.of(context).primaryColor,
              ),
            ),
            AppDimens.sm.width,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  count,
                  style: AppStyles.h5Bold.copyWith(
                    color: Theme.of(context).textTheme.titleMedium?.color,
                  ),
                ),
                Text(
                  label,
                  style: AppStyles.bodySmall.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
