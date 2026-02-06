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

  int? _selectedColor;
  String? _selectedSize;
  String? _sizeError;
  final Map<String, bool> _expandedComments = {};
  bool _isDescriptionExpanded = false;
  double _commentRating = 0.0;
  String? _ratingError;

  @override
  void initState() {
    super.initState();
    context.read<ProductsBloc>().add(ProductsLoadDetail(widget.productId));
    context.read<ProductDetailsBloc>().add(
      ProductDetailsStarted(widget.productId),
    );
    context.read<ProductCommentsBloc>().add(
      ProductCommentsStarted(widget.productId),
    );
  }

  String _formatCommentTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
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

          // Initial selection for color only
          if (_selectedColor == null && product.colors.isNotEmpty) {
            _selectedColor = product.colors.first;
          }

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.all(AppDimens.lg.r),
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(
                        AppDimens.cardRadius.r,
                      ),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: ProductImageSlider(images: product.imagePaths),
                      ),
                    ),
                    AppDimens.lg.height,
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppStyles.h4Bold.copyWith(
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                    AppDimens.sm.height,
                    _ratingSection(context),
                    AppDimens.md.height,
                    Row(
                      children: [
                        Text(
                          formatPrice(product.price),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppStyles.h2Bold.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontSize: 24.sp,
                          ),
                        ),
                      ],
                    ),

                    if (product.colors.isNotEmpty) ...[
                      AppDimens.lg.height,
                      Text(
                        'Ranglar',
                        style: AppStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                      AppDimens.sm.height,
                      Wrap(
                        spacing: 12.w,
                        children: product.colors.map((colorValue) {
                          final isSelected = _selectedColor == colorValue;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedColor = colorValue;
                              });
                            },
                            child: Container(
                              width: 32.w,
                              height: 32.w,
                              decoration: BoxDecoration(
                                color: Color(colorValue),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? Theme.of(context).primaryColor
                                      : Theme.of(context).dividerColor,
                                  width: isSelected ? 2.w : 1.w,
                                ),
                                boxShadow: [
                                  if (isSelected)
                                    BoxShadow(
                                      color: Color(
                                        colorValue,
                                      ).withValues(alpha: 0.4),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                ],
                              ),
                              child: isSelected
                                  ? Icon(
                                      Icons.check,
                                      size: 16.r,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                          );
                        }).toList(),
                      ),
                    ],

                    if (product.sizes.isNotEmpty) ...[
                      AppDimens.lg.height,
                      Text(
                        'O\'lchamlar',
                        style: AppStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                      AppDimens.sm.height,
                      Wrap(
                        spacing: 12.w,
                        children: product.sizes.map((size) {
                          final isSelected = _selectedSize == size;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedSize = size;
                                _sizeError = null; // Clear error when size is selected
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 8.h,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Theme.of(context).primaryColor
                                    : Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(
                                  color: isSelected
                                      ? Theme.of(context).primaryColor
                                      : Theme.of(context).dividerColor,
                                  width: 1.w,
                                ),
                              ),
                              child: Text(
                                size,
                                style: AppStyles.bodySmall.copyWith(
                                  color: isSelected
                                      ? Colors.white
                                      : Theme.of(
                                          context,
                                        ).textTheme.bodyMedium?.color,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      if (_sizeError != null) ...[
                        AppDimens.xs.height,
                        Text(
                          _sizeError!,
                          style: AppStyles.bodySmall.copyWith(
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ],

                    AppDimens.lg.height,
                    Text(
                      'Tavsif',
                      style: AppStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    AppDimens.xs.height,
                    _buildDescription(context, product.description),
                    AppDimens.lg.height,
                    _sellerSection(context, product),
                    AppDimens.lg.height,
                    _commentsHeader(context),
                    AppDimens.md.height,
                    _commentsList(context),
                    80.verticalSpace, // Spacing for bottom bar
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(AppDimens.lg.r),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).shadowColor.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (product!.sizes.isNotEmpty &&
                                _selectedSize == null) {
                              setState(() {
                                _sizeError = "Mos o'lchamni tanlang";
                              });
                            } else {
                              setState(() {
                                _sizeError = null;
                              });
                              // TODO: Implement add to cart logic with size and color
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppDimens.buttonRadius.r,
                              ),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.add_shopping_cart_rounded,
                                color: Colors.white,
                              ),
                              8.horizontalSpace,
                              Text(
                                'Savatga qo\'shish',
                                style: AppStyles.bodyMedium.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDescription(BuildContext context, String description) {
    final lines = description.split('\n');
    final hasMoreThan5Lines = lines.length > 5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          description,
          maxLines: 5,
          overflow: TextOverflow.ellipsis,
          style: AppStyles.bodyRegular.copyWith(
            color: Theme.of(context).textTheme.bodyMedium?.color,
            height: 1.5,
          ),
        ),
        if (hasMoreThan5Lines) ...[
          AppDimens.xs.height,
          InkWell(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => Container(
                  height: MediaQuery.of(context).size.height * 0.7,
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(AppDimens.cardRadius.r),
                    ),
                  ),
                  child: Column(
                    children: [
                      AppDimens.md.height,
                      Container(
                        width: 40.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: Theme.of(context).dividerColor,
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                      AppDimens.lg.height,
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDimens.lg.r,
                        ),
                        child: Text(
                          'Mahsulot haqida',
                          style: AppStyles.h4Bold.copyWith(
                            color: Theme.of(
                              context,
                            ).textTheme.titleLarge?.color,
                          ),
                        ),
                      ),
                      AppDimens.md.height,
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppDimens.lg.r,
                          ),
                          child: Text(
                            description,
                            style: AppStyles.bodyRegular.copyWith(
                              color: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.color,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ),
                      AppDimens.lg.height,
                    ],
                  ),
                ),
              );
            },
            child: Text(
              'Mahsulot haqida',
              style: AppStyles.bodySmall.copyWith(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _sellerSection(BuildContext context, ProductEntity product) {
    return InkWell(
      onTap: () => context.push(Routes.getSellerProfile(product.seller.id)),
      borderRadius: BorderRadius.circular(AppDimens.cardRadius.r),
      child: Container(
        padding: EdgeInsets.all(AppDimens.md.r),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppDimens.cardRadius.r),
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
                width: 50.w,
                height: 50.w,
                color: Theme.of(context).dividerColor,
                child: AppSvgIcon(
                  assetPath: product.seller.avatarPath,
                  size: 24.w,
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
                    product.seller.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  Text(
                    'Sotuvchi',
                    style: AppStyles.bodySmall.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Theme.of(context).iconTheme.color,
            ),
          ],
        ),
      ),
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
                  onTap: () => context.read<ProductDetailsBloc>().add(
                    ProductRatingUpdated(index + 1),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(right: AppDimens.xs.w),
                    child: Icon(
                      Icons.star_rounded,
                      size: AppDimens.iconSm,
                      color: isActive
                          ? const Color(0xFFFFB800)
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
      ],
    );
  }

  Widget _commentsHeader(BuildContext context) {
    return Row(
      children: [
        Text(
          'Comments',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppStyles.h5Bold.copyWith(
            color: Theme.of(context).textTheme.titleMedium?.color,
          ),
        ),
        const Spacer(),
        InkWell(
          onTap: () => _openCommentInput(context),
          borderRadius: BorderRadius.circular(AppDimens.imageRadius.r),
          child: Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.edit_note_rounded,
              size: AppDimens.iconMd,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCommentText(ProductCommentEntity comment) {
    final isExpanded = _expandedComments[comment.id] ?? false;
    final lines = comment.content.split('\n');
    final totalLines = lines.length;
    final hasMoreThan3Lines = totalLines > 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          comment.content,
          maxLines: isExpanded ? null : 3,
          overflow: isExpanded ? null : TextOverflow.ellipsis,
          style: AppStyles.bodyRegular.copyWith(
            color: Theme.of(context).textTheme.bodyMedium?.color,
            height: 1.4,
          ),
        ),
        if (hasMoreThan3Lines) ...[
          AppDimens.xxs.height,
          InkWell(
            onTap: () {
              setState(() {
                _expandedComments[comment.id] = !isExpanded;
              });
            },
            child: Text(
              isExpanded ? 'Show less' : '...more',
              style: AppStyles.bodySmall.copyWith(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
        AppDimens.xs.height,
        InkWell(
          onTap: () {
            // TODO: Implement reply to comment
            _openCommentInput(context, replyTo: comment);
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.reply_rounded,
                size: 16.r,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
              4.horizontalSpace,
              Text(
                'Reply',
                style: AppStyles.bodySmall.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
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
            return Container(
              margin: EdgeInsets.only(bottom: AppDimens.md.h),
              padding: EdgeInsets.all(AppDimens.md.r),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(AppDimens.cardRadius.r),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
                  width: 1.w,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                          AppDimens.circleRadius.r,
                        ),
                        child: Container(
                          width: AppDimens.avatarSm.w,
                          height: AppDimens.avatarSm.w,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).primaryColor,
                                Theme.of(context).primaryColor.withValues(alpha: 0.7),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            comment.userName.isNotEmpty 
                                ? comment.userName[0].toUpperCase()
                                : '?',
                            style: AppStyles.bodyMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      AppDimens.sm.width,
                      Expanded(
                        child: Text(
                          comment.userName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                      ),
                      Text(
                        _formatCommentTime(comment.createdAt),
                        style: AppStyles.bodySmall.copyWith(
                          fontSize: 10.sp,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                      if (isMine) ...[
                        4.horizontalSpace,
                        PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            Icons.more_vert_rounded,
                            size: 18.r,
                            color: Theme.of(context).iconTheme.color,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          onSelected: (value) {
                            if (value == 'edit') {
                              _openEditComment(context, comment);
                            } else if (value == 'delete') {
                              context.read<ProductCommentsBloc>().add(
                                ProductCommentDeleted(comment.id),
                              );
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.edit_outlined,
                                    size: 18.r,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  8.horizontalSpace,
                                  Text(
                                    'Edit',
                                    style: AppStyles.bodySmall.copyWith(
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete_outline_rounded,
                                    size: 18.r,
                                    color: Colors.red,
                                  ),
                                  8.horizontalSpace,
                                  Text(
                                    'Delete',
                                    style: AppStyles.bodySmall.copyWith(
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                  AppDimens.xs.height,
                  _buildCommentText(comment),
                  if (comment.rating > 0.0) ...[
                    AppDimens.xs.height,
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          final starValue = index + 1;
                          final isFilled = comment.rating >= starValue;
                          final isHalfFilled = comment.rating >= starValue - 0.5 && comment.rating < starValue;
                          
                          return Padding(
                            padding: EdgeInsets.only(right: 2.w),
                            child: Icon(
                              isHalfFilled ? Icons.star_half_rounded : Icons.star_rounded,
                              size: 16.r,
                              color: isFilled || isHalfFilled
                                  ? const Color(0xFFFFB800)
                                  : Theme.of(context).dividerColor,
                            ),
                          );
                        }),
                        4.horizontalSpace,
                        Text(
                          comment.rating.toStringAsFixed(1),
                          style: AppStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildRatingWidget(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onHorizontalDragUpdate: (details) {
                      final RenderBox box = context.findRenderObject() as RenderBox;
                      final localPosition = details.localPosition;
                      final width = box.size.width;
                      
                      double newRating = (localPosition.dx / width * 5.0).clamp(0.0, 5.0);
                      
                      // Round to nearest 0.1
                      newRating = (newRating * 10).round() / 10;
                      
                      // Auto jump to 1.0 if dragged from 0.0
                      if (_commentRating == 0.0 && newRating > 0.0 && newRating < 1.0) {
                        newRating = 1.0;
                      }
                      
                      setState(() {
                        _commentRating = newRating;
                        _ratingError = null;
                      });
                      this.setState(() {
                        _commentRating = newRating;
                        _ratingError = null;
                      });
                    },
                    onTapDown: (details) {
                      final RenderBox box = context.findRenderObject() as RenderBox;
                      final localPosition = details.localPosition;
                      final width = box.size.width;
                      
                      double newRating = (localPosition.dx / width * 5.0).clamp(0.0, 5.0);
                      newRating = (newRating * 10).round() / 10;
                      
                      if (_commentRating == 0.0 && newRating > 0.0 && newRating < 1.0) {
                        newRating = 1.0;
                      }
                      
                      setState(() {
                        _commentRating = newRating;
                        _ratingError = null;
                      });
                      this.setState(() {
                        _commentRating = newRating;
                        _ratingError = null;
                      });
                    },
                    child: Row(
                      children: List.generate(5, (index) {
                        final starValue = index + 1;
                        final isFilled = _commentRating >= starValue;
                        final isHalfFilled = _commentRating >= starValue - 0.5 && _commentRating < starValue;
                        
                        return Padding(
                          padding: EdgeInsets.only(right: 6.w),
                          child: Icon(
                            isHalfFilled ? Icons.star_half_rounded : Icons.star_rounded,
                            size: 40.r,
                            color: isFilled || isHalfFilled
                                ? const Color(0xFFFFB800)
                                : Theme.of(context).dividerColor,
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                8.horizontalSpace,
                Text(
                  _commentRating.toStringAsFixed(1),
                  style: AppStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleMedium?.color,
                  ),
                ),
              ],
            ),
            if (_ratingError != null) ...[
              AppDimens.xs.height,
              Text(
                _ratingError!,
                style: AppStyles.bodySmall.copyWith(
                  color: Colors.red,
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  void _openCommentInput(
    BuildContext context, {
    ProductCommentEntity? replyTo,
  }) {
    setState(() {
      _commentRating = 0.0;
      _ratingError = null;
    });
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (replyTo == null)
                    Expanded(
                      child: _buildRatingWidget(context),
                    )
                  else
                    const Spacer(),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    borderRadius: BorderRadius.circular(
                      AppDimens.imageRadius.r,
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(AppDimens.sm.r),
                      child: AppSvgIcon(
                        assetPath: AppIcons.close,
                        size: AppDimens.iconMd,
                        color: Theme.of(context).iconTheme.color,
                      ),
                    ),
                  ),
                ],
              ),
              if (replyTo == null) ...[
                AppDimens.xs.height,
                Text(
                  "Yulduzchalarni to'ldirish uchun chapdan o'ngga suring.",
                  style: AppStyles.bodySmall.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ],
              AppDimens.md.height,
              if (replyTo != null) ...[
                Container(
                  padding: EdgeInsets.all(AppDimens.sm.r),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.reply_rounded,
                        size: 16.r,
                        color: Theme.of(context).primaryColor,
                      ),
                      4.horizontalSpace,
                      Expanded(
                        child: Text(
                          'Replying to ${replyTo.userName}',
                          style: AppStyles.bodySmall.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                AppDimens.sm.height,
              ],
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      maxLines: 3,
                      minLines: 1,
                      style: AppStyles.bodyRegular.copyWith(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                      decoration: InputDecoration(
                        hintText: replyTo != null
                            ? 'Write a reply...'
                            : 'Izoh yozing...',
                        hintStyle: AppStyles.bodyRegular.copyWith(
                          color: Theme.of(context).hintColor,
                        ),
                        filled: true,
                        fillColor: Theme.of(context).scaffoldBackgroundColor,
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimens.imageRadius.r,
                          ),
                          borderSide: BorderSide(
                            color: Theme.of(context).dividerColor,
                            width: AppDimens.borderWidth.w,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimens.imageRadius.r,
                          ),
                          borderSide: BorderSide(
                            color: Theme.of(context).dividerColor,
                            width: AppDimens.borderWidth.w,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimens.imageRadius.r,
                          ),
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
                      final text = controller.text.trim();
                      if (text.isEmpty) return;

                      if (replyTo == null && _commentRating < 1.0) {
                        setState(() {
                          _ratingError = "Kamida 1 yulduzgacha ratingni tanlang";
                        });
                        return;
                      }

                      final commentContent = replyTo != null
                          ? '@${replyTo.userName}: $text'
                          : text;

                      final comment = ProductCommentEntity(
                        id: 'comment_${DateTime.now().millisecondsSinceEpoch}',
                        productId: widget.productId,
                        userId: _currentUserId,
                        userName: _currentUserName,
                        authorType: ProductCommentAuthor.user,
                        content: commentContent,
                        createdAt: DateTime.now(),
                        rating: _commentRating,
                      );
                      context.read<ProductCommentsBloc>().add(
                        ProductCommentAdded(comment),
                      );
                      setState(() {
                        _commentRating = 0.0;
                        _ratingError = null;
                      });
                      Navigator.of(context).pop();
                    },
                    borderRadius: BorderRadius.circular(
                      AppDimens.imageRadius.r,
                    ),
                    child: Container(
                      padding: EdgeInsets.all(AppDimens.sm.r),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(
                          AppDimens.imageRadius.r,
                        ),
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
                  style: AppStyles.bodyRegular.copyWith(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Izohni tahrirlash...',
                    hintStyle: AppStyles.bodyRegular.copyWith(
                      color: Theme.of(context).hintColor,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).scaffoldBackgroundColor,
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimens.imageRadius.r,
                      ),
                      borderSide: BorderSide(
                        color: Theme.of(context).dividerColor,
                        width: AppDimens.borderWidth.w,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimens.imageRadius.r,
                      ),
                      borderSide: BorderSide(
                        color: Theme.of(context).dividerColor,
                        width: AppDimens.borderWidth.w,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimens.imageRadius.r,
                      ),
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
                  context.read<ProductCommentsBloc>().add(
                    ProductCommentUpdated(comment.id, text),
                  );
                  Navigator.of(context).pop();
                },
                borderRadius: BorderRadius.circular(AppDimens.imageRadius.r),
                child: Container(
                  padding: EdgeInsets.all(AppDimens.sm.r),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(
                      AppDimens.imageRadius.r,
                    ),
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
