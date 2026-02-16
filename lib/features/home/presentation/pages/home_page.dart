import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/dimens.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/utils/colors.dart';
import '../../../../core/utils/styles.dart';
import '../../../products/presentation/managers/products_bloc.dart';
import '../../../products/presentation/managers/products_event.dart';
import '../../../products/presentation/managers/products_state.dart';
import '../../../products/presentation/widgets/products_grid.dart';
import '../managers/home_bloc.dart';
import '../managers/home_event.dart';
import '../managers/home_state.dart';
import '../widgets/home_sliver_app_bar.dart';
import '../widgets/post_creation_section.dart';
import '../widgets/user_posts_carousel.dart';
import '../widgets/category_section.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeBloc, HomeState>(
      listenWhen: (previous, current) =>
          previous.actionStatus != current.actionStatus,
      listener: (context, state) {
        if (state.actionStatus == HomeActionStatus.postCreated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.mainBlue,
              content: const Text('Post yaratildi'),
            ),
          );
          context.read<HomeBloc>().add(const HomeClearActionStatus());
          context.go(Routes.myPosts);
        }
        if (state.actionStatus == HomeActionStatus.error &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.red,
              content: Text(state.errorMessage!),
            ),
          );
          context.read<HomeBloc>().add(const HomeClearActionStatus());
        }
        if (state.actionStatus == HomeActionStatus.authRequired) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Hisobga kirish'),
              content: const Text(
                  'E\'lon joylash uchun Login qilishingiz kerak'),
              actions: [
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text('Bekor qilish'),
                ),
                TextButton(
                  onPressed: () {
                    context.pop();
                    context.go(Routes.login);
                  },
                  child: const Text('Kirish'),
                ),
              ],
            ),
          );
          context.read<HomeBloc>().add(const HomeClearActionStatus());
        }
      },
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            HomeSliverAppBar(
              onRightTap: () => context.push(Routes.notifications),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  AppDimens.lg.w,
                  AppDimens.sm.h,
                  AppDimens.lg.w,
                  AppDimens.md.h,
                ),
                child: const PostCreationSection(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppDimens.lg.w),
                child: Text(
                  "E'lonlar",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppStyles.h5Bold.copyWith(
                    color: Theme.of(context).textTheme.titleMedium?.color,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  AppDimens.lg.w,
                  AppDimens.md.h,
                  AppDimens.lg.w,
                  AppDimens.lg.h,
                ),
                child: BlocBuilder<HomeBloc, HomeState>(
                  builder: (context, state) {
                    return UserPostsCarousel(
                      posts: state.carouselPosts,
                      commentCounts: state.commentCounts,
                    );
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(
                  top: AppDimens.lg.h,
                  bottom: AppDimens.md.h,
                ),
                child: BlocBuilder<HomeBloc, HomeState>(
                  builder: (context, state) {
                    return CategorySection(categories: state.categories);
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimens.lg.w,
                  vertical: AppDimens.xs.h,
                ),
                child: Divider(
                  color: Theme.of(context).dividerColor,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  AppDimens.lg.w,
                  0,
                  AppDimens.lg.w,
                  AppDimens.sm.h,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: Text(
                        'Mahsulotlar',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppStyles.h5Bold.copyWith(
                          color: Theme.of(context).textTheme.titleMedium?.color,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => context.push(Routes.allProducts),
                      child: Text(
                        'Barchasi',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppStyles.bodySmall.copyWith(
                          decoration: TextDecoration.underline,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  AppDimens.lg.w,
                  0.h,
                  AppDimens.lg.w,
                  AppDimens.xxl.h,
                ),
                child: BlocBuilder<ProductsBloc, ProductsState>(
                  builder: (context, state) {
                    if (state.isLoading && state.visibleProducts.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return ProductsGrid(
                      products: state.visibleProducts,
                      showLoadMore:
                          state.visibleProducts.length <
                          state.filteredProducts.length,
                      onLoadMore: () => context.read<ProductsBloc>().add(
                        const ProductsLoadMore(),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
