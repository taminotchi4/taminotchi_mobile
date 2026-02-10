import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/styles.dart';
import '../../../../global/widgets/app_back_button.dart';
import '../../../../global/widgets/common_app_bar.dart';
import '../../../home/domain/entities/post_category_entity.dart';
import '../../../home/presentation/managers/home_bloc.dart';
import '../../../home/presentation/managers/home_event.dart';
import '../../../home/presentation/managers/home_state.dart';
import '../widgets/category_feed_post_list.dart';
import '../widgets/category_feed_subcategory_list.dart';
import '../widgets/post_creation_bottom_sheet.dart';

class CategoryFeedPage extends StatelessWidget {
  final String categoryId;
  final bool showAllPosts;

  const CategoryFeedPage({
    super.key,
    required this.categoryId,
    this.showAllPosts = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: _getCategoryTitle(context),
        leading: const AppBackButton(),
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          // Find category in top-level categories
          var category = state.categories.where((cat) => cat.id == categoryId).firstOrNull;
          
          // If not found, search in subcategories
          if (category == null) {
            for (final cat in state.categories) {
              if (cat.subcategories != null) {
                category = cat.subcategories!.where((sub) => sub.id == categoryId).firstOrNull;
                if (category != null) break;
              }
            }
          }

          // If still not found, show empty state
          if (category == null) {
            return CategoryFeedPostList(state: state, categoryId: categoryId);
          }

          // If showAllPosts is true, always show posts list
          if (showAllPosts) {
            return CategoryFeedPostList(state: state, categoryId: categoryId);
          }

          if (category.hasSubcategories) {
            return CategoryFeedSubcategoryList(state: state, category: category);
          } else {
            return CategoryFeedPostList(state: state, categoryId: categoryId);
          }
        },
      ),
      floatingActionButton: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (!state.canCreatePost) return const SizedBox.shrink();
          
          return FloatingActionButton.extended(
            onPressed: () => _handleCreatePost(context, state),
            backgroundColor: Theme.of(context).primaryColor,
            icon: Icon(Icons.add, color: Colors.white, size: 20.r),
            label: Text(
              'E\'lon joylash',
              style: AppStyles.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleCreatePost(BuildContext context, HomeState state) {
    // Find the current category
    var category = state.categories.where((cat) => cat.id == categoryId).firstOrNull;
    
    // If not found in top-level, search in subcategories
    PostCategoryEntity? parentCategory;
    if (category == null) {
      for (final cat in state.categories) {
        if (cat.subcategories != null) {
          category = cat.subcategories!.where((sub) => sub.id == categoryId).firstOrNull;
          if (category != null) {
            parentCategory = cat;
            break;
          }
        }
      }
    }

    final bloc = context.read<HomeBloc>();
    
    // Pre-select category based on context
    if (showAllPosts && category != null && category.hasSubcategories) {
      // In "Umumiy" view - pre-select parent category only
      bloc.add(HomeSelectCategory(category));
    } else if (category != null && !category.hasSubcategories && parentCategory != null) {
      // In specific subcategory - pre-select both parent and subcategory
      bloc.add(HomeSelectCategory(parentCategory));
      bloc.add(HomeSelectSubcategory(category));
    } else if (category != null) {
      // Regular category without subcategories
      bloc.add(HomeSelectCategory(category));
    }
    
    // Show bottom sheet with post creation form
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PostCreationBottomSheet(
        preSelectedCategory: category,
        preSelectedSubcategory: parentCategory != null ? category : null,
        preSelectedParent: parentCategory,
        showAllPosts: showAllPosts,
      ),
    );
  }

  String _getCategoryTitle(BuildContext context) {
    final state = context.read<HomeBloc>().state;
    
    // First try to find in top-level categories
    var category = state.categories.where((cat) => cat.id == categoryId).firstOrNull;
    
    // If not found, search in subcategories
    if (category == null) {
      for (final cat in state.categories) {
        if (cat.subcategories != null) {
          category = cat.subcategories!.where((sub) => sub.id == categoryId).firstOrNull;
          if (category != null) break;
        }
      }
    }
    
    return category?.name ?? 'Kategoriya';
  }
}
