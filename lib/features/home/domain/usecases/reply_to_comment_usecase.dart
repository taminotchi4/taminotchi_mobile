import '../../../../core/utils/result.dart';
import '../../domain/repositories/home_repository.dart';

class ReplyToCommentUseCase {
  final HomeRepository repository;

  ReplyToCommentUseCase(this.repository);

  Future<Result<void>> call({
    required String postId,
    required String parentCommentId,
    required String content,
  }) {
    return repository.replyToComment(
      postId: postId,
      parentCommentId: parentCommentId,
      content: content,
    );
  }
}
