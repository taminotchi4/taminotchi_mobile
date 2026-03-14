import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/dimens.dart';
import '../../../../core/utils/colors.dart';
import '../../../../core/utils/icons.dart';
import '../../../../core/utils/styles.dart';
import '../../../../global/widgets/app_svg_icon.dart';
import '../../../../core/utils/extensions.dart';
import '../../../home/domain/entities/post_category_entity.dart';
import '../../../home/presentation/managers/home_bloc.dart';
import '../../../home/presentation/managers/home_event.dart';
import '../../../home/presentation/managers/home_state.dart';

class PostCreationBottomSheet extends StatefulWidget {
  final PostCategoryEntity? preSelectedCategory;
  final PostCategoryEntity? preSelectedSubcategory;
  final PostCategoryEntity? preSelectedParent;
  final bool showAllPosts;

  const PostCreationBottomSheet({
    super.key,
    this.preSelectedCategory,
    this.preSelectedSubcategory,
    this.preSelectedParent,
    this.showAllPosts = false,
  });

  @override
  State<PostCreationBottomSheet> createState() => _PostCreationBottomSheetState();
}

class _PostCreationBottomSheetState extends State<PostCreationBottomSheet> {
  final TextEditingController _controller = TextEditingController();
  PostCategoryEntity? _selectedCategory;
  PostCategoryEntity? _selectedSubcategory;

