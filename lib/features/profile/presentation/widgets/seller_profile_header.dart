import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/dimens.dart';
import '../../../../core/utils/styles.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../global/widgets/app_svg_icon.dart';
import '../managers/seller_profile_bloc.dart';
import '../managers/seller_profile_event.dart';
import '../managers/seller_profile_state.dart';

class SellerProfileHeader extends StatelessWidget {
  final SellerProfileState state;

  const SellerProfileHeader({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.seller == null) return const SizedBox.shrink();

    final seller = state.seller!;
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(AppDimens.lg.r),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(AppDimens.cardRadius.r),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppDimens.imageRadius.r),
                    child: Container(
                      width: 80.w,
                      height: 80.w,
                      color: Theme.of(context).dividerColor,
                      child: AppSvgIcon(
                        assetPath: seller.avatarPath,
                        size: 40.w,
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
                          seller.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppStyles.h4Bold.copyWith(
                            color: Theme.of(context).textTheme.titleLarge?.color,
                          ),
                        ),
                        AppDimens.xs.height,
                        Text(
                          seller.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppStyles.bodySmall.copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                        AppDimens.sm.height,
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: AppDimens.iconSm,
                              color: Theme.of(context).primaryColor,
                            ),
                            4.horizontalSpace,
                            Expanded(
                              child: Text(
                                seller.address,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppStyles.bodySmall.copyWith(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              AppDimens.lg.height,
              _buildFollowButton(context, seller),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFollowButton(BuildContext context, dynamic seller) {
    return InkWell(
      onTap: state.canFollow
          ? () {
              context.read<SellerProfileBloc>().add(
                    const SellerProfileToggleFollow(),
                  );
            }
          : null,
      borderRadius: BorderRadius.circular(AppDimens.buttonRadius.r),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: 12.h,
        ),
        decoration: BoxDecoration(
          color: seller.isFollowing
              ? Theme.of(context).scaffoldBackgroundColor
              : Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(AppDimens.buttonRadius.r),
          border: Border.all(
            color: seller.isFollowing
                ? Theme.of(context).dividerColor
                : Colors.transparent,
            width: 1.w,
          ),
          boxShadow: seller.isFollowing
              ? []
              : [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Center(
          child: Text(
            seller.isFollowing ? 'Following' : 'Follow',
            style: AppStyles.bodyMedium.copyWith(
              color: seller.isFollowing
                  ? Theme.of(context).textTheme.bodyMedium?.color
                  : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
