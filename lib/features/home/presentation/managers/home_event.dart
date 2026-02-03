import '../../domain/entities/post_category_entity.dart';

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

class HomeAddImagesFromGallery extends HomeEvent {
  const HomeAddImagesFromGallery();
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
