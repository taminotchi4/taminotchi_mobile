import '../../../../core/utils/result.dart';
import '../repositories/home_repository.dart';

class GetCommentCountsUseCase {
  final HomeRepository repository;

  const GetCommentCountsUseCase(this.repository);

  Future<Result<Map<String, int>>> call() => repository.getCommentCounts();
}
