import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/dimens.dart';
import '../../../../core/utils/styles.dart';

import '../../../../global/widgets/app_back_button.dart';
import '../../../../global/widgets/common_app_bar.dart';
import '../../domain/entities/product_entity.dart';
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
  final String _currentUserId = 'user_1';
  final String _currentUserName = 'Mening akkauntim';

  int? _selectedColor;
  String? _selectedSize;
  String? _sizeError;

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
                    ),
                    80.verticalSpace, // Spacing for bottom bar
                  ],
                ),
              ),
              ProductBottomBar(
                onAddToCart: () {
                  if (product!.sizes.isNotEmpty && _selectedSize == null) {
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
              ),
            ],
          );
        },
      ),
    );
  }
}
