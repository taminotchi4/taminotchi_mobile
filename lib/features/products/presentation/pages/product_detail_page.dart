import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/dimens.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/styles.dart';

import '../../../../global/widgets/app_back_button.dart';
import '../../../../global/widgets/common_app_bar.dart';
import '../../../profile/domain/usecases/get_client_profile_usecase.dart';
import '../../data/repositories/product_comments_repository_impl.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_comments_repository.dart';
import '../managers/product_comments_bloc.dart';
import '../managers/product_comments_event.dart';
import '../managers/product_details_bloc.dart';
import '../managers/product_details_event.dart';
import '../managers/products_bloc.dart';
import '../managers/products_event.dart';
import '../managers/products_state.dart';
import '../widgets/product_attributes.dart';
import '../widgets/product_bottom_bar.dart';
import '../widgets/product_comments_section.dart';
import '../widgets/product_description_section.dart';
import '../widgets/product_image_slider.dart';
import '../widgets/product_info.dart';
import '../widgets/product_seller_info.dart';

class ProductDetailPage extends StatefulWidget {
  final String productId;

  const ProductDetailPage({super.key, required this.productId});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  String _currentUserId = '';
  String _currentUserName = 'Men';

  int? _selectedColor;
  String? _selectedSize;
  String? _sizeError;
  bool _commentIdCached = false;

  @override
  void initState() {
    super.initState();
    context.read<ProductsBloc>().add(ProductsLoadDetail(widget.productId));
    context.read<ProductDetailsBloc>().add(
          ProductDetailsStarted(widget.productId),
        );
    // Load current user profile
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final useCase = context.read<GetClientProfileUseCase>();
      final profile = await useCase();
      if (mounted) {
        setState(() {
          _currentUserId = profile.id;
          _currentUserName = profile.name.isNotEmpty ? profile.name : profile.username;
        });
      }
    } catch (_) {}
  }

  void _cacheCommentIdAndLoad(ProductEntity product) {
    if (_commentIdCached) return;
    final commentId = product.commentId;
    if (commentId != null && commentId.isNotEmpty) {
      final repo = context.read<ProductCommentsRepository>();
      if (repo is ProductCommentsRepositoryImpl) {
        repo.cacheCommentId(product.id, commentId);
      }
      _commentIdCached = true;
      context.read<ProductCommentsBloc>().add(
            ProductCommentsStarted(product.id),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: context.l10n.product,
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
                context.l10n.productsNotFound,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppStyles.bodySmall.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            );
          }

          // Cache commentId and trigger comments load
          _cacheCommentIdAndLoad(product);

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
                    ProductInfo(product: product),
                    ProductAttributes(
                      colors: product.colors,
                      sizes: product.sizes,
                      selectedColor: _selectedColor,
                      selectedSize: _selectedSize,
                      sizeError: _sizeError,
                      onColorSelected: (color) {
                        setState(() {
                          _selectedColor = color;
                        });
                      },
                      onSizeSelected: (size) {
                        setState(() {
                          _selectedSize = size;
                          _sizeError = null;
                        });
                      },
                    ),
                    ProductDescriptionSection(description: product.description),
                    ProductSellerInfo(product: product),
                    ProductCommentsSection(
                      productId: product.id,
                      currentUserId: _currentUserId,
                      currentUserName: _currentUserName,
                      commentId: product.commentId,
                      productName: product.name,
                    ),
                    80.verticalSpace, // Spacing for bottom bar
                  ],
                ),
              ),
              ProductBottomBar(
                onAddToCart: () {
                  if (product!.sizes.isNotEmpty && _selectedSize == null) {
                    setState(() {
                      _sizeError = context.l10n.selectSizeError;
                    });
                  } else {
                    setState(() {
                      _sizeError = null;
                    });
                    // TODO: Implement add to cart logic with size and color
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
