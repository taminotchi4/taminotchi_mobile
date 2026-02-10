import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/dimens.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/icons.dart';
import '../../../../core/utils/styles.dart';
import '../../../../global/widgets/app_back_button.dart';
import '../../../../global/widgets/app_svg_icon.dart';
import '../../../../global/widgets/common_app_bar.dart';
import '../../../products/presentation/widgets/products_grid.dart';
import '../managers/seller_profile_bloc.dart';
import '../managers/seller_profile_event.dart';
import '../managers/seller_profile_state.dart';
import '../widgets/seller_profile_header.dart';
import '../widgets/seller_stats_row.dart';
import '../widgets/seller_product_filter.dart';

class SellerProfilePage extends StatefulWidget {
  final String sellerId;

  const SellerProfilePage({super.key, required this.sellerId});

  @override
  State<SellerProfilePage> createState() => _SellerProfilePageState();
}

class _SellerProfilePageState extends State<SellerProfilePage> {
  @override
  void initState() {
    super.initState();
    context.read<SellerProfileBloc>().add(
          SellerProfileStarted(widget.sellerId),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: 'Sotuvchi',
        leading: const AppBackButton(),
        actions: [
          InkWell(
            onTap: () => context.push(
              Routes.getSellerChat(widget.sellerId),
            ),
            borderRadius: BorderRadius.circular(AppDimens.imageRadius.r),
            child: Padding(
              padding: EdgeInsets.all(AppDimens.sm.r),
              child: AppSvgIcon(
                assetPath: AppIcons.chat,
                size: AppDimens.iconMd,
                color: Theme.of(context).iconTheme.color,
              ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<SellerProfileBloc, SellerProfileState>(
        builder: (context, state) {
          final seller = state.seller;
          if (state.isLoading && seller == null) {
            return const Center(child: CircularProgressIndicator());
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
          return DefaultTabController(
            length: 1,
            child: ListView(
              padding: EdgeInsets.all(AppDimens.lg.r),
              children: [
                SellerProfileHeader(state: state),
                AppDimens.md.height,
                SellerStatsRow(state: state),
                AppDimens.lg.height,
                TabBar(
                  labelColor: Theme.of(context).textTheme.titleMedium?.color,
                  indicatorColor: Theme.of(context).primaryColor,
                  tabs: const [
                    Tab(text: 'Products'),
                  ],
                ),
                AppDimens.md.height,
                SellerProductFilter(state: state),
                AppDimens.md.height,
                ProductsGrid(
                  products: state.filteredProducts,
                  showLoadMore: false,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
