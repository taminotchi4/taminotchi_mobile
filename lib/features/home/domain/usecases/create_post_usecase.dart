import '../../../../core/utils/result.dart';
import '../entities/post_category_entity.dart';
import '../entities/post_image_entity.dart';
import '../entities/post_entity.dart';
import '../repositories/home_repository.dart';

class CreatePostUseCase {
  final HomeRepository repository;

  const CreatePostUseCase(this.repository);

  Future<Result<PostEntity>> call({
    required String content,
    required List<PostImageEntity> images,
    required PostCategoryEntity category,
  }) {
    return repository.createPost(
      content: content,
      images: images,
      category: category,
    );
  }
}
