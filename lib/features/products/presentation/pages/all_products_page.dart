import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/dimens.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../global/widgets/app_back_button.dart';
import '../../../../global/widgets/common_app_bar.dart';
import '../managers/products_bloc.dart';
import '../managers/products_state.dart';
import '../widgets/products_grid.dart';
import '../widgets/all_products_search_field.dart';
import '../widgets/all_products_category_bar.dart';

class AllProductsPage extends StatelessWidget {
  const AllProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(
        title: 'Barchasi',
        leading: AppBackButton(),
      ),
      body: BlocBuilder<ProductsBloc, ProductsState>(
        builder: (context, state) {
          return ListView(
            padding: EdgeInsets.all(AppDimens.lg.r),
            children: [
              const AllProductsSearchField(),
              AppDimens.md.height,
              AllProductsCategoryBar(state: state),
              AppDimens.lg.height,
              ProductsGrid(
                products: state.filteredProducts,
                showLoadMore: false,
              ),
            ],
          );
        },
      ),
    );
  }
}
