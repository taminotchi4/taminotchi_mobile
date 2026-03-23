import '../../../../core/utils/result.dart';
import '../entities/post_entity.dart';
import '../repositories/home_repository.dart';

class GetPostsByGroupUseCase {
  final HomeRepository repository;

  GetPostsByGroupUseCase(this.repository);

  Future<Result<List<PostEntity>>> call(String groupId) {
    return repository.getPostsByGroup(groupId);
  }
}
