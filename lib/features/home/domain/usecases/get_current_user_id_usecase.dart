import '../../../../core/utils/result.dart';
import '../repositories/home_repository.dart';

class GetCurrentUserIdUseCase {
  final HomeRepository repository;

  const GetCurrentUserIdUseCase(this.repository);

  Future<Result<String>> call() => repository.getCurrentUserId();
}
