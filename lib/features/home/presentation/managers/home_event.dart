import '../../domain/entities/post_category_entity.dart';
import '../../domain/entities/post_status.dart';

sealed class HomeEvent {
  const HomeEvent();
}

class HomeStarted extends HomeEvent {
  const HomeStarted();
}

class HomeExpandComposer extends HomeEvent {
  const HomeExpandComposer();
}

class HomeCollapseComposer extends HomeEvent {
  const HomeCollapseComposer();
}

class HomeSelectCategory extends HomeEvent {
  final PostCategoryEntity category;

  const HomeSelectCategory(this.category);
}

class HomeSelectSubcategory extends HomeEvent {
  final PostCategoryEntity? subcategory;

  const HomeSelectSubcategory(this.subcategory);
}

class HomeAddImagesFromGallery extends HomeEvent {
  const HomeAddImagesFromGallery();
}

class HomeAddImageFromCamera extends HomeEvent {
  const HomeAddImageFromCamera();
}

class HomeAddImagesFromFiles extends HomeEvent {
  const HomeAddImagesFromFiles();
}

class HomeRemoveImage extends HomeEvent {
  final String path;

  const HomeRemoveImage(this.path);
}

class HomeCreatePost extends HomeEvent {
  final String content;

  const HomeCreatePost(this.content);
}

class HomeLoadPostDetails extends HomeEvent {
  final String postId;

  const HomeLoadPostDetails(this.postId);
}

class HomeClearActionStatus extends HomeEvent {
  const HomeClearActionStatus();
}

class HomeClearContentError extends HomeEvent {
  const HomeClearContentError();
}

class HomeReplyToComment extends HomeEvent {
  final String postId;
  final String parentCommentId;
  final String content;

  const HomeReplyToComment({
    required this.postId,
    required this.parentCommentId,
    required this.content,
  });
}

class HomeUpdatePostStatus extends HomeEvent {
  final String postId;
  final PostStatus status;

  const HomeUpdatePostStatus({
    required this.postId,
    required this.status,
  });
}
