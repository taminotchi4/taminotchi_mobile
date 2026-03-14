import '../../../../core/utils/result.dart';
import '../entities/comment_entity.dart';
import '../repositories/home_repository.dart';

class GetCommentsUseCase {
  final HomeRepository repository;

  const GetCommentsUseCase(this.repository);

  Future<Result<List<CommentEntity>>> call(String postId) {
    return repository.getComments(postId);
  }
}
