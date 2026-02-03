import '../../../../core/utils/result.dart';
import '../entities/post_entity.dart';
import '../repositories/home_repository.dart';

class GetAllPostsUseCase {
  final HomeRepository repository;

  const GetAllPostsUseCase(this.repository);

  Future<Result<List<PostEntity>>> call() => repository.getAllPosts();
}
