import '../../../../core/utils/result.dart';
import '../entities/post_status.dart';
import '../repositories/home_repository.dart';

class UpdatePostStatusUseCase {
  final HomeRepository repository;

  const UpdatePostStatusUseCase(this.repository);

  Future<Result<void>> call({
    required String postId,
    required PostStatus status,
  }) async {
    return repository.updatePostStatus(
      postId: postId,
      status: status,
    );
  }
}
