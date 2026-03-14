import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/extensions.dart';
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

class CategoryFeedPage extends StatefulWidget {
  final String categoryId;
  final bool showAllPosts;

  const CategoryFeedPage({
    super.key,
    required this.categoryId,
    this.showAllPosts = false,
  });

  @override
  State<CategoryFeedPage> createState() => _CategoryFeedPageState();
}

class _CategoryFeedPageState extends State<CategoryFeedPage> {
  @override
  void initState() {
    super.initState();
    final bloc = context.read<HomeBloc>();
    final state = bloc.state;

    // Check if the id belongs to a group
    bool isGroup = false;
    state.categoryGroups.forEach((key, list) {
      if (list.any((g) => g.id == widget.categoryId)) {
        isGroup = true;
      }
    });

    if (isGroup) {
      bloc.add(HomeFetchPostsByGroup(widget.categoryId));
    } else {
      bloc.add(HomeFetchPostsByCategory(widget.categoryId));
    }
  }

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
          var category = state.categories.where((cat) => cat.id == widget.categoryId).firstOrNull;
          
          // If not found, search in subcategories
          if (category == null) {
            for (final cat in state.categories) {
              if (cat.subcategories != null) {
                category = cat.subcategories!.where((sub) => sub.id == widget.categoryId).firstOrNull;
                if (category != null) break;
              }
            }
          }

          // If still not found, show empty state
          if (category == null) {
            return CategoryFeedPostList(state: state, categoryId: widget.categoryId);
          }

          // If showAllPosts is true, always show posts list
          if (widget.showAllPosts) {
            return CategoryFeedPostList(state: state, categoryId: widget.categoryId);
          }

          if (category.hasSubcategories) {
            return CategoryFeedSubcategoryList(state: state, category: category);
          } else {
            return CategoryFeedPostList(state: state, categoryId: widget.categoryId);
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
              context.l10n.createPost,
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
    var category = state.categories.where((cat) => cat.id == widget.categoryId).firstOrNull;
    
    // If not found in top-level, search in subcategories
    PostCategoryEntity? parentCategory;
    if (category == null) {
      for (final cat in state.categories) {
        if (cat.subcategories != null) {
          category = cat.subcategories!.where((sub) => sub.id == widget.categoryId).firstOrNull;
          if (category != null) {
            parentCategory = cat;
            break;
          }
        }
      }
    }

    final bloc = context.read<HomeBloc>();
    
    // Pre-select category based on context
    if (widget.showAllPosts && category != null && category.hasSubcategories) {
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
        showAllPosts: widget.showAllPosts,
      ),
    );
  }

  String _getCategoryTitle(BuildContext context) {
    final state = context.read<HomeBloc>().state;

    // Helper function to find category by ID
    PostCategoryEntity? findCategoryById(String id) {
      // Search in top-level categories
      var foundCategory = state.categories.where((cat) => cat.id == id).firstOrNull;
      if (foundCategory != null) return foundCategory;

      // Search in subcategories
      for (final cat in state.categories) {
        if (cat.subcategories != null) {
          foundCategory = cat.subcategories!.where((sub) => sub.id == id).firstOrNull;
          if (foundCategory != null) return foundCategory;
        }
      }
      return null;
    }

    // Try to find category by widget.categoryId
    final category = findCategoryById(widget.categoryId);
    if (category != null) {
      return category.name;
    }

    // If not found as a category, try to find as a group
    final group = state.groups.where((g) => g.id == widget.categoryId).firstOrNull;
    if (group != null) {
      return group.name;
    }

    // If not found as a category or a regular group, try to find in category groups
    for (final categoryList in state.categoryGroups.values) {
      final foundInGroup = categoryList.where((cat) => cat.id == widget.categoryId).firstOrNull;
      if (foundInGroup != null) {
        return foundInGroup.name;
      }
    }
    
    return context.l10n.category;
  }
}
