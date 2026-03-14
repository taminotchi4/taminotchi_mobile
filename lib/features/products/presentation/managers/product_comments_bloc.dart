import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/add_product_comment_usecase.dart';
import '../../domain/usecases/delete_product_comment_usecase.dart';
import '../../domain/usecases/get_product_comments_usecase.dart';
import '../../domain/usecases/update_product_comment_usecase.dart';
import 'product_comments_event.dart';
import 'product_comments_state.dart';

class ProductCommentsBloc
    extends Bloc<ProductCommentsEvent, ProductCommentsState> {
  final GetProductCommentsUseCase getCommentsUseCase;
  final AddProductCommentUseCase addCommentUseCase;
  final UpdateProductCommentUseCase updateCommentUseCase;
  final DeleteProductCommentUseCase deleteCommentUseCase;

  ProductCommentsBloc({
    required this.getCommentsUseCase,
    required this.addCommentUseCase,
    required this.updateCommentUseCase,
    required this.deleteCommentUseCase,
  }) : super(ProductCommentsState.initial()) {
    on<ProductCommentsStarted>(_onStarted);
    on<ProductCommentAdded>(_onAdded);
    on<ProductCommentUpdated>(_onUpdated);
    on<ProductCommentDeleted>(_onDeleted);
  }

  Future<void> _onStarted(
    ProductCommentsStarted event,
    Emitter<ProductCommentsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    final result = await getCommentsUseCase(event.productId);
    result.fold(
      (_) => emit(state.copyWith(isLoading: false)),
      (comments) => emit(state.copyWith(
        isLoading: false,
        comments: comments,
      )),
    );
  }

  Future<void> _onAdded(
    ProductCommentAdded event,
    Emitter<ProductCommentsState> emit,
  ) async {
    final result = await addCommentUseCase(event.comment);
    result.fold(
      (_) {},
      (comment) => emit(state.copyWith(
        comments: [...state.comments, comment],
      )),
    );
  }

  Future<void> _onUpdated(
    ProductCommentUpdated event,
    Emitter<ProductCommentsState> emit,
  ) async {
    final result = await updateCommentUseCase(
      event.commentId,
      event.content,
    );
    result.fold(
      (_) {},
      (comment) {
        final updated = state.comments
            .map((item) => item.id == comment.id ? comment : item)
            .toList();
        emit(state.copyWith(comments: updated));
      },
    );
  }

  Future<void> _onDeleted(
    ProductCommentDeleted event,
    Emitter<ProductCommentsState> emit,
  ) async {
    final result = await deleteCommentUseCase(event.commentId);
    result.fold(
      (_) {},
      (_) {
        final updated = state.comments
            .where((item) => item.id != event.commentId)
            .toList();
        emit(state.copyWith(comments: updated));
      },
    );
  }
}
