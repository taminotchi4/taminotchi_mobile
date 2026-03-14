import '../../../../core/utils/result.dart';
import '../entities/post_entity.dart';
import '../repositories/home_repository.dart';

class GetMyPostsUseCase {
  final HomeRepository repository;

  const GetMyPostsUseCase(this.repository);

  Future<Result<List<PostEntity>>> call({bool forceRefresh = false}) =>
      repository.getMyPosts(forceRefresh: forceRefresh);
}
