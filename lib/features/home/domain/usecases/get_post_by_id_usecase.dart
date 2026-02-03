import '../../../../core/utils/result.dart';
import '../entities/post_entity.dart';
import '../repositories/home_repository.dart';

class GetPostByIdUseCase {
  final HomeRepository repository;

  const GetPostByIdUseCase(this.repository);

  Future<Result<PostEntity?>> call(String id) => repository.getPostById(id);
}
