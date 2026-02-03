import '../../../../core/utils/result.dart';
import '../entities/user_role.dart';
import '../repositories/home_repository.dart';

class GetCurrentUserRoleUseCase {
  final HomeRepository repository;

  const GetCurrentUserRoleUseCase(this.repository);

  Future<Result<UserRole>> call() => repository.getCurrentUserRole();
}
