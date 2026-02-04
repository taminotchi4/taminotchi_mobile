import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/dimens.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/icons.dart';
import '../../../../core/utils/styles.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../global/widgets/app_svg_icon.dart';
import '../../../../global/widgets/app_back_button.dart';
import '../../../../global/widgets/common_app_bar.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/entities/product_comment_entity.dart';
import '../managers/product_comments_bloc.dart';
import '../managers/product_comments_event.dart';
import '../managers/product_comments_state.dart';
import '../managers/product_details_bloc.dart';
import '../managers/product_details_event.dart';
import '../managers/product_details_state.dart';
import '../managers/products_bloc.dart';
import '../managers/products_event.dart';
import '../managers/products_state.dart';
import '../widgets/product_image_slider.dart';

class ProductDetailPage extends StatefulWidget {
  final String productId;

  const ProductDetailPage({super.key, required this.productId});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final String _currentUserId = 'user_1';
  final String _currentUserName = 'Mening akkauntim';

  @override
  void initState() {
    super.initState();
    context.read<ProductsBloc>().add(ProductsLoadDetail(widget.productId));
    context.read<ProductDetailsBloc>().add(ProductDetailsStarted(widget.productId));
    context.read<ProductCommentsBloc>().add(ProductCommentsStarted(widget.productId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(
        title: 'Mahsulot',
        leading: AppBackButton(),
      ),
      body: BlocBuilder<ProductsBloc, ProductsState>(
        builder: (context, state) {
          ProductEntity? product = state.activeProduct;
          if (product == null) {
            for (final item in state.products) {
              if (item.id == widget.productId) {
                product = item;
                break;
              }
            }
          }
          if (product == null) {
            return Center(
              child: Text(
                'Mahsulot topilmadi',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppStyles.bodySmall.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            );
          }
          return _buildContent(context, product);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, ProductEntity product) {
    return ListView(
      padding: EdgeInsets.all(AppDimens.lg.r),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimens.imageRadius.r),
          child: SizedBox(
            height: AppDimens.productDetailImageHeight.h,
            child: ProductImageSlider(images: product.imagePaths),
          ),
        ),
        AppDimens.lg.height,
        Text(
          product.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppStyles.h5Bold.copyWith(
            color: Theme.of(context).textTheme.titleMedium?.color,
          ),
        ),
        AppDimens.sm.height,
        Text(
          formatPrice(product.price),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppStyles.bodyRegular.copyWith(
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        AppDimens.md.height,
        _ratingSection(context),
        AppDimens.lg.height,
        Text(
          product.description,
          style: AppStyles.bodyRegular.copyWith(
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        AppDimens.lg.height,
        InkWell(
          onTap: () => context.push(Routes.getSellerProfile(product.seller.id)),
          borderRadius: BorderRadius.circular(AppDimens.imageRadius.r),
          child: Container(
            padding: EdgeInsets.all(AppDimens.md.r),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(AppDimens.imageRadius.r),
              border: Border.all(
                color: Theme.of(context).dividerColor,
                width: AppDimens.borderWidth.w,
              ),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimens.imageRadius.r),
                  child: Container(
                    width: AppDimens.sellerAvatar.w,
                    height: AppDimens.sellerAvatar.w,
                    color: Theme.of(context).dividerColor,
                    child: const AppSvgIcon(
                      assetPath: AppIcons.user,
                      size: AppDimens.iconMd,
                    ),
                  ),
                ),
                AppDimens.md.width,
                Expanded(
                  child: Text(
                    product.seller.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyles.bodySmall.copyWith(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
                AppDimens.sm.width,
                AppSvgIcon(
                  assetPath: AppIcons.profile,
                  size: AppDimens.iconMd,
                  color: Theme.of(context).iconTheme.color,
                ),
              ],
            ),
          ),
        ),
        AppDimens.lg.height,
        _commentsHeader(context),
        AppDimens.md.height,
        _commentsList(context),
      ],
    );
  }

  Widget _ratingSection(BuildContext context) {
    return Row(
      children: [
        BlocBuilder<ProductDetailsBloc, ProductDetailsState>(
          builder: (context, state) {
            final rating = state.rating;
            return Row(
              children: List.generate(5, (index) {
                final isActive = rating >= index + 1;
                return InkWell(
                  onTap: () => context
                      .read<ProductDetailsBloc>()
                      .add(ProductRatingUpdated(index + 1)),
                  child: Padding(
                    padding: EdgeInsets.only(right: AppDimens.xs.w),
                    child: AppSvgIcon(
                      assetPath: AppIcons.star,
                      size: AppDimens.iconSm,
                      color: isActive
                          ? Theme.of(context).primaryColor
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
        const Spacer(),
        InkWell(
          onTap: () => _openCommentInput(context),
          borderRadius: BorderRadius.circular(AppDimens.imageRadius.r),
          child: Padding(
            padding: EdgeInsets.all(AppDimens.sm.r),
            child: AppSvgIcon(
              assetPath: AppIcons.comment,
              size: AppDimens.iconMd,
              color: Theme.of(context).iconTheme.color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _commentsHeader(BuildContext context) {
    return Text(
      'Comments',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: AppStyles.h5Bold.copyWith(
        color: Theme.of(context).textTheme.titleMedium?.color,
      ),
    );
  }

  Widget _commentsList(BuildContext context) {
    return BlocBuilder<ProductCommentsBloc, ProductCommentsState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.comments.isEmpty) {
          return Text(
            'Izohlar yoq',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppStyles.bodySmall.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          );
        }
        return Column(
          children: state.comments.map((comment) {
            final isMine = comment.userId == _currentUserId;
            return Padding(
              padding: EdgeInsets.only(bottom: AppDimens.sm.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(AppDimens.circleRadius.r),
                    child: Container(
                      width: AppDimens.avatarSm.w,
                      height: AppDimens.avatarSm.w,
                      color: Theme.of(context).dividerColor,
                      child: AppSvgIcon(
                        assetPath: AppIcons.user,
                        size: AppDimens.iconSm,
                        color: Theme.of(context).iconTheme.color,
                      ),
                    ),
                  ),
                  AppDimens.sm.width,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          comment.userName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppStyles.bodySmall.copyWith(
                            color: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.color,
                          ),
                        ),
                        AppDimens.xs.height,
                        Text(
                          comment.content,
                          style: AppStyles.bodyRegular.copyWith(
                            color: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.color,
                          ),
                        ),
                        if (isMine) ...[
                          AppDimens.xs.height,
                          Row(
                            children: [
                              InkWell(
                                onTap: () => _openEditComment(context, comment),
                                child: Text(
                                  'Edit',
                                  style: AppStyles.bodySmall.copyWith(
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                              AppDimens.md.width,
                              InkWell(
                                onTap: () => context
                                    .read<ProductCommentsBloc>()
                                    .add(ProductCommentDeleted(comment.id)),
                                child: Text(
                                  'Delete',
                                  style: AppStyles.bodySmall.copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  void _openCommentInput(BuildContext context) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimens.cardRadius.r),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: AppDimens.lg.w,
            right: AppDimens.lg.w,
            bottom: MediaQuery.of(context).viewInsets.bottom + AppDimens.lg.h,
            top: AppDimens.lg.h,
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: 'Izoh yozing...',
                    hintStyle: AppStyles.bodyRegular.copyWith(
                      color: Theme.of(context).hintColor,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).scaffoldBackgroundColor,
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimens.imageRadius.r),
                      borderSide: BorderSide(
                        color: Theme.of(context).dividerColor,
                        width: AppDimens.borderWidth.w,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimens.imageRadius.r),
                      borderSide: BorderSide(
                        color: Theme.of(context).dividerColor,
                        width: AppDimens.borderWidth.w,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimens.imageRadius.r),
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: AppDimens.borderWidth.w,
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: AppDimens.sm.h,
                      horizontal: AppDimens.md.w,
                    ),
                  ),
                ),
              ),
              AppDimens.sm.width,
              InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                },
                borderRadius: BorderRadius.circular(AppDimens.imageRadius.r),
                child: Padding(
                  padding: EdgeInsets.all(AppDimens.sm.r),
                  child: AppSvgIcon(
                    assetPath: AppIcons.close,
                    size: AppDimens.iconMd,
                    color: Theme.of(context).iconTheme.color,
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  final text = controller.text.trim();
                  if (text.isEmpty) return;
                  final comment = ProductCommentEntity(
                    id: 'comment_${DateTime.now().millisecondsSinceEpoch}',
                    productId: widget.productId,
                    userId: _currentUserId,
                    userName: _currentUserName,
                    authorType: ProductCommentAuthor.user,
                    content: text,
                    createdAt: DateTime.now(),
                  );
                  context
                      .read<ProductCommentsBloc>()
                      .add(ProductCommentAdded(comment));
                  Navigator.of(context).pop();
                },
                borderRadius: BorderRadius.circular(AppDimens.imageRadius.r),
                child: Container(
                  padding: EdgeInsets.all(AppDimens.sm.r),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius:
                        BorderRadius.circular(AppDimens.imageRadius.r),
                  ),
                  child: const AppSvgIcon(
                    assetPath: AppIcons.send,
                    size: AppDimens.iconMd,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openEditComment(BuildContext context, ProductCommentEntity comment) {
    final controller = TextEditingController(text: comment.content);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimens.cardRadius.r),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: AppDimens.lg.w,
            right: AppDimens.lg.w,
            bottom: MediaQuery.of(context).viewInsets.bottom + AppDimens.lg.h,
            top: AppDimens.lg.h,
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: 'Izohni tahrirlash...',
                    hintStyle: AppStyles.bodyRegular.copyWith(
                      color: Theme.of(context).hintColor,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).scaffoldBackgroundColor,
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimens.imageRadius.r),
                      borderSide: BorderSide(
                        color: Theme.of(context).dividerColor,
                        width: AppDimens.borderWidth.w,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimens.imageRadius.r),
                      borderSide: BorderSide(
                        color: Theme.of(context).dividerColor,
                        width: AppDimens.borderWidth.w,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimens.imageRadius.r),
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: AppDimens.borderWidth.w,
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: AppDimens.sm.h,
                      horizontal: AppDimens.md.w,
                    ),
                  ),
                ),
              ),
              AppDimens.sm.width,
              InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                },
                borderRadius: BorderRadius.circular(AppDimens.imageRadius.r),
                child: Padding(
                  padding: EdgeInsets.all(AppDimens.sm.r),
                  child: AppSvgIcon(
                    assetPath: AppIcons.close,
                    size: AppDimens.iconMd,
                    color: Theme.of(context).iconTheme.color,
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  final text = controller.text.trim();
                  if (text.isEmpty) return;
                  context
                      .read<ProductCommentsBloc>()
                      .add(ProductCommentUpdated(comment.id, text));
                  Navigator.of(context).pop();
                },
                borderRadius: BorderRadius.circular(AppDimens.imageRadius.r),
                child: Container(
                  padding: EdgeInsets.all(AppDimens.sm.r),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius:
                        BorderRadius.circular(AppDimens.imageRadius.r),
                  ),
                  child: const AppSvgIcon(
                    assetPath: AppIcons.send,
                    size: AppDimens.iconMd,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
