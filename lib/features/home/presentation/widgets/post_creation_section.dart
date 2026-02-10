import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/dimens.dart';
import '../../../../core/utils/colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/icons.dart';
import '../../../../core/utils/styles.dart';
import '../../../../global/widgets/app_svg_icon.dart';
import '../../domain/entities/post_category_entity.dart';
import '../managers/home_bloc.dart';
import '../managers/home_event.dart';
import '../managers/home_state.dart';
import 'category_selector_dialog.dart';

class PostCreationSection extends StatefulWidget {
  const PostCreationSection({super.key});

  @override
  State<PostCreationSection> createState() => _PostCreationSectionState();
}

class _PostCreationSectionState extends State<PostCreationSection> {
  final TextEditingController _controller = TextEditingController();
  static const int _minLines = 3;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeBloc, HomeState>(
      listenWhen: (previous, current) =>
          previous.actionStatus != current.actionStatus ||
          previous.isComposerExpanded != current.isComposerExpanded,
      listener: (context, state) {
        if (state.actionStatus == HomeActionStatus.postCreated ||
            !state.isComposerExpanded) {
          _controller.clear();
        }
      },
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (!state.canCreatePost) {
            return _buildDisabledCard(context);
          }
          if (!state.isComposerExpanded) {
            return _buildCollapsed(context);
          }
          return _buildExpanded(context, state);
        },
      ),
    );
  }

  Widget _buildCollapsed(BuildContext context) {
    return InkWell(
      onTap: () => context.read<HomeBloc>().add(const HomeExpandComposer()),
      borderRadius: BorderRadius.circular(AppDimens.cardRadius.r),
      child: Container(
        height: AppDimens.buttonHeight.h,
        padding: EdgeInsets.symmetric(horizontal: AppDimens.lg.w),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppDimens.cardRadius.r),
          border: Border.all(
            color: Theme.of(context).dividerColor,
            width: AppDimens.borderWidth.w,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          "+ Elon joylash",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppStyles.bodyRegular.copyWith(
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
      ),
    );
  }

  Widget _buildExpanded(BuildContext context, HomeState state) {
    return Container(
      padding: EdgeInsets.all(AppDimens.lg.r),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppDimens.cardRadius.r),
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: AppDimens.borderWidth.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCategoryRow(context, state),
          if (state.categoryError != null) ...[
            AppDimens.xs.height,
            Padding(
              padding: EdgeInsets.only(left: AppDimens.sm.w),
              child: Text(
                state.categoryError!,
                style: AppStyles.bodySmall.copyWith(
                  fontSize: 11.sp,
                  color: AppColors.red,
                ),
              ),
            ),
          ],
          if (state.selectedCategory?.hasSubcategories == true) ...[
            AppDimens.md.height,
            _buildSubcategoryRow(context, state),
            if (state.subcategoryError != null) ...[
              AppDimens.xs.height,
              Padding(
                padding: EdgeInsets.only(left: AppDimens.sm.w),
                child: Text(
                  state.subcategoryError!,
                  style: AppStyles.bodySmall.copyWith(
                    fontSize: 11.sp,
                    color: AppColors.red,
                  ),
                ),
              ),
            ],
          ],
          AppDimens.md.height,
          _buildUploadRow(context),
          if (state.selectedImages.isNotEmpty) ...[
            AppDimens.md.height,
            _buildImagePreview(context, state),
          ],
          AppDimens.md.height,
          _buildTextField(context, state),
          if (state.contentError != null) ...[
            AppDimens.xs.height,
            Padding(
              padding: EdgeInsets.only(left: AppDimens.sm.w),
              child: Text(
                state.contentError!,
                style: AppStyles.bodySmall.copyWith(
                  fontSize: 11.sp,
                  color: AppColors.red,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryRow(BuildContext context, HomeState state) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () => _openCategoryDialog(context, state),
            borderRadius: BorderRadius.circular(AppDimens.imageRadius.r),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimens.md.w,
                vertical: AppDimens.sm.h,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(AppDimens.imageRadius.r),
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                  width: AppDimens.borderWidth.w,
                ),
              ),
              child: Row(
                children: [
                  AppSvgIcon(
                    assetPath:
                        state.selectedCategory?.iconPath ?? AppIcons.category,
                    size: AppDimens.iconMd,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  AppDimens.sm.width,
                  Expanded(
                    child: Text(
                      state.selectedCategory?.name ?? 'Kategoriyani tanlang',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppStyles.bodySmall.copyWith(
                        color: state.selectedCategory == null
                            ? Theme.of(context).hintColor
                            : Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        AppDimens.sm.width,
        InkWell(
          onTap: () => context.read<HomeBloc>().add(const HomeCollapseComposer()),
          borderRadius: BorderRadius.circular(AppDimens.imageRadius.r),
          child: Container(
            padding: EdgeInsets.all(AppDimens.sm.r),
            decoration: BoxDecoration(
              color: AppColors.red,
              borderRadius: BorderRadius.circular(AppDimens.imageRadius.r),
              border: Border.all(
                color: Theme.of(context).dividerColor,
                width: AppDimens.borderWidth.w,
              ),
            ),
            child: AppSvgIcon(
              assetPath: AppIcons.close,
              size: AppDimens.iconSm,
              color: AppColors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubcategoryRow(BuildContext context, HomeState state) {
    final subcategories = state.selectedCategory?.subcategories ?? [];
    
    return Wrap(
      spacing: AppDimens.sm.w,
      runSpacing: AppDimens.sm.h,
      children: subcategories.map((subcategory) {
        final isSelected = state.selectedSubcategory?.id == subcategory.id;
        return InkWell(
          onTap: () => context.read<HomeBloc>().add(HomeSelectSubcategory(subcategory)),
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
                    : Theme.of(context).textTheme.bodyMedium?.color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildUploadRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _uploadButton(
            context,
            label: 'Galereya',
            icon: AppIcons.gallery,
            onTap: () =>
                context.read<HomeBloc>().add(const HomeAddImagesFromGallery()),
          ),
        ),
        AppDimens.md.width,
        Expanded(
          child: _uploadButton(
            context,
            label: 'Kamera',
            icon: Icons.camera_alt, // Assuming AppIcons.camera exists for SVG, or replace with Icon(Icons.camera_alt) if _uploadButton is modified
            onTap: () =>
                context.read<HomeBloc>().add(const HomeAddImageFromCamera()),
          ),
        ),
      ],
    );
  }

  Widget _uploadButton(
    BuildContext context, {
    required String label,
    dynamic icon, // Can be String (SVG path) or IconData
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

  Widget _buildImagePreview(BuildContext context, HomeState state) {
    return SizedBox(
      height: AppDimens.previewImageHeight.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: state.selectedImages.length,
        separatorBuilder: (context, _) => AppDimens.sm.width,
        itemBuilder: (context, index) {
          final image = state.selectedImages[index];
          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppDimens.imageRadius.r),
                child: Container(
                  width: AppDimens.previewImageWidth.w,
                  height: AppDimens.previewImageHeight.h,
                  color: AppColors.gray100,
                  child: image.isLocal
                      ? Image.file(
                          File(image.path),
                          fit: BoxFit.cover,
                        )
                      : (image.path.toLowerCase().endsWith('.svg')
                          ? SvgPicture.asset(
                              image.path,
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              image.path,
                              fit: BoxFit.cover,
                            )),
                ),
              ),
              Positioned(
                top: AppDimens.xs.h,
                right: AppDimens.xs.w,
                child: InkWell(
                  onTap: () => context
                      .read<HomeBloc>()
                      .add(HomeRemoveImage(image.path)),
                  borderRadius: BorderRadius.circular(AppDimens.sm.r),
                  child: Container(
                    padding: EdgeInsets.all(AppDimens.xxs.r),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius:
                          BorderRadius.circular(AppDimens.imageRadius.r),
                    ),
                    child: const AppSvgIcon(
                      assetPath: AppIcons.close,
                      size: AppDimens.iconSm,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTextField(BuildContext context, HomeState state) {
    return Stack(
      children: [
        TextField(
          controller: _controller,
          minLines: _minLines,
          maxLines: null,
          onChanged: (value) {
            if (value.length >= 2 && state.contentError != null) {
              context.read<HomeBloc>().add(const HomeClearContentError());
            }
          },
          style: AppStyles.bodyRegular.copyWith(
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
          decoration: InputDecoration(
            hintText: "E'lon sifatida joylanishi kerak bo'lgan maxsulotning to'liq matnini kiriting",
            hintStyle:
                AppStyles.bodyRegular.copyWith(color: Theme.of(context).hintColor),
            filled: true,
            fillColor: Theme.of(context).scaffoldBackgroundColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.imageRadius.r),
              borderSide: BorderSide(
                color: Theme.of(context).dividerColor,
                width: AppDimens.borderWidth.w,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.imageRadius.r),
              borderSide: BorderSide(
                color: Theme.of(context).dividerColor,
                width: AppDimens.borderWidth.w,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.imageRadius.r),
              borderSide: BorderSide(
                color: AppColors.mainBlue,
                width: AppDimens.borderWidthActive.w,
              ),
            ),
            contentPadding: EdgeInsets.fromLTRB(
              AppDimens.md.w,
              AppDimens.md.h,
              AppDimens.buttonHeight.w,
              AppDimens.buttonHeight.h,
            ),
          ),
        ),
        Positioned(
          bottom: AppDimens.sm.h,
          right: AppDimens.sm.w,
          child: InkWell(
            onTap: state.isSubmitting
                ? null
                : () => context
                    .read<HomeBloc>()
                    .add(HomeCreatePost(_controller.text)),
            borderRadius: BorderRadius.circular(AppDimens.imageRadius.r),
            child: Container(
              padding: EdgeInsets.all(AppDimens.sm.r),
              decoration: BoxDecoration(
                color: AppColors.mainBlue,
                borderRadius: BorderRadius.circular(AppDimens.imageRadius.r),
              ),
              child: const AppSvgIcon(
                assetPath: AppIcons.send,
                size: AppDimens.iconMd,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDisabledCard(BuildContext context) {
    return Container(
      height: AppDimens.buttonHeight.h,
      padding: EdgeInsets.symmetric(horizontal: AppDimens.lg.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppDimens.cardRadius.r),
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: AppDimens.borderWidth.w,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        'Post yaratish faqat foydalanuvchilar uchun',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppStyles.bodySmall.copyWith(
          color: Theme.of(context).textTheme.bodySmall?.color,
        ),
      ),
    );
  }

  Future<void> _openCategoryDialog(
    BuildContext context,
    HomeState state,
  ) async {
    final bloc = context.read<HomeBloc>();
    final selected = await showDialog<PostCategoryEntity>(
      context: context,
      builder: (_) => CategorySelectorDialog(
        categories: state.categories,
        selectedCategory: state.selectedCategory,
      ),
    );
    if (!context.mounted) return;
    if (selected != null) {
      bloc.add(HomeSelectCategory(selected));
    }
  }
}