  @override
  void initState() {
    super.initState();
    // Set initial selections based on context
    if (widget.showAllPosts && widget.preSelectedCategory != null) {
      // In "Umumiy" - only pre-select parent
      _selectedCategory = widget.preSelectedCategory;
    } else if (widget.preSelectedParent != null && widget.preSelectedSubcategory != null) {
      // In subcategory - pre-select both
      _selectedCategory = widget.preSelectedParent;
      _selectedSubcategory = widget.preSelectedSubcategory;
    } else if (widget.preSelectedCategory != null) {
      // Regular category
      _selectedCategory = widget.preSelectedCategory;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeBloc, HomeState>(
      listenWhen: (previous, current) =>
          previous.actionStatus != current.actionStatus,
      listener: (context, state) {
        if (state.actionStatus == HomeActionStatus.postCreated) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('E\'lon muvaffaqiyatli joylandi'),
              backgroundColor: Theme.of(context).primaryColor,
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return BlocBuilder<HomeBloc, HomeState>(
              builder: (context, state) {
                return SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.all(AppDimens.lg.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildHeader(context),
                      AppDimens.lg.height,
                      _buildCategorySection(context, state),
                      AppDimens.lg.height,
                      _buildTextField(context, state),
                      AppDimens.lg.height,
                      _buildImageSection(context, state),
                      AppDimens.xl.height,
                      _buildSubmitButton(context, state),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'E\'lon joylash',
            style: AppStyles.h4Bold.copyWith(
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.close, size: 24.r),
        ),
      ],
    );
  }

  Widget _buildCategorySection(BuildContext context, HomeState state) {
    // Hide category selector if in "Umumiy" view (only show subcategory)
    final showCategorySelector = !widget.showAllPosts || _selectedCategory == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showCategorySelector) ...[
          _buildCategoryRow(context, state),
          if (state.categoryError != null) ...[
            AppDimens.xs.height,
            Text(
              state.categoryError!,
              style: AppStyles.bodySmall.copyWith(
                fontSize: 11.sp,
                color: AppColors.red,
              ),
            ),
          ],
        ],
        if (_selectedCategory?.hasSubcategories == true) ...[
          if (showCategorySelector) AppDimens.md.height,
          _buildSubcategoryRow(context, state),
          if (state.subcategoryError != null) ...[
            AppDimens.xs.height,
            Text(
              state.subcategoryError!,
              style: AppStyles.bodySmall.copyWith(
                fontSize: 11.sp,
                color: AppColors.red,
              ),
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildCategoryRow(BuildContext context, HomeState state) {
    return InkWell(
      onTap: () => _showCategorySelector(context, state),
      borderRadius: BorderRadius.circular(AppDimens.imageRadius.r),
      child: Container(
        padding: EdgeInsets.all(AppDimens.md.r),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppDimens.imageRadius.r),
          border: Border.all(
            color: state.categoryError != null
                ? AppColors.red
                : Theme.of(context).dividerColor,
            width: AppDimens.borderWidth.w,
          ),
        ),
        child: Row(
          children: [
            AppSvgIcon(
              assetPath: _selectedCategory?.iconPath ?? AppIcons.category,
              size: AppDimens.iconMd,
              color: Theme.of(context).iconTheme.color,
            ),
            AppDimens.sm.width,
            Expanded(
              child: Text(
                _selectedCategory?.name ?? 'Kategoriyani tanlang',
                style: AppStyles.bodyMedium.copyWith(
                  color: _selectedCategory == null
                      ? Theme.of(context).textTheme.bodySmall?.color
                      : Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ),
            Icon(Icons.chevron_right, size: 20.r),
          ],
        ),
      ),
    );
  }

  Widget _buildSubcategoryRow(BuildContext context, HomeState state) {
    final subcategories = _selectedCategory?.subcategories ?? [];
    // Check if we're in a specific subcategory view (not "Umumiy")
    final isInSubcategoryView = !widget.showAllPosts && widget.preSelectedSubcategory != null;

    return Wrap(
      spacing: AppDimens.sm.w,
      runSpacing: AppDimens.sm.h,
      children: subcategories.map((subcategory) {
        final isSelected = _selectedSubcategory?.id == subcategory.id;
        return InkWell(
          onTap: isInSubcategoryView ? null : () {
            setState(() {
              _selectedSubcategory = subcategory;
            });
            context.read<HomeBloc>().add(HomeSelectSubcategory(subcategory));
          },
          borderRadius: BorderRadius.circular(AppDimens.imageRadius.r),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppDimens.md.w,
              vertical: AppDimens.sm.h,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).primaryColor.withOpacity(0.1)
                  : Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(AppDimens.imageRadius.r),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).dividerColor,
                width: isSelected ? 1.5.w : AppDimens.borderWidth.w,
              ),
            ),
            child: Text(
              subcategory.name,
              style: AppStyles.bodySmall.copyWith(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : isInSubcategoryView && !isSelected
                        ? Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5)
                        : Theme.of(context).textTheme.bodyMedium?.color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showCategorySelector(BuildContext context, HomeState state) {
    // Implementation would show category selector dialog
    // For now, keeping it simple
  }

  Widget _buildTextField(BuildContext context, HomeState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: 'Qidirayotgan maxsulotingiz haqida yozing...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.imageRadius.r),
            ),
          ),
          onChanged: (value) {
            if (value.length >= 2 && state.contentError != null) {
              context.read<HomeBloc>().add(const HomeClearContentError());
            }
          },
        ),
        if (state.contentError != null) ...[
          AppDimens.xs.height,
          Text(
            state.contentError!,
            style: AppStyles.bodySmall.copyWith(
              fontSize: 11.sp,
              color: AppColors.red,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildImageSection(BuildContext context, HomeState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _uploadButton(
                context,
                label: 'Galereya',
                icon: AppIcons.gallery,
                onTap: () => context.read<HomeBloc>().add(const HomeAddImagesFromGallery()),
              ),
            ),
            AppDimens.md.width,
            Expanded(
              child: _uploadButton(
                context,
                label: 'Kamera',
                icon: Icons.camera_alt,
                onTap: () => context.read<HomeBloc>().add(const HomeAddImageFromCamera()),
              ),
            ),
          ],
        ),
        if (state.selectedImages.isNotEmpty) ...[
          AppDimens.md.height,
          _buildImageGrid(context, state),
        ],
      ],
    );
  }

  Widget _uploadButton(
    BuildContext context, {
    required String label,
    dynamic icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.imageRadius.r),
      child: Container(
        height: AppDimens.inputHeight.h,
        padding: EdgeInsets.symmetric(horizontal: AppDimens.md.w),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(AppDimens.imageRadius.r),
          border: Border.all(
            color: Theme.of(context).dividerColor,
            width: AppDimens.borderWidth.w,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon is String)
              AppSvgIcon(
                assetPath: icon,
                size: AppDimens.iconMd,
                color: Theme.of(context).iconTheme.color,
              )
            else if (icon is IconData)
              Icon(
                icon,
                size: AppDimens.iconMd.r,
                color: Theme.of(context).iconTheme.color,
              ),
            AppDimens.sm.width,
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppStyles.bodySmall.copyWith(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGrid(BuildContext context, HomeState state) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: AppDimens.sm.w,
        mainAxisSpacing: AppDimens.sm.h,
      ),
      itemCount: state.selectedImages.length,
      itemBuilder: (context, index) {
        final image = state.selectedImages[index];
        return Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppDimens.imageRadius.r),
              child: Image.file(
                File(image.path),
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: 4.r,
              right: 4.r,
              child: InkWell(
                onTap: () => context.read<HomeBloc>().add(HomeRemoveImage(image.path)),
                child: Container(
                  padding: EdgeInsets.all(4.r),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    size: 16.r,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSubmitButton(BuildContext context, HomeState state) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: state.isSubmitting
            ? null
            : () {
                final category = _selectedCategory;
                final subcategory = _selectedSubcategory;

                // Update bloc state before submitting
                if (category != null) {
                  context.read<HomeBloc>().add(HomeSelectCategory(category));
                }
                if (subcategory != null) {
                  context.read<HomeBloc>().add(HomeSelectSubcategory(subcategory));
                }

                context.read<HomeBloc>().add(HomeCreatePost(_controller.text));
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          padding: EdgeInsets.symmetric(vertical: AppDimens.md.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.imageRadius.r),
          ),
        ),
        child: state.isSubmitting
            ? SizedBox(
                height: 20.h,
                width: 20.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'E\'lon joylash',
                style: AppStyles.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
