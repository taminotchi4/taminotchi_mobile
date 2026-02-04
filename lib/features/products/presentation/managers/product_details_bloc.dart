import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'product_details_event.dart';
import 'product_details_state.dart';

class ProductDetailsBloc
    extends Bloc<ProductDetailsEvent, ProductDetailsState> {
  final Map<String, double> _ratings = {};
  final Random _random = Random();

  ProductDetailsBloc() : super(ProductDetailsState.initial()) {
    on<ProductDetailsStarted>(_onStarted);
    on<ProductRatingUpdated>(_onRatingUpdated);
  }

  void _onStarted(
    ProductDetailsStarted event,
    Emitter<ProductDetailsState> emit,
  ) {
    final rating = _ratings.putIfAbsent(
      event.productId,
      () => 3.5 + _random.nextDouble() * 1.5,
    );
    emit(state.copyWith(rating: rating));
  }

  void _onRatingUpdated(
    ProductRatingUpdated event,
    Emitter<ProductDetailsState> emit,
  ) {
    emit(state.copyWith(rating: event.rating));
  }
}
