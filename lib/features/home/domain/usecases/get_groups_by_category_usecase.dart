import '../../../../core/utils/result.dart';
import '../entities/group_entity.dart';
import '../repositories/home_repository.dart';

class GetGroupsByCategoryUseCase {
  final HomeRepository repository;

  const GetGroupsByCategoryUseCase(this.repository);

  Future<Result<List<GroupEntity>>> call(String categoryId,
          {bool forceRefresh = false}) =>
      repository.getGroupsByCategory(categoryId, forceRefresh: forceRefresh);
  }
